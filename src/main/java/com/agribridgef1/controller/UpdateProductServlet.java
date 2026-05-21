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

@WebServlet({"/updateProduct"})
@MultipartConfig
public class UpdateProductServlet extends HttpServlet {
   public UpdateProductServlet() {
   }

   protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      HttpSession session = request.getSession(false);
      if (session != null && session.getAttribute("userType") != null && "ADMIN".equals(session.getAttribute("userType"))) {
         int productId = 0;

         try {
            productId = Integer.parseInt(request.getParameter("productId"));
            String name = request.getParameter("name");
            String desc = request.getParameter("description");
            double price = Double.parseDouble(request.getParameter("price"));
            int qty = Integer.parseInt(request.getParameter("quantity"));
            String oldImage = request.getParameter("oldImage");
            if (name == null || name.trim().isEmpty() || price <= (double)0.0F || qty < 0) {
               response.sendRedirect("editProduct.jsp?id=" + productId + "&status=error");
               return;
            }

            Part filePart = request.getPart("imageFile");
            String imagePath = oldImage;
            if (filePart != null && filePart.getSize() > 0L) {
               String submittedName = filePart.getSubmittedFileName();
               String extension = "";
               int dotIndex = submittedName.lastIndexOf(".");
               if (dotIndex >= 0) {
                  extension = submittedName.substring(dotIndex);
               }

               long var10000 = System.currentTimeMillis();
               String fileName = "product_" + var10000 + extension;
               String var24 = this.getServletContext().getRealPath("");
               String uploadPath = var24 + File.separator + "uploads";
               File uploadDir = new File(uploadPath);
               if (!uploadDir.exists()) {
                  uploadDir.mkdirs();
               }

               String filePath = uploadPath + File.separator + fileName;
               filePart.write(filePath);
               imagePath = "uploads/" + fileName;
            }

            Product product = new Product();
            product.setProductId(productId);
            product.setProductName(name.trim());
            product.setDescription(desc);
            product.setPrice(price);
            product.setStockQuantity(qty);
            product.setImageUrl(imagePath);
            ProductDAO dao = new ProductDAO();
            dao.updateProduct(product);
            response.sendRedirect("manageProducts.jsp");
         } catch (Exception e) {
            e.printStackTrace();
            if (productId > 0) {
               response.sendRedirect("editProduct.jsp?id=" + productId + "&status=error");
            } else {
               response.sendRedirect("manageProducts.jsp");
            }
         }

      } else {
         response.sendRedirect("login.jsp");
      }
   }
}
