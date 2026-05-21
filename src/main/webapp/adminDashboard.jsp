<%@ page import="java.sql.*, com.agribridgef1.util.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String userType = (String) session.getAttribute("userType");

    if (session.getAttribute("userId") == null ||
        (!"ADMIN".equals(userType) && !"STAFF".equals(userType))) {
        response.sendRedirect("login.jsp");
        return;
    }

    double totalSales = 0;
    int totalOrders = 0;
    int activeProducts = 0;
    int pendingDeliveries = 0;

    Connection conn = null;

    try {
        conn = DBConnection.getConnection();

        // Total sales from paid/completed payments if payments table exists
        try {
            String sql =
                "SELECT COALESCE(SUM(o.total_amount), 0) AS total_sales " +
                "FROM orders o " +
                "WHERE o.order_id IN (" +
                "   SELECT p.order_id FROM payments p " +
                "   WHERE p.payment_status IN ('PAID', 'COMPLETED')" +
                ")";

            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                totalSales = rs.getDouble("total_sales");
            }

            rs.close();
            ps.close();

        } catch (Exception e) {
            // fallback: total all orders
            String sql = "SELECT COALESCE(SUM(total_amount), 0) AS total_sales FROM orders";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                totalSales = rs.getDouble("total_sales");
            }

            rs.close();
            ps.close();
        }

        // Total orders
        try {
            String sql = "SELECT COUNT(*) AS total_orders FROM orders";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                totalOrders = rs.getInt("total_orders");
            }

            rs.close();
            ps.close();
        } catch (Exception e) {
            totalOrders = 0;
        }

        // Active products
        try {
            String sql = "SELECT COUNT(*) AS active_products FROM products WHERE status = 'ACTIVE'";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                activeProducts = rs.getInt("active_products");
            }

            rs.close();
            ps.close();
        } catch (Exception e) {
            try {
                String sql = "SELECT COUNT(*) AS active_products FROM products";
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    activeProducts = rs.getInt("active_products");
                }

                rs.close();
                ps.close();
            } catch (Exception ignored) {}
        }

        // Pending deliveries
        try {
            String sql =
                "SELECT COUNT(*) AS pending_deliveries FROM orders " +
                "WHERE order_status IN ('PENDING', 'CONFIRMED', 'PROCESSING', 'OUT_FOR_DELIVERY')";

            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                pendingDeliveries = rs.getInt("pending_deliveries");
            }

            rs.close();
            ps.close();
        } catch (Exception e) {
            pendingDeliveries = 0;
        }

    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard - Egerton AgriBridge Hub</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style-backup.css?v=7">
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
            <a href="adminDashboard.jsp" class="active">
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

            <a href="manageOrders.jsp">
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
                            <h1>Estate Overview</h1>
                            <p>Welcome back. Here is today’s AgriBridge performance snapshot.</p>
                        </div>

                        <div class="estate-top-actions">
                <form action="manageOrders.jsp" method="get" class="estate-search">
                    <span>⌕</span>
                    <input type="text" name="search" placeholder="Search order ID...">
                </form>

                <a href="manageOrders.jsp?orderStatus=PENDING"
                   class="estate-icon-btn"
                   title="Pending Orders">
                    🔔
                </a>

                <a href="adminDashboard.jsp"
                   class="estate-profile"
                   title="Admin Dashboard">
                    👨‍💼
                </a>

                <a href="logout"
                   class="dashboard-logout-btn"
                   onclick="return confirm('Are you sure you want to logout?');">
                    Logout
                </a>
            </div>
        </header>

        <!-- STATS -->
        <section class="estate-stats-grid">

            <div class="estate-stat-card">
                <div class="estate-stat-icon green">💵</div>
                <p>Total Sales</p>
                <h2>KES <%= String.format("%,.2f", totalSales) %></h2>
                <small class="positive">↗ Revenue from completed orders</small>
            </div>

            <div class="estate-stat-card">
                <div class="estate-stat-icon gold">🧺</div>
                <p>Total Orders</p>
                <h2><%= totalOrders %></h2>
                <small>↻ Updated from orders table</small>
            </div>

            <div class="estate-stat-card">
                <div class="estate-stat-icon green">▣</div>
                <p>Active Products</p>
                <h2><%= activeProducts %></h2>
                <small class="positive">● Marketplace inventory</small>
            </div>

            <div class="estate-stat-card">
                <div class="estate-stat-icon red">🚚</div>
                <p>Pending Deliveries</p>
                <h2><%= pendingDeliveries %></h2>
                <small class="warning">! Action may be required</small>
            </div>

        </section>

        <!-- MIDDLE -->
        <section class="estate-middle-grid">

            <div class="estate-analytics-card">
                <div class="estate-card-header">
                    <div>
                        <h2>Revenue Analytics</h2>
                        <p>Visual performance overview</p>
                    </div>

                    <span>MONTHLY</span>
                </div>

                <div class="estate-chart">
                    <div style="height: 32%;"></div>
                    <div style="height: 48%;"></div>
                    <div class="highlight-gold" style="height: 62%;"></div>
                    <div style="height: 55%;"></div>
                    <div style="height: 75%;"></div>
                    <div style="height: 40%;"></div>
                    <div class="highlight-green" style="height: 84%;"></div>
                    <div style="height: 62%;"></div>
                    <div style="height: 44%;"></div>
                    <div style="height: 58%;"></div>
                </div>

                <div class="estate-chart-labels">
                    <span>Week 1</span>
                    <span>Week 2</span>
                    <span>Week 3</span>
                    <span>Week 4</span>
                </div>
            </div>

            <div class="estate-excellence-card">
                <h2>Pastoral Excellence</h2>
                <p>Your AgriBridge hub is operating with strong performance and traceability.</p>

                <div class="estate-progress-row">
                    <div>
                        <span>Order Processing</span>
                        <strong>92%</strong>
                    </div>
                    <div class="estate-progress-bar">
                        <span style="width: 92%;"></span>
                    </div>
                </div>

                <div class="estate-progress-row">
                    <div>
                        <span>Logistics Efficiency</span>
                        <strong>78%</strong>
                    </div>
                    <div class="estate-progress-bar soft">
                        <span style="width: 78%;"></span>
                    </div>
                </div>

                <a href="salesReport.jsp">View Full Report</a>
            </div>

        </section>

        <!-- RECENT ORDERS -->
        <section class="estate-recent-card">

            <div class="estate-card-header">
                <div>
                    <h2>Recent Orders</h2>
                    <p>Latest customer activity</p>
                </div>

                <a href="manageOrders.jsp">View All</a>
            </div>

            <div class="estate-orders-table">

                <div class="estate-orders-head">
                    <span>Order ID</span>
                    <span>Customer</span>
                    <span>Delivery</span>
                    <span>Amount</span>
                    <span>Status</span>
                </div>

                <%
                    PreparedStatement recentPs = null;
                    ResultSet recentRs = null;
                    boolean hasRecentOrders = false;

                    try {
                        if (conn == null || conn.isClosed()) {
                            conn = DBConnection.getConnection();
                        }

                        String recentSql =
                            "SELECT order_id, user_id, total_amount, order_status, delivery_zone " +
                            "FROM orders " +
                            "ORDER BY order_id DESC LIMIT 5";

                        recentPs = conn.prepareStatement(recentSql);
                        recentRs = recentPs.executeQuery();

                        while (recentRs.next()) {
                            hasRecentOrders = true;

                            int orderId = recentRs.getInt("order_id");
                            int customerId = recentRs.getInt("user_id");
                            double amount = recentRs.getDouble("total_amount");

                            String status = recentRs.getString("order_status");
                            String deliveryZone = recentRs.getString("delivery_zone");

                            if (status == null || status.trim().isEmpty()) {
                                status = "PENDING";
                            }

                            if (deliveryZone == null || deliveryZone.trim().isEmpty()) {
                                deliveryZone = "Not selected";
                            }

                            String statusClass = status.toLowerCase();
                %>

                    <div class="estate-order-row">
                        <span>#<%= orderId %></span>

                        <span>
                            <strong>Customer <%= customerId %></strong>
                            <small>ID: <%= customerId %></small>
                        </span>

                        <span><%= deliveryZone %></span>

                        <span>KES <%= String.format("%,.2f", amount) %></span>

                        <span>
                            <em class="estate-status <%= statusClass %>">
                                <%= status.replace("_", " ") %>
                            </em>
                        </span>
                    </div>

                <%
                        }

                    } catch (Exception e) {
                        e.printStackTrace();
                %>

                    <div class="estate-empty-row">
                        Could not load recent orders.
                    </div>

                <%
                    } finally {
                        if (recentRs != null) try { recentRs.close(); } catch (Exception e) {}
                        if (recentPs != null) try { recentPs.close(); } catch (Exception e) {}
                        if (conn != null) try { conn.close(); } catch (Exception e) {}
                    }

                    if (!hasRecentOrders) {
                %>

                    <div class="estate-empty-row">
                        No recent orders yet.
                    </div>

                <%
                    }
                %>

            </div>

        </section>

    </main>

</div>

</body>
</html>