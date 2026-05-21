package com.agribridgef1.model;

public class OrderItem {
   private int orderItemId;
   private int orderId;
   private int productId;
   private int quantity;
   private double price;

   public OrderItem() {
   }

   public OrderItem(int productId, int quantity, double price) {
      this.productId = productId;
      this.quantity = quantity;
      this.price = price;
   }

   public int getOrderItemId() {
      return this.orderItemId;
   }

   public void setOrderItemId(int orderItemId) {
      this.orderItemId = orderItemId;
   }

   public int getOrderId() {
      return this.orderId;
   }

   public void setOrderId(int orderId) {
      this.orderId = orderId;
   }

   public int getProductId() {
      return this.productId;
   }

   public void setProductId(int productId) {
      this.productId = productId;
   }

   public int getQuantity() {
      return this.quantity;
   }

   public void setQuantity(int quantity) {
      this.quantity = quantity;
   }

   public double getPrice() {
      return this.price;
   }

   public void setPrice(double price) {
      this.price = price;
   }
}
