package com.agribridgef1.dao;

import com.agribridgef1.model.Order;
import com.agribridgef1.model.OrderItem;
import com.agribridgef1.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {
   public OrderDAO() {
   }

   public int createOrder(Order order, List<OrderItem> items) {
      int orderId = 0;
      String orderSql = "INSERT INTO orders (user_id, delivery_address, delivery_time, order_status, total_amount) VALUES (?, ?, ?, ?, ?)";
      String itemSql = "INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)";

      try {
         Connection conn = DBConnection.getConnection();

         byte var21;
         label142: {
            try {
               conn.setAutoCommit(false);
               PreparedStatement orderPs = conn.prepareStatement(orderSql, 1);

               try {
                  orderPs.setInt(1, order.getUserId());
                  orderPs.setString(2, order.getDeliveryAddress());
                  orderPs.setString(3, order.getDeliveryTime());
                  orderPs.setString(4, order.getOrderStatus());
                  orderPs.setDouble(5, order.getTotalAmount());
                  orderPs.executeUpdate();
                  ResultSet rs = orderPs.getGeneratedKeys();

                  try {
                     if (rs.next()) {
                        orderId = rs.getInt(1);
                     }
                  } catch (Throwable var15) {
                     if (rs != null) {
                        try {
                           rs.close();
                        } catch (Throwable var14) {
                           var15.addSuppressed(var14);
                        }
                     }

                     throw var15;
                  }

                  if (rs != null) {
                     rs.close();
                  }
               } catch (Throwable var16) {
                  if (orderPs != null) {
                     try {
                        orderPs.close();
                     } catch (Throwable var13) {
                        var16.addSuppressed(var13);
                     }
                  }

                  throw var16;
               }

               if (orderPs != null) {
                  orderPs.close();
               }

               if (orderId == 0) {
                  conn.rollback();
                  var21 = 0;
                  break label142;
               }

               orderPs = conn.prepareStatement(itemSql);

               try {
                  for(OrderItem item : items) {
                     orderPs.setInt(1, orderId);
                     orderPs.setInt(2, item.getProductId());
                     orderPs.setInt(3, item.getQuantity());
                     orderPs.setDouble(4, item.getPrice());
                     orderPs.addBatch();
                  }

                  orderPs.executeBatch();
               } catch (Throwable var17) {
                  if (orderPs != null) {
                     try {
                        orderPs.close();
                     } catch (Throwable var12) {
                        var17.addSuppressed(var12);
                     }
                  }

                  throw var17;
               }

               if (orderPs != null) {
                  orderPs.close();
               }

               conn.commit();
            } catch (Throwable var18) {
               if (conn != null) {
                  try {
                     conn.close();
                  } catch (Throwable var11) {
                     var18.addSuppressed(var11);
                  }
               }

               throw var18;
            }

            if (conn != null) {
               conn.close();
            }

            return orderId;
         }

         if (conn != null) {
            conn.close();
         }

         return var21;
      } catch (Exception e) {
         e.printStackTrace();
         orderId = 0;
         return orderId;
      }
   }

   public List<Order> getOrdersByUser(int userId) {
      List<Order> list = new ArrayList();
      String sql = "SELECT * FROM orders WHERE user_id = ? ORDER BY order_date DESC";

      try {
         Connection conn = DBConnection.getConnection();

         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ps.setInt(1, userId);
               ResultSet rs = ps.executeQuery();

               try {
                  while(rs.next()) {
                     Order o = new Order();
                     o.setOrderId(rs.getInt("order_id"));
                     o.setUserId(rs.getInt("user_id"));
                     o.setDeliveryAddress(rs.getString("delivery_address"));
                     o.setDeliveryTime(rs.getString("delivery_time"));
                     o.setOrderStatus(rs.getString("order_status"));
                     o.setTotalAmount(rs.getDouble("total_amount"));
                     list.add(o);
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

      return list;
   }

   public List<OrderItem> getOrderItems(int orderId) {
      List<OrderItem> list = new ArrayList();
      String sql = "SELECT * FROM order_items WHERE order_id = ?";

      try {
         Connection conn = DBConnection.getConnection();

         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ps.setInt(1, orderId);
               ResultSet rs = ps.executeQuery();

               try {
                  while(rs.next()) {
                     OrderItem item = new OrderItem();
                     item.setProductId(rs.getInt("product_id"));
                     item.setQuantity(rs.getInt("quantity"));
                     item.setPrice(rs.getDouble("price"));
                     list.add(item);
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

      return list;
   }

   public List<Order> getAllOrders() {
      List<Order> list = new ArrayList();
      String sql = "SELECT * FROM orders ORDER BY order_date DESC";

      try {
         Connection conn = DBConnection.getConnection();

         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ResultSet rs = ps.executeQuery();

               try {
                  while(rs.next()) {
                     Order o = new Order();
                     o.setOrderId(rs.getInt("order_id"));
                     o.setUserId(rs.getInt("user_id"));
                     o.setDeliveryAddress(rs.getString("delivery_address"));
                     o.setDeliveryTime(rs.getString("delivery_time"));
                     o.setOrderStatus(rs.getString("order_status"));
                     o.setTotalAmount(rs.getDouble("total_amount"));
                     list.add(o);
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

      return list;
   }

   public boolean updateOrderStatus(int orderId, String status) {
      String sql = "UPDATE orders SET order_status = ? WHERE order_id = ?";

      try {
         Connection conn = DBConnection.getConnection();

         boolean var6;
         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ps.setString(1, status);
               ps.setInt(2, orderId);
               var6 = ps.executeUpdate() > 0;
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

         return var6;
      } catch (Exception e) {
         e.printStackTrace();
         return false;
      }
   }

   public boolean assignDelivery(int orderId, int agentId) {
      String sql = "INSERT INTO deliveries (order_id, delivery_agent_id, delivery_status, assigned_date) VALUES (?, ?, 'ASSIGNED', NOW())";

      try {
         Connection conn = DBConnection.getConnection();

         boolean var6;
         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ps.setInt(1, orderId);
               ps.setInt(2, agentId);
               var6 = ps.executeUpdate() > 0;
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

         return var6;
      } catch (Exception e) {
         e.printStackTrace();
         return false;
      }
   }

   public List<Order> getDeliveriesByAgent(int agentId) {
      List<Order> list = new ArrayList();
      String sql = "SELECT o.*, d.delivery_status FROM orders o JOIN deliveries d ON o.order_id = d.order_id WHERE d.delivery_agent_id = ? ORDER BY o.order_date DESC";

      try {
         Connection conn = DBConnection.getConnection();

         try {
            PreparedStatement ps = conn.prepareStatement(sql);

            try {
               ps.setInt(1, agentId);
               ResultSet rs = ps.executeQuery();

               try {
                  while(rs.next()) {
                     Order o = new Order();
                     o.setOrderId(rs.getInt("order_id"));
                     o.setUserId(rs.getInt("user_id"));
                     o.setDeliveryAddress(rs.getString("delivery_address"));
                     o.setDeliveryTime(rs.getString("delivery_time"));
                     o.setOrderStatus(rs.getString("delivery_status"));
                     o.setTotalAmount(rs.getDouble("total_amount"));
                     list.add(o);
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

      return list;
   }

   public boolean updateDeliveryStatus(int orderId, int agentId, String deliveryStatus) {
      String deliverySql = "UPDATE deliveries SET delivery_status = ?, delivered_date = CASE WHEN ? = 'DELIVERED' THEN NOW() ELSE delivered_date END WHERE order_id = ? AND delivery_agent_id = ?";
      String orderSql = "UPDATE orders SET order_status = ? WHERE order_id = ?";

      try {
         Connection conn = DBConnection.getConnection();

         boolean var19;
         try {
            conn.setAutoCommit(false);
            PreparedStatement deliveryPs = conn.prepareStatement(deliverySql);

            try {
               deliveryPs.setString(1, deliveryStatus);
               deliveryPs.setString(2, deliveryStatus);
               deliveryPs.setInt(3, orderId);
               deliveryPs.setInt(4, agentId);
               deliveryPs.executeUpdate();
            } catch (Throwable var15) {
               if (deliveryPs != null) {
                  try {
                     deliveryPs.close();
                  } catch (Throwable var13) {
                     var15.addSuppressed(var13);
                  }
               }

               throw var15;
            }

            if (deliveryPs != null) {
               deliveryPs.close();
            }

            String orderStatus;
            if ("PICKED_UP".equals(deliveryStatus)) {
               orderStatus = "PROCESSING";
            } else if ("IN_TRANSIT".equals(deliveryStatus)) {
               orderStatus = "OUT_FOR_DELIVERY";
            } else if ("DELIVERED".equals(deliveryStatus)) {
               orderStatus = "DELIVERED";
            } else if ("FAILED".equals(deliveryStatus)) {
               orderStatus = "CONFIRMED";
            } else {
               orderStatus = "CONFIRMED";
            }

            PreparedStatement orderPs = conn.prepareStatement(orderSql);

            try {
               orderPs.setString(1, orderStatus);
               orderPs.setInt(2, orderId);
               orderPs.executeUpdate();
            } catch (Throwable var14) {
               if (orderPs != null) {
                  try {
                     orderPs.close();
                  } catch (Throwable var12) {
                     var14.addSuppressed(var12);
                  }
               }

               throw var14;
            }

            if (orderPs != null) {
               orderPs.close();
            }

            conn.commit();
            var19 = true;
         } catch (Throwable var16) {
            if (conn != null) {
               try {
                  conn.close();
               } catch (Throwable var11) {
                  var16.addSuppressed(var11);
               }
            }

            throw var16;
         }

         if (conn != null) {
            conn.close();
         }

         return var19;
      } catch (Exception e) {
         e.printStackTrace();
         return false;
      }
   }
}
