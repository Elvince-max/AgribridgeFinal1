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
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
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

            <a href="manageProducts.jsp">
                <span>▣</span>
                Manage Products
            </a>

            <a href="addProduct.jsp" class="active">
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
            <a class="estate-add-btn" href="manageProducts.jsp">
                View Inventory
            </a>

            <a href="logout" class="estate-logout">
                ⎋ Logout
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="estate-main">

        <header class="estate-topbar">
            <div>
                <h1>Add Product</h1>
                <p>Create a new dairy product for the customer marketplace.</p>
            </div>

            <div class="estate-top-actions">
                <a href="manageProducts.jsp" class="estate-icon-btn">▣</a>
                <a href="adminDashboard.jsp" class="estate-profile">👨‍💼</a>
            </div>
        </header>

        <div class="estate-inner-page">

            <div class="admin-products-header">
                <div>
                    <p class="eyebrow">PRODUCT CREATION</p>
                    <h1>Add New Product</h1>
                    <p>Upload product details, price, stock quantity, and image for the public catalogue.</p>
                </div>

                <div class="admin-products-header-actions">
                    <a class="btn btn-secondary" href="manageProducts.jsp">Back to Products</a>
                    <a class="btn" href="products.jsp">View Marketplace</a>
                </div>
            </div>

            <% if ("1".equals(request.getParameter("success"))) { %>
                <div class="review-success">
                    Product added successfully.
                </div>
            <% } else if ("error".equals(request.getParameter("status"))) { %>
                <div class="review-error">
                    Could not add product. Please check your input and try again.
                </div>
            <% } %>

            <div class="product-form-layout">

                <!-- FORM -->
                <div class="product-form-card">
                    <h2>Product Information</h2>
                    <p>Fill in the product details below.</p>

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

                        <div class="product-form-two">
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
                        <input type="file"
                               name="imageFile"
                               id="imageFile"
                               accept="image/*"
                               onchange="previewProductImage(event)"
                               required>

                        <small class="product-form-helper">
                            Recommended image: clear product photo, landscape or square format.
                        </small>

                        <div class="product-form-actions">
                            <button class="btn" type="submit">Add Product</button>
                            <a class="btn btn-secondary" href="manageProducts.jsp">Cancel</a>
                        </div>

                    </form>
                </div>

                <!-- PREVIEW -->
                <div class="product-preview-card">
                    <p class="eyebrow">LIVE PREVIEW</p>
                    <h2>Product Preview</h2>

                    <div class="product-preview-image">
                        <img id="imagePreview" src="" alt="Product preview" class="hidden">
                        <div id="imagePlaceholder">No image selected</div>
                    </div>

                    <div class="product-preview-info">
                        <h3 id="previewName">Product name</h3>
                        <p id="previewDescription">Product description will appear here.</p>
                        <strong id="previewPrice">KES 0.00</strong>
                        <span id="previewStock">Stock: 0</span>
                    </div>
                </div>

            </div>

        </div>

    </main>

</div>

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
        previewStock.innerText = "Stock: " + (quantity.value || "0");
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