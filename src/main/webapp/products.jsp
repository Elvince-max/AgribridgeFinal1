<%@ page import="java.util.*, com.agribridgef1.dao.*, com.agribridgef1.model.Product" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    boolean loggedIn = session.getAttribute("userId") != null;

    String userType = (String) session.getAttribute("userType");
    if (userType == null) {
        userType = "";
    }
    userType = userType.trim().toUpperCase();

    boolean isCustomer = loggedIn && "CUSTOMER".equals(userType);
    boolean isAdmin = loggedIn && ("ADMIN".equals(userType) || "STAFF".equals(userType));
    boolean isDeliveryAgent = loggedIn && "DELIVERY_AGENT".equals(userType);

    String dashboardLink = "products.jsp";

    if (isCustomer) {
        dashboardLink = "customerDashboard.jsp";
    } else if (isAdmin) {
        dashboardLink = "adminDashboard.jsp";
    } else if (isDeliveryAgent) {
        dashboardLink = "delivery.jsp";
    }

    ProductDAO dao = new ProductDAO();
    CategoryDAO categoryDAO = new CategoryDAO();

    String keyword = request.getParameter("search");
    String categoryParam = request.getParameter("category");

    List<Product> products;

    if (categoryParam != null && !categoryParam.trim().isEmpty()) {
        try {
            int categoryId = Integer.parseInt(categoryParam);
            products = dao.getProductsByCategory(categoryId);
        } catch (NumberFormatException ex) {
            products = dao.getAllProducts();
            categoryParam = "";
        }
    } else if (keyword != null && !keyword.trim().isEmpty()) {
        products = dao.searchProducts(keyword.trim());
    } else {
        products = dao.getAllProducts();
    }

    Map<Integer, String> categories = categoryDAO.getAllCategories();

    double cartTotal = 0;
    int cartCount = 0;

    Object cartObject = session.getAttribute("cart");

    if (cartObject instanceof Map) {
        Map<Integer, Integer> cart = (Map<Integer, Integer>) cartObject;

        for (Map.Entry<Integer, Integer> entry : cart.entrySet()) {
            Product cartProduct = dao.getProductById(entry.getKey());

            if (cartProduct != null) {
                int quantity = entry.getValue();
                cartTotal += cartProduct.getPrice() * quantity;
                cartCount += quantity;
            }
        }
    }

    int productCount = products != null ? products.size() : 0;
%>

<!DOCTYPE html>
<html>
<head>
    <title>Marketplace - Egerton AgriBridge Hub</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- CSS order matters -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/base.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/components.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/marketplace.css?v=2">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/responsive.css?v=1">
</head>

<body class="market-body">

<!-- =========================
     MARKETPLACE NAVBAR
========================= -->
<header class="market-navbar">

    <button class="market-menu-btn" type="button" onclick="toggleMarketMenu()" aria-label="Open menu">
        ☰
    </button>

    <a class="market-logo" href="index.jsp">
        EgertonAgriBridgeHub
    </a>

    <nav class="market-nav-links">
        <a href="index.jsp">Home</a>
        <a href="products.jsp" class="active">Marketplace</a>
        <a href="index.jsp#process">Process</a>
        <a href="index.jsp#heritage">About</a>

        <% if (loggedIn) { %>
            <a href="<%= dashboardLink %>">Dashboard</a>

            <% if (isCustomer) { %>
                <a href="myOrders.jsp">Orders</a>
            <% } else if (isAdmin) { %>
                <a href="manageProducts.jsp">Products</a>
                <a href="manageOrders.jsp">Orders</a>
            <% } else if (isDeliveryAgent) { %>
                <a href="delivery.jsp">Deliveries</a>
            <% } %>
        <% } else { %>
            <a href="login.jsp">Login</a>
        <% } %>
    </nav>

    <div class="market-nav-right">
        <form method="get" action="products.jsp" class="market-search">
            <input type="text"
                   name="search"
                   placeholder="Search dairy..."
                   value="<%= keyword != null ? keyword : "" %>">
            <button type="submit" aria-label="Search">⌕</button>
        </form>

        <% if (isCustomer) { %>
            <a class="market-cart-icon" href="cart.jsp" title="Cart">
                🛒
                <span id="cartCountBadge" class="<%= cartCount > 0 ? "" : "hidden" %>">
                    <%= cartCount %>
                </span>
            </a>
        <% } else { %>
            <a class="market-cart-icon" href="products.jsp" title="Marketplace">
                🛒
            </a>
        <% } %>
    </div>
</header>

<!-- MOBILE SIDE DRAWER MENU -->
<div id="marketMenuOverlay" class="market-menu-overlay" onclick="closeMarketMenu()"></div>

