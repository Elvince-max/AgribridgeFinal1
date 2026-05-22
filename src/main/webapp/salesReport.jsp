<%@ page import="java.sql.*, com.agribridgef1.util.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String userType = (String) session.getAttribute("userType");

    if (session.getAttribute("userId") == null ||
        (!"ADMIN".equals(userType) && !"STAFF".equals(userType))) {
        response.sendRedirect("login.jsp");
        return;
    }

    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");

    boolean hasStartDate = startDate != null && !startDate.trim().isEmpty();
    boolean hasEndDate = endDate != null && !endDate.trim().isEmpty();

    String dateError = null;

    java.time.LocalDate today = java.time.LocalDate.now();

    if (hasStartDate || hasEndDate) {
        if (!hasStartDate || !hasEndDate) {
            dateError = "Please select both start date and end date.";
        } else {
            try {
                java.time.LocalDate start = java.time.LocalDate.parse(startDate);
                java.time.LocalDate end = java.time.LocalDate.parse(endDate);

                if (start.isAfter(end)) {
                    dateError = "Start date cannot be after end date.";
                } else if (start.isAfter(today) || end.isAfter(today)) {
                    dateError = "Future dates are not allowed.";
                }
            } catch (Exception e) {
                dateError = "Invalid date format selected.";
            }
        }
    }

    if (dateError != null) {
        hasStartDate = false;
        hasEndDate = false;
    }

    double totalSales = 0;
    int totalOrders = 0;
    double averageOrderValue = 0;

    int pending = 0;
    int confirmed = 0;
    int processing = 0;
    int outForDelivery = 0;
    int delivered = 0;
    int cancelled = 0;

    int paidPayments = 0;
    int pendingPayments = 0;
    int failedPayments = 0;

    Connection conn = null;

    try {
        conn = DBConnection.getConnection();

        boolean dateFilterApplied = false;
        String dateColumn = "";

        if (hasStartDate && hasEndDate) {
            try {
                PreparedStatement testPs = conn.prepareStatement(
                    "SELECT COUNT(*) FROM orders WHERE DATE(created_at) BETWEEN ? AND ?"
                );
                testPs.setString(1, startDate);
                testPs.setString(2, endDate);
                testPs.executeQuery();
                testPs.close();

                dateColumn = "created_at";
                dateFilterApplied = true;

            } catch (Exception e1) {
                try {
                    PreparedStatement testPs = conn.prepareStatement(
                        "SELECT COUNT(*) FROM orders WHERE DATE(order_date) BETWEEN ? AND ?"
                    );
                    testPs.setString(1, startDate);
                    testPs.setString(2, endDate);
                    testPs.executeQuery();
                    testPs.close();

                    dateColumn = "order_date";
                    dateFilterApplied = true;

                } catch (Exception e2) {
                    dateFilterApplied = false;
                    dateError = "Date filtering could not be applied because no valid order date column was found.";
                }
            }
        }

        String dateWhere = "";

        if (dateFilterApplied) {
            dateWhere = " WHERE DATE(" + dateColumn + ") BETWEEN ? AND ? ";
        }

        String summarySql =
            "SELECT COUNT(*) AS total_orders, COALESCE(SUM(total_amount), 0) AS total_sales " +
            "FROM orders " + dateWhere;

        PreparedStatement ps = conn.prepareStatement(summarySql);

        if (dateFilterApplied) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
        }

        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            totalOrders = rs.getInt("total_orders");
            totalSales = rs.getDouble("total_sales");
        }

        rs.close();
        ps.close();

        if (totalOrders > 0) {
            averageOrderValue = totalSales / totalOrders;
        }

        String statusSql =
            "SELECT order_status, COUNT(*) AS total FROM orders " +
            dateWhere +
            "GROUP BY order_status";

        ps = conn.prepareStatement(statusSql);

        if (dateFilterApplied) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
        }

        rs = ps.executeQuery();

        while (rs.next()) {
            String status = rs.getString("order_status");
            int count = rs.getInt("total");

            if ("PENDING".equalsIgnoreCase(status)) {
                pending = count;
            } else if ("CONFIRMED".equalsIgnoreCase(status)) {
                confirmed = count;
            } else if ("PROCESSING".equalsIgnoreCase(status)) {
                processing = count;
            } else if ("OUT_FOR_DELIVERY".equalsIgnoreCase(status)) {
                outForDelivery = count;
            } else if ("DELIVERED".equalsIgnoreCase(status)) {
                delivered = count;
            } else if ("CANCELLED".equalsIgnoreCase(status)) {
                cancelled = count;
            } else if ("SHIPPED".equalsIgnoreCase(status)) {
                outForDelivery = count;
            }
        }

        rs.close();
        ps.close();

        try {
            String paymentSql =
                "SELECT payment_status, COUNT(*) AS total FROM payments GROUP BY payment_status";

            ps = conn.prepareStatement(paymentSql);
            rs = ps.executeQuery();

            while (rs.next()) {
                String paymentStatus = rs.getString("payment_status");
                int count = rs.getInt("total");

                if ("PAID".equalsIgnoreCase(paymentStatus) || "COMPLETED".equalsIgnoreCase(paymentStatus)) {
                    paidPayments += count;
                } else if ("FAILED".equalsIgnoreCase(paymentStatus)) {
                    failedPayments += count;
                } else {
                    pendingPayments += count;
                }
            }

            rs.close();
            ps.close();

        } catch (Exception e) {
            pendingPayments = totalOrders;
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    int maxStatusValue = Math.max(1, Math.max(
        Math.max(pending, confirmed),
        Math.max(Math.max(processing, outForDelivery), Math.max(delivered, cancelled))
    ));

    int paidPercent = totalOrders > 0 ? (paidPayments * 100 / Math.max(totalOrders, 1)) : 0;
    int deliveredPercent = totalOrders > 0 ? (delivered * 100 / totalOrders) : 0;

    if (paidPercent > 100) {
        paidPercent = 100;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Sales Reports - Egerton AgriBridge Hub</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- CSS order matters -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/base.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/components.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/sales-report.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/responsive.css?v=1">
</head>

<body class="sales-report-body">

<div class="sales-admin-shell">

    <!-- SIDEBAR -->
    <aside class="sales-admin-sidebar no-print">
        <div class="sales-admin-brand">
            <div class="sales-admin-brand-mark">🌿</div>
            <div>
                <h2>AgriBridge</h2>
                <p>Admin Portal</p>
            </div>
        </div>

        <nav class="sales-admin-menu">
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

            <a href="manageOrders.jsp">
                <span>▤</span>
                Orders
            </a>

            <a href="salesReport.jsp" class="active">
                <span>▥</span>
                Reports
            </a>

            <a href="products.jsp">
                <span>🛒</span>
                Marketplace
            </a>
        </nav>

        <div class="sales-admin-sidebar-promo">
            <h3>Reports Center</h3>
            <p>Analyze revenue, order performance, payments, and product contribution.</p>
            <a href="salesReport.jsp">Refresh Report</a>
        </div>

        <div class="sales-admin-sidebar-bottom">
            <a href="logout" onclick="return confirm('Are you sure you want to logout?');">
                ⎋ Logout
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="sales-admin-main">

        <!-- MOBILE TOP BAR -->
        <header class="sales-mobile-topbar no-print">
            <a href="adminDashboard.jsp" aria-label="Dashboard">☰</a>
            <strong>Reports</strong>
            <div>
                <a href="manageOrders.jsp" aria-label="Orders">📦</a>
                <a href="manageProducts.jsp" aria-label="Products">▣</a>
            </div>
        </header>

        <!-- DESKTOP TOP BAR -->
        <header class="sales-admin-topbar no-print">
            <div>
                <h1>Sales Analytics</h1>
                <p>Track revenue, order performance, payments, and product sales.</p>
            </div>

            <div class="sales-admin-top-actions">
                <form action="manageOrders.jsp" method="get" class="sales-admin-search">
                    <span>⌕</span>
                    <input type="text" name="search" placeholder="Search transactions...">
                </form>

                <a href="manageOrders.jsp"
                   class="sales-admin-icon-btn"
                   title="Orders">
                    🔔
                </a>

                <a href="adminDashboard.jsp"
                   class="sales-admin-profile"
                   title="Admin Dashboard">
                    👨‍💼
                </a>
            </div>
        </header>

        <div class="sales-admin-content" id="salesReportArea">

            <!-- HERO -->
            <section class="sales-hero-card">
                <div>
                    <p class="sales-eyebrow">FINANCIAL REPORTING</p>
                    <h2>Sales Reports</h2>
                    <p>
                        Analyze revenue, product performance, order status, and customer payment progress.
                    </p>

                    <% if (hasStartDate && hasEndDate && dateError == null) { %>
                        <p class="sales-date-range">
                            Report period: <strong><%= startDate %></strong> to <strong><%= endDate %></strong>
                        </p>
                    <% } else { %>
                        <p class="sales-date-range">
                            Report period: <strong>All-time</strong>
                        </p>
                    <% } %>

                    <div class="sales-hero-actions no-print">
                        <a href="manageOrders.jsp">View Orders</a>
                        <a href="manageProducts.jsp">View Inventory</a>
                    </div>
                </div>

                <div class="sales-hero-summary">
                    <span>Total Revenue</span>
                    <strong>KES <%= String.format("%,.2f", totalSales) %></strong>
                    <small><%= totalOrders %> recorded orders</small>
                </div>
            </section>

            <% if (dateError != null) { %>
                <div class="sales-error">
                    <%= dateError %>
                </div>
            <% } %>

            <!-- FILTERS -->
            <section class="sales-filter-card no-print">
                <form method="get" action="salesReport.jsp" class="sales-filter-form" onsubmit="return validateSalesDates();">
                    <div>
                        <label>Start Date</label>
                        <input type="date"
                               id="startDate"
                               name="startDate"
                               max="<%= java.time.LocalDate.now() %>"
                               value="<%= hasStartDate ? startDate : "" %>">
                    </div>

                    <div>
                        <label>End Date</label>
                        <input type="date"
                               id="endDate"
                               name="endDate"
                               max="<%= java.time.LocalDate.now() %>"
                               value="<%= hasEndDate ? endDate : "" %>">
                    </div>

                    <div>
                        <label>Category</label>
                        <select name="category">
                            <option value="">All Products</option>
                        </select>
                    </div>

                    <div class="sales-filter-actions">
                        <button type="submit">Apply Filters</button>
                        <a href="salesReport.jsp">Clear</a>
                    </div>
                </form>
            </section>

            <!-- EXPORT BUTTONS -->
            <div class="sales-export-actions no-print">
                <button type="button" class="sales-report-btn" onclick="downloadPDFReport()">
                    ▣ PDF Report
                </button>

                <button type="button" class="sales-excel-btn" onclick="exportSalesTableToCSV()">
                    ▤ Export Excel
                </button>
            </div>

            <!-- STATS -->
            <section class="sales-stat-grid">

                <div class="sales-stat-card">
                    <div class="sales-stat-icon green">💵</div>
                    <span>Total Revenue</span>
                    <h2>KES <%= String.format("%,.2f", totalSales) %></h2>
                    <small>Revenue from recorded orders</small>
                </div>

                <div class="sales-stat-card">
                    <div class="sales-stat-icon gold">🧺</div>
                    <span>Total Orders</span>
                    <h2><%= totalOrders %></h2>
                    <small>All placed customer orders</small>
                </div>

                <div class="sales-stat-card">
                    <div class="sales-stat-icon red">▥</div>
                    <span>Average Order Value</span>
                    <h2>KES <%= String.format("%,.2f", averageOrderValue) %></h2>
                    <small>Sales divided by orders</small>
                </div>

                <div class="sales-stat-card dark">
                    <div class="sales-stat-icon dark-icon">↗</div>
                    <span>Delivered Rate</span>
                    <h2><%= deliveredPercent %>%</h2>
                    <small>Completed delivery performance</small>
                </div>

            </section>

            <!-- CHARTS -->
            <section class="sales-chart-grid">

                <div class="sales-chart-card">
                    <div class="sales-card-header">
                        <div>
                            <h2>Order Status Performance</h2>
                            <p>
                                <% if (hasStartDate && hasEndDate && dateError == null) { %>
                                    <%= startDate %> to <%= endDate %>
                                <% } else { %>
                                    All-time order status distribution
                                <% } %>
                            </p>
                        </div>

                        <span>STATUS</span>
                    </div>

                    <div class="sales-bar-chart">
                        <div>
                            <span style="height:<%= (pending * 100 / maxStatusValue) %>%"></span>
                            <small>Pending</small>
                        </div>

                        <div>
                            <span style="height:<%= (confirmed * 100 / maxStatusValue) %>%"></span>
                            <small>Confirmed</small>
                        </div>

                        <div>
                            <span style="height:<%= (processing * 100 / maxStatusValue) %>%"></span>
                            <small>Processing</small>
                        </div>

                        <div>
                            <span style="height:<%= (outForDelivery * 100 / maxStatusValue) %>%"></span>
                            <small>Transit</small>
                        </div>

                        <div>
                            <span class="green" style="height:<%= (delivered * 100 / maxStatusValue) %>%"></span>
                            <small>Delivered</small>
                        </div>

                        <div>
                            <span class="red" style="height:<%= (cancelled * 100 / maxStatusValue) %>%"></span>
                            <small>Cancelled</small>
                        </div>
                    </div>
                </div>

                <div class="sales-split-card">
                    <h2>Payment Split</h2>
                    <p>Payment completion summary</p>

                    <div class="sales-donut"
                         style="background: conic-gradient(#004d22 0 <%= paidPercent %>%, #ffb020 <%= paidPercent %>% 85%, #b91c1c 85% 100%);">
                        <div>
                            <strong><%= paidPercent %>%</strong>
                            <span>PAID</span>
                        </div>
                    </div>

                    <div class="sales-split-list">
                        <p><span><i class="dot green"></i> Paid / Completed</span> <strong><%= paidPayments %></strong></p>
                        <p><span><i class="dot gold"></i> Pending</span> <strong><%= pendingPayments %></strong></p>
                        <p><span><i class="dot red"></i> Failed</span> <strong><%= failedPayments %></strong></p>
                    </div>
                </div>

            </section>

            <!-- PRODUCT SALES BREAKDOWN -->
            <section class="sales-breakdown-card">

                <div class="sales-card-header">
                    <div>
                        <h2>Product Sales Breakdown</h2>
                        <p>Units sold and revenue generated per product.</p>
                    </div>

                    <a href="manageProducts.jsp" class="no-print">View Full Inventory ›</a>
                </div>

                <div class="sales-table" id="salesTable">

                    <div class="sales-table-head">
                        <span>Product Name</span>
                        <span>Units Sold</span>
                        <span>Revenue Generated</span>
                        <span>Performance</span>
                        <span>Status</span>
                    </div>

                    <%
                        PreparedStatement productPs = null;
                        ResultSet productRs = null;
                        boolean hasProductRows = false;

                        try {
                            if (conn == null || conn.isClosed()) {
                                conn = DBConnection.getConnection();
                            }

                            String productSql =
                                "SELECT p.product_name, p.image_url, " +
                                "COALESCE(SUM(oi.quantity), 0) AS units_sold, " +
                                "COALESCE(SUM(oi.quantity * oi.price), 0) AS revenue " +
                                "FROM products p " +
                                "LEFT JOIN order_items oi ON p.product_id = oi.product_id " +
                                "GROUP BY p.product_id, p.product_name, p.image_url " +
                                "ORDER BY revenue DESC " +
                                "LIMIT 8";

                            productPs = conn.prepareStatement(productSql);
                            productRs = productPs.executeQuery();

                            while (productRs.next()) {
                                hasProductRows = true;

                                String productName = productRs.getString("product_name");
                                String imageUrl = productRs.getString("image_url");
                                int unitsSold = productRs.getInt("units_sold");
                                double revenue = productRs.getDouble("revenue");

                                int performance = totalSales > 0 ? (int)((revenue / totalSales) * 100) : 0;

                                if (performance > 100) {
                                    performance = 100;
                                }

                                String statusLabel = "Steady";
                                String statusClass = "steady";

                                if (performance >= 40) {
                                    statusLabel = "High Performance";
                                    statusClass = "high";
                                } else if (performance >= 20) {
                                    statusLabel = "Top Margin";
                                    statusClass = "top";
                                }
                    %>

                        <div class="sales-table-row">
                            <span class="sales-product-cell">
                                <% if (imageUrl != null && !imageUrl.trim().isEmpty()) { %>
                                    <img src="<%= request.getContextPath() + "/" + imageUrl %>" alt="<%= productName %>">
                                <% } else { %>
                                    <em>No Image</em>
                                <% } %>

                                <strong><%= productName %></strong>
                            </span>

                            <span><%= unitsSold %></span>

                            <span>KES <%= String.format("%,.2f", revenue) %></span>

                            <span>
                                <div class="sales-mini-progress">
                                    <i style="width:<%= performance %>%"></i>
                                </div>
                                <%= performance %>%
                            </span>

                            <span>
                                <mark class="<%= statusClass %>"><%= statusLabel %></mark>
                            </span>
                        </div>

                    <%
                            }

                        } catch (Exception e) {
                            e.printStackTrace();
                    %>

                        <div class="sales-empty-row">Could not load product breakdown.</div>

                    <%
                        } finally {
                            if (productRs != null) try { productRs.close(); } catch (Exception e) {}
                            if (productPs != null) try { productPs.close(); } catch (Exception e) {}
                        }

                        if (!hasProductRows) {
                    %>

                        <div class="sales-empty-row">No product sales data available.</div>

                    <%
                        }
                    %>

                </div>

            </section>

        </div>

    </main>

</div>

<!-- MOBILE BOTTOM NAV -->
<nav class="sales-admin-bottom-nav no-print">
    <a href="adminDashboard.jsp">
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

    <a href="salesReport.jsp" class="active">
        <span>▥</span>
        Reports
    </a>
</nav>

<%
    if (conn != null) {
        try { conn.close(); } catch (Exception e) {}
    }
%>

<script>
    const startDateInput = document.getElementById("startDate");
    const endDateInput = document.getElementById("endDate");

    if (startDateInput && endDateInput) {
        startDateInput.addEventListener("change", function () {
            endDateInput.min = startDateInput.value;

            if (endDateInput.value && endDateInput.value < startDateInput.value) {
                endDateInput.value = "";
            }
        });

        endDateInput.addEventListener("change", function () {
            if (startDateInput.value && endDateInput.value < startDateInput.value) {
                alert("End date cannot be earlier than start date.");
                endDateInput.value = "";
            }
        });
    }

    function validateSalesDates() {
        const start = startDateInput.value;
        const end = endDateInput.value;

        if ((start && !end) || (!start && end)) {
            alert("Please select both start date and end date.");
            return false;
        }

        if (start && end && start > end) {
            alert("Start date cannot be after end date.");
            return false;
        }

        return true;
    }

    function downloadPDFReport() {
        window.print();
    }

    function exportSalesTableToCSV() {
        const rows = document.querySelectorAll(".sales-table-head, .sales-table-row");

        if (!rows || rows.length === 0) {
            alert("No sales data available to export.");
            return;
        }

        let csv = [];

        rows.forEach(row => {
            const cols = row.querySelectorAll("span");
            let rowData = [];

            cols.forEach(col => {
                let text = col.innerText.replace(/\s+/g, " ").trim();
                text = text.replace(/"/g, '""');
                rowData.push('"' + text + '"');
            });

            csv.push(rowData.join(","));
        });

        const csvContent = csv.join("\n");
        const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });

        const link = document.createElement("a");
        const url = URL.createObjectURL(blob);

        let fileName = "sales_report";

        if (startDateInput && endDateInput && startDateInput.value && endDateInput.value) {
            fileName += "_" + startDateInput.value + "_to_" + endDateInput.value;
        }

        link.setAttribute("href", url);
        link.setAttribute("download", fileName + ".csv");
        link.style.display = "none";

        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }
</script>

</body>
</html>
