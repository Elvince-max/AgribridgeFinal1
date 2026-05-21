package com.agribridgef1.dao;

import com.agribridgef1.model.Review;
import com.agribridgef1.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {
   public ReviewDAO() {
   }

   public void addReview(Review review) {
      String sql = "INSERT INTO reviews (product_id, user_id, rating, comment) VALUES (?, ?, ?, ?)";

      try {
         Connection conn = DBConnection.getConnection();

         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ps.setInt(1, review.getProductId());
               ps.setInt(2, review.getUserId());
               ps.setInt(3, review.getRating());
               ps.setString(4, review.getComment());
               ps.executeUpdate();
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
      } catch (Exception e) {
         e.printStackTrace();
      }

   }

   public List<Review> getReviewsByProductId(int productId) {
      List<Review> reviews = new ArrayList();
      String sql = "SELECT r.review_id, r.product_id, r.user_id, r.rating, r.comment, r.created_at, u.full_name AS customer_name FROM reviews r JOIN users u ON r.user_id = u.user_id WHERE r.product_id = ? ORDER BY r.created_at DESC";

      try {
         Connection conn = DBConnection.getConnection();

         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ps.setInt(1, productId);
               ResultSet rs = ps.executeQuery();

               try {
                  while(rs.next()) {
                     Review review = new Review();
                     review.setReviewId(rs.getInt("review_id"));
                     review.setProductId(rs.getInt("product_id"));
                     review.setUserId(rs.getInt("user_id"));
                     review.setRating(rs.getInt("rating"));
                     review.setComment(rs.getString("comment"));
                     review.setCreatedAt(rs.getString("created_at"));
                     review.setCustomerName(rs.getString("customer_name"));
                     reviews.add(review);
                  }
               } catch (Throwable var12) {
                  if (rs != null) {
                     try {
                        rs.close();
                     } catch (Throwable var11) {
                        var12.addSuppressed(var11);
                     }
                  }

                  throw var12;
               }

               if (rs != null) {
                  rs.close();
               }
            } catch (Throwable var13) {
               if (ps != null) {
                  try {
                     ps.close();
                  } catch (Throwable var10) {
                     var13.addSuppressed(var10);
                  }
               }

               throw var13;
            }

            if (ps != null) {
               ps.close();
            }
         } catch (Throwable var14) {
            if (conn != null) {
               try {
                  conn.close();
               } catch (Throwable var9) {
                  var14.addSuppressed(var9);
               }
            }

            throw var14;
         }

         if (conn != null) {
            conn.close();
         }
      } catch (Exception e) {
         e.printStackTrace();
      }

      return reviews;
   }

   public double getAverageRating(int productId) {
      String sql = "SELECT AVG(rating) AS average_rating FROM reviews WHERE product_id = ?";

      try {
         Connection conn = DBConnection.getConnection();

         double var6;
         label114: {
            try {
               PreparedStatement ps;
               label106: {
                  ps = conn.prepareStatement(sql);

                  try {
                     ps.setInt(1, productId);
                     ResultSet rs = ps.executeQuery();

                     label86: {
                        try {
                           if (rs.next()) {
                              var6 = rs.getDouble("average_rating");
                              break label86;
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
                        break label106;
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
                  break label114;
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

            return (double)0.0F;
         }

         if (conn != null) {
            conn.close();
         }

         return var6;
      } catch (Exception e) {
         e.printStackTrace();
         return (double)0.0F;
      }
   }
}
