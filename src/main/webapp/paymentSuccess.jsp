<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String orderId = request.getParameter("orderId");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Payment Success</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <meta charset="UTF-8">
</head>
<body>

<div class="container">
    <div class="card" style="text-align:center;">
        <h2>Payment Successful 🎉</h2>

        <p>Your order #<%= orderId %> has been processed.</p>

        <br>

        <a class="btn" href="myOrders.jsp">View My Orders</a>
        <br><br>
        <a class="btn btn-secondary" href="products.jsp">Continue Shopping</a>
    </div>
</div>

</body>
</html>