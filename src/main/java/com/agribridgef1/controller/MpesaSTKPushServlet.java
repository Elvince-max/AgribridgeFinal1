package com.agribridgef1.controller;

import com.agribridgef1.dao.PaymentDAO;
import com.agribridgef1.service.MpesaService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import org.json.JSONObject;

@WebServlet({"/mpesaSTKPush"})
public class MpesaSTKPushServlet extends HttpServlet {
   public MpesaSTKPushServlet() {
   }

   protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      HttpSession session = request.getSession(false);
      if (session != null && session.getAttribute("userId") != null) {
         int orderId = Integer.parseInt(request.getParameter("orderId"));
         double amountDouble = Double.parseDouble(request.getParameter("amount"));
         int amount = (int)amountDouble;
         String phone = request.getParameter("phone");
         phone = this.formatPhoneNumber(phone);
         if (phone == null) {
            response.sendRedirect("payment.jsp?orderId=" + orderId + "&error=phone");
         } else {
            try {
               MpesaService service = new MpesaService();
               String stkResponse = service.stkPush(phone, amount, orderId);
               JSONObject json = new JSONObject(stkResponse);
               String responseCode = json.optString("ResponseCode", "");
               String checkoutRequestId = json.optString("CheckoutRequestID", "");
               if ("0".equals(responseCode) && !checkoutRequestId.isEmpty()) {
                  PaymentDAO paymentDAO = new PaymentDAO();
                  paymentDAO.savePendingMpesaPayment(orderId, amountDouble, checkoutRequestId);
                  session.setAttribute("checkoutRequestId", checkoutRequestId);
                  response.sendRedirect("mpesaPending.jsp?orderId=" + orderId);
               } else {
                  response.sendRedirect("payment.jsp?orderId=" + orderId + "&error=mpesa");
               }
            } catch (Exception e) {
               e.printStackTrace();
               response.sendRedirect("payment.jsp?orderId=" + orderId + "&error=mpesa");
            }

         }
      } else {
         response.sendRedirect("login.jsp");
      }
   }

   private String formatPhoneNumber(String phone) {
      if (phone == null) {
         return null;
      } else {
         phone = phone.trim().replaceAll("\\s+", "");
         if (!phone.matches("07[0-9]{8}") && !phone.matches("01[0-9]{8}")) {
            return !phone.matches("2547[0-9]{8}") && !phone.matches("2541[0-9]{8}") ? null : phone;
         } else {
            return "254" + phone.substring(1);
         }
      }
   }
}
