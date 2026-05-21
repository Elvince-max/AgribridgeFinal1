package com.agribridgef1.controller;

import com.agribridgef1.dao.ProductDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet({"/deleteProduct"})
public class DeleteProductServlet extends HttpServlet {
   public DeleteProductServlet() {
   }

   protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
      int productId = Integer.parseInt(request.getParameter("id"));
      ProductDAO dao = new ProductDAO();
      dao.deactivateProduct(productId);
      response.sendRedirect("manageProducts.jsp");
   }
}
