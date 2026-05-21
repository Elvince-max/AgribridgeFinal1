package com.agribridgef1.controller;

import com.agribridgef1.dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

@WebServlet({"/updateOrderStatus"})
public class UpdateOrderStatusServlet extends HttpServlet {
   private static final Set<String> ALLOWED_STATUSES = new HashSet(Arrays.asList("PENDING", "CONFIRMED", "PROCESSING", "OUT_FOR_DELIVERY", "DELIVERED", "CANCELLED"));

   public UpdateOrderStatusServlet() {
   }

   protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      HttpSession session = request.getSession(false);
      String userType = session != null ? (String)session.getAttribute("userType") : null;
      if (session != null && userType != null && ("ADMIN".equals(userType) || "STAFF".equals(userType))) {
         try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            String status = request.getParameter("status");
            if (status == null || !ALLOWED_STATUSES.contains(status)) {
               response.sendRedirect("manageOrders.jsp?status=error");
               return;
            }

            OrderDAO dao = new OrderDAO();
            dao.updateOrderStatus(orderId, status);
            response.sendRedirect("manageOrders.jsp?status=updated");
         } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("manageOrders.jsp?status=error");
         }

      } else {
         response.sendRedirect("login.jsp");
      }
   }
}
