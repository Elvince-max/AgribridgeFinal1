package com.agribridgef1.controller;

import com.agribridgef1.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet({"/changePassword"})
public class ChangePasswordServlet extends HttpServlet {
   public ChangePasswordServlet() {
   }

   protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      HttpSession session = request.getSession(false);
      if (session != null && session.getAttribute("userId") != null) {
         int userId = (Integer)session.getAttribute("userId");
         String currentPassword = request.getParameter("currentPassword");
         String newPassword = request.getParameter("newPassword");
         String confirmPassword = request.getParameter("confirmPassword");
         if (currentPassword != null && newPassword != null && confirmPassword != null) {
            if (newPassword.length() < 6) {
               response.sendRedirect("profile.jsp?security=weak");
            } else if (!newPassword.equals(confirmPassword)) {
               response.sendRedirect("profile.jsp?security=mismatch");
            } else {
               UserDAO dao = new UserDAO();
               boolean currentPasswordCorrect = dao.verifyCurrentPassword(userId, currentPassword);
               if (!currentPasswordCorrect) {
                  response.sendRedirect("profile.jsp?security=wrong_current");
               } else {
                  boolean changed = dao.changePassword(userId, newPassword);
                  if (changed) {
                     response.sendRedirect("profile.jsp?security=changed");
                  } else {
                     response.sendRedirect("profile.jsp?security=error");
                  }

               }
            }
         } else {
            response.sendRedirect("profile.jsp?security=error");
         }
      } else {
         response.sendRedirect("login.jsp");
      }
   }
}
