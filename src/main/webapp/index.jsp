<%@ page import="java.util.*, com.agribridgef1.dao.ProductDAO, com.agribridgef1.model.Product" %>
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
    List<Product> products = dao.getAllProducts();

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

    /*
       Recommended hero image names.
       Put these inside: src/main/webapp/uploads/

       IMPORTANT:
       - Use the same names below or change them here.
       - Avoid spaces in image filenames.
       - Compress images for fast loading.
    */
    String heroImage1 = request.getContextPath() + "/uploads/milk-cow.jpg";
    String heroImage2 = request.getContextPath() + "/uploads/milking_man.jpg";
    String heroImage3 = request.getContextPath() + "/uploads/egerton_gate.jpg";
%>

<!DOCTYPE html>
<html>
<head>
    <title>Egerton AgriBridge Hub</title>
    <meta charset="UTF-8">

    <!-- Very important for phone responsiveness -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- Preload first hero image to avoid the ugly blank image start -->
    <link rel="preload" as="image" href="<%= heroImage1 %>">

    <!-- CSS order matters: base first, components second, page CSS third, responsive last -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/base.css?v=2">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/components.css?v=2">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/landing.css?v=2">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/responsive.css?v=2">
</head>

<body class="landing-body modern-landing-body">

<!-- =========================
     NAVBAR
========================= -->
<header class="modern-navbar">

    <button class="mobile-menu-btn" type="button" onclick="toggleMobileMenu()" aria-label="Open menu">
        ☰
    </button>

    <a href="index.jsp" class="modern-logo">
        EgertonAgriBridgeHub
    </a>

    <nav class="modern-nav-links">
        <a href="index.jsp" class="active">Home</a>
        <a href="products.jsp">Marketplace</a>
        <a href="#process">Process</a>
        <a href="#heritage">About</a>

        <% if (loggedIn) { %>
            <a href="<%= dashboardLink %>">Dashboard</a>

            <% if (isAdmin) { %>
                <a href="manageProducts.jsp">Products</a>
                <a href="manageOrders.jsp">Orders</a>
            <% } else if (isCustomer) { %>
                <a href="myOrders.jsp">Orders</a>
            <% } else if (isDeliveryAgent) { %>
                <a href="delivery.jsp">Deliveries</a>
            <% } %>

        <% } else { %>
            <a href="login.jsp">Login</a>
            <a href="register.jsp">Register</a>
        <% } %>
    </nav>

    <div class="modern-nav-actions">
<!--        <a href="products.jsp" class="modern-icon-link" title="Search">
            🔍
        </a>-->

        <% if (isCustomer) { %>
            <a href="cart.jsp" class="modern-cart-link" title="Cart">
                🛒
                <span id="cartCountBadge" class="<%= cartCount > 0 ? "" : "hidden" %>">
                    <%= cartCount %>
                </span>
            </a>
        <% } else { %>
            <a href="products.jsp" class="modern-cart-link" title="Marketplace">
                🛒
            </a>
        <% } %>

        <% if (loggedIn) { %>
            <a href="logout" class="modern-login-btn">Logout</a>
        <% } else { %>
            <a href="login.jsp" class="modern-login-btn">Login</a>
        <% } %>
    </div>
</header>

<!-- MOBILE SIDE DRAWER MENU -->
<div id="mobileMenuOverlay" class="mobile-menu-overlay" onclick="closeMobileMenu()"></div>

<aside id="mobileMenu" class="modern-mobile-menu" aria-label="Mobile navigation menu">
    <div class="mobile-menu-header">
        <strong>EgertonAgriBridgeHub</strong>
        <button type="button" onclick="closeMobileMenu()" aria-label="Close menu">×</button>
    </div>

    <a href="index.jsp">Home</a>
    <a href="products.jsp">Marketplace</a>
    <a href="#process">Process</a>
    <a href="#heritage">About</a>

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
     HERO SLIDESHOW