<aside id="marketMobileMenu" class="market-mobile-menu" aria-label="Mobile marketplace menu">
    <div class="market-mobile-menu-header">
        <strong>EgertonAgriBridgeHub</strong>
        <button type="button" onclick="closeMarketMenu()" aria-label="Close menu">×</button>
    </div>

    <a href="index.jsp">Home</a>
    <a href="products.jsp">Marketplace</a>
    <a href="index.jsp#process">Process</a>
    <a href="index.jsp#heritage">About</a>

    <% if (loggedIn) { %>
        <a href="<%= dashboardLink %>">Dashboard</a>

        <% if (isCustomer) { %>
            <a href="cart.jsp">Cart</a>
            <a href="myOrders.jsp">My Orders</a>
        <% } else if (isAdmin) { %>
            <a href="manageProducts.jsp">Products</a>
            <a href="manageOrders.jsp">Orders</a>
        <% } else if (isDeliveryAgent) { %>
            <a href="delivery.jsp">My Deliveries</a>
        <% } %>

        <a href="logout">Logout</a>
    <% } else { %>
        <a href="login.jsp">Login</a>
        <a href="register.jsp">Register</a>
    <% } %>
</aside>

<!-- =========================
     MARKET HERO
========================= -->
<section class="market-header">
    <div>
        <p class="market-eyebrow">FRESH EGERTON DAIRY</p>
        <h1>The Dairy Collection</h1>
        <p>
            Fresh from the pastures of Egerton University. Browse trusted dairy products,
            add items to your cart, and complete checkout with ease.
        </p>
    </div>

    <div class="market-header-card">
        <span>Available products</span>
        <strong><%= productCount %></strong>
        <small>Milk • Yoghurt • Cheese • Butter • Ghee</small>
    </div>
</section>

<!-- =========================
     MOBILE SEARCH
========================= -->
<section class="market-mobile-search-section">
    <form method="get" action="products.jsp" class="market-mobile-search">
        <input type="text"
               name="search"
               placeholder="Search dairy..."
               value="<%= keyword != null ? keyword : "" %>">
        <button type="submit">Search</button>
    </form>
</section>

<!-- =========================
     CATEGORY TABS
========================= -->
<section class="market-tabs-wrap">
    <div class="market-tabs">

        <a class="<%= (categoryParam == null || categoryParam.isEmpty()) ? "active" : "" %>"
           href="products.jsp">
           All Products
        </a>

        <%
            for (Map.Entry<Integer, String> entry : categories.entrySet()) {
                String activeClass = "";

                if (categoryParam != null && categoryParam.equals(String.valueOf(entry.getKey()))) {
                    activeClass = "active";
                }
        %>
            <a class="<%= activeClass %>"
               href="products.jsp?category=<%= entry.getKey() %>">
               <%= entry.getValue() %>
            </a>
        <%
            }
        %>

    </div>
</section>

<!-- =========================
     PRODUCTS
========================= -->
<section class="market-products">

    <%
        if (products.isEmpty()) {
    %>

        <div class="market-empty">
            <h2>No products found</h2>
            <p>Try searching another product or selecting a different category.</p>
            <a href="products.jsp">View All Products</a>
        </div>

    <%
        } else {
            for (Product p : products) {
                String stockLabel;
                String stockClass;

                if (p.getStockQuantity() <= 0) {
                    stockLabel = "OUT OF STOCK";
                    stockClass = "out";
                } else if (p.getStockQuantity() >= 1 && p.getStockQuantity() <= 5) {
                    stockLabel = "LOW STOCK";
                    stockClass = "low";
                } else {
                    stockLabel = "IN STOCK";
                    stockClass = "in";
                }
    %>

        <article class="market-product-card">

            <a class="market-product-image"
               href="productDetails.jsp?id=<%= p.getProductId() %>">

                <%
                    if (p.getImageUrl() != null && !p.getImageUrl().isEmpty()) {
                %>
                    <img src="<%= request.getContextPath() + "/" + p.getImageUrl() %>"
                         alt="<%= p.getProductName() %>"
                         loading="lazy">
                <%
                    } else {
                %>
                    <div class="market-no-image">No Image</div>
                <%
                    }
                %>

                <span class="market-stock <%= stockClass %>">
                    <%= stockLabel %>
                </span>
            </a>

            <div class="market-product-info">
                <h3><%= p.getProductName() %></h3>

                <p class="market-desc">
                    <%= p.getDescription() %>
                </p>

                <p class="market-price">
                    KES <%= String.format("%.2f", p.getPrice()) %>
                    <span>/ item</span>
                </p>

                <div class="market-card-actions">
                    <a class="market-details-btn"
                       href="productDetails.jsp?id=<%= p.getProductId() %>">
                        Details
                    </a>

                    <%
                        if (p.getStockQuantity() <= 0) {
                    %>
                        <button class="market-cart-btn disabled" disabled>
                            Out
                        </button>
                    <%
                        } else if (isCustomer) {
                    %>
                        <a class="market-cart-btn"
                           href="cart?id=<%= p.getProductId() %>"
                           onclick="addToCart(event, this)"
                           data-price="<%= p.getPrice() %>">
                            🛒 Add
                        </a>
                    <%
                        } else if (loggedIn && !isCustomer) {
                    %>
                        <a class="market-cart-btn"
                           href="<%= dashboardLink %>">
                            Dashboard
                        </a>
                    <%
                        } else {
                    %>
                        <a class="market-cart-btn"
                           href="login.jsp">
                            Login
                        </a>
                    <%
                        }
                    %>
                </div>
            </div>

        </article>

    <%
            }
        }
    %>

