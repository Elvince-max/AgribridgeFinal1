<%@ page import="java.sql.*, java.util.*, com.agribridgef1.util.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userType = (String) session.getAttribute("userType");

    if (userType == null) {
        userType = "";
    }

    userType = userType.trim().toUpperCase();

    boolean isCustomer = "CUSTOMER".equals(userType);

    if (!isCustomer) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = (int) session.getAttribute("userId");

    String orderIdParam = request.getParameter("orderId");

    if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
        response.sendRedirect("myOrders.jsp");
        return;
    }

    int orderId = Integer.parseInt(orderIdParam);

    String orderStatus = "PENDING";
    String deliveryZone = "Not specified";
    String deliveryAddress = "Not provided";
    String phone = "Not provided";
    String notes = "";
    String paymentStatus = "PENDING";
    double totalAmount = 0;
    double deliveryFee = 0;

    boolean orderFound = false;

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();

        String sql = "SELECT * FROM orders WHERE order_id = ? AND user_id = ?";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, orderId);
        ps.setInt(2, userId);

        rs = ps.executeQuery();

        if (rs.next()) {
            orderFound = true;

            try { orderStatus = rs.getString("order_status"); } catch (Exception e) {}
            try { totalAmount = rs.getDouble("total_amount"); } catch (Exception e) {}
            try { deliveryZone = rs.getString("delivery_zone"); } catch (Exception e) {}
            try { deliveryFee = rs.getDouble("delivery_fee"); } catch (Exception e) {}
            try { phone = rs.getString("phone"); } catch (Exception e) {}
            try { deliveryAddress = rs.getString("delivery_address"); } catch (Exception e) {}
            try { notes = rs.getString("notes"); } catch (Exception e) {}
        }

        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}

        try {
            String paymentSql =
                "SELECT payment_status FROM payments " +
                "WHERE order_id = ? " +
                "ORDER BY payment_id DESC LIMIT 1";

            ps = conn.prepareStatement(paymentSql);
            ps.setInt(1, orderId);

            rs = ps.executeQuery();

            if (rs.next()) {
                paymentStatus = rs.getString("payment_status");
            }

        } catch (Exception e) {
            paymentStatus = "PENDING";
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }

    if (!orderFound) {
        response.sendRedirect("myOrders.jsp");
        return;
    }

    if (orderStatus == null || orderStatus.trim().isEmpty()) {
        orderStatus = "PENDING";
    }

    if (paymentStatus == null || paymentStatus.trim().isEmpty()) {
        paymentStatus = "PENDING";
    }

    if (deliveryZone == null || deliveryZone.trim().isEmpty()) {
        deliveryZone = "Not specified";
    }

    if (deliveryAddress == null || deliveryAddress.trim().isEmpty()) {
        deliveryAddress = "Not provided";
    }

    if (phone == null || phone.trim().isEmpty()) {
        phone = "Not provided";
    }

    String orderClass = orderStatus.toLowerCase().replace(" ", "-");
    String paymentClass = paymentStatus.toLowerCase().replace(" ", "-");

    boolean unpaid =
            !"PAID".equalsIgnoreCase(paymentStatus) &&
            !"COMPLETED".equalsIgnoreCase(paymentStatus);
%>

<!DOCTYPE html>
<html>
<head>
    <title>Order Confirmation - Egerton AgriBridge Hub</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- CSS order matters -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/base.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/components.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/order-confirmation.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/responsive.css?v=1">
</head>

<body class="confirmation-body">