========================= -->
<section class="hero-modern is-loading">

    <div class="hero-slideshow">

        <!-- The first slide MUST have active, otherwise the page starts blank -->
        <div class="hero-slide active"
             style="background-image: url('<%= heroImage1 %>');">
        </div>

        <div class="hero-slide"
             style="background-image: url('<%= heroImage2 %>');">
        </div>

        <div class="hero-slide"
             style="background-image: url('<%= heroImage3 %>');">
        </div>

    </div>

    <div class="hero-dark-overlay"></div>

    <div class="hero-inner">
        <p class="hero-eyebrow">🌿 FARM TO TABLE, DIGITALLY</p>

        <h1>
            Fresh Dairy,<br>
            From Farm to Table
        </h1>

        <p class="hero-subtext">
            Premium Egerton dairy products, crafted with care and delivered
            through a clean, traceable digital ordering experience.
        </p>

        <div class="hero-modern-actions">
            <a class="hero-primary-btn" href="products.jsp">
                Shop Now →
            </a>

            <% if (loggedIn) { %>
                <a class="hero-secondary-btn" href="<%= dashboardLink %>">
                    Dashboard
                </a>
            <% } else { %>
                <a class="hero-secondary-btn" href="login.jsp">
                    Login to Order
                </a>
            <% } %>
        </div>
    </div>

</section>

<!-- =========================
     FLOATING BENEFITS STRIP
========================= -->
<section class="hero-benefit-strip reveal-on-scroll">

    <div class="benefit-item">
        <div class="benefit-icon">🌿</div>
        <div>
            <h4>Farm Fresh</h4>
            <p>Sourced fresh from trusted Egerton farms.</p>
        </div>
    </div>

    <div class="benefit-item">
        <div class="benefit-icon">🛡️</div>
        <div>
            <h4>Quality Assured</h4>
            <p>Tested for premium quality and food safety.</p>
        </div>
    </div>

    <div class="benefit-item">
        <div class="benefit-icon">🚚</div>
        <div>
            <h4>Delivered Fresh</h4>
            <p>Cold-chain care keeps your order fresh.</p>
        </div>
    </div>

</section>

<!-- =========================
     FEATURED PRODUCTS
========================= -->
<section class="modern-products-section" id="products">

    <div class="modern-section-heading">
        <div>
            <p class="eyebrow">PREMIUM SELECTION</p>
            <h2>Featured Dairy Products</h2>
        </div>

        <a href="products.jsp">View all products →</a>
    </div>

    <div class="modern-featured-grid">

        <%
            int count = 0;

            for (Product p : products) {
                if (count >= 4) break;
                count++;

                String stockLabel;
                String stockClass;

                if (p.getStockQuantity() <= 0) {
                    stockLabel = "OUT OF STOCK";
                    stockClass = "out";
                } else if (p.getStockQuantity() >= 1 && p.getStockQuantity() <= 5) {
                    stockLabel = "LOW STOCK";
                    stockClass = "low";
                } else {
                    stockLabel = "FRESH";
                    stockClass = "in";
                }
        %>

        <div class="modern-product-card reveal-on-scroll">

            <div class="modern-product-image-wrap">
                <span class="modern-stock-badge <%= stockClass %>">
                    <%= stockLabel %>
                </span>

                <% if (p.getImageUrl() != null && !p.getImageUrl().isEmpty()) { %>
                    <img src="<%= request.getContextPath() + "/" + p.getImageUrl() %>"
                         alt="<%= p.getProductName() %>"
                         loading="lazy">
                <% } else { %>
                    <div class="modern-no-image">No Image</div>
                <% } %>

                <a class="modern-heart-btn" href="productDetails.jsp?id=<%= p.getProductId() %>">
                    ♡
                </a>
            </div>

            <div class="modern-product-info">
                <h3><%= p.getProductName() %></h3>
                <p><%= p.getDescription() %></p>

                <strong>KES <%= String.format("%.2f", p.getPrice()) %></strong>

                <div class="modern-product-actions">
                    <a class="modern-details-btn"
                       href="productDetails.jsp?id=<%= p.getProductId() %>">
                        Details
                    </a>

                    <% if (p.getStockQuantity() <= 0) { %>
                        <button class="modern-add-cart-btn disabled" disabled>
                            🛒 Add
                        </button>

                    <% } else if (loggedIn && isCustomer) { %>
                        <a class="modern-add-cart-btn"
                           href="cart?id=<%= p.getProductId() %>"
                           onclick="addToCart(event, this)"
                           data-price="<%= p.getPrice() %>">
                            🛒 Add to Cart
                        </a>

                    <% } else if (loggedIn && !isCustomer) { %>
                        <a class="modern-add-cart-btn" href="<%= dashboardLink %>">
                            🛒 Dashboard
                        </a>

                    <% } else { %>
                        <a class="modern-add-cart-btn" href="login.jsp">
                            🛒 Add to Cart
                        </a>
                    <% } %>
                </div>
            </div>
        </div>

        <%
            }
        %>

    </div>
</section>

<!-- =========================
     EXTRA TRUST STRIP
