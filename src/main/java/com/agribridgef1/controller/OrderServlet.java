package com.agribridgef1.controller;

import com.agribridgef1.dao.OrderDAO;
import com.agribridgef1.dao.ProductDAO;
import com.agribridgef1.model.Order;
import com.agribridgef1.model.OrderItem;
import com.agribridgef1.model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet({"/placeOrder"})
public class OrderServlet extends HttpServlet {
   public OrderServlet() {
   }

   protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      HttpSession session = request.getSession(false);
      if (session != null && session.getAttribute("userId") != null) {
         Map<Integer, Integer> cart = (Map)session.getAttribute("cart");
         if (cart != null && !cart.isEmpty()) {
            int userId = (Integer)session.getAttribute("userId");
            String deliveryAddress = request.getParameter("deliveryAddress");
            String deliveryTime = request.getParameter("deliveryTime");
            ProductDAO productDAO = new ProductDAO();
            double total = (double)0.0F;
            List<OrderItem> items = new ArrayList();

            for(Map.Entry<Integer, Integer> entry : cart.entrySet()) {
               Product product = productDAO.getProductById((Integer)entry.getKey());
               int quantity = (Integer)entry.getValue();
               total += product.getPrice() * (double)quantity;
               items.add(new OrderItem(product.getProductId(), quantity, product.getPrice()));
            }

            Order order = new Order(userId, deliveryAddress, deliveryTime, "PENDING", total);
            OrderDAO orderDAO = new OrderDAO();
            int orderId = orderDAO.createOrder(order, items);
            if (orderId > 0) {
               session.removeAttribute("cart");
               response.sendRedirect("orderConfirmation.jsp?orderId=" + orderId);
            } else {
               response.sendRedirect("checkout.jsp?error=1");
            }

         } else {
            response.sendRedirect("cart.jsp");
         }
      } else {
         response.sendRedirect("login.jsp");
      }
   }
}
