package com.agribridgef1.dao;

import com.agribridgef1.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class PaymentDAO {

    public PaymentDAO() {
    }

    public boolean savePayment(int orderId, double amount, String method, String code, String status) {
        String sql = "INSERT INTO payments (order_id, amount, payment_method, transaction_code, payment_status) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ps.setDouble(2, amount);
            ps.setString(3, method);
            ps.setString(4, code);
            ps.setString(5, status);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean savePendingMpesaPayment(int orderId, double amount, String checkoutRequestId) {
        String sql =
            "INSERT INTO payments " +
            "(order_id, amount, payment_method, transaction_code, payment_status, checkout_request_id) " +
            "VALUES (?, ?, 'MPESA', NULL, 'PENDING', ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ps.setDouble(2, amount);
            ps.setString(3, checkoutRequestId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateMpesaPaymentStatus(String checkoutRequestId, String transactionCode, String paymentStatus) {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int paymentId;
            int orderId;
            String oldStatus;

            String findSql =
                "SELECT payment_id, order_id, payment_status " +
                "FROM payments WHERE checkout_request_id = ? FOR UPDATE";

            try (PreparedStatement findPs = conn.prepareStatement(findSql)) {
                findPs.setString(1, checkoutRequestId);

                try (ResultSet rs = findPs.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }

                    paymentId = rs.getInt("payment_id");
                    orderId = rs.getInt("order_id");
                    oldStatus = rs.getString("payment_status");
                }
            }

            if (oldStatus == null || oldStatus.trim().isEmpty()) {
                oldStatus = "PENDING";
            }

            boolean alreadyPaid = "PAID".equalsIgnoreCase(oldStatus) || "COMPLETED".equalsIgnoreCase(oldStatus);

            String updatePaymentSql =
                "UPDATE payments " +
                "SET transaction_code = ?, payment_status = ? " +
                "WHERE payment_id = ?";

            try (PreparedStatement updatePaymentPs = conn.prepareStatement(updatePaymentSql)) {
                updatePaymentPs.setString(1, transactionCode);
                updatePaymentPs.setString(2, paymentStatus);
                updatePaymentPs.setInt(3, paymentId);
                updatePaymentPs.executeUpdate();
            }

            if (("PAID".equalsIgnoreCase(paymentStatus) || "COMPLETED".equalsIgnoreCase(paymentStatus)) && !alreadyPaid) {
                boolean enoughStock = checkStockAvailability(conn, orderId);

                if (!enoughStock) {
                    conn.rollback();
                    System.out.println("Payment successful but insufficient stock for order #" + orderId);
                    return false;
                }

                reduceProductStock(conn, orderId);
                confirmOrder(conn, orderId);
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();

            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception rollbackError) {
                    rollbackError.printStackTrace();
                }
            }

            return false;

        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception closeError) {
                    closeError.printStackTrace();
                }
            }
        }
    }

    private boolean checkStockAvailability(Connection conn, int orderId) throws SQLException {
        String sql =
            "SELECT oi.product_id, oi.quantity, p.stock_quantity " +
            "FROM order_items oi " +
            "JOIN products p ON oi.product_id = p.product_id " +
            "WHERE oi.order_id = ? FOR UPDATE";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int orderedQuantity = rs.getInt("quantity");
                    int currentStock = rs.getInt("stock_quantity");

                    if (currentStock < orderedQuantity) {
                        return false;
                    }
                }
            }
        }

        return true;
    }

    private void reduceProductStock(Connection conn, int orderId) throws SQLException {
        String sql =
            "UPDATE products p " +
            "JOIN order_items oi ON p.product_id = oi.product_id " +
            "SET p.stock_quantity = p.stock_quantity - oi.quantity " +
            "WHERE oi.order_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.executeUpdate();
        }
    }

    private void confirmOrder(Connection conn, int orderId) throws SQLException {
        String sql =
            "UPDATE orders " +
            "SET order_status = 'CONFIRMED' " +
            "WHERE order_id = ? AND order_status NOT IN ('DELIVERED', 'CANCELLED')";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.executeUpdate();
        }
    }

    public int getOrderIdByCheckoutRequestId(String checkoutRequestId) {
        String sql = "SELECT order_id FROM payments WHERE checkout_request_id = ? LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, checkoutRequestId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("order_id");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public String getPaymentStatusByOrderId(int orderId) {
        String sql =
            "SELECT payment_status " +
            "FROM payments " +
            "WHERE order_id = ? " +
            "ORDER BY payment_date DESC LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String status = rs.getString("payment_status");
                    return status != null ? status : "PENDING";
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return "PENDING";
    }

    public String getPaymentMethodByOrderId(int orderId) {
        String sql =
            "SELECT payment_method " +
            "FROM payments " +
            "WHERE order_id = ? " +
            "ORDER BY payment_date DESC LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String method = rs.getString("payment_method");
                    return method != null ? method : "N/A";
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return "N/A";
    }

    public String getTransactionCodeByOrderId(int orderId) {
        String sql =
            "SELECT transaction_code " +
            "FROM payments " +
            "WHERE order_id = ? " +
            "ORDER BY payment_date DESC LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String code = rs.getString("transaction_code");
                    return code != null ? code : "N/A";
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return "N/A";
    }
}