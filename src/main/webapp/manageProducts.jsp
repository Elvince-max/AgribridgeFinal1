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

        if ("ACTIVE".equalsIgnoreCase(p.getStatus())) {
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
            matchesStatus = statusFilter.equalsIgnoreCase(p.getStatus());
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
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style-backup.css">
</head>

<body class="estate-dashboard-body">

<div class="estate-layout">

    <!-- SIDEBAR -->
    <aside class="estate-sidebar">
        <div class="estate-brand">
            <h2>AgriBridge</h2>
            <p>Modern Pastoral Management</p>
        </div>

        <nav class="estate-menu">
            <a href="adminDashboard.jsp">
                <span>▦</span>
                Dashboard
            </a>

            <a href="manageProducts.jsp" class="active">
                <span>▣</span>
                Manage Products
            </a>

            <a href="addProduct.jsp">
                <span>＋</span>
                Add Product
            </a>

            <a href="manageOrders.jsp">
                <span>▤</span>
                Manage Orders
            </a>

            <a href="salesReport.jsp">
                <span>▥</span>
                Sales Reports
            </a>

            <a href="products.jsp">
                <span>🛒</span>
                Marketplace
            </a>
        </nav>

        <div class="estate-sidebar-bottom">
            <a class="estate-add-btn" href="addProduct.jsp">
                ＋ Add New Product
            </a>

            <a href="logout" class="estate-logout">
                ⎋ Logout
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="estate-main">

        <!-- TOP BAR -->
        <header class="estate-topbar">
            <div>
                <h1>Product Inventory</h1>
                <p>Manage dairy products, stock levels, visibility, and catalogue availability.</p>
            </div>

            <div class="estate-top-actions">
                <form action="manageProducts.jsp" method="get" class="estate-search">
                    <span>⌕</span>
                    <input type="text"
                           name="search"
                           placeholder="Search product..."
                           value="<%= hasSearch ? search : "" %>">
                </form>

                <a href="manageProducts.jsp" class="estate-icon-btn">🔔</a>
                <a href="adminDashboard.jsp" class="estate-profile">👨‍💼</a>
            </div>
        </header>

        <div class="estate-inner-page">

            <div class="admin-products-header">
                <div>
                    <p class="eyebrow">INVENTORY CONTROL</p>
                    <h1>Manage Products</h1>
                    <p>Track stock, edit product details, and control what customers see in the marketplace.</p>
                </div>

                <div class="admin-products-header-actions">
                    <a class="btn" href="addProduct.jsp">Add New Product</a>
                    <a class="btn btn-secondary" href="products.jsp">View Public Catalog</a>
                </div>
            </div>

            <!-- PRODUCT STATS -->
            <section class="admin-product-stats">
                <div>
                    <span>Total Products</span>
                    <strong><%= totalProducts %></strong>
                </div>

                <div>
                    <span>Active Products</span>
                    <strong><%= activeProducts %></strong>
                </div>

                <div>
                    <span>Low Stock</span>
                    <strong><%= lowStockProducts %></strong>
                </div>

                <div>
                    <span>Out of Stock</span>
                    <strong><%= outOfStockProducts %></strong>
                </div>
            </section>

            <!-- SEARCH / FILTER -->
            <div class="admin-order-search-card premium-filter-card">
                <form method="get" action="manageProducts.jsp" class="admin-product-search-form">

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

                    <div class="admin-order-search-actions">
                        <button class="btn" type="submit">Search</button>
                        <a class="btn btn-secondary" href="manageProducts.jsp">Clear</a>
                    </div>

                </form>
            </div>

            <% if (products.isEmpty()) { %>

                <div class="cart-empty-state">
                    <div class="cart-empty-icon">🥛</div>
                    <h2>No products found</h2>
                    <p>No products match your current search or filter selection.</p>
                    <a href="manageProducts.jsp">Clear Filters</a>
                </div>

            <% } else { %>

                <div class="admin-product-list">

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

                    <div class="admin-product-card">

                        <div class="admin-product-image">
                            <% if (p.getImageUrl() != null && !p.getImageUrl().isEmpty()) { %>
                                <img src="<%= request.getContextPath() + "/" + p.getImageUrl() %>"
                                     alt="<%= p.getProductName() %>">
                            <% } else { %>
                                <div class="admin-product-no-image">No Image</div>
                            <% } %>
                        </div>

                        <div class="admin-product-main">
                            <div>
                                <p class="delivery-eyebrow">PRODUCT #<%= p.getProductId() %></p>
                                <h2><%= p.getProductName() %></h2>
                                <p><%= p.getDescription() != null ? p.getDescription() : "No description provided." %></p>
                            </div>

                            <div class="admin-product-meta">
                                <div>
                                    <span>Price</span>
                                    <strong>KES <%= String.format("%.2f", p.getPrice()) %></strong>
                                </div>

                                <div>
                                    <span>Stock</span>
                                    <strong><%= p.getStockQuantity() %></strong>
                                </div>

                                <div>
                                    <span>Product Status</span>
                                    <strong class="admin-product-status <%= productStatusClass %>">
                                        <%= productStatus %>
                                    </strong>
                                </div>

                                <div>
                                    <span>Stock Status</span>
                                    <strong class="admin-stock-status <%= stockClass %>">
                                        <%= stockLabel %>
                                    </strong>
                                </div>
                            </div>
                        </div>

                        <div class="admin-product-actions">
                            <a class="btn" href="editProduct.jsp?id=<%= p.getProductId() %>">
                                Edit
                            </a>

                            <% if ("INACTIVE".equalsIgnoreCase(productStatus)) { %>
                                <a class="btn"
                                   href="activateProduct?id=<%= p.getProductId() %>"
                                   onclick="return confirm('Activate this product? It will be visible to customers.');">
                                   Activate
                                </a>
                            <% } else { %>
                                <a class="btn btn-danger"
                                   href="deleteProduct?id=<%= p.getProductId() %>"
                                   onclick="return confirm('Deactivate this product? It will be hidden from customers.');">
                                   Deactivate
                                </a>
                            <% } %>
                        </div>

                    </div>

                    <%
                        }
                    %>

                </div>

            <% } %>

        </div>

    </main>

</div>

</body>
</html>