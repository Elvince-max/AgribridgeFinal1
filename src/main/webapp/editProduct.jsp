<%@ page import="com.agribridgef1.dao.ProductDAO, com.agribridgef1.model.Product" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    if (session.getAttribute("userType") == null ||
       !"ADMIN".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    String idParam = request.getParameter("id");

    if (idParam == null || idParam.trim().isEmpty()) {
        response.sendRedirect("manageProducts.jsp");
        return;
    }

    int productId = Integer.parseInt(idParam);

    ProductDAO dao = new ProductDAO();
    Product product = dao.getProductById(productId);

    if (product == null) {
        response.sendRedirect("manageProducts.jsp");
        return;
    }

    String imageUrl = product.getImageUrl() != null ? product.getImageUrl() : "";
%>

<!DOCTYPE html>
<html>
<head>
    <title>Edit Product - Egerton AgriBridge Hub</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- CSS order matters -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/base.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/components.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/edit-product.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/responsive.css?v=1">
</head>

<body class="edit-product-body">

<div class="edit-product-shell">

    <!-- SIDEBAR -->
    <aside class="edit-product-sidebar">
        <div class="edit-product-brand">
            <div class="edit-product-brand-mark">🌿</div>
            <div>
                <h2>AgriBridge</h2>
                <p>Admin Portal</p>
            </div>
        </div>

        <nav class="edit-product-menu">
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

        <div class="edit-product-sidebar-promo">
            <h3>Product Update</h3>
            <p>Modify product details carefully because changes affect what customers see.</p>
            <a href="manageProducts.jsp">Back to Inventory</a>
        </div>

        <div class="edit-product-sidebar-bottom">
            <a href="logout" onclick="return confirm('Are you sure you want to logout?');">
                ⎋ Logout
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="edit-product-main">

        <!-- MOBILE TOP BAR -->
        <header class="edit-product-mobile-topbar">
            <a href="manageProducts.jsp" aria-label="Back to products">←</a>
            <strong>Edit Product</strong>
            <div>
                <a href="addProduct.jsp" aria-label="Add Product">＋</a>
                <a href="adminDashboard.jsp" aria-label="Dashboard">👨‍💼</a>
            </div>
        </header>

        <!-- DESKTOP TOP BAR -->
        <header class="edit-product-topbar">
            <div>
                <h1>Edit Product</h1>
                <p>Update product details, price, stock, and catalogue image.</p>
            </div>

            <div class="edit-product-top-actions">
                <a href="manageProducts.jsp" class="edit-product-top-btn">Back to Products</a>

                <a href="products.jsp"
                   class="edit-product-icon-btn"
                   title="Marketplace">
                    🛒
                </a>

                <a href="adminDashboard.jsp"
                   class="edit-product-profile"
                   title="Admin Dashboard">
                    👨‍💼
                </a>
            </div>
        </header>

        <div class="edit-product-content">

            <!-- HERO -->
            <section class="edit-product-hero-card">
                <div>
                    <p class="edit-product-eyebrow">PRODUCT UPDATE</p>
                    <h2>Edit Product #<%= product.getProductId() %></h2>
                    <p>
                        Modify existing product information and refresh the public catalogue.
                    </p>

                    <div class="edit-product-hero-actions">
                        <a href="manageProducts.jsp">Back to Products</a>
                        <a href="products.jsp">View Marketplace</a>
                    </div>
                </div>

                <div class="edit-product-hero-summary">
                    <span>Current Stock</span>
                    <strong><%= product.getStockQuantity() %></strong>
                    <small>KES <%= String.format("%.2f", product.getPrice()) %></small>
                </div>
            </section>

            <% if ("error".equals(request.getParameter("status"))) { %>
                <div class="edit-product-error">
                    Could not update product. Please check your input and try again.
                </div>
            <% } %>

            <section class="edit-product-layout">

                <!-- FORM -->
                <div class="edit-product-form-card">
                    <div class="edit-product-card-header">
                        <div>
                            <h2>Product Information</h2>
                            <p>Update the product details below.</p>
                        </div>
                        <span>Editing</span>
                    </div>

                    <form action="updateProduct" method="post" enctype="multipart/form-data" onsubmit="return validateProductForm();">

                        <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                        <input type="hidden" name="oldImage" value="<%= imageUrl %>">

                        <label>Product Name</label>
                        <input type="text"
                               name="name"
                               id="productName"
                               value="<%= product.getProductName() %>"
                               required>

                        <label>Description</label>
                        <textarea name="description"
                                  id="description"
                                  rows="5"
                                  required><%= product.getDescription() != null ? product.getDescription() : "" %></textarea>

                        <div class="edit-product-form-two">
                            <div>
                                <label>Price</label>
                                <input type="number"
                                       name="price"
                                       id="price"
                                       step="0.01"
                                       min="1"
                                       value="<%= product.getPrice() %>"
                                       required>
                            </div>

                            <div>
                                <label>Stock Quantity</label>
                                <input type="number"
                                       name="quantity"
                                       id="quantity"
                                       min="0"
                                       value="<%= product.getStockQuantity() %>"
                                       required>
                            </div>
                        </div>

                        <label>Change Image Optional</label>
                        <label class="edit-product-upload-box" for="imageFile">
                            <input type="file"
                                   name="imageFile"
                                   id="imageFile"
                                   accept="image/*"
                                   onchange="previewProductImage(event)">

                            <span>📷</span>
                            <strong>Choose a new image</strong>
                            <small>Leave empty if you want to keep the current image.</small>
                        </label>

                        <div class="edit-product-form-actions">
                            <button type="submit">Update Product</button>
                            <a href="manageProducts.jsp">Cancel</a>
                        </div>

                    </form>
                </div>

                <!-- PREVIEW -->
                <aside class="edit-product-preview-card">
                    <div class="edit-product-card-header">
                        <div>
                            <p class="edit-product-eyebrow dark">CURRENT PREVIEW</p>
                            <h2>Product Preview</h2>
                        </div>
                    </div>

                    <div class="edit-product-preview-image">
                        <% if (!imageUrl.trim().isEmpty()) { %>
                            <img id="imagePreview"
                                 src="<%= request.getContextPath() + "/" + imageUrl %>"
                                 alt="<%= product.getProductName() %>">
                            <div id="imagePlaceholder" class="hidden">
                                <span>🥛</span>
                                <strong>No image selected</strong>
                                <small>Your selected image will appear here.</small>
                            </div>
                        <% } else { %>
                            <img id="imagePreview" src="" alt="Product preview" class="hidden">
                            <div id="imagePlaceholder">
                                <span>🥛</span>
                                <strong>No image selected</strong>
                                <small>Your selected image will appear here.</small>
                            </div>
                        <% } %>
                    </div>

                    <div class="edit-product-preview-info">
                        <h3 id="previewName"><%= product.getProductName() %></h3>
                        <p id="previewDescription"><%= product.getDescription() != null ? product.getDescription() : "No description provided." %></p>

                        <div class="edit-product-preview-meta">
                            <div>
                                <span>Price</span>
                                <strong id="previewPrice">KES <%= String.format("%.2f", product.getPrice()) %></strong>
                            </div>

                            <div>
                                <span>Stock</span>
                                <strong id="previewStock"><%= product.getStockQuantity() %> units</strong>
                            </div>
                        </div>
                    </div>

                    <div class="edit-product-help-card">
                        <h3>Update tip</h3>
                        <p>Use a clear product image and accurate stock count. This helps customers trust the catalogue.</p>
                    </div>
                </aside>

            </section>

        </div>

    </main>

</div>

<!-- MOBILE BOTTOM NAV -->
<nav class="edit-product-bottom-nav">
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

    <a href="addProduct.jsp">
        <span>＋</span>
        Add
    </a>
</nav>

<script>
    const productName = document.getElementById("productName");
    const description = document.getElementById("description");
    const price = document.getElementById("price");
    const quantity = document.getElementById("quantity");

    const previewName = document.getElementById("previewName");
    const previewDescription = document.getElementById("previewDescription");
    const previewPrice = document.getElementById("previewPrice");
    const previewStock = document.getElementById("previewStock");

    function updatePreview() {
        previewName.innerText = productName.value || "Product name";
        previewDescription.innerText = description.value || "Product description will appear here.";
        previewPrice.innerText = "KES " + (price.value ? parseFloat(price.value).toFixed(2) : "0.00");
        previewStock.innerText = (quantity.value || "0") + " units";
    }

    productName.addEventListener("input", updatePreview);
    description.addEventListener("input", updatePreview);
    price.addEventListener("input", updatePreview);
    quantity.addEventListener("input", updatePreview);

    function previewProductImage(event) {
        const file = event.target.files[0];
        const imagePreview = document.getElementById("imagePreview");
        const imagePlaceholder = document.getElementById("imagePlaceholder");

        if (file) {
            imagePreview.src = URL.createObjectURL(file);
            imagePreview.classList.remove("hidden");
            imagePlaceholder.classList.add("hidden");
        }
    }

    function validateProductForm() {
        if (productName.value.trim().length < 2) {
            alert("Product name must be at least 2 characters.");
            return false;
        }

        if (parseFloat(price.value) <= 0) {
            alert("Price must be greater than zero.");
            return false;
        }

        if (parseInt(quantity.value) < 0) {
            alert("Stock quantity cannot be negative.");
            return false;
        }

        return true;
    }
</script>

</body>
</html>
