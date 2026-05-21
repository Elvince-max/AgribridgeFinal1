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

@WebFilter({"/adminDashboard.jsp", "/salesReport.jsp", "/addProduct.jsp", "/manageProducts.jsp", "/editProduct.jsp", "/customers.jsp", "/customerProfile.jsp", "/manageOrders.jsp", "/delivery.jsp", "/addProduct", "/updateProduct", "/deleteProduct", "/activateProduct", "/updateOrderStatus", "/assignDelivery", "/updateDeliveryStatus"})
public class RoleFilter extends HttpFilter implements Filter {
   public RoleFilter() {
   }

   public void init(FilterConfig filterConfig) throws ServletException {
   }

   protected void doFilter(HttpServletRequest request, HttpServletResponse response, FilterChain chain) throws IOException, ServletException {
      HttpSession session = request.getSession(false);
      if (session != null && session.getAttribute("userType") != null) {
         String userType = (String)session.getAttribute("userType");
         String uri = request.getRequestURI();
         boolean adminOnly = uri.endsWith("adminDashboard.jsp") || uri.endsWith("salesReport.jsp") || uri.endsWith("addProduct.jsp") || uri.endsWith("manageProducts.jsp") || uri.endsWith("editProduct.jsp") || uri.endsWith("customers.jsp") || uri.endsWith("customerProfile.jsp") || uri.endsWith("/addProduct") || uri.endsWith("/updateProduct") || uri.endsWith("/deleteProduct") || uri.endsWith("/activateProduct");
         boolean adminOrStaff = uri.endsWith("manageOrders.jsp") || uri.endsWith("/updateOrderStatus") || uri.endsWith("/assignDelivery");
         boolean deliveryAgentOnly = uri.endsWith("delivery.jsp") || uri.endsWith("/updateDeliveryStatus");
         if (adminOnly) {
            if ("ADMIN".equals(userType)) {
               chain.doFilter(request, response);
            } else {
               response.sendRedirect(request.getContextPath() + "/products.jsp");
            }

         } else if (!adminOrStaff) {
            if (deliveryAgentOnly) {
               if ("DELIVERY_AGENT".equals(userType)) {
                  chain.doFilter(request, response);
               } else {
                  response.sendRedirect(request.getContextPath() + "/products.jsp");
               }

            } else {
               chain.doFilter(request, response);
            }
         } else {
            if (!"ADMIN".equals(userType) && !"STAFF".equals(userType)) {
               response.sendRedirect(request.getContextPath() + "/products.jsp");
            } else {
               chain.doFilter(request, response);
            }

         }
      } else {
         response.sendRedirect(request.getContextPath() + "/login.jsp");
      }
   }

   public void destroy() {
   }
}