========================= -->
<section class="modern-trust-strip reveal-on-scroll">

    <div>
        <span>🚜</span>
        <h4>Support Local Farmers</h4>
        <p>Empowering Egerton farming communities.</p>
    </div>

    <div>
        <span>🌱</span>
        <h4>Sustainable Practices</h4>
        <p>Committed to ethical sourcing and the environment.</p>
    </div>

    <div>
        <span>✅</span>
        <h4>Traceable & Trusted</h4>
        <p>End-to-end traceability for peace of mind.</p>
    </div>

</section>

<!-- =========================
     PROCESS
========================= -->
<section class="process-section modern-process-section reveal-on-scroll" id="process">

    <p class="eyebrow center">OUR PROCESS</p>

    <h2>Farm-to-Table Efficiency</h2>

    <p class="process-intro">
        A simple digital path from browsing to payment and fresh delivery.
    </p>

    <div class="process-grid modern-process-grid">

        <div class="process-card">
            <div class="process-icon">🔍</div>
            <span>1</span>
            <h3>Browse</h3>
            <p>Explore fresh milk, yoghurt, cheese, butter and more.</p>
        </div>

        <div class="process-card highlight">
            <div class="process-icon">💳</div>
            <span>2</span>
            <h3>Order & Pay</h3>
            <p>Checkout securely using M-Pesa or cash on delivery.</p>
        </div>

        <div class="process-card">
            <div class="process-icon">🚚</div>
            <span>3</span>
            <h3>Delivered</h3>
            <p>Your order is assigned, tracked and delivered fresh.</p>
        </div>

    </div>
</section>

<!-- =========================
     HERITAGE
========================= -->
<section class="heritage-section modern-heritage-section reveal-on-scroll" id="heritage">

    <div class="heritage-panel">
        <p class="eyebrow gold">OUR HERITAGE</p>

        <h2>Egerton. Heritage in Every Drop.</h2>

        <p>
            Egerton AgriBridge Hub connects customers to trusted agricultural products
            through a modern digital marketplace for ordering, payment, delivery and management.
        </p>

        <div class="heritage-stats">
            <div>
                <h3>80+</h3>
                <p>Years of Excellence</p>
            </div>

            <div>
                <h3>100%</h3>
                <p>Farm Sourced</p>
            </div>

            <div>
                <h3>24/7</h3>
                <p>Digital Access</p>
            </div>
        </div>
    </div>

    <div class="heritage-image">
        <img src="<%= request.getContextPath() %>/uploads/egerton_gate.jpg"
             alt="Egerton farm landscape"
             loading="lazy">

        <div class="quality-card">
            <h3>Guaranteed Quality</h3>
            <p>Handled with care for freshness, safety and trust.</p>
        </div>
    </div>

</section>

<!-- =========================
     FOOTER
========================= -->
<footer class="landing-footer modern-footer">

    <div>
        <h3>EgertonAgriBridgeHub</h3>
        <p>Bridging farm to table, digitally.</p>
    </div>

    <div class="footer-links">
        <a href="products.jsp">Marketplace</a>

        <% if (loggedIn) { %>
            <a href="<%= dashboardLink %>">Dashboard</a>
            <a href="logout">Logout</a>
        <% } else { %>
            <a href="login.jsp">Login</a>
            <a href="register.jsp">Register</a>
        <% } %>

        <a href="#">Privacy Policy</a>
        <a href="#">Terms of Service</a>
    </div>

</footer>

<!-- =========================
     PHONE BOTTOM NAV
========================= -->
<nav class="mobile-bottom-nav">

    <a href="index.jsp" class="active">
        <span>⌂</span>
        Home
    </a>

    <a href="products.jsp">
        <span>🏬</span>
        Marketplace
    </a>

    <% if (loggedIn && isCustomer) { %>
        <a href="myOrders.jsp">
            <span>📦</span>
            Orders
        </a>

        <a href="customerDashboard.jsp">
            <span>👤</span>
            Account
        </a>
    <% } else if (loggedIn && isAdmin) { %>
        <a href="manageOrders.jsp">
            <span>📦</span>
            Orders
        </a>

        <a href="adminDashboard.jsp">
            <span>👤</span>
            Admin
        </a>
    <% } else if (loggedIn && isDeliveryAgent) { %>
        <a href="delivery.jsp">
            <span>🚚</span>
            Delivery
        </a>

        <a href="logout">
            <span>↪</span>
            Logout
        </a>
    <% } else { %>
        <a href="login.jsp">
            <span>👤</span>
            Login
        </a>

        <a href="register.jsp">
            <span>＋</span>
            Register
        </a>
    <% } %>

