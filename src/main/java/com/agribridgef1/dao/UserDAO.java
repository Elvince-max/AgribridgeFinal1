package com.agribridgef1.dao;

import com.agribridgef1.model.User;
import com.agribridgef1.util.DBConnection;
import com.agribridgef1.util.PasswordUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
   public UserDAO() {
   }

   public boolean registerUser(User user) {
      String sql = "INSERT INTO users (full_name, email, phone, password_hash, user_type) VALUES (?, ?, ?, ?, ?)";

      try {
         Connection conn = DBConnection.getConnection();

         boolean var5;
         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ps.setString(1, user.getFullName());
               ps.setString(2, user.getEmail());
               ps.setString(3, user.getPhone());
               ps.setString(4, user.getPasswordHash());
               ps.setString(5, user.getUserType());
               var5 = ps.executeUpdate() > 0;
            } catch (Throwable var9) {
               if (ps != null) {
                  try {
                     ps.close();
                  } catch (Throwable var8) {
                     var9.addSuppressed(var8);
                  }
               }

               throw var9;
            }

            if (ps != null) {
               ps.close();
            }
         } catch (Throwable var10) {
            if (conn != null) {
               try {
                  conn.close();
               } catch (Throwable var7) {
                  var10.addSuppressed(var7);
               }
            }

            throw var10;
         }

         if (conn != null) {
            conn.close();
         }

         return var5;
      } catch (SQLException e) {
         e.printStackTrace();
         return false;
      }
   }

   public User loginUser(String email, String password) {
      String sql = "SELECT * FROM users WHERE email = ?";

      try {
         Connection conn = DBConnection.getConnection();

         User var9;
         label88: {
            try {
               PreparedStatement ps = conn.prepareStatement(sql);

               label81: {
                  try {
                     ps.setString(1, email);
                     ResultSet rs = ps.executeQuery();
                     if (!rs.next()) {
                        break label81;
                     }

                     String storedPassword = rs.getString("password_hash");
                     if (!PasswordUtil.verifyPassword(password, storedPassword)) {
                        break label81;
                     }

                     User user = new User();
                     user.setUserId(rs.getInt("user_id"));
                     user.setFullName(rs.getString("full_name"));
                     user.setEmail(rs.getString("email"));
                     user.setPhone(rs.getString("phone"));
                     user.setUserType(rs.getString("user_type"));
                     var9 = user;
                  } catch (Throwable var12) {
                     if (ps != null) {
                        try {
                           ps.close();
                        } catch (Throwable var11) {
                           var12.addSuppressed(var11);
                        }
                     }

                     throw var12;
                  }

                  if (ps != null) {
                     ps.close();
                  }
                  break label88;
               }

               if (ps != null) {
                  ps.close();
               }
            } catch (Throwable var13) {
               if (conn != null) {
                  try {
                     conn.close();
                  } catch (Throwable var10) {
                     var13.addSuppressed(var10);
                  }
               }

               throw var13;
            }

            if (conn != null) {
               conn.close();
            }

            return null;
         }

         if (conn != null) {
            conn.close();
         }

         return var9;
      } catch (SQLException e) {
         e.printStackTrace();
         return null;
      }
   }

   public List<User> getAllCustomers() {
      List<User> customers = new ArrayList();
      String sql = "SELECT * FROM users WHERE user_type = 'CUSTOMER' ORDER BY created_at DESC";

      try {
         Connection conn = DBConnection.getConnection();

         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ResultSet rs = ps.executeQuery();

               try {
                  while(rs.next()) {
                     User user = new User();
                     user.setUserId(rs.getInt("user_id"));
                     user.setFullName(rs.getString("full_name"));
                     user.setEmail(rs.getString("email"));
                     user.setPhone(rs.getString("phone"));
                     user.setUserType(rs.getString("user_type"));
                     customers.add(user);
                  }
               } catch (Throwable var11) {
                  if (rs != null) {
                     try {
                        rs.close();
                     } catch (Throwable var10) {
                        var11.addSuppressed(var10);
                     }
                  }

                  throw var11;
               }

               if (rs != null) {
                  rs.close();
               }
            } catch (Throwable var12) {
               if (ps != null) {
                  try {
                     ps.close();
                  } catch (Throwable var9) {
                     var12.addSuppressed(var9);
                  }
               }

               throw var12;
            }

            if (ps != null) {
               ps.close();
            }
         } catch (Throwable var13) {
            if (conn != null) {
               try {
                  conn.close();
               } catch (Throwable var8) {
                  var13.addSuppressed(var8);
               }
            }

            throw var13;
         }

         if (conn != null) {
            conn.close();
         }
      } catch (Exception e) {
         e.printStackTrace();
      }

      return customers;
   }

   public User getUserById(int userId) {
      String sql = "SELECT * FROM users WHERE user_id = ?";

      try {
         Connection conn = DBConnection.getConnection();

         User var7;
         label84: {
            try {
               PreparedStatement ps = conn.prepareStatement(sql);

               label78: {
                  try {
                     ps.setInt(1, userId);
                     ResultSet rs = ps.executeQuery();
                     if (!rs.next()) {
                        break label78;
                     }

                     User user = new User();
                     user.setUserId(rs.getInt("user_id"));
                     user.setFullName(rs.getString("full_name"));
                     user.setEmail(rs.getString("email"));
                     user.setPhone(rs.getString("phone"));
                     user.setUserType(rs.getString("user_type"));
                     var7 = user;
                  } catch (Throwable var10) {
                     if (ps != null) {
                        try {
                           ps.close();
                        } catch (Throwable var9) {
                           var10.addSuppressed(var9);
                        }
                     }

                     throw var10;
                  }

                  if (ps != null) {
                     ps.close();
                  }
                  break label84;
               }

               if (ps != null) {
                  ps.close();
               }
            } catch (Throwable var11) {
               if (conn != null) {
                  try {
                     conn.close();
                  } catch (Throwable var8) {
                     var11.addSuppressed(var8);
                  }
               }

               throw var11;
            }

            if (conn != null) {
               conn.close();
            }

            return null;
         }

         if (conn != null) {
            conn.close();
         }

         return var7;
      } catch (Exception e) {
         e.printStackTrace();
         return null;
      }
   }

   public boolean emailExistsForAnotherUser(String email, int userId) {
      String sql = "SELECT user_id FROM users WHERE email = ? AND user_id <> ? LIMIT 1";

      try {
         Connection conn = DBConnection.getConnection();

         boolean var7;
         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ps.setString(1, email);
               ps.setInt(2, userId);
               ResultSet rs = ps.executeQuery();
               var7 = rs.next();
            } catch (Throwable var10) {
               if (ps != null) {
                  try {
                     ps.close();
                  } catch (Throwable var9) {
                     var10.addSuppressed(var9);
                  }
               }

               throw var10;
            }

            if (ps != null) {
               ps.close();
            }
         } catch (Throwable var11) {
            if (conn != null) {
               try {
                  conn.close();
               } catch (Throwable var8) {
                  var11.addSuppressed(var8);
               }
            }

            throw var11;
         }

         if (conn != null) {
            conn.close();
         }

         return var7;
      } catch (Exception e) {
         e.printStackTrace();
         return true;
      }
   }

   public boolean updateProfile(int userId, String fullName, String email, String phone) {
      String sql = "UPDATE users SET full_name = ?, email = ?, phone = ? WHERE user_id = ?";

      try {
         Connection conn = DBConnection.getConnection();

         boolean var8;
         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ps.setString(1, fullName);
               ps.setString(2, email);
               ps.setString(3, phone);
               ps.setInt(4, userId);
               var8 = ps.executeUpdate() > 0;
            } catch (Throwable var12) {
               if (ps != null) {
                  try {
                     ps.close();
                  } catch (Throwable var11) {
                     var12.addSuppressed(var11);
                  }
               }

               throw var12;
            }

            if (ps != null) {
               ps.close();
            }
         } catch (Throwable var13) {
            if (conn != null) {
               try {
                  conn.close();
               } catch (Throwable var10) {
                  var13.addSuppressed(var10);
               }
            }

            throw var13;
         }

         if (conn != null) {
            conn.close();
         }

         return var8;
      } catch (Exception e) {
         e.printStackTrace();
         return false;
      }
   }

   public boolean verifyCurrentPassword(int userId, String currentPassword) {
      String sql = "SELECT password_hash FROM users WHERE user_id = ?";

      try {
         Connection conn = DBConnection.getConnection();

         boolean var8;
         label84: {
            try {
               PreparedStatement ps = conn.prepareStatement(sql);

               label78: {
                  try {
                     ps.setInt(1, userId);
                     ResultSet rs = ps.executeQuery();
                     if (!rs.next()) {
                        break label78;
                     }

                     String storedPassword = rs.getString("password_hash");
                     var8 = PasswordUtil.verifyPassword(currentPassword, storedPassword);
                  } catch (Throwable var11) {
                     if (ps != null) {
                        try {
                           ps.close();
                        } catch (Throwable var10) {
                           var11.addSuppressed(var10);
                        }
                     }

                     throw var11;
                  }

                  if (ps != null) {
                     ps.close();
                  }
                  break label84;
               }

               if (ps != null) {
                  ps.close();
               }
            } catch (Throwable var12) {
               if (conn != null) {
                  try {
                     conn.close();
                  } catch (Throwable var9) {
                     var12.addSuppressed(var9);
                  }
               }

               throw var12;
            }

            if (conn != null) {
               conn.close();
            }

            return false;
         }

         if (conn != null) {
            conn.close();
         }

         return var8;
      } catch (Exception e) {
         e.printStackTrace();
         return false;
      }
   }

   public boolean changePassword(int userId, String newPassword) {
      String sql = "UPDATE users SET password_hash = ? WHERE user_id = ?";
      String hashedPassword = PasswordUtil.hashPassword(newPassword);

      try {
         Connection conn = DBConnection.getConnection();

         boolean var7;
         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ps.setString(1, hashedPassword);
               ps.setInt(2, userId);
               var7 = ps.executeUpdate() > 0;
            } catch (Throwable var11) {
               if (ps != null) {
                  try {
                     ps.close();
                  } catch (Throwable var10) {
                     var11.addSuppressed(var10);
                  }
               }

               throw var11;
            }

            if (ps != null) {
               ps.close();
            }
         } catch (Throwable var12) {
            if (conn != null) {
               try {
                  conn.close();
               } catch (Throwable var9) {
                  var12.addSuppressed(var9);
               }
            }

            throw var12;
         }

         if (conn != null) {
            conn.close();
         }

         return var7;
      } catch (Exception e) {
         e.printStackTrace();
         return false;
      }
   }
}