</section>

<!-- =========================
     CHECKOUT STRIP
========================= -->
<section class="market-checkout-strip">
    <div>
        <h2>Swift M-Pesa Checkout</h2>
        <p>
            Add dairy items to your cart and continue to checkout when ready.
        </p>
    </div>

    <div class="market-checkout-box">
        <span>Cart Total</span>
        <h3 id="cartTotalText">KES <%= String.format("%.2f", cartTotal) %></h3>

        <%
            if (!loggedIn) {
        %>
            <a href="login.jsp">Login</a>
        <%
            } else if (!isCustomer) {
        %>
            <a href="<%= dashboardLink %>">Dashboard</a>
        <%
            } else {
        %>
            <a id="checkoutBtn"
               href="cart.jsp"
               class="<%= cartTotal > 0 ? "" : "disabled-checkout" %>">
               <%= cartTotal > 0 ? "Checkout" : "Add Items" %>
            </a>
        <%
            }
        %>
    </div>
</section>

<!-- PHONE FIXED CART SUMMARY -->
<% if (isCustomer) { %>
    <aside class="market-mobile-cart-summary">
        <div>
            <span>Cart Total</span>
            <strong id="mobileCartTotalText">KES <%= String.format("%.2f", cartTotal) %></strong>
        </div>
        <a id="mobileCheckoutBtn"
           href="cart.jsp"
           class="<%= cartTotal > 0 ? "" : "disabled-checkout" %>">
            <%= cartTotal > 0 ? "Checkout" : "Cart" %>
        </a>
    </aside>
<% } %>

<!-- =========================
     FOOTER
========================= -->
<footer class="market-footer">
    <div>
        <h3>EgertonAgriBridgeHub</h3>
        <p>© 2024 EgertonAgriBridgeHub. Modern pastoral excellence.</p>
    </div>

    <div class="market-footer-links">
        <a href="#">Privacy Policy</a>
        <a href="#">Terms of Service</a>
        <a href="login.jsp">Farmer Login</a>
        <a href="#">Sustainability</a>
    </div>

    <div class="market-footer-icons">
        🌿 🚜 🚚
    </div>
</footer>

<script>
    let cartCount = <%= cartCount %>;
    let cartTotal = <%= cartTotal %>;

    function toggleMarketMenu() {
        const menu = document.getElementById("marketMobileMenu");
        const overlay = document.getElementById("marketMenuOverlay");

        if (!menu || !overlay) {
            return;
        }

        menu.classList.toggle("show");
        overlay.classList.toggle("show");
        document.body.classList.toggle("menu-open");
    }

    function closeMarketMenu() {
        const menu = document.getElementById("marketMobileMenu");
        const overlay = document.getElementById("marketMenuOverlay");

        if (!menu || !overlay) {
            return;
        }

        menu.classList.remove("show");
        overlay.classList.remove("show");
        document.body.classList.remove("menu-open");
    }

    document.querySelectorAll(".market-mobile-menu a").forEach(function(link) {
        link.addEventListener("click", function() {
            closeMarketMenu();
        });
    });

    document.addEventListener("keydown", function(event) {
        if (event.key === "Escape") {
            closeMarketMenu();
        }
    });

    function addToCart(event, link) {
        event.preventDefault();

        const url = link.getAttribute("href");
        const price = parseFloat(link.getAttribute("data-price"));
        const originalText = link.innerHTML;

        link.innerHTML = "Adding...";
        link.style.pointerEvents = "none";

        fetch(url, {
            method: "GET"
        })
        .then(response => {
            if (response.ok) {
                cartCount++;
                cartTotal += price;

                const badge = document.getElementById("cartCountBadge");
                const totalText = document.getElementById("cartTotalText");
                const mobileTotalText = document.getElementById("mobileCartTotalText");
                const checkoutBtn = document.getElementById("checkoutBtn");
                const mobileCheckoutBtn = document.getElementById("mobileCheckoutBtn");

                if (badge) {
                    badge.innerText = cartCount;
                    badge.classList.remove("hidden");
                }

                if (totalText) {
                    totalText.innerText = "KES " + cartTotal.toFixed(2);
                }

                if (mobileTotalText) {
                    mobileTotalText.innerText = "KES " + cartTotal.toFixed(2);
                }

                if (checkoutBtn) {
                    checkoutBtn.innerText = "Checkout";
                    checkoutBtn.classList.remove("disabled-checkout");
                }

                if (mobileCheckoutBtn) {
                    mobileCheckoutBtn.innerText = "Checkout";
                    mobileCheckoutBtn.classList.remove("disabled-checkout");
                }

                link.innerHTML = "Added ✓";

                setTimeout(() => {
                    link.innerHTML = originalText;
                    link.style.pointerEvents = "auto";
                }, 900);

            } else {
                link.innerHTML = "Try Again";
                link.style.pointerEvents = "auto";
            }
        })
        .catch(error => {
            console.log(error);
            link.innerHTML = "Try Again";
            link.style.pointerEvents = "auto";
        });
    }
</script>

</body>
</html>
