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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- CSS order matters -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/base.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/components.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/manage-orders.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/responsive.css?v=1">
</head>

<body class="manage-orders-body">

<div class="orders-admin-shell">

    <!-- SIDEBAR -->
    <aside class="orders-admin-sidebar">
        <div class="orders-admin-brand">
            <div class="orders-admin-brand-mark">🌿</div>
            <div>
                <h2>AgriBridge</h2>
                <p>Admin Portal</p>
            </div>
        </div>

        <nav class="orders-admin-menu">
            <a href="adminDashboard.jsp">
                <span>▦</span>
                Dashboard
            </a>

            <a href="manageProducts.jsp">
                <span>▣</span>
                Products
            </a>

            <a href="addProduct.jsp">
                <span>＋</span>
                Add Product
            </a>

            <a href="manageOrders.jsp" class="active">
                <span>▤</span>
                Orders
            </a>

            <a href="salesReport.jsp">
                <span>▥</span>
                Reports
            </a>

            <a href="products.jsp">
                <span>🛒</span>
                Marketplace
            </a>
        </nav>

        <div class="orders-admin-sidebar-promo">
            <h3>Order Control</h3>
            <p>Review payment status, update order progress, and assign delivery agents.</p>
            <a href="manageOrders.jsp?orderStatus=PENDING">Pending Orders</a>
        </div>

        <div class="orders-admin-sidebar-bottom">
            <a href="logout" onclick="return confirm('Are you sure you want to logout?');">
                ⎋ Logout
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="orders-admin-main">

        <!-- MOBILE TOP BAR -->
        <header class="orders-mobile-topbar">
            <a href="adminDashboard.jsp" aria-label="Dashboard">☰</a>
            <strong>Orders</strong>
            <div>
                <a href="manageProducts.jsp" aria-label="Products">▣</a>
                <a href="salesReport.jsp" aria-label="Reports">▥</a>
            </div>
        </header>

        <!-- DESKTOP TOP BAR -->
        <header class="orders-admin-topbar">
            <div>
                <h1>Orders Management</h1>
                <p>Review customer orders, payment status, delivery details, and assigned agents.</p>
            </div>

            <div class="orders-admin-top-actions">
                <form action="manageOrders.jsp" method="get" class="orders-admin-search">
                    <span>⌕</span>
                    <input type="text"
                           name="search"
                           placeholder="Search order/customer ID..."
                           value="<%= hasSearch ? search : "" %>">
                </form>

                <a href="manageOrders.jsp?orderStatus=PENDING"
                   class="orders-admin-icon-btn"
                   title="Pending Orders">
                    🔔
                </a>

                <a href="adminDashboard.jsp"
                   class="orders-admin-profile"
                   title="Admin Dashboard">
                    👨‍💼
                </a>
            </div>
        </header>

        <div class="orders-admin-content">

            <!-- HERO -->
            <section class="orders-hero-card">
                <div>
                    <p class="orders-eyebrow">STAFF ORDER CONTROL</p>
                    <h2>Manage Orders</h2>
                    <p>
                        Search, filter, update order status, and assign delivery agents from one clean workspace.
                    </p>

                    <div class="orders-hero-actions">
                        <a href="manageOrders.jsp?orderStatus=PENDING">Pending Orders</a>
                        <a href="products.jsp">View Marketplace</a>
                    </div>
                </div>

                <div class="orders-hero-summary">
                    <span>Filter Mode</span>
                    <strong><%= (hasSearch || hasOrderStatusFilter || hasPaymentStatusFilter) ? "ON" : "OFF" %></strong>
                    <small><%= (hasSearch || hasOrderStatusFilter || hasPaymentStatusFilter) ? "Showing selected records" : "Showing all orders" %></small>
                </div>
            </section>

            <%
                if ("updated".equals(request.getParameter("status"))) {
            %>
                <div class="orders-success">Order status updated successfully.</div>
            <%
                } else if ("assigned".equals(request.getParameter("status"))) {
            %>
                <div class="orders-success">Delivery agent assigned successfully.</div>
            <%
                } else if ("error".equals(request.getParameter("status"))) {
            %>
                <div class="orders-error">Something went wrong. Please try again.</div>
            <%
                }
            %>

            <!-- SEARCH AND FILTER BAR -->
            <section class="orders-filter-card">
                <form method="get" action="manageOrders.jsp" class="orders-filter-form">

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

                    <div class="orders-filter-actions">
                        <button type="submit">Search</button>
                        <a href="manageOrders.jsp">Clear</a>
                    </div>

                </form>
            </section>

            <section class="orders-list-card">

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

                            String paymentClass = paymentStatus.toLowerCase().replace("_", "-");
                            String orderStatusClass = orderStatus.toLowerCase().replace("_", "-");
                %>

                    <% if (resultCount == 1 && (hasSearch || hasOrderStatusFilter || hasPaymentStatusFilter)) { %>
                        <div class="orders-result-count">
                            Showing filtered results
                        </div>
                    <% } %>

                    <article class="orders-card">

                        <div class="orders-card-top">
                            <div>
                                <p class="orders-small-label">ORDER RECORD</p>
                                <h2>Order #<%= orderId %></h2>
                                <p>Customer ID: <strong><%= customerId %></strong></p>
                                <p>Placed: <%= orderDate != null ? orderDate : "Date unavailable" %></p>
                            </div>

                            <div class="orders-total">
                                <span>Total</span>
                                <strong>KES <%= String.format("%.2f", totalAmount) %></strong>
                            </div>
                        </div>

                        <div class="orders-info-grid">

                            <div class="orders-info">
                                <span>Payment Status</span>
                                <strong class="orders-payment <%= paymentClass %>">
                                    <%= paymentStatus %>
                                </strong>
                            </div>

                            <div class="orders-info">
                                <span>Order Status</span>
                                <strong class="orders-status <%= orderStatusClass %>">
                                    <%= orderStatus.replace("_", " ") %>
                                </strong>
                            </div>

                            <div class="orders-info">
                                <span>Delivery Status</span>
                                <strong><%= deliveryStatus.replace("_", " ") %></strong>
                            </div>

                            <div class="orders-info">
                                <span>Delivery Fee</span>
                                <strong>KES <%= String.format("%.2f", deliveryFee) %></strong>
                            </div>

                        </div>

                        <details class="orders-details">
                            <summary>View fulfilment details</summary>

                            <div class="orders-fulfilment-box">
                                <h3>Fulfilment Details</h3>

                                <p><strong>Zone:</strong> <%= deliveryZone %></p>
                                <p><strong>Phone:</strong> <%= phone %></p>
                                <p><strong>Address / Pickup:</strong> <%= deliveryAddress %></p>

                                <% if (notes != null && !notes.trim().isEmpty()) { %>
                                    <p><strong>Notes:</strong> <%= notes %></p>
                                <% } %>
                            </div>
                        </details>

                        <div class="orders-actions">

                            <form action="updateOrderStatus" method="post" class="orders-action-form">
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

                                <button type="submit">Update</button>
                            </form>

                            <form action="assignDelivery" method="post" class="orders-action-form">
                                <input type="hidden" name="orderId" value="<%= orderId %>">

                                <label>Assign Delivery Agent</label>
                                <input type="number" name="agentId" placeholder="Enter Agent ID" required>

                                <button class="secondary" type="submit">Assign</button>
                            </form>

                            <div class="orders-view-box">
                                <label>Customer View</label>
                                <a href="orderDetails.jsp?orderId=<%= orderId %>">
                                    View Details
                                </a>
                            </div>

                        </div>

                    </article>

                <%
                        }

                    } catch (Exception e) {
                        e.printStackTrace();
                %>

                    <div class="orders-error">
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

                    <div class="orders-empty-state">
                        <div>🔍</div>
                        <h2>No matching orders</h2>
                        <p>No orders match your current search or filter selection.</p>
                        <a href="manageOrders.jsp">Clear Filters</a>
                    </div>

                <%
                    }
                %>

            </section>

        </div>

    </main>

</div>

<!-- MOBILE BOTTOM NAV -->
<nav class="orders-admin-bottom-nav">
    <a href="adminDashboard.jsp">
        <span>⌂</span>
        Home
    </a>

    <a href="manageOrders.jsp" class="active">
        <span>📦</span>
        Orders
    </a>

    <a href="manageProducts.jsp">
        <span>▣</span>
        Products
    </a>

    <a href="salesReport.jsp">
        <span>▥</span>
        Reports
    </a>
</nav>

</body>
</html>
