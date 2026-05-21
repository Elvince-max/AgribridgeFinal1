package com.agribridgef1.controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet({"/logout"})
public class LogoutServlet extends HttpServlet {
   public LogoutServlet() {
   }

   protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
      HttpSession session = request.getSession(false);
      if (session != null) {
         session.invalidate();
      }

      response.sendRedirect(request.getContextPath() + "/login.jsp");
   }
}
