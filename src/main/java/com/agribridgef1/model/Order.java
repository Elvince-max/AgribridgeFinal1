package com.agribridgef1.model;

public class Order {
   private int orderId;
   private int userId;
   private String deliveryAddress;
   private String deliveryTime;
   private String orderStatus;
   private double totalAmount;

   public Order() {
   }

   public Order(int userId, String deliveryAddress, String deliveryTime, String orderStatus, double totalAmount) {
      this.userId = userId;
      this.deliveryAddress = deliveryAddress;
      this.deliveryTime = deliveryTime;
      this.orderStatus = orderStatus;
      this.totalAmount = totalAmount;
   }

   public int getOrderId() {
      return this.orderId;
   }

   public void setOrderId(int orderId) {
      this.orderId = orderId;
   }

   public int getUserId() {
      return this.userId;
   }

   public void setUserId(int userId) {
      this.userId = userId;
   }

   public String getDeliveryAddress() {
      return this.deliveryAddress;
   }

   public void setDeliveryAddress(String deliveryAddress) {
      this.deliveryAddress = deliveryAddress;
   }

   public String getDeliveryTime() {
      return this.deliveryTime;
   }

   public void setDeliveryTime(String deliveryTime) {
      this.deliveryTime = deliveryTime;
   }

   public String getOrderStatus() {
      return this.orderStatus;
   }

   public void setOrderStatus(String orderStatus) {
      this.orderStatus = orderStatus;
   }

   public double getTotalAmount() {
      return this.totalAmount;
   }

   public void setTotalAmount(double totalAmount) {
      this.totalAmount = totalAmount;
   }
}
