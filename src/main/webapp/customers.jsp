<%@ page import="java.util.*, com.agribridgef1.dao.UserDAO, com.agribridgef1.model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    if (session.getAttribute("userType") == null ||
        !"ADMIN".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    UserDAO userDAO = new UserDAO();
    List<User> customers = userDAO.getAllCustomers();
%>

<!DOCTYPE html>
<html>
<head>
    <title>Customers - AgribridgeF1</title>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>

<div class="navbar">
    <div class="logo">AgribridgeF1 Admin</div>
    <div>
        <a href="adminDashboard.jsp">Dashboard</a>
        <a href="manageProducts.jsp">Products</a>
        <a href="manageOrders.jsp">Orders</a>
        <a href="customers.jsp">Customers</a>
        <a href="salesReport.jsp">Reports</a>
        <a href="logout">Logout</a>
    </div>
</div>

<div class="container">
    <h2>Customer Profiles</h2>
    <br>

    <%
        if (customers.isEmpty()) {
    %>
        <div class="card">
            <p>No customers found.</p>
        </div>
    <%
        } else {
    %>

    <table>
        <tr>
            <th>Customer ID</th>
            <th>Full Name</th>
            <th>Email</th>
            <th>Phone</th>
            <th>Action</th>
        </tr>

        <%
            for (User customer : customers) {
        %>
        <tr>
            <td>#<%= customer.getUserId() %></td>
            <td><%= customer.getFullName() %></td>
            <td><%= customer.getEmail() %></td>
            <td><%= customer.getPhone() %></td>
            <td>
                <a class="btn" href="customerProfile.jsp?id=<%= customer.getUserId() %>">
                    View Profile
                </a>
            </td>
        </tr>
        <%
            }
        %>
    </table>

    <%
        }
    %>
</div>

</body>
</html>