package com.agribridgef1.controller;

import com.agribridgef1.dao.ProductDAO;
import com.agribridgef1.model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet({"/cart"})
public class CartServlet extends HttpServlet {
   public CartServlet() {
   }

   protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      HttpSession session = request.getSession();
      Map<Integer, Integer> cart = (Map)session.getAttribute("cart");
      if (cart == null) {
         cart = new HashMap();
         session.setAttribute("cart", cart);
      }

      String action = request.getParameter("action");
      String idParam = request.getParameter("id");
      ProductDAO productDAO = new ProductDAO();
      if ("clear".equals(action)) {
         cart.clear();
         response.sendRedirect("cart.jsp");
      } else if (idParam != null && !idParam.trim().isEmpty()) {
         int productId = Integer.parseInt(idParam);
         Product product = productDAO.getProductById(productId);
         if (product == null) {
            response.sendRedirect("products.jsp");
         } else {
            int currentQuantity = (Integer)cart.getOrDefault(productId, 0);
            if ("remove".equals(action)) {
               cart.remove(productId);
            } else if ("increase".equals(action)) {
               if (currentQuantity < product.getStockQuantity()) {
                  cart.put(productId, currentQuantity + 1);
               }
            } else if ("decrease".equals(action)) {
               if (currentQuantity > 1) {
                  cart.put(productId, currentQuantity - 1);
               } else {
                  cart.remove(productId);
               }
            } else if (product.getStockQuantity() > 0 && currentQuantity < product.getStockQuantity()) {
               cart.put(productId, currentQuantity + 1);
            }

            String referer = request.getHeader("Referer");
            if (referer != null && !referer.trim().isEmpty()) {
               response.sendRedirect(referer);
            } else {
               response.sendRedirect("cart.jsp");
            }

         }
      } else {
         response.sendRedirect("cart.jsp");
      }
   }
}
