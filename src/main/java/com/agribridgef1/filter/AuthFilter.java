package com.agribridgef1.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter({"/*"})
public class AuthFilter extends HttpFilter implements Filter {
   public AuthFilter() {
   }

   public void init(FilterConfig filterConfig) throws ServletException {
   }

   protected void doFilter(HttpServletRequest request, HttpServletResponse response, FilterChain chain) throws IOException, ServletException {
      String uri = request.getRequestURI();
      boolean isLoggedIn = false;
      HttpSession session = request.getSession(false);
      if (session != null && session.getAttribute("userId") != null) {
         isLoggedIn = true;
      }

      boolean isPublicPage = uri.endsWith("/") || uri.endsWith("index.jsp") || uri.endsWith("products.jsp") || uri.endsWith("productDetails.jsp") || uri.endsWith("login.jsp") || uri.endsWith("register.jsp") || uri.endsWith("/login") || uri.endsWith("/register") || uri.endsWith("/mpesaCallback") || uri.contains("/assets/") || uri.contains("/uploads/");
      if (!isPublicPage && !isLoggedIn) {
         response.sendRedirect(request.getContextPath() + "/login.jsp");
      } else {
         chain.doFilter(request, response);
      }

   }

   public void destroy() {
   }
}
