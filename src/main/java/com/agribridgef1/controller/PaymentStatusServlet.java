package com.agribridgef1.controller;

import com.agribridgef1.dao.PaymentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet({"/paymentStatus"})
public class PaymentStatusServlet extends HttpServlet {
   public PaymentStatusServlet() {
   }

   protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      HttpSession session = request.getSession(false);
      if (session != null && session.getAttribute("userId") != null) {
         int orderId = Integer.parseInt(request.getParameter("orderId"));
         PaymentDAO paymentDAO = new PaymentDAO();
         String status = paymentDAO.getPaymentStatusByOrderId(orderId);
         response.setContentType("application/json");
         response.getWriter().write("{\"status\":\"" + status + "\"}");
      } else {
         response.setStatus(401);
      }
   }
}
