<%@ page import="java.sql.*, com.agribridgef1.util.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String userType = (String) session.getAttribute("userType");

    if (session.getAttribute("userId") == null ||
        (!"ADMIN".equals(userType) && !"STAFF".equals(userType))) {
        response.sendRedirect("login.jsp");
        return;
    }

    String search = request.getParameter("search");
    String orderStatusFilter = request.getParameter("orderStatus");
    String paymentStatusFilter = request.getParameter("paymentStatus");

    boolean hasSearch = search != null && !search.trim().isEmpty();
    boolean hasOrderStatusFilter = orderStatusFilter != null && !orderStatusFilter.trim().isEmpty();
    boolean hasPaymentStatusFilter = paymentStatusFilter != null && !paymentStatusFilter.trim().isEmpty();

    boolean searchIsNumber = false;
    int searchNumber = 0;

    if (hasSearch) {
        try {
            searchNumber = Integer.parseInt(search.trim());
            searchIsNumber = true;
        } catch (Exception e) {
            searchIsNumber = false;
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Orders - Egerton AgriBridge Hub</title>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
</head>

<body class="estate-dashboard-body">

<div class="estate-layout">

    <!-- SIDEBAR -->
    <aside class="estate-sidebar">
        <div class="estate-brand">
            <h2>AgriBridge</h2>
            <p>Modern Pastoral Management</p>
        </div>

        <nav class="estate-menu">
            <a href="adminDashboard.jsp">
                <span>▦</span>
                Dashboard
            </a>

            <a href="manageProducts.jsp">
                <span>▣</span>
                Manage Products
            </a>

            <a href="addProduct.jsp">
                <span>＋</span>
                Add Product
            </a>

            <a href="manageOrders.jsp" class="active">
                <span>▤</span>
                Manage Orders
            </a>

            <a href="salesReport.jsp">
                <span>▥</span>
                Sales Reports
            </a>

            <a href="products.jsp">
                <span>🛒</span>
                Marketplace
            </a>
        </nav>

        <div class="estate-sidebar-bottom">
            <a class="estate-add-btn" href="addProduct.jsp">
                ＋ Add New Product
            </a>

            <a href="logout" class="estate-logout">
                ⎋ Logout
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="estate-main">

        <!-- TOP BAR -->
        <header class="estate-topbar">
            <div>
                <h1>Orders Management</h1>
                <p>Review customer orders, payment status, delivery details, and assigned agents.</p>
            </div>

            <div class="estate-top-actions">
                <form action="manageOrders.jsp" method="get" class="estate-search">
                    <span>⌕</span>
                    <input type="text" name="search" placeholder="Search order/customer ID..."
                           value="<%= hasSearch ? search : "" %>">
                </form>

                <a href="manageOrders.jsp" class="estate-icon-btn">🔔</a>
                <a href="adminDashboard.jsp" class="estate-profile">👨‍💼</a>
            </div>
        </header>

        <div class="admin-orders-page estate-inner-page">

            <div class="admin-orders-header">
                <div>
                    <p class="eyebrow">STAFF ORDER CONTROL</p>
                    <h1>Manage Orders</h1>
                    <p>Search, filter, update order status, and assign delivery agents.</p>
                </div>

                <a class="btn" href="products.jsp">View Marketplace</a>
            </div>

            <%
                if ("updated".equals(request.getParameter("status"))) {
            %>
                <div class="review-success">Order status updated successfully.</div>
            <%
                } else if ("assigned".equals(request.getParameter("status"))) {
            %>
                <div class="review-success">Delivery agent assigned successfully.</div>
            <%
                } else if ("error".equals(request.getParameter("status"))) {
            %>
                <div class="review-error">Something went wrong. Please try again.</div>
            <%
                }
            %>

            <!-- SEARCH AND FILTER BAR -->
            <div class="admin-order-search-card premium-filter-card">
                <form method="get" action="manageOrders.jsp" class="admin-order-search-form">

                    <div>
                        <label>Search Order / Customer</label>
                        <input type="text"
                               name="search"
                               placeholder="Example: 12"
                               value="<%= hasSearch ? search : "" %>">
                    </div>

                    <div>
                        <label>Order Status</label>
                        <select name="orderStatus">
                            <option value="">All Order Statuses</option>
                            <option value="PENDING" <%= "PENDING".equals(orderStatusFilter) ? "selected" : "" %>>PENDING</option>
                            <option value="CONFIRMED" <%= "CONFIRMED".equals(orderStatusFilter) ? "selected" : "" %>>CONFIRMED</option>
                            <option value="PROCESSING" <%= "PROCESSING".equals(orderStatusFilter) ? "selected" : "" %>>PROCESSING</option>
                            <option value="OUT_FOR_DELIVERY" <%= "OUT_FOR_DELIVERY".equals(orderStatusFilter) ? "selected" : "" %>>OUT FOR DELIVERY</option>
                            <option value="DELIVERED" <%= "DELIVERED".equals(orderStatusFilter) ? "selected" : "" %>>DELIVERED</option>
                            <option value="CANCELLED" <%= "CANCELLED".equals(orderStatusFilter) ? "selected" : "" %>>CANCELLED</option>
                        </select>
                    </div>

                    <div>
                        <label>Payment Status</label>
                        <select name="paymentStatus">
                            <option value="">All Payment Statuses</option>
                            <option value="PENDING" <%= "PENDING".equals(paymentStatusFilter) ? "selected" : "" %>>PENDING</option>
                            <option value="PAID" <%= "PAID".equals(paymentStatusFilter) ? "selected" : "" %>>PAID</option>
                            <option value="FAILED" <%= "FAILED".equals(paymentStatusFilter) ? "selected" : "" %>>FAILED</option>
                            <option value="COMPLETED" <%= "COMPLETED".equals(paymentStatusFilter) ? "selected" : "" %>>COMPLETED</option>
                        </select>
                    </div>

                    <div class="admin-order-search-actions">
                        <button class="btn" type="submit">Search</button>
                        <a class="btn btn-secondary" href="manageOrders.jsp">Clear</a>
                    </div>

                </form>
            </div>

            <div class="admin-orders-card">

                <%
                    Connection conn = null;
                    PreparedStatement ps = null;
                    ResultSet rs = null;

                    boolean hasOrders = false;
                    int resultCount = 0;

                    try {
                        conn = DBConnection.getConnection();

                        String sql =
                            "SELECT o.*, " +
                            "(SELECT p.payment_status FROM payments p " +
                            " WHERE p.order_id = o.order_id " +
                            " ORDER BY p.payment_id DESC LIMIT 1) AS latest_payment_status " +
                            "FROM orders o " +
                            "WHERE 1=1 ";

                        if (hasSearch && searchIsNumber) {
                            sql += "AND (o.order_id = ? OR o.user_id = ?) ";
                        } else if (hasSearch && !searchIsNumber) {
                            sql += "AND 1=0 ";
                        }

                        if (hasOrderStatusFilter) {
                            sql += "AND o.order_status = ? ";
                        }

                        if (hasPaymentStatusFilter) {
                            sql += "AND COALESCE((SELECT p.payment_status FROM payments p " +
                                   "WHERE p.order_id = o.order_id ORDER BY p.payment_id DESC LIMIT 1), 'PENDING') = ? ";
                        }

                        sql += "ORDER BY o.order_id DESC";

                        ps = conn.prepareStatement(sql);

                        int paramIndex = 1;

                        if (hasSearch && searchIsNumber) {
                            ps.setInt(paramIndex++, searchNumber);
                            ps.setInt(paramIndex++, searchNumber);
                        }

                        if (hasOrderStatusFilter) {
                            ps.setString(paramIndex++, orderStatusFilter);
                        }

                        if (hasPaymentStatusFilter) {
                            ps.setString(paramIndex++, paymentStatusFilter);
                        }

                        rs = ps.executeQuery();

                        while (rs.next()) {
                            hasOrders = true;
                            resultCount++;

                            int orderId = rs.getInt("order_id");
                            int customerId = rs.getInt("user_id");

                            double totalAmount = 0;
                            double deliveryFee = 0;

                            String orderStatus = "PENDING";
                            String deliveryStatus = "PENDING";
                            String deliveryZone = "Not selected";
                            String deliveryAddress = "Not provided";
                            String phone = "Not provided";
                            String notes = "";
                            String orderDate = "Date unavailable";

                            try { totalAmount = rs.getDouble("total_amount"); } catch (Exception e) {}
                            try { orderStatus = rs.getString("order_status"); } catch (Exception e) {}
                            try { deliveryStatus = rs.getString("delivery_status"); } catch (Exception e) {}
                            try { deliveryZone = rs.getString("delivery_zone"); } catch (Exception e) {}
                            try { deliveryFee = rs.getDouble("delivery_fee"); } catch (Exception e) {}
                            try { deliveryAddress = rs.getString("delivery_address"); } catch (Exception e) {}
                            try { phone = rs.getString("phone"); } catch (Exception e) {}
                            try { notes = rs.getString("notes"); } catch (Exception e) {}

                            try { orderDate = rs.getString("created_at"); } catch (Exception e) {}

                            if (orderDate == null || orderDate.trim().isEmpty()) {
                                try { orderDate = rs.getString("order_date"); } catch (Exception e) {}
                            }

                            if (orderStatus == null || orderStatus.trim().isEmpty()) {
                                orderStatus = "PENDING";
                            }

                            if (deliveryStatus == null || deliveryStatus.trim().isEmpty()) {
                                deliveryStatus = "PENDING";
                            }

                            if (deliveryZone == null || deliveryZone.trim().isEmpty()) {
                                deliveryZone = "Not selected";
                            }

                            if (deliveryAddress == null || deliveryAddress.trim().isEmpty()) {
                                deliveryAddress = "Not provided";
                            }

                            if (phone == null || phone.trim().isEmpty()) {
                                phone = "Not provided";
                            }

                            String paymentStatus = "PENDING";

                            try {
                                paymentStatus = rs.getString("latest_payment_status");
                            } catch (Exception e) {
                                paymentStatus = "PENDING";
                            }

                            if (paymentStatus == null || paymentStatus.trim().isEmpty()) {
                                paymentStatus = "PENDING";
                            }

                            String paymentClass = paymentStatus.toLowerCase();
                            String orderStatusClass = orderStatus.toLowerCase();
                %>

                    <% if (resultCount == 1 && (hasSearch || hasOrderStatusFilter || hasPaymentStatusFilter)) { %>
                        <div class="admin-order-result-count">
                            Showing filtered results
                        </div>
                    <% } %>

                    <div class="admin-order-card premium-order-card">

                        <div class="admin-order-top">
                            <div>
                                <p class="delivery-eyebrow">ORDER RECORD</p>
                                <h2>Order #<%= orderId %></h2>
                                <p>Customer ID: <strong><%= customerId %></strong></p>
                                <p>Placed: <%= orderDate != null ? orderDate : "Date unavailable" %></p>
                            </div>

                            <div class="admin-order-total">
                                <span>Total</span>
                                <strong>KES <%= String.format("%.2f", totalAmount) %></strong>
                            </div>
                        </div>

                        <div class="admin-order-grid">

                            <div class="admin-order-info">
                                <span>Payment Status</span>
                                <strong class="status-pill <%= paymentClass %>">
                                    <%= paymentStatus %>
                                </strong>
                            </div>

                            <div class="admin-order-info">
                                <span>Order Status</span>
                                <strong class="estate-status <%= orderStatusClass %>">
                                    <%= orderStatus.replace("_", " ") %>
                                </strong>
                            </div>

                            <div class="admin-order-info">
                                <span>Delivery Status</span>
                                <strong><%= deliveryStatus.replace("_", " ") %></strong>
                            </div>

                            <div class="admin-order-info">
                                <span>Delivery Fee</span>
                                <strong>KES <%= String.format("%.2f", deliveryFee) %></strong>
                            </div>

                        </div>

                        <details class="premium-order-details">
                            <summary>View fulfilment details</summary>

                            <div class="admin-delivery-box premium-fulfilment-box">
                                <h3>Fulfilment Details</h3>

                                <p><strong>Zone:</strong> <%= deliveryZone %></p>
                                <p><strong>Phone:</strong> <%= phone %></p>
                                <p><strong>Address / Pickup:</strong> <%= deliveryAddress %></p>

                                <% if (notes != null && !notes.trim().isEmpty()) { %>
                                    <p><strong>Notes:</strong> <%= notes %></p>
                                <% } %>
                            </div>
                        </details>

                        <div class="admin-order-actions">

                            <form action="updateOrderStatus" method="post" class="admin-order-form">
                                <input type="hidden" name="orderId" value="<%= orderId %>">

                                <label>Update Order Status</label>
                                <select name="status" required>
                                    <option value="PENDING" <%= "PENDING".equals(orderStatus) ? "selected" : "" %>>PENDING</option>
                                    <option value="CONFIRMED" <%= "CONFIRMED".equals(orderStatus) ? "selected" : "" %>>CONFIRMED</option>
                                    <option value="PROCESSING" <%= "PROCESSING".equals(orderStatus) ? "selected" : "" %>>PROCESSING</option>
                                    <option value="OUT_FOR_DELIVERY" <%= "OUT_FOR_DELIVERY".equals(orderStatus) ? "selected" : "" %>>OUT FOR DELIVERY</option>
                                    <option value="DELIVERED" <%= "DELIVERED".equals(orderStatus) ? "selected" : "" %>>DELIVERED</option>
                                    <option value="CANCELLED" <%= "CANCELLED".equals(orderStatus) ? "selected" : "" %>>CANCELLED</option>
                                </select>

                                <button class="btn" type="submit">Update</button>
                            </form>

                            <form action="assignDelivery" method="post" class="admin-order-form">
                                <input type="hidden" name="orderId" value="<%= orderId %>">

                                <label>Assign Delivery Agent</label>
                                <input type="number" name="agentId" placeholder="Enter Agent ID" required>

                                <button class="btn btn-secondary" type="submit">Assign</button>
                            </form>

                            <div class="admin-order-view">
                                <label>Customer View</label>
                                <a class="btn" href="orderDetails.jsp?orderId=<%= orderId %>">
                                    View Details
                                </a>
                            </div>

                        </div>

                    </div>

                <%
                        }

                    } catch (Exception e) {
                        e.printStackTrace();
                %>

                    <div class="review-error">
                        Could not load orders. Please confirm your orders/payments table column names.
                    </div>

                <%
                    } finally {
                        if (rs != null) try { rs.close(); } catch (Exception e) {}
                        if (ps != null) try { ps.close(); } catch (Exception e) {}
                        if (conn != null) try { conn.close(); } catch (Exception e) {}
                    }

                    if (!hasOrders) {
                %>

                    <div class="cart-empty-state">
                        <div class="cart-empty-icon">🔍</div>
                        <h2>No matching orders</h2>
                        <p>No orders match your current search or filter selection.</p>
                        <a href="manageOrders.jsp">Clear Filters</a>
                    </div>

                <%
                    }
                %>

            </div>

        </div>

    </main>

</div>

</body>
</html>