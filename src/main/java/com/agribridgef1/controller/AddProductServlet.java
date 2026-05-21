package com.agribridgef1.controller;

import com.agribridgef1.dao.ProductDAO;
import com.agribridgef1.model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;

@WebServlet({"/addProduct"})
@MultipartConfig
public class AddProductServlet extends HttpServlet {
   public AddProductServlet() {
   }

   protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      HttpSession session = request.getSession(false);
      if (session != null && session.getAttribute("userType") != null && "ADMIN".equals(session.getAttribute("userType"))) {
         try {
            String name = request.getParameter("name");
            String desc = request.getParameter("description");
            double price = Double.parseDouble(request.getParameter("price"));
            int qty = Integer.parseInt(request.getParameter("quantity"));
            if (name == null || name.trim().isEmpty() || price <= (double)0.0F || qty < 0) {
               response.sendRedirect("addProduct.jsp?status=error");
               return;
            }

            Part filePart = request.getPart("imageFile");
            String imagePath = "";
            if (filePart != null && filePart.getSize() > 0L) {
               String submittedName = filePart.getSubmittedFileName();
               String extension = "";
               int dotIndex = submittedName.lastIndexOf(".");
               if (dotIndex >= 0) {
                  extension = submittedName.substring(dotIndex);
               }

               long var10000 = System.currentTimeMillis();
               String fileName = "product_" + var10000 + extension;
               String var21 = this.getServletContext().getRealPath("");
               String uploadPath = var21 + File.separator + "uploads";
               File uploadDir = new File(uploadPath);
               if (!uploadDir.exists()) {
                  uploadDir.mkdirs();
               }

               String filePath = uploadPath + File.separator + fileName;
               filePart.write(filePath);
               imagePath = "uploads/" + fileName;
            }

            Product product = new Product(name.trim(), desc, price, qty, imagePath);
            ProductDAO dao = new ProductDAO();
            dao.addProduct(product);
            response.sendRedirect("addProduct.jsp?success=1");
         } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("addProduct.jsp?status=error");
         }

      } else {
         response.sendRedirect("login.jsp");
      }
   }
}
