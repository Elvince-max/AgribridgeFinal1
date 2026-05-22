<%@ page import="java.util.*, com.agribridgef1.dao.ProductDAO, com.agribridgef1.model.Product" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    if (session.getAttribute("userType") == null ||
       !"ADMIN".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    ProductDAO dao = new ProductDAO();
    List<Product> allProducts = dao.getAllProductsAdmin();

    String search = request.getParameter("search");
    String stockFilter = request.getParameter("stockFilter");
    String statusFilter = request.getParameter("statusFilter");

    boolean hasSearch = search != null && !search.trim().isEmpty();
    boolean hasStockFilter = stockFilter != null && !stockFilter.trim().isEmpty();
    boolean hasStatusFilter = statusFilter != null && !statusFilter.trim().isEmpty();

    List<Product> products = new ArrayList<>();

    int totalProducts = 0;
    int activeProducts = 0;
    int lowStockProducts = 0;
    int outOfStockProducts = 0;

    for (Product p : allProducts) {
        totalProducts++;

        String currentStatus = p.getStatus();

        if (currentStatus == null || currentStatus.trim().isEmpty()) {
            currentStatus = "ACTIVE";
        }

        if ("ACTIVE".equalsIgnoreCase(currentStatus)) {
            activeProducts++;
        }

        if (p.getStockQuantity() == 0) {
            outOfStockProducts++;
        } else if (p.getStockQuantity() >= 1 && p.getStockQuantity() <= 5) {
            lowStockProducts++;
        }

        boolean matchesSearch = true;
        boolean matchesStock = true;
        boolean matchesStatus = true;

        if (hasSearch) {
            String keyword = search.trim().toLowerCase();

            String productName = p.getProductName() != null ? p.getProductName().toLowerCase() : "";
            String description = p.getDescription() != null ? p.getDescription().toLowerCase() : "";

            matchesSearch = productName.contains(keyword) || description.contains(keyword);
        }

        if (hasStockFilter) {
            if ("IN_STOCK".equals(stockFilter)) {
                matchesStock = p.getStockQuantity() > 5;
            } else if ("LOW_STOCK".equals(stockFilter)) {
                matchesStock = p.getStockQuantity() >= 1 && p.getStockQuantity() <= 5;
            } else if ("OUT_OF_STOCK".equals(stockFilter)) {
                matchesStock = p.getStockQuantity() == 0;
            }
        }

        if (hasStatusFilter) {
            matchesStatus = statusFilter.equalsIgnoreCase(currentStatus);
        }

        if (matchesSearch && matchesStock && matchesStatus) {
            products.add(p);
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Products - Egerton AgriBridge Hub</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- CSS order matters -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/base.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/components.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/manage-products.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/responsive.css?v=1">
</head>

<body class="manage-products-body">

<div class="products-admin-shell">

    <!-- SIDEBAR -->
    <aside class="products-admin-sidebar">
        <div class="products-admin-brand">
            <div class="products-admin-brand-mark">🌿</div>
            <div>
                <h2>AgriBridge</h2>
                <p>Admin Portal</p>
            </div>
        </div>

        <nav class="products-admin-menu">
            <a href="adminDashboard.jsp">
                <span>▦</span>
                Dashboard
            </a>

            <a href="manageProducts.jsp" class="active">
                <span>▣</span>
                Products
            </a>

            <a href="addProduct.jsp">
                <span>＋</span>
                Add Product
            </a>

            <a href="manageOrders.jsp">
                <span>▤</span>
                Orders
            </a>

            <a href="salesReport.jsp">
                <span>▥</span>
                Reports
            </a>

            <a href="products.jsp">
                <span>🛒</span>
                Marketplace
            </a>
        </nav>

        <div class="products-admin-sidebar-promo">
            <h3>Inventory Control</h3>
            <p>Keep product stock, prices, images, and marketplace visibility updated.</p>
            <a href="addProduct.jsp">Add Product</a>
        </div>

        <div class="products-admin-sidebar-bottom">
            <a href="logout" onclick="return confirm('Are you sure you want to logout?');">
                ⎋ Logout
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="products-admin-main">

        <!-- MOBILE TOP BAR -->
        <header class="products-mobile-topbar">
            <a href="adminDashboard.jsp" aria-label="Dashboard">☰</a>
            <strong>Products</strong>
            <div>
                <a href="addProduct.jsp" aria-label="Add Product">＋</a>
                <a href="manageOrders.jsp" aria-label="Orders">📦</a>
            </div>
        </header>

        <!-- DESKTOP TOP BAR -->
        <header class="products-admin-topbar">
            <div>
                <h1>Product Inventory</h1>
                <p>Manage dairy products, stock levels, visibility, and catalogue availability.</p>
            </div>

            <div class="products-admin-top-actions">
                <form action="manageProducts.jsp" method="get" class="products-admin-search">
                    <span>⌕</span>
                    <input type="text"
                           name="search"
                           placeholder="Search product..."
                           value="<%= hasSearch ? search : "" %>">
                </form>

                <a href="addProduct.jsp"
                   class="products-admin-icon-btn"
                   title="Add Product">
                    ＋
                </a>

                <a href="adminDashboard.jsp"
                   class="products-admin-profile"
                   title="Admin Dashboard">
                    👨‍💼
                </a>
            </div>
        </header>

        <div class="products-admin-content">

            <!-- HERO -->
            <section class="products-hero-card">
                <div>
                    <p class="products-eyebrow">INVENTORY CONTROL</p>
                    <h2>Manage Products</h2>
                    <p>
                        Track stock, edit product details, and control what customers see in the marketplace.
                    </p>

                    <div class="products-hero-actions">
                        <a href="addProduct.jsp">Add New Product</a>
                        <a href="products.jsp">View Public Catalog</a>
                    </div>
                </div>

                <div class="products-hero-summary">
                    <span>Total Products</span>
                    <strong><%= totalProducts %></strong>
                    <small><%= activeProducts %> active products</small>
                </div>
            </section>

            <!-- PRODUCT STATS -->
            <section class="products-stats-grid">
                <div class="products-stat-card">
                    <div>▣</div>
                    <span>Total Products</span>
                    <h3><%= totalProducts %></h3>
                    <p>All products in the database</p>
                </div>

                <div class="products-stat-card">
                    <div>✅</div>
                    <span>Active Products</span>
                    <h3><%= activeProducts %></h3>
                    <p>Visible in marketplace</p>
                </div>

                <div class="products-stat-card warning">
                    <div>⚠️</div>
                    <span>Low Stock</span>
                    <h3><%= lowStockProducts %></h3>
                    <p>Stock quantity between 1 and 5</p>
                </div>

                <div class="products-stat-card danger">
                    <div>⛔</div>
                    <span>Out of Stock</span>
                    <h3><%= outOfStockProducts %></h3>
                    <p>Products with zero stock</p>
                </div>
            </section>

            <!-- SEARCH / FILTER -->
            <section class="products-filter-card">
                <form method="get" action="manageProducts.jsp" class="products-filter-form">

                    <div>
                        <label>Search Product</label>
                        <input type="text"
                               name="search"
                               placeholder="Example: milk, yoghurt, butter..."
                               value="<%= hasSearch ? search : "" %>">
                    </div>

                    <div>
                        <label>Stock Status</label>
                        <select name="stockFilter">
                            <option value="">All Stock Levels</option>
                            <option value="IN_STOCK" <%= "IN_STOCK".equals(stockFilter) ? "selected" : "" %>>In Stock</option>
                            <option value="LOW_STOCK" <%= "LOW_STOCK".equals(stockFilter) ? "selected" : "" %>>Low Stock</option>
                            <option value="OUT_OF_STOCK" <%= "OUT_OF_STOCK".equals(stockFilter) ? "selected" : "" %>>Out of Stock</option>
                        </select>
                    </div>

                    <div>
                        <label>Product Status</label>
                        <select name="statusFilter">
                            <option value="">All Product Statuses</option>
                            <option value="ACTIVE" <%= "ACTIVE".equals(statusFilter) ? "selected" : "" %>>Active</option>
                            <option value="INACTIVE" <%= "INACTIVE".equals(statusFilter) ? "selected" : "" %>>Inactive</option>
                        </select>
                    </div>

                    <div class="products-filter-actions">
                        <button type="submit">Search</button>
                        <a href="manageProducts.jsp">Clear</a>
                    </div>

                </form>
            </section>

            <% if (products.isEmpty()) { %>

                <div class="products-empty-state">
                    <div>🥛</div>
                    <h2>No products found</h2>
                    <p>No products match your current search or filter selection.</p>
                    <a href="manageProducts.jsp">Clear Filters</a>
                </div>

            <% } else { %>

                <section class="products-list">

                    <%
                        for (Product p : products) {
                            String productStatus = p.getStatus();

                            if (productStatus == null || productStatus.trim().isEmpty()) {
                                productStatus = "ACTIVE";
                            }

                            String stockLabel;
                            String stockClass;

                            if (p.getStockQuantity() == 0) {
                                stockLabel = "Out of Stock";
                                stockClass = "out";
                            } else if (p.getStockQuantity() >= 1 && p.getStockQuantity() <= 5) {
                                stockLabel = "Low Stock";
                                stockClass = "low";
                            } else {
                                stockLabel = "In Stock";
                                stockClass = "in";
                            }

                            String productStatusClass = "ACTIVE".equalsIgnoreCase(productStatus) ? "active" : "inactive";
                    %>

                    <article class="products-card">

                        <div class="products-image">
                            <% if (p.getImageUrl() != null && !p.getImageUrl().isEmpty()) { %>
                                <img src="<%= request.getContextPath() + "/" + p.getImageUrl() %>"
                                     alt="<%= p.getProductName() %>"
                                     loading="lazy">
                            <% } else { %>
                                <div class="products-no-image">No Image</div>
                            <% } %>
                        </div>

                        <div class="products-main">
                            <p class="products-small-label">PRODUCT #<%= p.getProductId() %></p>
                            <h2><%= p.getProductName() %></h2>
                            <p><%= p.getDescription() != null ? p.getDescription() : "No description provided." %></p>

                            <div class="products-meta">
                                <div>
                                    <span>Price</span>
                                    <strong>KES <%= String.format("%.2f", p.getPrice()) %></strong>
                                </div>

                                <div>
                                    <span>Stock</span>
                                    <strong><%= p.getStockQuantity() %></strong>
                                </div>

                                <div>
                                    <span>Status</span>
                                    <strong class="products-status <%= productStatusClass %>">
                                        <%= productStatus %>
                                    </strong>
                                </div>

                                <div>
                                    <span>Stock Status</span>
                                    <strong class="products-stock <%= stockClass %>">
                                        <%= stockLabel %>
                                    </strong>
                                </div>
                            </div>
                        </div>

                        <div class="products-actions">
                            <a href="editProduct.jsp?id=<%= p.getProductId() %>">
                                Edit
                            </a>

                            <% if ("INACTIVE".equalsIgnoreCase(productStatus)) { %>
                                <a href="activateProduct?id=<%= p.getProductId() %>"
                                   onclick="return confirm('Activate this product? It will be visible to customers.');">
                                   Activate
                                </a>
                            <% } else { %>
                                <a class="danger"
                                   href="deleteProduct?id=<%= p.getProductId() %>"
                                   onclick="return confirm('Deactivate this product? It will be hidden from customers.');">
                                   Deactivate
                                </a>
                            <% } %>
                        </div>

                    </article>

                    <%
                        }
                    %>

                </section>

            <% } %>

        </div>

    </main>

</div>

<!-- MOBILE BOTTOM NAV -->
<nav class="products-admin-bottom-nav">
    <a href="adminDashboard.jsp">
        <span>⌂</span>
        Home
    </a>

    <a href="manageOrders.jsp">
        <span>📦</span>
        Orders
    </a>

    <a href="manageProducts.jsp" class="active">
        <span>▣</span>
        Products
    </a>

    <a href="salesReport.jsp">
        <span>▥</span>
        Reports
    </a>
</nav>

</body>
</html>
