package com.agribridgef1.controller;

import com.agribridgef1.dao.ProductDAO;
import com.agribridgef1.model.Product;
import com.agribridgef1.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Map;

@WebServlet({"/checkout"})
public class CheckoutServlet extends HttpServlet {

    public CheckoutServlet() {
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Map<Integer, Integer> cart = (Map<Integer, Integer>) session.getAttribute("cart");

        if (cart == null || cart.isEmpty()) {
            response.sendRedirect("cart.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        String deliveryZone = request.getParameter("deliveryZone");
        String phone = request.getParameter("phone");
        String deliveryAddress = request.getParameter("deliveryAddress");
        String notes = request.getParameter("notes");

        if ("Campus pickup".equals(deliveryZone)) {
            deliveryAddress = "Campus pickup";
        }

        if (notes == null) {
            notes = "";
        }

        if (deliveryAddress == null || deliveryAddress.trim().isEmpty()) {
            deliveryAddress = "Not provided";
        }

        double deliveryFee = 0;

        try {
            deliveryFee = Double.parseDouble(request.getParameter("deliveryFee"));
        } catch (Exception e) {
            deliveryFee = 0;
        }

        ProductDAO productDAO = new ProductDAO();
        double subtotal = 0;

        for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
            Product product = productDAO.getProductById(entry.getKey());

            if (product != null) {
                int quantity = entry.getValue();
                subtotal += product.getPrice() * quantity;
            }
        }

        double totalAmount = subtotal + deliveryFee;

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int orderId;

            String orderSql =
                "INSERT INTO orders " +
                "(user_id, total_amount, order_status, delivery_zone, delivery_fee, phone, delivery_address, notes) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

            try (PreparedStatement orderPs = conn.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS)) {
                orderPs.setInt(1, userId);
                orderPs.setDouble(2, totalAmount);
                orderPs.setString(3, "PENDING");
                orderPs.setString(4, deliveryZone);
                orderPs.setDouble(5, deliveryFee);
                orderPs.setString(6, phone);
                orderPs.setString(7, deliveryAddress);
                orderPs.setString(8, notes);

                orderPs.executeUpdate();

                try (ResultSet rs = orderPs.getGeneratedKeys()) {
                    if (!rs.next()) {
                        throw new SQLException("Failed to create order.");
                    }

                    orderId = rs.getInt(1);
                }
            }

            String itemSql =
                "INSERT INTO order_items " +
                "(order_id, product_id, quantity, price) " +
                "VALUES (?, ?, ?, ?)";

            try (PreparedStatement itemPs = conn.prepareStatement(itemSql)) {
                for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
                    int productId = entry.getKey();
                    int quantity = entry.getValue();

                    Product product = productDAO.getProductById(productId);

                    if (product != null) {
                        itemPs.setInt(1, orderId);
                        itemPs.setInt(2, productId);
                        itemPs.setInt(3, quantity);
                        itemPs.setDouble(4, product.getPrice());
                        itemPs.addBatch();
                    }
                }

                itemPs.executeBatch();
            }

            conn.commit();

            cart.clear();
            response.sendRedirect("orderConfirmation.jsp?orderId=" + orderId);

        } catch (Exception e) {
            e.printStackTrace();

            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackError) {
                    rollbackError.printStackTrace();
                }
            }

            response.sendRedirect("checkout.jsp?error=1");

        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException closeError) {
                    closeError.printStackTrace();
                }
            }
        }
    }
}
