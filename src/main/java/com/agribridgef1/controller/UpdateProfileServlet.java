package com.agribridgef1.controller;

import com.agribridgef1.dao.UserDAO;
import com.agribridgef1.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet({"/updateProfile"})
public class UpdateProfileServlet extends HttpServlet {
   public UpdateProfileServlet() {
   }

   protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      HttpSession session = request.getSession(false);
      if (session != null && session.getAttribute("userId") != null) {
         int userId = (Integer)session.getAttribute("userId");
         String fullName = request.getParameter("fullName");
         String email = request.getParameter("email");
         String phone = request.getParameter("phone");
         if (fullName != null && fullName.trim().length() >= 2 && email != null && !email.trim().isEmpty()) {
            fullName = fullName.trim();
            email = email.trim().toLowerCase();
            if (phone != null) {
               phone = phone.trim();
            }

            UserDAO dao = new UserDAO();
            if (dao.emailExistsForAnotherUser(email, userId)) {
               response.sendRedirect("profile.jsp?profile=email_exists");
            } else {
               boolean updated = dao.updateProfile(userId, fullName, email, phone);
               if (updated) {
                  session.setAttribute("fullName", fullName);
                  User updatedUser = dao.getUserById(userId);
                  if (updatedUser != null) {
                     session.setAttribute("user", updatedUser);
                     session.setAttribute("userType", updatedUser.getUserType());
                  }

                  response.sendRedirect("profile.jsp?profile=updated");
               } else {
                  response.sendRedirect("profile.jsp?profile=error");
               }

            }
         } else {
            response.sendRedirect("profile.jsp?profile=error");
         }
      } else {
         response.sendRedirect("login.jsp");
      }
   }
}
