package com.agribridgef1.dao;

import com.agribridgef1.model.Product;
import com.agribridgef1.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {
   public ProductDAO() {
   }

   public boolean addProduct(Product product) {
      String sql = "INSERT INTO products (product_name, description, price, stock_quantity, image_url, status) VALUES (?, ?, ?, ?, ?, 'ACTIVE')";

      try {
         Connection conn = DBConnection.getConnection();

         boolean var5;
         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ps.setString(1, product.getProductName());
               ps.setString(2, product.getDescription());
               ps.setDouble(3, product.getPrice());
               ps.setInt(4, product.getStockQuantity());
               ps.setString(5, product.getImageUrl());
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
      } catch (Exception e) {
         e.printStackTrace();
         return false;
      }
   }

   public List<Product> getAllProducts() {
      List<Product> list = new ArrayList();
      String sql = "SELECT * FROM products WHERE status = 'ACTIVE' ORDER BY product_id DESC";

      try {
         Connection conn = DBConnection.getConnection();

         try {
            Statement stmt = conn.createStatement();

            try {
               ResultSet rs = stmt.executeQuery(sql);

               try {
                  while(rs.next()) {
                     Product p = this.mapProduct(rs);
                     list.add(p);
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
               if (stmt != null) {
                  try {
                     stmt.close();
                  } catch (Throwable var9) {
                     var12.addSuppressed(var9);
                  }
               }

               throw var12;
            }

            if (stmt != null) {
               stmt.close();
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

      return list;
   }

   public List<Product> getAllProductsAdmin() {
      List<Product> list = new ArrayList();
      String sql = "SELECT * FROM products ORDER BY product_id DESC";

      try {
         Connection conn = DBConnection.getConnection();

         try {
            Statement stmt = conn.createStatement();

            try {
               ResultSet rs = stmt.executeQuery(sql);

               try {
                  while(rs.next()) {
                     Product p = this.mapProduct(rs);
                     list.add(p);
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
               if (stmt != null) {
                  try {
                     stmt.close();
                  } catch (Throwable var9) {
                     var12.addSuppressed(var9);
                  }
               }

               throw var12;
            }

            if (stmt != null) {
               stmt.close();
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

      return list;
   }

   public Product getProductById(int id) {
      String sql = "SELECT * FROM products WHERE product_id = ?";
      Product p = null;

      try {
         Connection conn = DBConnection.getConnection();

         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ps.setInt(1, id);
               ResultSet rs = ps.executeQuery();
               if (rs.next()) {
                  p = this.mapProduct(rs);
               }
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
      } catch (Exception e) {
         e.printStackTrace();
      }

      return p;
   }

   public List<Product> searchProducts(String keyword) {
      List<Product> list = new ArrayList();
      String sql = "SELECT * FROM products WHERE status = 'ACTIVE' AND (product_name LIKE ? OR description LIKE ?) ORDER BY product_id DESC";

      try {
         Connection conn = DBConnection.getConnection();

         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ps.setString(1, "%" + keyword + "%");
               ps.setString(2, "%" + keyword + "%");
               ResultSet rs = ps.executeQuery();

               while(rs.next()) {
                  Product p = this.mapProduct(rs);
                  list.add(p);
               }
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
      } catch (Exception e) {
         e.printStackTrace();
      }

      return list;
   }

   public List<Product> getProductsByCategory(int categoryId) {
      List<Product> list = new ArrayList();
      String sql = "SELECT * FROM products WHERE status = 'ACTIVE' AND category_id = ? ORDER BY product_id DESC";

      try {
         Connection conn = DBConnection.getConnection();

         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ps.setInt(1, categoryId);
               ResultSet rs = ps.executeQuery();

               while(rs.next()) {
                  Product p = this.mapProduct(rs);
                  list.add(p);
               }
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
      } catch (Exception e) {
         e.printStackTrace();
      }

      return list;
   }

   public List<Product> getLowStockProducts(int limit) {
      List<Product> list = new ArrayList();
      String sql = "SELECT * FROM products WHERE status = 'ACTIVE' AND stock_quantity <= ? ORDER BY stock_quantity ASC";

      try {
         Connection conn = DBConnection.getConnection();

         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ps.setInt(1, limit);
               ResultSet rs = ps.executeQuery();

               while(rs.next()) {
                  Product p = this.mapProduct(rs);
                  list.add(p);
               }
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
      } catch (Exception e) {
         e.printStackTrace();
      }

      return list;
   }

   public boolean updateProduct(Product product) {
      String sql = "UPDATE products SET product_name = ?, description = ?, price = ?, stock_quantity = ?, image_url = ? WHERE product_id = ?";

      try {
         Connection conn = DBConnection.getConnection();

         boolean var5;
         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ps.setString(1, product.getProductName());
               ps.setString(2, product.getDescription());
               ps.setDouble(3, product.getPrice());
               ps.setInt(4, product.getStockQuantity());
               ps.setString(5, product.getImageUrl());
               ps.setInt(6, product.getProductId());
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
      } catch (Exception e) {
         e.printStackTrace();
         return false;
      }
   }

   public boolean deactivateProduct(int productId) {
      String sql = "UPDATE products SET status = 'INACTIVE' WHERE product_id = ?";

      try {
         Connection conn = DBConnection.getConnection();

         boolean var5;
         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ps.setInt(1, productId);
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
      } catch (Exception e) {
         e.printStackTrace();
         return false;
      }
   }

   public boolean activateProduct(int productId) {
      String sql = "UPDATE products SET status = 'ACTIVE' WHERE product_id = ?";

      try {
         Connection conn = DBConnection.getConnection();

         boolean var5;
         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ps.setInt(1, productId);
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
      } catch (Exception e) {
         e.printStackTrace();
         return false;
      }
   }

   private Product mapProduct(ResultSet rs) throws SQLException {
      Product p = new Product();
      p.setProductId(rs.getInt("product_id"));
      p.setProductName(rs.getString("product_name"));
      p.setDescription(rs.getString("description"));
      p.setPrice(rs.getDouble("price"));
      p.setStockQuantity(rs.getInt("stock_quantity"));
      p.setImageUrl(rs.getString("image_url"));
      p.setStatus(rs.getString("status"));
      return p;
   }
}
