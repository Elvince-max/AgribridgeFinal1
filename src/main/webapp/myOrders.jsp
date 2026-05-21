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

    String filterStatus = request.getParameter("status");
    String search = request.getParameter("search");

    boolean hasFilter = filterStatus != null && !filterStatus.trim().isEmpty();
    boolean hasSearch = search != null && !search.trim().isEmpty();

    boolean searchIsNumber = false;
    int searchOrderId = 0;

    if (hasSearch) {
        try {
            searchOrderId = Integer.parseInt(search.trim());
            searchIsNumber = true;
        } catch (Exception e) {
            searchIsNumber = false;
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>My Orders - Egerton AgriBridge Hub</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- CSS order matters -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/base.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/components.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/customer-orders.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/responsive.css?v=1">
</head>

<body class="customer-orders-body">

<div class="customer-dash-layout">

    <!-- SIDEBAR -->
    <aside class="customer-sidebar">
        <div class="customer-brand">
            <h2>AgriBridge</h2>
            <p>Customer Portal</p>
        </div>

        <nav class="customer-menu">
            <a href="customerDashboard.jsp">
                <span>▦</span>
                Dashboard
            </a>

            <a href="index.jsp">
                <span>⌂</span>
                Home
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
        </nav>

        <div class="customer-sidebar-bottom">
            <a class="customer-shop-btn" href="products.jsp">
                ＋ Shop Products
            </a>

            <a href="index.jsp" class="customer-logout">
                ⌂ Visit Home Page
            </a>

            <a href="logout" class="customer-logout">
                ⎋ Logout
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="customer-main">

        <!-- MOBILE TOP BAR -->
        <header class="orders-mobile-topbar">
            <a href="customerDashboard.jsp" aria-label="Dashboard">☰</a>
            <strong>My Orders</strong>
            <div>
                <a href="cart.jsp" aria-label="Cart">🛒</a>
                <a href="profile.jsp" aria-label="Profile">👤</a>
            </div>
        </header>

        <!-- TOP BAR -->
        <header class="customer-topbar">
            <div>
                <h1>My Orders</h1>
                <p>Track your orders, payments, delivery progress, and fulfilment status.</p>
            </div>

            <div class="customer-top-actions">
                <form action="products.jsp" method="get" class="customer-search">
                    <span>⌕</span>
                    <input type="text" name="search" placeholder="Search products...">
                </form>

                <a href="index.jsp" class="customer-icon-btn" title="Home">⌂</a>
                <a href="cart.jsp" class="customer-icon-btn" title="Cart">🧺</a>
                <a href="customerDashboard.jsp" class="customer-profile" title="Dashboard">👤</a>
            </div>
        </header>

        <div class="customer-content">

            <div class="customer-orders-hero">
                <div>
                    <p class="eyebrow">ORDER HISTORY</p>
                    <h1>Track Your Orders</h1>
                    <p>
                        View payment status, delivery method, order progress,
                        and continue payment for pending orders.
                    </p>
                </div>

                <a href="products.jsp">Continue Shopping</a>
            </div>

            <!-- FILTERS -->
            <div class="customer-orders-filter-card">
                <form action="myOrders.jsp" method="get" class="customer-orders-filter-form">

                    <div>
                        <label>Search Order</label>
                        <input type="text"
                               name="search"
                               placeholder="Enter order number"
                               value="<%= hasSearch ? search : "" %>">
                    </div>

                    <div>
                        <label>Order Status</label>
                        <select name="status">
                            <option value="">All Orders</option>
                            <option value="PENDING" <%= "PENDING".equals(filterStatus) ? "selected" : "" %>>Pending</option>
                            <option value="CONFIRMED" <%= "CONFIRMED".equals(filterStatus) ? "selected" : "" %>>Confirmed</option>
                            <option value="PROCESSING" <%= "PROCESSING".equals(filterStatus) ? "selected" : "" %>>Processing</option>
                            <option value="OUT_FOR_DELIVERY" <%= "OUT_FOR_DELIVERY".equals(filterStatus) ? "selected" : "" %>>Out for Delivery</option>
                            <option value="DELIVERED" <%= "DELIVERED".equals(filterStatus) ? "selected" : "" %>>Delivered</option>
                            <option value="CANCELLED" <%= "CANCELLED".equals(filterStatus) ? "selected" : "" %>>Cancelled</option>
                        </select>
                    </div>

                    <div class="customer-orders-filter-actions">
                        <button type="submit">Filter</button>
                        <a href="myOrders.jsp">Clear</a>
                    </div>

                </form>
            </div>

            <!-- ORDERS -->
            <section class="customer-orders-list-page">

                <%
                    Connection conn = null;
                    PreparedStatement ps = null;
                    ResultSet rs = null;

                    boolean hasOrders = false;

                    try {
                        conn = DBConnection.getConnection();

                        String sql =
                            "SELECT o.order_id, o.total_amount, o.order_status, " +
                            "o.delivery_zone, o.delivery_fee, " +
                            "(SELECT p.payment_status FROM payments p " +
                            " WHERE p.order_id = o.order_id " +
                            " ORDER BY p.payment_id DESC LIMIT 1) AS payment_status " +
                            "FROM orders o " +
                            "WHERE o.user_id = ? ";

                        if (hasSearch && searchIsNumber) {
                            sql += "AND o.order_id = ? ";
                        } else if (hasSearch && !searchIsNumber) {
                            sql += "AND 1 = 0 ";
                        }

                        if (hasFilter) {
                            sql += "AND o.order_status = ? ";
                        }

                        sql += "ORDER BY o.order_id DESC";

                        ps = conn.prepareStatement(sql);

                        int paramIndex = 1;
                        ps.setInt(paramIndex++, userId);

                        if (hasSearch && searchIsNumber) {
                            ps.setInt(paramIndex++, searchOrderId);
                        }

                        if (hasFilter) {
                            ps.setString(paramIndex++, filterStatus);
                        }

                        rs = ps.executeQuery();

                        while (rs.next()) {
                            hasOrders = true;

                            int orderId = rs.getInt("order_id");
                            double totalAmount = rs.getDouble("total_amount");

                            String orderStatus = rs.getString("order_status");
                            String deliveryZone = rs.getString("delivery_zone");
                            double deliveryFee = rs.getDouble("delivery_fee");
                            String paymentStatus = rs.getString("payment_status");

                            if (orderStatus == null || orderStatus.trim().isEmpty()) {
                                orderStatus = "PENDING";
                            }

                            if (paymentStatus == null || paymentStatus.trim().isEmpty()) {
                                paymentStatus = "PENDING";
                            }

                            if (deliveryZone == null || deliveryZone.trim().isEmpty()) {
                                deliveryZone = "Not selected";
                            }

                            String paymentClass = paymentStatus.toLowerCase();
                            String orderClass = orderStatus.toLowerCase();

                            boolean placedDone = true;

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
                                    "DELIVERED".equalsIgnoreCase(orderStatus);

                            boolean deliveredDone =
                                    "DELIVERED".equalsIgnoreCase(orderStatus);

                            boolean unpaid =
                                    !"PAID".equalsIgnoreCase(paymentStatus) &&
                                    !"COMPLETED".equalsIgnoreCase(paymentStatus);
                %>

                    <div class="customer-order-card-page">

                        <div class="customer-order-main-info">
                            <div>
                                <p class="eyebrow">ORDER RECORD</p>
                                <h2>Order #<%= orderId %></h2>
                                <p>
                                    Fulfilment:
                                    <strong><%= deliveryZone %></strong>
                                </p>
                            </div>

                            <div class="customer-order-amount">
                                <span>Total Amount</span>
                                <strong>KES <%= String.format("%,.2f", totalAmount) %></strong>
                                <small>Delivery fee: KES <%= String.format("%.2f", deliveryFee) %></small>
                            </div>
                        </div>

                        <div class="customer-order-badges">
                            <span class="customer-status <%= orderClass %>">
                                <%= orderStatus.replace("_", " ") %>
                            </span>

                            <span class="customer-payment <%= paymentClass %>">
                                <%= paymentStatus %>
                            </span>
                        </div>

                        <div class="customer-order-progress">
                            <div class="<%= placedDone ? "done" : "" %>">
                                <span>1</span>
                                <p>Placed</p>
                            </div>

                            <div class="<%= confirmedDone ? "done" : "" %>">
                                <span>2</span>
                                <p>Confirmed</p>
                            </div>

                            <div class="<%= processingDone ? "done" : "" %>">
                                <span>3</span>
                                <p>Processing</p>
                            </div>

                            <div class="<%= deliveryDone ? "done" : "" %>">
                                <span>4</span>
                                <p>Delivery</p>
                            </div>

                            <div class="<%= deliveredDone ? "done" : "" %>">
                                <span>5</span>
                                <p>Done</p>
                            </div>
                        </div>

                        <div class="customer-order-actions-page">
                            <a href="orderDetails.jsp?orderId=<%= orderId %>">
                                View Details
                            </a>

                            <% if (unpaid) { %>
                                <a class="pay" href="payment.jsp?orderId=<%= orderId %>">
                                    Pay Now
                                </a>
                            <% } %>
                        </div>

                    </div>

                <%
                        }

                    } catch (Exception e) {
                        e.printStackTrace();
                %>

                    <div class="review-error">
                        Could not load your orders. Please check the orders/payments table column names.
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
                        <div class="cart-empty-icon">🧺</div>
                        <h2>No matching orders</h2>
                        <p>Your order history will appear here once you place an order.</p>
                        <a href="products.jsp">Start Shopping</a>
                    </div>

                <%
                    }
                %>

            </section>

        </div>

    </main>

</div>


<!-- MOBILE BOTTOM NAV -->
<nav class="orders-bottom-nav">
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