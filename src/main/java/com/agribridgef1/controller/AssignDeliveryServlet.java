package com.agribridgef1.controller;

import com.agribridgef1.dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet({"/assignDelivery"})
public class AssignDeliveryServlet extends HttpServlet {
   public AssignDeliveryServlet() {
   }

   protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      HttpSession session = request.getSession(false);
      String userType = session != null ? (String)session.getAttribute("userType") : null;
      if (session != null && userType != null && ("ADMIN".equals(userType) || "STAFF".equals(userType))) {
         try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            int agentId = Integer.parseInt(request.getParameter("agentId"));
            OrderDAO dao = new OrderDAO();
            dao.assignDelivery(orderId, agentId);
            response.sendRedirect("manageOrders.jsp?status=assigned");
         } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("manageOrders.jsp?status=error");
         }

      } else {
         response.sendRedirect("login.jsp");
      }
   }
}