</nav>

<!-- =========================
     JAVASCRIPT
========================= -->
<script>
    let cartCount = <%= cartCount %>;
    let cartTotal = <%= cartTotal %>;

    function toggleMobileMenu() {
        const menu = document.getElementById("mobileMenu");
        const overlay = document.getElementById("mobileMenuOverlay");

        if (!menu || !overlay) {
            return;
        }

        menu.classList.toggle("show");
        overlay.classList.toggle("show");
        document.body.classList.toggle("menu-open");
    }

    function closeMobileMenu() {
        const menu = document.getElementById("mobileMenu");
        const overlay = document.getElementById("mobileMenuOverlay");

        if (!menu || !overlay) {
            return;
        }

        menu.classList.remove("show");
        overlay.classList.remove("show");
        document.body.classList.remove("menu-open");
    }

    // Close mobile drawer when a link is clicked
    document.querySelectorAll(".modern-mobile-menu a").forEach(function(link) {
        link.addEventListener("click", function() {
            closeMobileMenu();
        });
    });

    // Close mobile drawer using Escape key
    document.addEventListener("keydown", function(event) {
        if (event.key === "Escape") {
            closeMobileMenu();
        }
    });

    // Hero loading and slideshow.
    // This prevents the slideshow from starting before the first background is ready.
    const hero = document.querySelector(".hero-modern");
    const heroSlides = document.querySelectorAll(".hero-slide");
    let currentHeroSlide = 0;
    let heroTimer = null;

    function startHeroSlideshow() {
        if (heroTimer || heroSlides.length <= 1) {
            return;
        }

        heroTimer = setInterval(function() {
            heroSlides[currentHeroSlide].classList.remove("active");

            currentHeroSlide = (currentHeroSlide + 1) % heroSlides.length;

            heroSlides[currentHeroSlide].classList.add("active");
        }, 4800);
    }

    function loadFirstHeroImageThenStart() {
        if (!hero || heroSlides.length === 0) {
            return;
        }

        const firstSlideStyle = heroSlides[0].getAttribute("style");
        const match = firstSlideStyle.match(/url\(['"]?(.*?)['"]?\)/);

        if (!match || !match[1]) {
            hero.classList.remove("is-loading");
            startHeroSlideshow();
            return;
        }

        const firstImage = new Image();

        firstImage.onload = function() {
            hero.classList.remove("is-loading");
            heroSlides[0].classList.add("active");
            startHeroSlideshow();
        };

        firstImage.onerror = function() {
            hero.classList.remove("is-loading");
            heroSlides[0].classList.add("active");
            startHeroSlideshow();
        };

        firstImage.src = match[1];
    }

    loadFirstHeroImageThenStart();

    // Light scroll animation. This is decorative, not required for navigation.
    const revealItems = document.querySelectorAll(".reveal-on-scroll");

    if ("IntersectionObserver" in window) {
        const observer = new IntersectionObserver(function(entries) {
            entries.forEach(function(entry) {
                if (entry.isIntersecting) {
                    entry.target.classList.add("revealed");
                    observer.unobserve(entry.target);
                }
            });
        }, {
            threshold: 0.12
        });

        revealItems.forEach(function(item) {
            observer.observe(item);
        });
    } else {
        revealItems.forEach(function(item) {
            item.classList.add("revealed");
        });
    }

    // Add to cart without forcing user to leave the page
    function addToCart(event, link) {
        event.preventDefault();

        const url = link.getAttribute("href");
        const price = parseFloat(link.getAttribute("data-price"));

        const originalText = link.innerHTML;
        link.innerHTML = "✓ Added";
        link.style.pointerEvents = "none";

        fetch(url, {
            method: "GET"
        })
        .then(response => {
            if (response.ok) {
                cartCount++;
                cartTotal += price;

                const badge = document.getElementById("cartCountBadge");

                if (badge) {
                    badge.innerText = cartCount;
                    badge.classList.remove("hidden");
                }

                setTimeout(() => {
                    link.innerHTML = originalText;
                    link.style.pointerEvents = "auto";
                }, 900);

            } else {
                link.innerHTML = "!";
                link.style.pointerEvents = "auto";
            }
        })
        .catch(error => {
            console.log(error);
            link.innerHTML = "!";
            link.style.pointerEvents = "auto";
        });
    }
</script>

</body>
</html>