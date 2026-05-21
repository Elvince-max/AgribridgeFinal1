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
                ＋ Add Product
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
                <h1>Edit Product</h1>
                <p>Update product details, price, stock, and catalogue image.</p>
            </div>

            <div class="estate-top-actions">
                <a href="manageProducts.jsp" class="estate-icon-btn">▣</a>
                <a href="adminDashboard.jsp" class="estate-profile">👨‍💼</a>
            </div>
        </header>

        <div class="estate-inner-page">

            <div class="admin-products-header">
                <div>
                    <p class="eyebrow">PRODUCT UPDATE</p>
                    <h1>Edit Product</h1>
                    <p>Modify existing product information and refresh the public catalogue.</p>
                </div>

                <div class="admin-products-header-actions">
                    <a class="btn btn-secondary" href="manageProducts.jsp">Back to Products</a>
                    <a class="btn" href="products.jsp">View Marketplace</a>
                </div>
            </div>

            <% if ("error".equals(request.getParameter("status"))) { %>
                <div class="review-error">
                    Could not update product. Please check your input and try again.
                </div>
            <% } %>

            <div class="product-form-layout">

                <!-- FORM -->
                <div class="product-form-card">
                    <h2>Product Information</h2>
                    <p>Update the product details below.</p>

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

                        <div class="product-form-two">
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
                        <input type="file"
                               name="imageFile"
                               id="imageFile"
                               accept="image/*"
                               onchange="previewProductImage(event)">

                        <small class="product-form-helper">
                            Leave empty if you want to keep the current image.
                        </small>

                        <div class="product-form-actions">
                            <button class="btn" type="submit">Update Product</button>
                            <a class="btn btn-secondary" href="manageProducts.jsp">Cancel</a>
                        </div>

                    </form>
                </div>

                <!-- PREVIEW -->
                <div class="product-preview-card">
                    <p class="eyebrow">CURRENT PREVIEW</p>
                    <h2>Product Preview</h2>

                    <div class="product-preview-image">
                        <% if (!imageUrl.trim().isEmpty()) { %>
                            <img id="imagePreview"
                                 src="<%= request.getContextPath() + "/" + imageUrl %>"
                                 alt="<%= product.getProductName() %>">
                            <div id="imagePlaceholder" class="hidden">No image selected</div>
                        <% } else { %>
                            <img id="imagePreview" src="" alt="Product preview" class="hidden">
                            <div id="imagePlaceholder">No image selected</div>
                        <% } %>
                    </div>

                    <div class="product-preview-info">
                        <h3 id="previewName"><%= product.getProductName() %></h3>
                        <p id="previewDescription"><%= product.getDescription() != null ? product.getDescription() : "No description provided." %></p>
                        <strong id="previewPrice">KES <%= String.format("%.2f", product.getPrice()) %></strong>
                        <span id="previewStock">Stock: <%= product.getStockQuantity() %></span>
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