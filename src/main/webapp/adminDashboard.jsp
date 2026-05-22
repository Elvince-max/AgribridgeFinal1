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
    int lowStockProducts = 0;

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
            try {
                String sql = "SELECT COALESCE(SUM(total_amount), 0) AS total_sales FROM orders";
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    totalSales = rs.getDouble("total_sales");
                }

                rs.close();
                ps.close();
            } catch (Exception ignored) {}
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

        // Low stock products
        try {
            String sql = "SELECT COUNT(*) AS low_stock_products FROM products WHERE stock_quantity <= 5";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                lowStockProducts = rs.getInt("low_stock_products");
            }

            rs.close();
            ps.close();
        } catch (Exception e) {
            lowStockProducts = 0;
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

    <!-- CSS order matters -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/base.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/components.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/admin-dashboard.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/responsive.css?v=1">
</head>

<body class="admin-dashboard-body">

<div class="admin-shell">

    <!-- SIDEBAR -->
    <aside class="admin-sidebar">
        <div class="admin-brand">
            <div class="admin-brand-mark">🌿</div>
            <div>
                <h2>AgriBridge</h2>
                <p>Admin Portal</p>
            </div>
        </div>

        <nav class="admin-menu">
            <a href="adminDashboard.jsp" class="active">
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

            <a href="manageOrders.jsp">
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

        <div class="admin-sidebar-promo">
            <h3>Operations Hub</h3>
            <p>Monitor orders, products, payments, and deliveries from one workspace.</p>
            <a href="addProduct.jsp">Add Product</a>
        </div>

        <div class="admin-sidebar-bottom">
            <a href="logout" onclick="return confirm('Are you sure you want to logout?');">
                ⎋ Logout
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="admin-main">

        <!-- MOBILE TOP BAR -->
        <header class="admin-mobile-topbar">
            <a href="adminDashboard.jsp" aria-label="Dashboard">☰</a>
            <strong>Admin</strong>
            <div>
                <a href="manageOrders.jsp" aria-label="Orders">📦</a>
                <a href="addProduct.jsp" aria-label="Add Product">＋</a>
            </div>
        </header>

        <!-- DESKTOP TOP BAR -->
        <header class="admin-topbar">
            <div>
                <h1>Admin Dashboard</h1>
                <p>Welcome back. Here is today’s AgriBridge performance snapshot.</p>
            </div>

            <div class="admin-top-actions">
                <form action="manageOrders.jsp" method="get" class="admin-search">
                    <span>⌕</span>
                    <input type="text" name="search" placeholder="Search order ID...">
                </form>

                <a href="manageOrders.jsp?orderStatus=PENDING"
                   class="admin-icon-btn"
                   title="Pending Orders">
                    🔔
                </a>

                <a href="adminDashboard.jsp"
                   class="admin-profile"
                   title="Admin Dashboard">
                    👨‍💼
                </a>
            </div>
        </header>

        <div class="admin-content">

            <!-- HERO -->
            <section class="admin-hero-card">
                <div>
                    <p class="admin-eyebrow">OPERATIONS OVERVIEW</p>
                    <h2>AgriBridge Control Center</h2>
                    <p>
                        Track sales, products, orders, delivery workload, and recent customer activity
                        from a single admin workspace.
                    </p>

                    <div class="admin-hero-actions">
                        <a href="manageOrders.jsp">Manage Orders</a>
                        <a href="addProduct.jsp">Add Product</a>
                    </div>
                </div>

                <div class="admin-hero-summary">
                    <span>Total Sales</span>
                    <strong>KES <%= String.format("%,.2f", totalSales) %></strong>
                    <small>Paid / completed orders</small>
                </div>
            </section>

            <!-- STATS -->
            <section class="admin-stats-grid">

                <div class="admin-stat-card">
                    <div>💵</div>
                    <span>Total Sales</span>
                    <h3>KES <%= String.format("%,.2f", totalSales) %></h3>
                    <p>Revenue from completed payments</p>
                </div>

                <div class="admin-stat-card">
                    <div>🧺</div>
                    <span>Total Orders</span>
                    <h3><%= totalOrders %></h3>
                    <p>All customer orders</p>
                </div>

                <div class="admin-stat-card">
                    <div>▣</div>
                    <span>Active Products</span>
                    <h3><%= activeProducts %></h3>
                    <p>Visible marketplace inventory</p>
                </div>

                <div class="admin-stat-card warning">
                    <div>🚚</div>
                    <span>Pending Deliveries</span>
                    <h3><%= pendingDeliveries %></h3>
                    <p>Orders needing fulfilment</p>
                </div>

            </section>

            <!-- MIDDLE -->
            <section class="admin-middle-grid">

                <div class="admin-analytics-card">
                    <div class="admin-card-header">
                        <div>
                            <h2>Revenue Analytics</h2>
                            <p>Visual monthly performance overview.</p>
                        </div>

                        <span>MONTHLY</span>
                    </div>

                    <div class="admin-chart">
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

                    <div class="admin-chart-labels">
                        <span>Week 1</span>
                        <span>Week 2</span>
                        <span>Week 3</span>
                        <span>Week 4</span>
                    </div>
                </div>

                <aside class="admin-health-card">
                    <h2>Operations Health</h2>
                    <p>Your AgriBridge hub is running with active order and inventory tracking.</p>

                    <div class="admin-progress-row">
                        <div>
                            <span>Order Processing</span>
                            <strong>92%</strong>
                        </div>

                        <div class="admin-progress-bar">
                            <span style="width: 92%;"></span>
                        </div>
                    </div>

                    <div class="admin-progress-row">
                        <div>
                            <span>Logistics Efficiency</span>
                            <strong>78%</strong>
                        </div>

                        <div class="admin-progress-bar soft">
                            <span style="width: 78%;"></span>
                        </div>
                    </div>

                    <div class="admin-alert-card">
                        <span>Low Stock Products</span>
                        <strong><%= lowStockProducts %></strong>
                        <small>Products with stock quantity of 5 or below</small>
                    </div>

                    <a href="salesReport.jsp">View Full Report</a>
                </aside>

            </section>

            <!-- RECENT ORDERS -->
            <section class="admin-recent-card">

                <div class="admin-card-header">
                    <div>
                        <h2>Recent Orders</h2>
                        <p>Latest customer activity.</p>
                    </div>

                    <a href="manageOrders.jsp">View All</a>
                </div>

                <div class="admin-orders-list">

                    <div class="admin-orders-head">
                        <span>Order</span>
                        <span>Customer</span>
                        <span>Delivery</span>
                        <span>Amount</span>
                        <span>Status</span>
                        <span>Action</span>
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
                                "SELECT o.order_id, o.user_id, o.total_amount, o.order_status, o.delivery_zone, " +
                                "u.full_name " +
                                "FROM orders o " +
                                "LEFT JOIN users u ON o.user_id = u.user_id " +
                                "ORDER BY o.order_id DESC LIMIT 5";

                            recentPs = conn.prepareStatement(recentSql);
                            recentRs = recentPs.executeQuery();

                            while (recentRs.next()) {
                                hasRecentOrders = true;

                                int orderId = recentRs.getInt("order_id");
                                int customerId = recentRs.getInt("user_id");
                                double amount = recentRs.getDouble("total_amount");

                                String status = recentRs.getString("order_status");
                                String delivery = recentRs.getString("delivery_zone");
                                String customerName = recentRs.getString("full_name");

                                if (status == null || status.trim().isEmpty()) {
                                    status = "PENDING";
                                }

                                if (delivery == null || delivery.trim().isEmpty()) {
                                    delivery = "Not selected";
                                }

                                if (customerName == null || customerName.trim().isEmpty()) {
                                    customerName = "Customer " + customerId;
                                }

                                String statusClass = status.toLowerCase().replace(" ", "-").replace("_", "-");
                    %>

                        <div class="admin-order-row">
                            <span>#<%= orderId %></span>

                            <span>
                                <strong><%= customerName %></strong>
                                <small>ID: <%= customerId %></small>
                            </span>

                            <span><%= delivery %></span>

                            <span>KES <%= String.format("%,.2f", amount) %></span>

                            <span>
                                <em class="admin-status <%= statusClass %>">
                                    <%= status.replace("_", " ") %>
                                </em>
                            </span>

                            <span>
                                <a href="orderDetailsStaff.jsp?orderId=<%= orderId %>">View</a>
                            </span>
                        </div>

                    <%
                            }

                        } catch (Exception e) {
                            e.printStackTrace();
                    %>

                        <div class="admin-empty-row">
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

                        <div class="admin-empty-row">
                            No recent orders yet.
                        </div>

                    <%
                        }
                    %>

                </div>

            </section>

        </div>

    </main>

</div>

<!-- MOBILE BOTTOM NAV -->
<nav class="admin-bottom-nav">
    <a href="adminDashboard.jsp" class="active">
        <span>⌂</span>
        Home
    </a>

    <a href="manageOrders.jsp">
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
