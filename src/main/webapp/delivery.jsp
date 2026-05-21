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
%>

<!DOCTYPE html>
<html>
<head>
    <title>My Deliveries - Egerton AgriBridge Hub</title>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
</head>

<body class="delivery-body compact-delivery-body">

<div class="delivery-shell compact-delivery-shell">

    <!-- TOP BAR -->
    <div class="delivery-topbar compact-delivery-topbar">
        <a href="products.jsp" class="delivery-back">←</a>

        <div>
            <h2>AgriBridge Deliveries</h2>
            <p><%= deliveries.size() %> assigned delivery order(s)</p>
        </div>

        <a href="logout" class="delivery-avatar" title="Logout">
            🚚
        </a>
    </div>

    <% if ("updated".equals(request.getParameter("status"))) { %>
        <div class="delivery-success">
            Delivery status updated successfully.
        </div>
    <% } else if ("error".equals(request.getParameter("status"))) { %>
        <div class="delivery-error">
            Could not update delivery status. Please try again.
        </div>
    <% } %>

    <% if (deliveries.isEmpty()) { %>

        <div class="delivery-empty">
            <div>📦</div>
            <h2>No deliveries assigned</h2>
            <p>Your assigned customer deliveries will appear here.</p>
        </div>

    <% } else { %>

        <div class="compact-delivery-list">

            <%
                for (Order o : deliveries) {
                    String currentStatus = o.getOrderStatus();

                    if (currentStatus == null || currentStatus.trim().isEmpty()) {
                        currentStatus = "ASSIGNED";
                    }

                    String statusLabel = currentStatus.replace("_", " ");
                    String statusClass = currentStatus.toLowerCase();

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

            <div class="compact-delivery-card">

                <!-- COMPACT HEADER -->
                <div class="compact-delivery-header">
                    <div>
                        <p class="delivery-eyebrow">ORDER #<%= o.getOrderId() %></p>
                        <h2>Customer Delivery</h2>
                    </div>

                    <span class="compact-status-pill <%= statusClass %>">
                        <%= statusLabel %>
                    </span>
                </div>

                <!-- QUICK SUMMARY -->
                <div class="compact-delivery-main">
                    <div class="compact-info-item">
                        <span>Customer</span>
                        <strong>ID: <%= o.getUserId() %></strong>
                    </div>

                    <div class="compact-info-item">
                        <span>Total</span>
                        <strong>KES <%= String.format("%.2f", o.getTotalAmount()) %></strong>
                    </div>

                    <div class="compact-info-item wide">
                        <span>Address / Pickup Point</span>
                        <strong><%= deliveryAddress %></strong>
                    </div>

                    <div class="compact-info-item">
                        <span>Preferred Time</span>
                        <strong><%= deliveryTime %></strong>
                    </div>
                </div>

                <!-- MINI STATUS TRACK -->
                <div class="compact-status-track">
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

                <!-- STATUS UPDATE -->
                <form action="updateDeliveryStatus" method="post" class="compact-delivery-form">
                    <input type="hidden" name="orderId" value="<%= o.getOrderId() %>">

                    <select name="deliveryStatus" required>
                        <option value="ASSIGNED" <%= "ASSIGNED".equals(currentStatus) ? "selected" : "" %>>ASSIGNED</option>
                        <option value="PICKED_UP" <%= "PICKED_UP".equals(currentStatus) ? "selected" : "" %>>PICKED UP</option>
                        <option value="IN_TRANSIT" <%= "IN_TRANSIT".equals(currentStatus) ? "selected" : "" %>>IN TRANSIT</option>
                        <option value="DELIVERED" <%= "DELIVERED".equals(currentStatus) ? "selected" : "" %>>DELIVERED</option>
                        <option value="FAILED" <%= "FAILED".equals(currentStatus) ? "selected" : "" %>>FAILED</option>
                    </select>

                    <button type="submit">Update</button>
                </form>

                <!-- EXPANDABLE CUSTOMER DETAILS + ITEMS -->
                <details class="compact-delivery-details">
                    <summary>View customer details and order contents</summary>

                    <!-- CUSTOMER DETAILS -->
                    <div class="compact-customer-box">
                        <p class="delivery-eyebrow">CUSTOMER DETAILS</p>

                        <div class="compact-customer-grid">
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

                        <div class="compact-contact-actions">
                            <a href="#" class="delivery-contact-btn">📞 Call Customer</a>
                            <a href="#" class="delivery-contact-btn">💬 Message Customer</a>
                        </div>
                    </div>

                    <!-- ORDER CONTENTS -->
                    <div class="compact-items-list">
                        <p class="delivery-eyebrow">ORDER CONTENTS</p>

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

                            <div class="compact-delivery-item">
                                <% if (imageUrl != null && !imageUrl.trim().isEmpty()) { %>
                                    <img src="<%= request.getContextPath() + "/" + imageUrl %>"
                                         alt="<%= productName %>">
                                <% } else { %>
                                    <div class="delivery-item-placeholder">No Image</div>
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

                            <div class="delivery-mini-error">
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

                            <div class="delivery-mini-empty">
                                No order items found.
                            </div>

                        <%
                            }
                        %>

                    </div>
                </details>

            </div>

            <%
                }
            %>

        </div>

    <% } %>

</div>

</body>
</html>