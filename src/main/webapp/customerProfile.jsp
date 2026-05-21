<%@ page import="java.util.*, com.agribridgef1.dao.*, com.agribridgef1.model.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    if (session.getAttribute("userType") == null ||
        !"ADMIN".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    String idParam = request.getParameter("id");

    if (idParam == null || idParam.isEmpty()) {
        response.sendRedirect("customers.jsp");
        return;
    }

    int customerId = Integer.parseInt(idParam);

    UserDAO userDAO = new UserDAO();
    OrderDAO orderDAO = new OrderDAO();
    PaymentDAO paymentDAO = new PaymentDAO();

    User customer = userDAO.getUserById(customerId);

    if (customer == null) {
        response.sendRedirect("customers.jsp");
        return;
    }

    List<Order> orders = orderDAO.getOrdersByUser(customerId);

    double totalSpent = 0;
    int paidOrders = 0;

    for (Order o : orders) {
        String paymentStatus = paymentDAO.getPaymentStatusByOrderId(o.getOrderId());

        if ("PAID".equals(paymentStatus)) {
            totalSpent += o.getTotalAmount();
            paidOrders++;
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Customer Profile - AgribridgeF1</title>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>

<div class="navbar">
    <div class="logo">Agribridge Admin</div>
    <div>
        <a href="adminDashboard.jsp">Dashboard</a>
        <a href="customers.jsp">Customers</a>
        <a href="manageOrders.jsp">Orders</a>
        <a href="salesReport.jsp">Reports</a>
        <a href="logout">Logout</a>
    </div>
</div>

<div class="container">

    <div class="card">
        <h2><%= customer.getFullName() %></h2>
        <br>

        <p><strong>Customer ID:</strong> #<%= customer.getUserId() %></p>
        <p><strong>Email:</strong> <%= customer.getEmail() %></p>
        <p><strong>Phone:</strong> <%= customer.getPhone() %></p>
        <p><strong>User Type:</strong> <%= customer.getUserType() %></p>
    </div>

    <br>

    <div class="grid">
        <div class="stat-card">
            <h3><%= orders.size() %></h3>
            <p>Total Orders</p>
        </div>

        <div class="stat-card">
            <h3><%= paidOrders %></h3>
            <p>Paid Orders</p>
        </div>

        <div class="stat-card">
            <h3>KES <%= totalSpent %></h3>
            <p>Total Spent</p>
        </div>
    </div>

    <br><br>

    <div class="card">
        <h2>Order History</h2>
        <br>

        <%
            if (orders.isEmpty()) {
        %>
            <p>This customer has not placed any orders yet.</p>
        <%
            } else {
        %>

        <table>
            <tr>
                <th>Order</th>
                <th>Order Status</th>
                <th>Payment Status</th>
                <th>Delivery Time</th>
                <th>Total</th>
            </tr>

            <%
                for (Order o : orders) {
                    String paymentStatus = paymentDAO.getPaymentStatusByOrderId(o.getOrderId());
            %>
            <tr>
                <td>#<%= o.getOrderId() %></td>
                <td><span class="alert-badge"><%= o.getOrderStatus() %></span></td>
                <td>
                    <%
                        if ("PAID".equals(paymentStatus)) {
                    %>
                        <span style="color:green; font-weight:bold;">PAID</span>
                    <%
                        } else if ("FAILED".equals(paymentStatus)) {
                    %>
                        <span style="color:red; font-weight:bold;">FAILED</span>
                    <%
                        } else {
                    %>
                        <span class="alert-badge"><%= paymentStatus %></span>
                    <%
                        }
                    %>
                </td>
                <td><%= o.getDeliveryTime() %></td>
                <td>KES <%= o.getTotalAmount() %></td>
            </tr>
            <%
                }
            %>
        </table>

        <%
            }
        %>
    </div>

    <br>

    <a class="btn btn-secondary" href="customers.jsp">Back to Customers</a>

</div>

</body>
</html>