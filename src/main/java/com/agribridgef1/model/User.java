package com.agribridgef1.model;

public class User {
   private int userId;
   private String fullName;
   private String email;
   private String phone;
   private String passwordHash;
   private String userType;

   public User() {
   }

   public User(String fullName, String email, String phone, String passwordHash, String userType) {
      this.fullName = fullName;
      this.email = email;
      this.phone = phone;
      this.passwordHash = passwordHash;
      this.userType = userType;
   }

   public int getUserId() {
      return this.userId;
   }

   public void setUserId(int userId) {
      this.userId = userId;
   }

   public String getFullName() {
      return this.fullName;
   }

   public void setFullName(String fullName) {
      this.fullName = fullName;
   }

   public String getEmail() {
      return this.email;
   }

   public void setEmail(String email) {
      this.email = email;
   }

   public String getPhone() {
      return this.phone;
   }

   public void setPhone(String phone) {
      this.phone = phone;
   }

   public String getPasswordHash() {
      return this.passwordHash;
   }

   public void setPasswordHash(String passwordHash) {
      this.passwordHash = passwordHash;
   }

   public String getUserType() {
      return this.userType;
   }

   public void setUserType(String userType) {
      this.userType = userType;
   }
}
