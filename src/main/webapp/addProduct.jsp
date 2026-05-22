<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    if (session.getAttribute("userType") == null ||
       !"ADMIN".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Add Product - Egerton AgriBridge Hub</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- CSS order matters -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/base.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/components.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/add-product.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/responsive.css?v=1">
</head>

<body class="add-product-body">

<div class="add-product-shell">

    <!-- SIDEBAR -->
    <aside class="add-product-sidebar">
        <div class="add-product-brand">
            <div class="add-product-brand-mark">🌿</div>
            <div>
                <h2>AgriBridge</h2>
                <p>Admin Portal</p>
            </div>
        </div>

        <nav class="add-product-menu">
            <a href="adminDashboard.jsp">
                <span>▦</span>
                Dashboard
            </a>

            <a href="manageProducts.jsp">
                <span>▣</span>
                Products
            </a>

            <a href="addProduct.jsp" class="active">
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

        <div class="add-product-sidebar-promo">
            <h3>Product Creation</h3>
            <p>Add clear product details, correct stock, and a clean product image for the marketplace.</p>
            <a href="manageProducts.jsp">View Inventory</a>
        </div>

        <div class="add-product-sidebar-bottom">
            <a href="logout" onclick="return confirm('Are you sure you want to logout?');">
                ⎋ Logout
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="add-product-main">

        <!-- MOBILE TOP BAR -->
        <header class="add-product-mobile-topbar">
            <a href="manageProducts.jsp" aria-label="Back to products">←</a>
            <strong>Add Product</strong>
            <div>
                <a href="manageOrders.jsp" aria-label="Orders">📦</a>
                <a href="adminDashboard.jsp" aria-label="Dashboard">👨‍💼</a>
            </div>
        </header>

        <!-- DESKTOP TOP BAR -->
        <header class="add-product-topbar">
            <div>
                <h1>Add Product</h1>
                <p>Create a new dairy product for the customer marketplace.</p>
            </div>

            <div class="add-product-top-actions">
                <a href="manageProducts.jsp" class="add-product-top-btn">View Inventory</a>

                <a href="products.jsp"
                   class="add-product-icon-btn"
                   title="Marketplace">
                    🛒
                </a>

                <a href="adminDashboard.jsp"
                   class="add-product-profile"
                   title="Admin Dashboard">
                    👨‍💼
                </a>
            </div>
        </header>

        <div class="add-product-content">

            <!-- HERO -->
            <section class="add-product-hero-card">
                <div>
                    <p class="add-product-eyebrow">PRODUCT CREATION</p>
                    <h2>Add New Product</h2>
                    <p>
                        Upload product details, price, stock quantity, and image for the public dairy catalogue.
                    </p>

                    <div class="add-product-hero-actions">
                        <a href="manageProducts.jsp">Back to Products</a>
                        <a href="products.jsp">View Marketplace</a>
                    </div>
                </div>

                <div class="add-product-hero-summary">
                    <span>Required Details</span>
                    <strong>4</strong>
                    <small>Name, price, stock, and image</small>
                </div>
            </section>

            <% if ("1".equals(request.getParameter("success"))) { %>
                <div class="add-product-success">
                    Product added successfully.
                </div>
            <% } else if ("error".equals(request.getParameter("status"))) { %>
                <div class="add-product-error">
                    Could not add product. Please check your input and try again.
                </div>
            <% } %>

            <section class="add-product-layout">

                <!-- FORM -->
                <div class="add-product-form-card">
                    <div class="add-product-card-header">
                        <div>
                            <h2>Product Information</h2>
                            <p>Fill in the product details below.</p>
                        </div>
                        <span>Step 1</span>
                    </div>

                    <form action="addProduct" method="post" enctype="multipart/form-data" onsubmit="return validateProductForm();">

                        <label>Product Name</label>
                        <input type="text"
                               name="name"
                               id="productName"
                               placeholder="Example: Fresh Milk 1L"
                               required>

                        <label>Description</label>
                        <textarea name="description"
                                  id="description"
                                  rows="5"
                                  placeholder="Describe the product, packaging, freshness, or usage..."></textarea>

                        <div class="add-product-form-two">
                            <div>
                                <label>Price</label>
                                <input type="number"
                                       name="price"
                                       id="price"
                                       step="0.01"
                                       min="1"
                                       placeholder="Example: 120"
                                       required>
                            </div>

                            <div>
                                <label>Stock Quantity</label>
                                <input type="number"
                                       name="quantity"
                                       id="quantity"
                                       min="0"
                                       placeholder="Example: 50"
                                       required>
                            </div>
                        </div>

                        <label>Upload Image</label>
                        <label class="add-product-upload-box" for="imageFile">
                            <input type="file"
                                   name="imageFile"
                                   id="imageFile"
                                   accept="image/*"
                                   onchange="previewProductImage(event)"
                                   required>

                            <span>📷</span>
                            <strong>Choose product image</strong>
                            <small>Recommended: clear square or landscape photo.</small>
                        </label>

                        <div class="add-product-form-actions">
                            <button type="submit">Add Product</button>
                            <a href="manageProducts.jsp">Cancel</a>
                        </div>

                    </form>
                </div>

                <!-- PREVIEW -->
                <aside class="add-product-preview-card">
                    <div class="add-product-card-header">
                        <div>
                            <p class="add-product-eyebrow dark">LIVE PREVIEW</p>
                            <h2>Product Preview</h2>
                        </div>
                    </div>

                    <div class="add-product-preview-image">
                        <img id="imagePreview" src="" alt="Product preview" class="hidden">
                        <div id="imagePlaceholder">
                            <span>🥛</span>
                            <strong>No image selected</strong>
                            <small>Your uploaded product image will appear here.</small>
                        </div>
                    </div>

                    <div class="add-product-preview-info">
                        <h3 id="previewName">Product name</h3>
                        <p id="previewDescription">Product description will appear here.</p>

                        <div class="add-product-preview-meta">
                            <div>
                                <span>Price</span>
                                <strong id="previewPrice">KES 0.00</strong>
                            </div>

                            <div>
                                <span>Stock</span>
                                <strong id="previewStock">0 units</strong>
                            </div>
                        </div>
                    </div>

                    <div class="add-product-help-card">
                        <h3>Image tip</h3>
                        <p>Use a bright, clean image with the product centered. Avoid very tall images because they create too much scrolling on phone.</p>
                    </div>
                </aside>

            </section>

        </div>

    </main>

</div>

<!-- MOBILE BOTTOM NAV -->
<nav class="add-product-bottom-nav">
    <a href="adminDashboard.jsp">
        <span>⌂</span>
        Home
    </a>

    <a href="manageOrders.jsp">
        <span>📦</span>
        Orders
    </a>

    <a href="manageProducts.jsp">
        <span>▣</span>
        Products
    </a>

    <a href="addProduct.jsp" class="active">
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
