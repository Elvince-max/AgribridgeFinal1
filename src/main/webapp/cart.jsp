<%@ page import="java.util.*, com.agribridgef1.dao.ProductDAO, com.agribridgef1.model.Product" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    boolean loggedIn = session.getAttribute("userId") != null;

    if (!loggedIn) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userType = (String) session.getAttribute("userType");

    if (userType == null) {
        userType = "";
    }

    userType = userType.trim().toUpperCase();

    boolean isCustomer = "CUSTOMER".equals(userType);

    if (!isCustomer) {
        response.sendRedirect("login.jsp");
        return;
    }

    ProductDAO dao = new ProductDAO();

    Map<Integer, Integer> cart = (Map<Integer, Integer>) session.getAttribute("cart");

    if (cart == null) {
        cart = new HashMap<>();
        session.setAttribute("cart", cart);
    }

    double subtotal = 0;
    int cartCount = 0;

    List<Product> cartProducts = new ArrayList<>();

    for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
        Product product = dao.getProductById(entry.getKey());

        if (product != null) {
            cartProducts.add(product);

            int quantity = entry.getValue();
            subtotal += product.getPrice() * quantity;
            cartCount += quantity;
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Your Cart - Egerton AgriBridge Hub</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- CSS order matters -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/base.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/components.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/cart.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/responsive.css?v=1">
</head>

<body class="cart-body">

<div class="cart-shell">

    <!-- SIDEBAR -->
    <aside class="cart-sidebar">
        <div class="cart-brand">
            <div class="cart-brand-mark">🌿</div>
            <div>
                <h2>AgriBridge</h2>
                <p>Customer Portal</p>
            </div>
        </div>

        <nav class="cart-menu">
            <a href="customerDashboard.jsp">
                <span>▦</span>
                Dashboard
            </a>

            <a href="products.jsp">
                <span>🛒</span>
                Marketplace
            </a>

            <a href="myOrders.jsp">
                <span>▤</span>
                My Orders
            </a>

            <a href="profile.jsp">
                <span>👤</span>
                Profile
            </a>

            <a href="cart.jsp" class="active">
                <span>🧺</span>
                Cart
            </a>
        </nav>

        <div class="cart-sidebar-promo">
            <h3>Your Fresh Basket</h3>
            <p>Review quantities, remove items, then continue to checkout.</p>
            <a href="products.jsp">Continue Shopping</a>
        </div>

        <div class="cart-sidebar-bottom">
            <a href="logout" onclick="return confirm('Are you sure you want to logout?');">
                ⎋ Logout
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="cart-main">

        <!-- MOBILE TOP BAR -->
        <header class="cart-mobile-topbar">
            <a href="products.jsp" aria-label="Marketplace">←</a>
            <strong>My Cart</strong>
            <div>
                <a href="myOrders.jsp" aria-label="Orders">📦</a>
                <a href="profile.jsp" aria-label="Profile">👤</a>
            </div>
        </header>

        <!-- DESKTOP TOP BAR -->
        <header class="cart-topbar">
            <div>
                <h1>Your Cart</h1>
                <p>Review your fresh dairy basket before checkout.</p>
            </div>

            <div class="cart-top-actions">
                <a href="products.jsp" class="cart-top-btn">Continue Shopping</a>

                <a class="cart-icon-btn active" href="cart.jsp" title="Cart">
                    🛒
                    <% if (cartCount > 0) { %>
                        <span><%= cartCount %></span>
                    <% } %>
                </a>

                <a class="cart-profile-btn" href="customerDashboard.jsp" title="Dashboard">👤</a>
            </div>
        </header>

        <div class="cart-content">

            <div class="cart-breadcrumb">
                <a href="products.jsp">MARKETPLACE</a>
                <span>›</span>
                <strong>SHOPPING CART</strong>
            </div>

            <section class="cart-hero-card">
                <div>
                    <p class="cart-eyebrow">FRESH DAIRY BASKET</p>
                    <h2>Your Harvest Basket</h2>
                    <p>
                        Confirm your selected dairy products, update quantities,
                        and proceed to delivery or campus pickup checkout.
                    </p>
                </div>

                <div class="cart-hero-summary">
                    <span>Items</span>
                    <strong><%= cartCount %></strong>
                    <small>Total before delivery</small>
                    <b>KES <%= String.format("%,.2f", subtotal) %></b>
                </div>
            </section>

            <% if (cartProducts.isEmpty()) { %>

                <div class="cart-empty-state">
                    <div class="cart-empty-icon">🧺</div>
                    <h2>Your basket is empty</h2>
                    <p>Browse fresh dairy products and add items to begin checkout.</p>
                    <a href="products.jsp">Continue Shopping</a>
                </div>

            <% } else { %>

                <div class="cart-layout">

                    <!-- CART ITEMS -->
                    <section class="cart-items-card">

                        <div class="cart-card-header">
                            <div>
                                <h2>Cart Items</h2>
                                <p><%= cartCount %> item<%= cartCount == 1 ? "" : "s" %> selected.</p>
                            </div>

                            <a href="cart?action=clear"
                               onclick="return confirm('Empty your entire cart?');">
                                Empty Cart
                            </a>
                        </div>

                        <div class="cart-table-head">
                            <span>Product</span>
                            <span>Quantity</span>
                            <span>Price</span>
                            <span>Subtotal</span>
                        </div>

                        <%
                            for (Product p : cartProducts) {
                                int quantity = cart.get(p.getProductId());
                                double itemSubtotal = p.getPrice() * quantity;
                        %>

                            <article class="cart-item">

                                <div class="cart-product-cell">
                                    <% if (p.getImageUrl() != null && !p.getImageUrl().isEmpty()) { %>
                                        <img src="<%= request.getContextPath() + "/" + p.getImageUrl() %>"
                                             alt="<%= p.getProductName() %>"
                                             loading="lazy">
                                    <% } else { %>
                                        <div class="cart-no-image">No Image</div>
                                    <% } %>

                                    <div>
                                        <h3><%= p.getProductName() %></h3>
                                        <p><%= p.getDescription() %></p>

                                        <% if (quantity >= p.getStockQuantity()) { %>
                                            <small class="cart-stock-warning">
                                                Maximum available stock selected
                                            </small>
                                        <% } %>

                                        <a class="cart-remove"
                                           href="cart?action=remove&id=<%= p.getProductId() %>"
                                           onclick="return confirm('Remove this item from cart?');">
                                            🗑 Remove
                                        </a>
                                    </div>
                                </div>

                                <div class="cart-quantity-cell">
                                    <a href="cart?action=decrease&id=<%= p.getProductId() %>">−</a>
                                    <strong><%= quantity %></strong>

                                    <% if (quantity < p.getStockQuantity()) { %>
                                        <a href="cart?action=increase&id=<%= p.getProductId() %>">+</a>
                                    <% } else { %>
                                        <span class="qty-disabled">+</span>
                                    <% } %>
                                </div>

                                <div class="cart-price-cell">
                                    <small>Price</small>
                                    <strong>KES <%= String.format("%.2f", p.getPrice()) %></strong>
                                </div>

                                <div class="cart-subtotal-cell">
                                    <small>Subtotal</small>
                                    <strong>KES <%= String.format("%.2f", itemSubtotal) %></strong>
                                </div>

                            </article>

                        <%
                            }
                        %>

                    </section>

                    <!-- SUMMARY -->
                    <aside class="cart-summary-card">
                        <h2>Cart Total</h2>

                        <div class="summary-row">
                            <span>Subtotal</span>
                            <strong>KES <%= String.format("%.2f", subtotal) %></strong>
                        </div>

                        <div class="summary-row">
                            <span>Delivery / Pickup</span>
                            <strong>Selected at checkout</strong>
                        </div>

                        <small class="cart-estimate-note">
                            Choose campus pickup or a delivery zone during checkout.
                        </small>

                        <hr>

                        <div class="summary-total">
                            <span>Total before delivery</span>
                            <strong>KES <%= String.format("%.2f", subtotal) %></strong>
                        </div>

                        <a class="checkout-main-btn" href="checkout.jsp">
                            Proceed to Checkout
                        </a>

                        <div class="mpesa-checkout-note">
                            <div>M</div>
                            <div>
                                <h4>M-Pesa Direct Checkout</h4>
                                <p>Securely pay via M-Pesa STK Push after confirming pickup or delivery.</p>
                            </div>
                        </div>

                        <div class="cart-security-icons">
                            <span>🛡️</span>
                            <span>🔒</span>
                            <span>✅</span>
                        </div>
                    </aside>

                </div>

            <% } %>

        </div>

    </main>

</div>

<% if (!cartProducts.isEmpty()) { %>
    <aside class="cart-mobile-summary">
        <div>
            <span>Total</span>
            <strong>KES <%= String.format("%,.2f", subtotal) %></strong>
        </div>

        <a href="checkout.jsp">
            Checkout
        </a>
    </aside>
<% } %>

<!-- MOBILE BOTTOM NAV -->
<nav class="cart-bottom-nav">
    <a href="customerDashboard.jsp">
        <span>⌂</span>
        Home
    </a>

    <a href="myOrders.jsp">
        <span>📦</span>
        Orders
    </a>

    <a href="products.jsp">
        <span>🛒</span>
        Shop
    </a>

    <a href="cart.jsp" class="active">
        <span>🧺</span>
        Cart
    </a>
</nav>

</body>
</html>
