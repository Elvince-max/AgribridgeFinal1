package com.agribridgef1.controller;

import com.agribridgef1.dao.PaymentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.UUID;

@WebServlet({"/payment"})
public class PaymentServlet extends HttpServlet {
   public PaymentServlet() {
   }

   protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      HttpSession session = request.getSession(false);
      if (session != null && session.getAttribute("userId") != null) {
         try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            double amount = Double.parseDouble(request.getParameter("amount"));
            String method = request.getParameter("method");
            String transactionCode = UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            String status = "PENDING";
            PaymentDAO dao = new PaymentDAO();
            boolean success = dao.savePayment(orderId, amount, method, transactionCode, status);
            if (success) {
               response.sendRedirect("orderDetails.jsp?orderId=" + orderId);
            } else {
               response.sendRedirect("payment.jsp?orderId=" + orderId + "&error=1");
            }
         } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("myOrders.jsp");
         }

      } else {
         response.sendRedirect("login.jsp");
      }
   }
}
