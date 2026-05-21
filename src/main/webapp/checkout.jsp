<%@ page import="java.util.*, com.agribridgef1.dao.ProductDAO, com.agribridgef1.model.Product" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    if (session.getAttribute("userId") == null) {
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

    if (cart == null || cart.isEmpty()) {
        response.sendRedirect("cart.jsp");
        return;
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
    <title>Checkout - Egerton AgriBridge Hub</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- CSS order matters -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/base.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/components.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/checkout.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/responsive.css?v=1">
</head>

<body class="checkout-body">

<div class="checkout-shell">

    <!-- SIDEBAR -->
    <aside class="checkout-sidebar">
        <div class="checkout-brand">
            <div class="checkout-brand-mark">🌿</div>
            <div>
                <h2>AgriBridge</h2>
                <p>Customer Portal</p>
            </div>
        </div>

        <nav class="checkout-menu">
            <a href="customerDashboard.jsp">
                <span>▦</span>
                Dashboard
            </a>

            <a href="products.jsp">
                <span>🛒</span>
                Marketplace
            </a>

            <a href="cart.jsp">
                <span>🧺</span>
                Cart
            </a>

            <a href="checkout.jsp" class="active">
                <span>💵</span>
                Checkout
            </a>

            <a href="myOrders.jsp">
                <span>▤</span>
                My Orders
            </a>
        </nav>

        <div class="checkout-sidebar-promo">
            <h3>Almost done</h3>
            <p>Select pickup or delivery, confirm contacts, then place your order.</p>
            <a href="cart.jsp">Back to Cart</a>
        </div>

        <div class="checkout-sidebar-bottom">
            <a href="logout" onclick="return confirm('Are you sure you want to logout?');">
                ⎋ Logout
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="checkout-main-page">

        <!-- MOBILE TOP BAR -->
        <header class="checkout-mobile-topbar">
            <a href="cart.jsp" aria-label="Back to cart">←</a>
            <strong>Checkout</strong>
            <div>
                <a href="myOrders.jsp" aria-label="Orders">📦</a>
                <a href="profile.jsp" aria-label="Profile">👤</a>
            </div>
        </header>

        <!-- DESKTOP TOP BAR -->
        <header class="checkout-topbar">
            <div>
                <h1>Checkout</h1>
                <p>Choose delivery or pickup and confirm your order.</p>
            </div>

            <div class="checkout-top-actions">
                <a href="cart.jsp" class="checkout-top-btn">Back to Cart</a>

                <a class="checkout-icon-btn" href="cart.jsp" title="Cart">
                    🛒
                    <% if (cartCount > 0) { %>
                        <span><%= cartCount %></span>
                    <% } %>
                </a>

                <a class="checkout-profile-btn" href="customerDashboard.jsp" title="Dashboard">👤</a>
            </div>
        </header>

        <div class="checkout-content">

            <div class="checkout-breadcrumb">
                <a href="products.jsp">MARKETPLACE</a>
                <span>›</span>
                <a href="cart.jsp">CART</a>
                <span>›</span>
                <strong>CHECKOUT</strong>
            </div>

            <section class="checkout-hero-card">
                <div>
                    <p class="checkout-eyebrow">ORDER CHECKOUT</p>
                    <h2>Complete Your Order</h2>
                    <p>
                        Confirm your fulfilment option, phone number, and final order amount
                        before moving to payment.
                    </p>
                </div>

                <div class="checkout-hero-summary">
                    <span>Items</span>
                    <strong><%= cartCount %></strong>
                    <small>Subtotal</small>
                    <b>KES <%= String.format("%,.2f", subtotal) %></b>
                </div>
            </section>

            <form action="checkout" method="post" class="checkout-layout">

                <!-- LEFT SIDE -->
                <section class="checkout-form-area">

                    <div class="checkout-card">
                        <div class="checkout-card-header">
                            <div>
                                <h2>Delivery Option</h2>
                                <p>Select how you would like to receive your order.</p>
                            </div>
                            <span>Step 1</span>
                        </div>

                        <label>Delivery Zone</label>
                        <select id="deliveryZone" name="deliveryZone" onchange="updateDeliveryFee()" required>
                            <option value="Campus pickup" data-fee="0">Campus pickup - KES 0</option>
                            <option value="Campus delivery" data-fee="50">Campus delivery - KES 50</option>
                            <option value="Njoro town" data-fee="70">Njoro town - KES 70</option>
                            <option value="Nakuru town" data-fee="100">Nakuru town - KES 100</option>
                            <option value="Outside Nakuru" data-fee="250">Outside Nakuru - KES 250</option>
                        </select>

                        <div id="deliveryWarning" class="checkout-warning hidden">
                            Delivery fee is higher than your cart subtotal. Consider adding more items or choosing campus pickup.
                        </div>
                    </div>

                    <div class="checkout-card" id="deliveryDetailsCard">
                        <div class="checkout-card-header">
                            <div>
                                <h2 id="deliveryDetailsTitle">Pickup Details</h2>
                                <p>Provide contact information for fulfilment.</p>
                            </div>
                            <span>Step 2</span>
                        </div>

                        <label>Phone Number</label>
                        <input type="text"
                               name="phone"
                               placeholder="0712345678"
                               pattern="0[17][0-9]{8}"
                               title="Use 07XXXXXXXX or 01XXXXXXXX"
                               required>

                        <div id="deliveryAddressGroup" class="hidden">
                            <label id="deliveryAddressLabel">Delivery Address / Location</label>
                            <textarea name="deliveryAddress"
                                      id="deliveryAddress"
                                      rows="4"
                                      placeholder=""></textarea>

                            <small id="addressHelperText" class="checkout-helper-text">
                                Provide a clear location and nearby landmark to help the delivery agent find you easily.
                            </small>
                        </div>

                        <div id="deliveryNotesGroup">
                            <label>Extra Notes</label>
                            <textarea name="notes"
                                      rows="3"
                                      placeholder="Optional notes, e.g. preferred pickup time"></textarea>
                        </div>
                    </div>

                    <div class="checkout-card">
                        <div class="checkout-card-header">
                            <div>
                                <h2>Order Items</h2>
                                <p>Products included in this checkout.</p>
                            </div>
                            <span><%= cartCount %> item<%= cartCount == 1 ? "" : "s" %></span>
                        </div>

                        <div class="checkout-items-list">
                            <%
                                for (Product p : cartProducts) {
                                    int quantity = cart.get(p.getProductId());
                                    double itemSubtotal = p.getPrice() * quantity;
                            %>

                            <div class="checkout-item">
                                <% if (p.getImageUrl() != null && !p.getImageUrl().isEmpty()) { %>
                                    <img src="<%= request.getContextPath() + "/" + p.getImageUrl() %>"
                                         alt="<%= p.getProductName() %>"
                                         loading="lazy">
                                <% } else { %>
                                    <div class="checkout-no-image">No Image</div>
                                <% } %>

                                <div>
                                    <h3><%= p.getProductName() %></h3>
                                    <p>Quantity: <%= quantity %></p>
                                </div>

                                <strong>KES <%= String.format("%.2f", itemSubtotal) %></strong>
                            </div>

                            <%
                                }
                            %>
                        </div>
                    </div>

                </section>

                <!-- RIGHT SUMMARY -->
                <aside class="checkout-summary-card">
                    <h2>Order Summary</h2>

                    <div class="summary-row">
                        <span>Subtotal</span>
                        <strong>KES <%= String.format("%.2f", subtotal) %></strong>
                    </div>

                    <div class="summary-row">
                        <span>Delivery Fee</span>
                        <strong id="deliveryFeeText">KES 0.00</strong>
                    </div>

                    <hr>

                    <div class="summary-total">
                        <span>Total</span>
                        <strong id="totalText">KES <%= String.format("%.2f", subtotal) %></strong>
                    </div>

                    <input type="hidden" name="subtotal" value="<%= subtotal %>">
                    <input type="hidden" id="deliveryFeeInput" name="deliveryFee" value="0">
                    <input type="hidden" id="totalAmountInput" name="totalAmount" value="<%= subtotal %>">

                    <button class="checkout-main-btn" type="submit">
                        Place Order
                    </button>

                    <div class="mpesa-checkout-note">
                        <div>M</div>
                        <div>
                            <h4>M-Pesa Available</h4>
                            <p>You can pay using M-Pesa STK Push after placing the order.</p>
                        </div>
                    </div>

                    <a class="checkout-back-link" href="cart.jsp">
                        ← Back to Cart
                    </a>
                </aside>

            </form>

        </div>

    </main>

</div>

<aside class="checkout-mobile-summary">
    <div>
        <span>Total</span>
        <strong id="mobileTotalText">KES <%= String.format("%,.2f", subtotal) %></strong>
    </div>

    <button type="button" onclick="submitCheckoutForm()">
        Place Order
    </button>
</aside>

<!-- MOBILE BOTTOM NAV -->
<nav class="checkout-bottom-nav">
    <a href="customerDashboard.jsp">
        <span>⌂</span>
        Home
    </a>

    <a href="cart.jsp">
        <span>🧺</span>
        Cart
    </a>

    <a href="products.jsp">
        <span>🛒</span>
        Shop
    </a>

    <a href="myOrders.jsp">
        <span>📦</span>
        Orders
    </a>
</nav>

<script>
    const subtotal = <%= subtotal %>;

    function updateDeliveryFee() {
        const select = document.getElementById("deliveryZone");
        const selectedOption = select.options[select.selectedIndex];

        const deliveryFee = parseFloat(selectedOption.getAttribute("data-fee"));
        const selectedZone = selectedOption.value;
        const total = subtotal + deliveryFee;

        document.getElementById("deliveryFeeText").innerText = "KES " + deliveryFee.toFixed(2);
        document.getElementById("totalText").innerText = "KES " + total.toFixed(2);
        document.getElementById("mobileTotalText").innerText = "KES " + total.toFixed(2);

        document.getElementById("deliveryFeeInput").value = deliveryFee.toFixed(2);
        document.getElementById("totalAmountInput").value = total.toFixed(2);

        const warning = document.getElementById("deliveryWarning");
        const deliveryAddressGroup = document.getElementById("deliveryAddressGroup");
        const deliveryAddress = document.getElementById("deliveryAddress");
        const deliveryAddressLabel = document.getElementById("deliveryAddressLabel");
        const deliveryDetailsTitle = document.getElementById("deliveryDetailsTitle");
        const addressHelperText = document.getElementById("addressHelperText");
        const notesTextarea = document.querySelector("textarea[name='notes']");

        if (deliveryFee > subtotal && subtotal > 0) {
            warning.classList.remove("hidden");
        } else {
            warning.classList.add("hidden");
        }

        if (selectedZone === "Campus pickup") {
            deliveryDetailsTitle.innerText = "Pickup Details";

            deliveryAddressGroup.classList.add("hidden");
            deliveryAddress.removeAttribute("required");
            deliveryAddress.value = "Campus pickup";

            notesTextarea.placeholder = "Optional notes, e.g. preferred pickup time";

        } else {
            deliveryDetailsTitle.innerText = "Delivery Details";

            deliveryAddressGroup.classList.remove("hidden");
            deliveryAddress.setAttribute("required", "required");

            if (deliveryAddress.value === "Campus pickup") {
                deliveryAddress.value = "";
            }

            notesTextarea.placeholder = "Optional notes for delivery agent";

            if (selectedZone === "Campus delivery") {
                deliveryAddressLabel.innerText = "Campus Location";
                deliveryAddress.placeholder = "Example: Egerton main campus, near library, hostel, lecture hall, or department...";
                addressHelperText.innerText = "Mention the exact campus area, building, hostel, office, or nearby landmark.";

            } else if (selectedZone === "Njoro town") {
                deliveryAddressLabel.innerText = "Njoro Town Address";
                deliveryAddress.placeholder = "Example: Njoro town, near Total petrol station, opposite stage, shop name...";
                addressHelperText.innerText = "Include estate, street, shop/building name, or a common Njoro landmark.";

            } else if (selectedZone === "Nakuru town") {
                deliveryAddressLabel.innerText = "Nakuru Town Address";
                deliveryAddress.placeholder = "Example: Nakuru town, Section 58, near main stage, building name, floor/room...";
                addressHelperText.innerText = "Include estate/area, street, building, floor/room, and nearby landmark.";

            } else if (selectedZone === "Outside Nakuru") {
                deliveryAddressLabel.innerText = "Full Delivery Address";
                deliveryAddress.placeholder = "Example: Town/County, estate/village, road, landmark, recipient name if different...";
                addressHelperText.innerText = "Provide full location details because this delivery is outside the normal Nakuru zone.";

            } else {
                deliveryAddressLabel.innerText = "Delivery Address / Location";
                deliveryAddress.placeholder = "Example: Your area, street, building, and nearby landmark...";
                addressHelperText.innerText = "Provide a clear location and nearby landmark to help the delivery agent find you easily.";
            }
        }
    }

    function submitCheckoutForm() {
        const form = document.querySelector(".checkout-layout");

        if (form) {
            form.requestSubmit();
        }
    }

    updateDeliveryFee();
</script>

</body>
</html>