<div class="confirmation-shell">

    <!-- SIDEBAR -->
    <aside class="confirmation-sidebar">
        <div class="confirmation-brand">
            <div class="confirmation-brand-mark">🌿</div>
            <div>
                <h2>AgriBridge</h2>
                <p>Customer Portal</p>
            </div>
        </div>

        <nav class="confirmation-menu">
            <a href="customerDashboard.jsp">
                <span>▦</span>
                Dashboard
            </a>

            <a href="products.jsp">
                <span>🛒</span>
                Marketplace
            </a>

            <a href="cart.jsp">
                <span>🧺</span>
                Cart
            </a>

            <a href="myOrders.jsp" class="active">
                <span>▤</span>
                My Orders
            </a>

            <a href="profile.jsp">
                <span>👤</span>
                Profile
            </a>
        </nav>

        <div class="confirmation-sidebar-promo">
            <h3>Order Created</h3>
            <p>Your order is saved. Complete payment to speed up processing.</p>
            <a href="payment.jsp?orderId=<%= orderId %>">Pay Now</a>
        </div>

        <div class="confirmation-sidebar-bottom">
            <a href="logout" onclick="return confirm('Are you sure you want to logout?');">
                ⎋ Logout
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="confirmation-main">

        <!-- MOBILE TOP BAR -->
        <header class="confirmation-mobile-topbar">
            <a href="myOrders.jsp" aria-label="My orders">←</a>
            <strong>Confirmed</strong>
            <div>
                <a href="products.jsp" aria-label="Shop">🛒</a>
                <a href="profile.jsp" aria-label="Profile">👤</a>
            </div>
        </header>

        <!-- DESKTOP TOP BAR -->
        <header class="confirmation-topbar">
            <div>
                <h1>Order Confirmation</h1>
                <p>Your order <strong>#<%= orderId %></strong> has been created.</p>
            </div>

            <div class="confirmation-top-actions">
                <a href="payment.jsp?orderId=<%= orderId %>" class="confirmation-top-btn">Pay Now</a>
                <a class="confirmation-icon-btn" href="myOrders.jsp" title="My Orders">📦</a>
                <a class="confirmation-profile-btn" href="customerDashboard.jsp" title="Dashboard">👤</a>
            </div>
        </header>

        <div class="confirmation-content">

            <div class="confirmation-breadcrumb">
                <a href="customerDashboard.jsp">DASHBOARD</a>
                <span>›</span>
                <a href="myOrders.jsp">MY ORDERS</a>
                <span>›</span>
                <strong>ORDER #<%= orderId %></strong>
            </div>

            <section class="confirmation-hero-card">
                <div class="confirmation-success-icon">✓</div>

                <div>
                    <p class="confirmation-eyebrow">ORDER CREATED</p>
                    <h2>Order Confirmed</h2>
                    <p>
                        Your order has been placed successfully. 
                        <% if (unpaid) { %>
                            Complete payment to help us process it faster.
                        <% } else { %>
                            Your payment has been recorded and your order is ready for processing.
                        <% } %>
                    </p>

                    <div class="confirmation-hero-badges">
                        <span class="confirmation-status <%= orderClass %>">
                            <%= orderStatus.replace("_", " ") %>
                        </span>

                        <span class="confirmation-payment <%= paymentClass %>">
                            <%= paymentStatus %>
                        </span>
                    </div>
                </div>

                <div class="confirmation-order-card">
                    <span>Order Number</span>
                    <strong>#<%= orderId %></strong>
                    <small>Total Amount</small>
                    <b>KES <%= String.format("%,.2f", totalAmount) %></b>
                </div>
            </section>

            <section class="confirmation-grid">

                <div class="confirmation-info-box">
                    <span>Total Amount</span>
                    <strong>KES <%= String.format("%.2f", totalAmount) %></strong>
                </div>

                <div class="confirmation-info-box">
                    <span>Order Status</span>
                    <strong><%= orderStatus.replace("_", " ") %></strong>
                </div>

                <div class="confirmation-info-box">
                    <span>Payment Status</span>
                    <strong><%= paymentStatus %></strong>
                </div>

                <div class="confirmation-info-box">
                    <span>Delivery Fee</span>
                    <strong>KES <%= String.format("%.2f", deliveryFee) %></strong>
                </div>

            </section>

            <section class="confirmation-main-grid">

                <div class="confirmation-details-card">
                    <div class="confirmation-card-header">
                        <div>
                            <h2>Contact & Fulfilment Details</h2>
                            <p>These details will guide pickup or delivery fulfilment.</p>
                        </div>
                    </div>

                    <div class="confirmation-detail-list">
                        <div>
                            <span>Phone</span>
                            <strong><%= phone %></strong>
                        </div>

                        <div>
                            <span>Delivery Option</span>
                            <strong><%= deliveryZone %></strong>
                        </div>

                        <div>
                            <span>Location / Pickup</span>
                            <strong><%= deliveryAddress %></strong>
                        </div>

                        <% if (notes != null && !notes.trim().isEmpty()) { %>
                            <div>
                                <span>Notes</span>
                                <strong><%= notes %></strong>
                            </div>
                        <% } %>
                    </div>
                </div>

                <aside class="confirmation-next-card">
                    <h2>Next Steps</h2>

                    <div class="confirmation-step done">
                        <span>✓</span>
                        <div>
                            <strong>Order saved</strong>
                            <small>Your order has been recorded.</small>
                        </div>
                    </div>

                    <div class="confirmation-step <%= unpaid ? "active" : "done" %>">
                        <span><%= unpaid ? "2" : "✓" %></span>
                        <div>
                            <strong><%= unpaid ? "Complete payment" : "Payment recorded" %></strong>
                            <small><%= unpaid ? "Use M-Pesa or cash on delivery." : "Your payment status is updated." %></small>
                        </div>
                    </div>

                    <div class="confirmation-step">
                        <span>3</span>
                        <div>
                            <strong>Processing</strong>
                            <small>Staff will prepare your dairy products.</small>
                        </div>
                    </div>

                    <div class="confirmation-actions">
                        <% if (unpaid) { %>
                            <a class="confirmation-pay-btn" href="payment.jsp?orderId=<%= orderId %>">
                                Pay Now with M-Pesa
                            </a>
                        <% } %>

                        <a class="confirmation-secondary-btn" href="orderDetails.jsp?orderId=<%= orderId %>">
                            View Order Details
                        </a>

                        <a class="confirmation-light-btn" href="products.jsp">
                            Continue Shopping
                        </a>
                    </div>
                </aside>

            </section>

        </div>

    </main>

</div>

<aside class="confirmation-mobile-summary">
    <div>
        <span>Total</span>
        <strong>KES <%= String.format("%,.2f", totalAmount) %></strong>
    </div>

    <% if (unpaid) { %>
        <a href="payment.jsp?orderId=<%= orderId %>">Pay</a>
    <% } else { %>
        <a href="orderDetails.jsp?orderId=<%= orderId %>">Details</a>
    <% } %>
</aside>

<!-- MOBILE BOTTOM NAV -->
<nav class="confirmation-bottom-nav">
    <a href="customerDashboard.jsp">
        <span>⌂</span>
        Home
    </a>

    <a href="myOrders.jsp" class="active">
        <span>📦</span>
        Orders
    </a>

    <a href="products.jsp">
        <span>🛒</span>
        Shop
    </a>

    <a href="profile.jsp">
        <span>👤</span>
        Profile
    </a>
</nav>

</body>
</html>
