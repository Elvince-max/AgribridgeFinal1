package com.agribridgef1.controller;

import com.agribridgef1.dao.UserDAO;
import com.agribridgef1.model.User;
import com.agribridgef1.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet({"/register"})
public class RegisterServlet extends HttpServlet {
   public RegisterServlet() {
   }

   protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      String fullName = request.getParameter("fullName");
      String email = request.getParameter("email");
      String phone = request.getParameter("phone");
      String password = PasswordUtil.hashPassword(request.getParameter("password"));
      String userType = "CUSTOMER";
      User user = new User(fullName, email, phone, password, userType);
      UserDAO dao = new UserDAO();
      boolean success = dao.registerUser(user);
      if (success) {
         response.sendRedirect("login.jsp");
      } else {
         response.sendRedirect("register.jsp?error=1");
      }

   }
}
