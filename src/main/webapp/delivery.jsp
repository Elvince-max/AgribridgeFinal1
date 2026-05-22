<%@ page import="java.util.*, java.sql.*, com.agribridgef1.dao.OrderDAO, com.agribridgef1.model.Order, com.agribridgef1.util.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userType = (String) session.getAttribute("userType");

    if (!"DELIVERY_AGENT".equals(userType)) {
        response.sendRedirect("login.jsp");
        return;
    }

    int agentId = (int) session.getAttribute("userId");

    OrderDAO dao = new OrderDAO();
    List<Order> deliveries = dao.getDeliveriesByAgent(agentId);

    int assignedCount = 0;
    int transitCount = 0;
    int deliveredCount = 0;
    int failedCount = 0;

    for (Order o : deliveries) {
        String s = o.getOrderStatus();

        if (s == null || s.trim().isEmpty()) {
            s = "ASSIGNED";
        }

        if ("DELIVERED".equalsIgnoreCase(s)) {
            deliveredCount++;
        } else if ("IN_TRANSIT".equalsIgnoreCase(s) || "PICKED_UP".equalsIgnoreCase(s)) {
            transitCount++;
        } else if ("FAILED".equalsIgnoreCase(s)) {
            failedCount++;
        } else {
            assignedCount++;
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>My Deliveries - Egerton AgriBridge Hub</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- CSS order matters -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/base.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/components.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/delivery.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/responsive.css?v=1">
</head>

<body class="agent-deliveries-body">

<div class="agent-shell">

    <!-- SIDEBAR -->
    <aside class="agent-sidebar">
        <div class="agent-brand">
            <div class="agent-brand-mark">🚚</div>
            <div>
                <h2>AgriBridge</h2>
                <p>Delivery Portal</p>
            </div>
        </div>

        <nav class="agent-menu">
            <a href="myDeliveries.jsp" class="active">
                <span>▤</span>
                My Deliveries
            </a>

            <a href="products.jsp">
                <span>🛒</span>
                Marketplace
            </a>

            <a href="customerDashboard.jsp">
                <span>⌂</span>
                Home
            </a>
        </nav>

        <div class="agent-sidebar-promo">
            <h3>Delivery Workbench</h3>
            <p>Track assigned orders, update progress, and view customer fulfilment details.</p>
            <a href="myDeliveries.jsp">Refresh Deliveries</a>
        </div>

        <div class="agent-sidebar-bottom">
            <a href="logout" onclick="return confirm('Are you sure you want to logout?');">
                ⎋ Logout
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="agent-main">

        <!-- MOBILE TOP BAR -->
        <header class="agent-mobile-topbar">
            <a href="products.jsp" aria-label="Marketplace">←</a>
            <strong>Deliveries</strong>
            <div>
                <a href="myDeliveries.jsp" aria-label="Refresh">⟳</a>
                <a href="logout" aria-label="Logout">🚚</a>
            </div>
        </header>

        <!-- DESKTOP TOP BAR -->
        <header class="agent-topbar">
            <div>
                <h1>My Deliveries</h1>
                <p><%= deliveries.size() %> assigned delivery order(s)</p>
            </div>

            <div class="agent-top-actions">
                <a href="myDeliveries.jsp" class="agent-top-btn">Refresh</a>
                <a href="products.jsp" class="agent-icon-btn" title="Marketplace">🛒</a>
                <a href="logout" class="agent-profile" title="Logout">🚚</a>
            </div>
        </header>

        <div class="agent-content">

            <!-- HERO -->
            <section class="agent-hero-card">
                <div>
                    <p class="agent-eyebrow">DELIVERY AGENT</p>
                    <h2>Assigned Deliveries</h2>
                    <p>
                        View customer destinations, order contents, delivery progress, and update order movement.
                    </p>

                    <div class="agent-hero-actions">
                        <a href="myDeliveries.jsp">Refresh List</a>
                        <a href="products.jsp">Open Marketplace</a>
                    </div>
                </div>

                <div class="agent-hero-summary">
                    <span>Assigned Orders</span>
                    <strong><%= deliveries.size() %></strong>
                    <small><%= deliveredCount %> delivered</small>
                </div>
            </section>

            <% if ("updated".equals(request.getParameter("status"))) { %>
                <div class="agent-success">
                    Delivery status updated successfully.
                </div>
            <% } else if ("error".equals(request.getParameter("status"))) { %>
                <div class="agent-error">
                    Could not update delivery status. Please try again.
                </div>
            <% } %>

            <!-- STATS -->
            <section class="agent-stats-grid">
                <div class="agent-stat-card">
                    <div>📦</div>
                    <span>Assigned</span>
                    <h3><%= assignedCount %></h3>
                </div>

                <div class="agent-stat-card warning">
                    <div>🚚</div>
                    <span>In Transit</span>
                    <h3><%= transitCount %></h3>
                </div>

                <div class="agent-stat-card">
                    <div>✅</div>
                    <span>Delivered</span>
                    <h3><%= deliveredCount %></h3>
                </div>

                <div class="agent-stat-card danger">
                    <div>⚠️</div>
                    <span>Failed</span>
                    <h3><%= failedCount %></h3>
                </div>
            </section>

            <% if (deliveries.isEmpty()) { %>

                <div class="agent-empty-state">
                    <div>📦</div>
                    <h2>No deliveries assigned</h2>
                    <p>Your assigned customer deliveries will appear here.</p>
                    <a href="myDeliveries.jsp">Refresh</a>
                </div>

            <% } else { %>

                <section class="agent-delivery-list">

                    <%
                        for (Order o : deliveries) {
                            String currentStatus = o.getOrderStatus();

                            if (currentStatus == null || currentStatus.trim().isEmpty()) {
                                currentStatus = "ASSIGNED";
                            }

                            String statusLabel = currentStatus.replace("_", " ");
                            String statusClass = currentStatus.toLowerCase().replace("_", "-");

                            String deliveryAddress = o.getDeliveryAddress();

                            if (deliveryAddress == null || deliveryAddress.trim().isEmpty()) {
                                deliveryAddress = "Location not provided";
                            }

                            String deliveryTime = o.getDeliveryTime();

                            if (deliveryTime == null || deliveryTime.trim().isEmpty()) {
                                deliveryTime = "Time not specified";
                            }

                            boolean assignedDone =
                                    "ASSIGNED".equalsIgnoreCase(currentStatus) ||
                                    "PICKED_UP".equalsIgnoreCase(currentStatus) ||
                                    "IN_TRANSIT".equalsIgnoreCase(currentStatus) ||
                                    "DELIVERED".equalsIgnoreCase(currentStatus);

                            boolean pickedDone =
                                    "PICKED_UP".equalsIgnoreCase(currentStatus) ||
                                    "IN_TRANSIT".equalsIgnoreCase(currentStatus) ||
                                    "DELIVERED".equalsIgnoreCase(currentStatus);

                            boolean transitDone =
                                    "IN_TRANSIT".equalsIgnoreCase(currentStatus) ||
                                    "DELIVERED".equalsIgnoreCase(currentStatus);

                            boolean deliveredDone =
                                    "DELIVERED".equalsIgnoreCase(currentStatus);
                    %>

                    <article class="agent-delivery-card">

                        <div class="agent-delivery-header">
                            <div>
                                <p class="agent-small-label">ORDER #<%= o.getOrderId() %></p>
                                <h2>Customer Delivery</h2>
                                <p>Customer ID: <strong><%= o.getUserId() %></strong></p>
                            </div>

                            <span class="agent-status-pill <%= statusClass %>">
                                <%= statusLabel %>
                            </span>
                        </div>

                        <div class="agent-delivery-main">
                            <div class="agent-info-item">
                                <span>Customer</span>
                                <strong>ID: <%= o.getUserId() %></strong>
                            </div>

                            <div class="agent-info-item">
                                <span>Total</span>
                                <strong>KES <%= String.format("%.2f", o.getTotalAmount()) %></strong>
                            </div>

                            <div class="agent-info-item wide">
                                <span>Address / Pickup Point</span>
                                <strong><%= deliveryAddress %></strong>
                            </div>

                            <div class="agent-info-item">
                                <span>Preferred Time</span>
                                <strong><%= deliveryTime %></strong>
                            </div>
                        </div>

                        <div class="agent-status-track">
                            <div class="<%= assignedDone ? "done" : "" %>">
                                <span>1</span>
                                <p>Assigned</p>
                            </div>

                            <div class="<%= pickedDone ? "done" : "" %>">
                                <span>2</span>
                                <p>Picked</p>
                            </div>

                            <div class="<%= transitDone ? "done" : "" %>">
                                <span>3</span>
                                <p>Transit</p>
                            </div>

                            <div class="<%= deliveredDone ? "done" : "" %>">
                                <span>4</span>
                                <p>Delivered</p>
                            </div>
                        </div>

                        <form action="updateDeliveryStatus" method="post" class="agent-delivery-form">
                            <input type="hidden" name="orderId" value="<%= o.getOrderId() %>">

                            <div>
                                <label>Update Delivery Status</label>
                                <select name="deliveryStatus" required>
                                    <option value="ASSIGNED" <%= "ASSIGNED".equals(currentStatus) ? "selected" : "" %>>ASSIGNED</option>
                                    <option value="PICKED_UP" <%= "PICKED_UP".equals(currentStatus) ? "selected" : "" %>>PICKED UP</option>
                                    <option value="IN_TRANSIT" <%= "IN_TRANSIT".equals(currentStatus) ? "selected" : "" %>>IN TRANSIT</option>
                                    <option value="DELIVERED" <%= "DELIVERED".equals(currentStatus) ? "selected" : "" %>>DELIVERED</option>
                                    <option value="FAILED" <%= "FAILED".equals(currentStatus) ? "selected" : "" %>>FAILED</option>
                                </select>
                            </div>

                            <button type="submit">Update</button>
                        </form>

                        <details class="agent-delivery-details">
                            <summary>View customer details and order contents</summary>

                            <div class="agent-customer-box">
                                <p class="agent-small-label">CUSTOMER DETAILS</p>

                                <div class="agent-customer-grid">
                                    <div>
                                        <span>Customer ID</span>
                                        <strong><%= o.getUserId() %></strong>
                                    </div>

                                    <div>
                                        <span>Preferred Time</span>
                                        <strong><%= deliveryTime %></strong>
                                    </div>

                                    <div>
                                        <span>Total Amount</span>
                                        <strong>KES <%= String.format("%.2f", o.getTotalAmount()) %></strong>
                                    </div>

                                    <div>
                                        <span>Status</span>
                                        <strong><%= statusLabel %></strong>
                                    </div>

                                    <div class="full">
                                        <span>Address / Pickup Point</span>
                                        <strong><%= deliveryAddress %></strong>
                                    </div>
                                </div>

                                <div class="agent-contact-actions">
                                    <a href="#">📞 Call Customer</a>
                                    <a href="#">💬 Message Customer</a>
                                </div>
                            </div>

                            <div class="agent-items-list">
                                <p class="agent-small-label">ORDER CONTENTS</p>

                                <%
                                    Connection conn = null;
                                    PreparedStatement ps = null;
                                    ResultSet rs = null;
                                    boolean hasItems = false;

                                    try {
                                        conn = DBConnection.getConnection();

                                        String itemSql =
                                            "SELECT oi.quantity, oi.price, p.product_name, p.description, p.image_url " +
                                            "FROM order_items oi " +
                                            "JOIN products p ON oi.product_id = p.product_id " +
                                            "WHERE oi.order_id = ?";

                                        ps = conn.prepareStatement(itemSql);
                                        ps.setInt(1, o.getOrderId());

                                        rs = ps.executeQuery();

                                        while (rs.next()) {
                                            hasItems = true;

                                            String productName = rs.getString("product_name");
                                            String description = rs.getString("description");
                                            String imageUrl = rs.getString("image_url");
                                            int quantity = rs.getInt("quantity");
                                            double price = rs.getDouble("price");
                                            double itemSubtotal = quantity * price;
                                %>

                                    <div class="agent-delivery-item">
                                        <% if (imageUrl != null && !imageUrl.trim().isEmpty()) { %>
                                            <img src="<%= request.getContextPath() + "/" + imageUrl %>"
                                                 alt="<%= productName %>">
                                        <% } else { %>
                                            <div class="agent-item-placeholder">No Image</div>
                                        <% } %>

                                        <div>
                                            <h3><%= productName %></h3>
                                            <p>
                                                <%= quantity %> item(s)
                                                <% if (description != null && !description.trim().isEmpty()) { %>
                                                    • <%= description %>
                                                <% } %>
                                            </p>
                                        </div>

                                        <strong>KES <%= String.format("%.2f", itemSubtotal) %></strong>
                                    </div>

                                <%
                                        }

                                    } catch (Exception e) {
                                        e.printStackTrace();
                                %>

                                    <div class="agent-mini-error">
                                        Could not load order items.
                                    </div>

                                <%
                                    } finally {
                                        if (rs != null) try { rs.close(); } catch (Exception e) {}
                                        if (ps != null) try { ps.close(); } catch (Exception e) {}
                                        if (conn != null) try { conn.close(); } catch (Exception e) {}
                                    }

                                    if (!hasItems) {
                                %>

                                    <div class="agent-mini-empty">
                                        No order items found.
                                    </div>

                                <%
                                    }
                                %>

                            </div>
                        </details>

                    </article>

                    <%
                        }
                    %>

                </section>

            <% } %>

        </div>

    </main>

</div>

<!-- MOBILE BOTTOM NAV -->
<nav class="agent-bottom-nav">
    <a href="myDeliveries.jsp" class="active">
        <span>🚚</span>
        Deliveries
    </a>

    <a href="products.jsp">
        <span>🛒</span>
        Shop
    </a>

    <a href="myDeliveries.jsp">
        <span>⟳</span>
        Refresh
    </a>

    <a href="logout">
        <span>⎋</span>
        Logout
    </a>
</nav>

</body>
</html>
