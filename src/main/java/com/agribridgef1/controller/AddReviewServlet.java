package com.agribridgef1.controller;

import com.agribridgef1.dao.ReviewDAO;
import com.agribridgef1.model.Review;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet({"/addReview"})
public class AddReviewServlet extends HttpServlet {
   public AddReviewServlet() {
   }

   protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      HttpSession session = request.getSession(false);
      if (session != null && session.getAttribute("userId") != null) {
         int userId = (Integer)session.getAttribute("userId");
         int productId = Integer.parseInt(request.getParameter("productId"));
         int rating = Integer.parseInt(request.getParameter("rating"));
         String comment = request.getParameter("comment");
         Review review = new Review(productId, userId, rating, comment);
         ReviewDAO dao = new ReviewDAO();
         dao.addReview(review);
         response.sendRedirect("productDetails.jsp?id=" + productId);
      } else {
         response.sendRedirect("login.jsp");
      }
   }
}
