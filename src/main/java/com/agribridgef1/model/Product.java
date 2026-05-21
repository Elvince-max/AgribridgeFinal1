package com.agribridgef1.model;

public class Product {
   private int productId;
   private String productName;
   private String description;
   private double price;
   private int stockQuantity;
   private String imageUrl;
   private String status;

   public Product() {
   }

   public Product(String productName, String description, double price, int stockQuantity, String imageUrl) {
      this.productName = productName;
      this.description = description;
      this.price = price;
      this.stockQuantity = stockQuantity;
      this.imageUrl = imageUrl;
      this.status = "ACTIVE";
   }

   public int getProductId() {
      return this.productId;
   }

   public void setProductId(int productId) {
      this.productId = productId;
   }

   public String getProductName() {
      return this.productName;
   }

   public void setProductName(String productName) {
      this.productName = productName;
   }

   public String getDescription() {
      return this.description;
   }

   public void setDescription(String description) {
      this.description = description;
   }

   public double getPrice() {
      return this.price;
   }

   public void setPrice(double price) {
      this.price = price;
   }

   public int getStockQuantity() {
      return this.stockQuantity;
   }

   public void setStockQuantity(int stockQuantity) {
      this.stockQuantity = stockQuantity;
   }

   public String getImageUrl() {
      return this.imageUrl;
   }

   public void setImageUrl(String imageUrl) {
      this.imageUrl = imageUrl;
   }

   public String getStatus() {
      return this.status;
   }

   public void setStatus(String status) {
      this.status = status;
   }
}
