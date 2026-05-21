<%@ page import="java.sql.*, com.agribridgef1.util.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userType = (String) session.getAttribute("userType");

    if (userType == null || !"CUSTOMER".equals(userType.trim().toUpperCase())) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = (int) session.getAttribute("userId");

    String orderIdParam = request.getParameter("orderId");

    if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
        orderIdParam = request.getParameter("id");
    }

    if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
        response.sendRedirect("myOrders.jsp");
        return;
    }

    int orderId = Integer.parseInt(orderIdParam);

    String orderStatus = "PENDING";
    String paymentStatus = "PENDING";
    String deliveryStatus = "PENDING";
    String deliveryZone = "";
    String deliveryAddress = "";
    String phone = "";
    String notes = "";
    String orderDate = "";
    double totalAmount = 0;
    double deliveryFee = 0;

    boolean orderFound = false;

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();

        String orderSql = "SELECT * FROM orders WHERE order_id = ? AND user_id = ?";
        ps = conn.prepareStatement(orderSql);
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

            try { deliveryStatus = rs.getString("delivery_status"); } catch (Exception e) {}

            try { orderDate = rs.getString("created_at"); } catch (Exception e) {}

            if (orderDate == null || orderDate.trim().isEmpty()) {
                try { orderDate = rs.getString("order_date"); } catch (Exception e) {}
            }
        }

        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}

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
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
    }

    if (!orderFound) {
        if (conn != null) try { conn.close(); } catch (Exception e) {}
        response.sendRedirect("myOrders.jsp");
        return;
    }

    if (orderStatus == null || orderStatus.trim().isEmpty()) {
        orderStatus = "PENDING";
    }

    if (paymentStatus == null || paymentStatus.trim().isEmpty()) {
        paymentStatus = "PENDING";
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

    boolean placedDone = true;

    boolean paidDone =
            "PAID".equalsIgnoreCase(paymentStatus) ||
            "COMPLETED".equalsIgnoreCase(paymentStatus);

    boolean confirmedDone =
            "CONFIRMED".equalsIgnoreCase(orderStatus) ||
            "PROCESSING".equalsIgnoreCase(orderStatus) ||
            "OUT_FOR_DELIVERY".equalsIgnoreCase(orderStatus) ||
            "DELIVERED".equalsIgnoreCase(orderStatus);

    boolean processingDone =
            "PROCESSING".equalsIgnoreCase(orderStatus) ||
            "OUT_FOR_DELIVERY".equalsIgnoreCase(orderStatus) ||
            "DELIVERED".equalsIgnoreCase(orderStatus);

    boolean deliveryDone =
            "OUT_FOR_DELIVERY".equalsIgnoreCase(orderStatus) ||
            "DELIVERED".equalsIgnoreCase(orderStatus) ||
            "OUT_FOR_DELIVERY".equalsIgnoreCase(deliveryStatus) ||
            "DELIVERED".equalsIgnoreCase(deliveryStatus);

    boolean completedDone =
            "DELIVERED".equalsIgnoreCase(orderStatus) ||
            "DELIVERED".equalsIgnoreCase(deliveryStatus);

    boolean unpaid =
            !"PAID".equalsIgnoreCase(paymentStatus) &&
            !"COMPLETED".equalsIgnoreCase(paymentStatus);

    String orderClass = orderStatus.toLowerCase().replace(" ", "-");
    String paymentClass = paymentStatus.toLowerCase().replace(" ", "-");
    String deliveryClass = deliveryStatus.toLowerCase().replace(" ", "-");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Order Details - Egerton AgriBridge Hub</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- CSS order matters -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/base.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/components.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/order-details.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/responsive.css?v=1">
</head>

<body class="order-details-body">

<div class="order-details-layout">

    <!-- SIDEBAR -->
    <aside class="order-sidebar">
        <div class="order-brand">
            <div class="order-brand-mark">🌿</div>
            <div>
                <h2>AgriBridge</h2>
                <p>Customer Portal</p>
            </div>
        </div>

        <nav class="order-menu">
            <a href="customerDashboard.jsp">
                <span>▦</span>
                Dashboard
            </a>

            <a href="products.jsp">
                <span>🛒</span>
                Marketplace
            </a>

            <a href="myOrders.jsp" class="active">
                <span>▤</span>
                My Orders
            </a>

            <a href="profile.jsp">
                <span>👤</span>
                Profile
            </a>

            <a href="cart.jsp">
                <span>🧺</span>
                Cart
            </a>
        </nav>

        <div class="order-sidebar-promo">
            <h3>Order Tracking</h3>
            <p>Follow payment, preparation and delivery progress in one place.</p>
            <a href="myOrders.jsp">Back to Orders</a>
        </div>

        <div class="order-sidebar-bottom">
            <a href="logout" onclick="return confirm('Are you sure you want to logout?');">
                ⎋ Logout
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="order-main">

        <!-- MOBILE TOP BAR -->
        <header class="order-mobile-topbar">
            <a href="myOrders.jsp" aria-label="Back to orders">←</a>
            <strong>Order #<%= orderId %></strong>
            <div>
                <a href="cart.jsp" aria-label="Cart">🛒</a>
                <a href="profile.jsp" aria-label="Profile">👤</a>
            </div>
        </header>

        <!-- DESKTOP TOP BAR -->
        <header class="order-topbar">
            <div>
                <h1>Order Details</h1>
                <p>Viewing order <strong>#<%= orderId %></strong>.</p>
            </div>

            <div class="order-top-actions">
                <a href="myOrders.jsp" class="order-icon-btn" title="Back to orders">←</a>
                <a href="cart.jsp" class="order-icon-btn" title="Cart">🛒</a>
                <a href="customerDashboard.jsp" class="order-profile-btn" title="Dashboard">👤</a>
            </div>
        </header>

        <div class="order-content">

            <!-- HERO -->
            <section class="order-hero">
                <div class="order-hero-main">
                    <p class="order-eyebrow">ORDER TRACKING</p>
                    <h2>Order #<%= orderId %></h2>
                    <p>
                        Placed:
                        <strong><%= orderDate != null && !orderDate.trim().isEmpty() ? orderDate : "Date unavailable" %></strong>
                    </p>

                    <div class="order-hero-badges">
                        <span class="order-status <%= orderClass %>">
                            <%= orderStatus.replace("_", " ") %>
                        </span>

                        <span class="order-payment <%= paymentClass %>">
                            <%= paymentStatus %>
                        </span>
                    </div>
                </div>

                <div class="order-total-card">
                    <span>Total Amount</span>
                    <strong>KES <%= String.format("%,.2f", totalAmount) %></strong>
                    <small>Delivery fee: KES <%= String.format("%.2f", deliveryFee) %></small>

                    <% if (unpaid) { %>
                        <a href="payment.jsp?orderId=<%= orderId %>">
                            Pay Now
                        </a>
                    <% } %>
                </div>
            </section>

            <!-- TIMELINE -->
            <section class="order-timeline-card">
                <div class="order-panel-header">
                    <div>
                        <h2>Order Status Flow</h2>
                        <p>Follow your order from checkout to fulfilment.</p>
                    </div>
                </div>

                <div class="order-detail-timeline">

                    <div class="order-detail-step <%= placedDone ? "done" : "" %>">
                        <div>✓</div>
                        <h4>Placed</h4>
                        <p>Order created</p>
                    </div>

                    <div class="order-detail-step <%= paidDone ? "done" : "" %>">
                        <div><%= paidDone ? "✓" : "2" %></div>
                        <h4>Payment</h4>
                        <p><%= paymentStatus %></p>
                    </div>

                    <div class="order-detail-step <%= confirmedDone ? "done" : "" %>">
                        <div><%= confirmedDone ? "✓" : "3" %></div>
                        <h4>Confirmed</h4>
                        <p><%= orderStatus.replace("_", " ") %></p>
                    </div>

                    <div class="order-detail-step <%= processingDone ? "done" : "" %>">
                        <div><%= processingDone ? "✓" : "4" %></div>
                        <h4>Processing</h4>
                        <p>Items being prepared</p>
                    </div>

                    <div class="order-detail-step <%= deliveryDone ? "done" : "" %>">
                        <div><%= deliveryDone ? "✓" : "5" %></div>
                        <h4>Delivery</h4>
                        <p><%= deliveryStatus.replace("_", " ") %></p>
                    </div>

                    <div class="order-detail-step <%= completedDone ? "done" : "" %>">
                        <div><%= completedDone ? "✓" : "6" %></div>
                        <h4>Completed</h4>
                        <p>Fulfilled</p>
                    </div>

                </div>
            </section>

            <section class="order-details-grid">

                <!-- ITEMS -->
                <div class="order-panel">
                    <div class="order-panel-header">
                        <div>
                            <h2>Order Items</h2>
                            <p>Products included in this order.</p>
                        </div>
                    </div>

                    <div class="order-items-list">

                        <%
                            PreparedStatement itemPs = null;
                            ResultSet itemRs = null;

                            try {
                                String itemSql =
                                    "SELECT oi.quantity, oi.price, p.product_name, p.description, p.image_url " +
                                    "FROM order_items oi " +
                                    "JOIN products p ON oi.product_id = p.product_id " +
                                    "WHERE oi.order_id = ?";

                                itemPs = conn.prepareStatement(itemSql);
                                itemPs.setInt(1, orderId);

                                itemRs = itemPs.executeQuery();

                                boolean hasItems = false;

                                while (itemRs.next()) {
                                    hasItems = true;

                                    int quantity = itemRs.getInt("quantity");
                                    double price = itemRs.getDouble("price");
                                    double itemSubtotal = quantity * price;

                                    String productName = itemRs.getString("product_name");
                                    String description = itemRs.getString("description");
                                    String imageUrl = itemRs.getString("image_url");
                        %>

                            <div class="order-item-detail">
                                <% if (imageUrl != null && !imageUrl.trim().isEmpty()) { %>
                                    <img src="<%= request.getContextPath() + "/" + imageUrl %>"
                                         alt="<%= productName %>"
                                         loading="lazy">
                                <% } else { %>
                                    <div class="order-no-image">No Image</div>
                                <% } %>

                                <div>
                                    <h3><%= productName %></h3>
                                    <p><%= description != null ? description : "" %></p>
                                    <small>
                                        Quantity: <%= quantity %> × KES <%= String.format("%.2f", price) %>
                                    </small>
                                </div>

                                <strong>KES <%= String.format("%.2f", itemSubtotal) %></strong>
                            </div>

                        <%
                                }

                                if (!hasItems) {
                        %>

                            <div class="order-empty-small">
                                No items found for this order.
                            </div>

                        <%
                                }

                            } catch (Exception e) {
                                e.printStackTrace();
                        %>

                            <div class="order-error">
                                Could not load order items.
                            </div>

                        <%
                            } finally {
                                if (itemRs != null) try { itemRs.close(); } catch (Exception e) {}
                                if (itemPs != null) try { itemPs.close(); } catch (Exception e) {}
                                if (conn != null) try { conn.close(); } catch (Exception e) {}
                            }
                        %>

                    </div>
                </div>

                <!-- SIDE PANEL -->
                <aside class="order-side">

                    <div class="order-side-card">
                        <h2>Payment</h2>

                        <span class="order-payment <%= paymentClass %>">
                            <%= paymentStatus %>
                        </span>

                        <% if (unpaid) { %>
                            <a class="order-pay-now-btn" href="payment.jsp?orderId=<%= orderId %>">
                                Pay Now
                            </a>
                        <% } %>
                    </div>

                    <div class="order-side-card">
                        <h2>Fulfilment</h2>

                        <div>
                            <span>Option</span>
                            <strong><%= deliveryZone %></strong>
                        </div>

                        <div>
                            <span>Delivery Status</span>
                            <strong class="fulfilment-status <%= deliveryClass %>">
                                <%= deliveryStatus.replace("_", " ") %>
                            </strong>
                        </div>

                        <div>
                            <span>Delivery Fee</span>
                            <strong>KES <%= String.format("%.2f", deliveryFee) %></strong>
                        </div>

                        <div>
                            <span>Phone</span>
                            <strong><%= phone %></strong>
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

                    <a class="order-back-orders" href="myOrders.jsp">
                        ← Back to My Orders
                    </a>

                </aside>

            </section>

        </div>

    </main>

</div>

<!-- MOBILE BOTTOM NAV -->
<nav class="order-bottom-nav">
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
