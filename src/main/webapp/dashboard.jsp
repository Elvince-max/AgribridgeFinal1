<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String fullName = (String) session.getAttribute("fullName");
    String userType = (String) session.getAttribute("userType");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Dashboard - AgribridgeF1</title>
    <meta charset="UTF-8">
</head>
<body>

<h2>Welcome, <%= fullName %></h2>
<p>User Type: <%= userType %></p>

<a href="logout">Logout</a>

</body>
</html>