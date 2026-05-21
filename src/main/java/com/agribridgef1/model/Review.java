package com.agribridgef1.model;

public class Review {
   private int reviewId;
   private int productId;
   private int userId;
   private String customerName;
   private int rating;
   private String comment;
   private String createdAt;

   public Review() {
   }

   public Review(int productId, int userId, int rating, String comment) {
      this.productId = productId;
      this.userId = userId;
      this.rating = rating;
      this.comment = comment;
   }

   public int getReviewId() {
      return this.reviewId;
   }

   public void setReviewId(int reviewId) {
      this.reviewId = reviewId;
   }

   public int getProductId() {
      return this.productId;
   }

   public void setProductId(int productId) {
      this.productId = productId;
   }

   public int getUserId() {
      return this.userId;
   }

   public void setUserId(int userId) {
      this.userId = userId;
   }

   public String getCustomerName() {
      return this.customerName;
   }

   public void setCustomerName(String customerName) {
      this.customerName = customerName;
   }

   public int getRating() {
      return this.rating;
   }

   public void setRating(int rating) {
      this.rating = rating;
   }

   public String getComment() {
      return this.comment;
   }

   public void setComment(String comment) {
      this.comment = comment;
   }

   public String getCreatedAt() {
      return this.createdAt;
   }

   public void setCreatedAt(String createdAt) {
      this.createdAt = createdAt;
   }
}
