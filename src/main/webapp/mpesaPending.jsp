<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userType = (String) session.getAttribute("userType");

    if (userType == null || !"CUSTOMER".equals(userType.trim().toUpperCase())) {
        response.sendRedirect("login.jsp");
        return;
    }

    String orderId = request.getParameter("orderId");

    if (orderId == null || orderId.trim().isEmpty()) {
        response.sendRedirect("myOrders.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>M-Pesa Payment Pending - Egerton AgriBridge Hub</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- CSS order matters -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/base.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/components.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/mpesa-pending.css?v=1">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/responsive.css?v=1">
</head>

<body class="mpesa-pending-body">

<div class="mpesa-shell">

    <!-- SIDEBAR -->
    <aside class="mpesa-sidebar">
        <div class="mpesa-brand">
            <div class="mpesa-brand-mark">🌿</div>
            <div>
                <h2>AgriBridge</h2>
                <p>Customer Portal</p>
            </div>
        </div>

        <nav class="mpesa-menu">
            <a href="customerDashboard.jsp">
                <span>▦</span>
                Dashboard
            </a>

            <a href="products.jsp">
                <span>🛒</span>
                Marketplace
            </a>

            <a href="myOrders.jsp" class="active">
                <span>▤</span>
                My Orders
            </a>

            <a href="cart.jsp">
                <span>🧺</span>
                Cart
            </a>

            <a href="profile.jsp">
                <span>👤</span>
                Profile
            </a>
        </nav>

        <div class="mpesa-sidebar-promo">
            <h3>Payment Check</h3>
            <p>Keep this page open while we confirm your M-Pesa payment.</p>
            <a href="orderDetails.jsp?orderId=<%= orderId %>">Order Details</a>
        </div>

        <div class="mpesa-sidebar-bottom">
            <a href="logout" onclick="return confirm('Are you sure you want to logout?');">
                ⎋ Logout
            </a>
        </div>
    </aside>

    <!-- MAIN -->
    <main class="mpesa-main">

        <!-- MOBILE TOP BAR -->
        <header class="mpesa-mobile-topbar">
            <a href="payment.jsp?orderId=<%= orderId %>" aria-label="Back to payment">←</a>
            <strong>M-Pesa</strong>
            <div>
                <a href="myOrders.jsp" aria-label="Orders">📦</a>
                <a href="profile.jsp" aria-label="Profile">👤</a>
            </div>
        </header>

        <!-- DESKTOP TOP BAR -->
        <header class="mpesa-topbar">
            <div>
                <h1>M-Pesa Payment</h1>
                <p>Waiting for confirmation for order <strong>#<%= orderId %></strong>.</p>
            </div>

            <div class="mpesa-top-actions">
                <a href="payment.jsp?orderId=<%= orderId %>" class="mpesa-top-btn">Retry Payment</a>
                <a class="mpesa-icon-btn" href="myOrders.jsp" title="My Orders">📦</a>
                <a class="mpesa-profile-btn" href="customerDashboard.jsp" title="Dashboard">👤</a>
            </div>
        </header>

        <div class="mpesa-content">

            <div class="mpesa-breadcrumb">
                <a href="customerDashboard.jsp">DASHBOARD</a>
                <span>›</span>
                <a href="myOrders.jsp">MY ORDERS</a>
                <span>›</span>
                <strong>ORDER #<%= orderId %></strong>
            </div>

            <section class="mpesa-hero-card" id="pendingHeader">
                <div>
                    <p class="mpesa-eyebrow">M-PESA CHECKOUT</p>
                    <h2 id="headerTitle">Payment in Progress</h2>
                    <p id="headerSubtitle">
                        Please complete the M-Pesa prompt on your phone to confirm Order #<%= orderId %>.
                    </p>

                    <div class="mpesa-hero-badges">
                        <span id="statusChip">Pending</span>
                        <span>🔒 Secure STK Push</span>
                    </div>
                </div>

                <div class="mpesa-order-card">
                    <span>Order Number</span>
                    <strong>#<%= orderId %></strong>
                    <small>Payment method</small>
                    <b>M-Pesa STK Push</b>
                </div>
            </section>

            <section class="mpesa-main-card">

                <div class="mpesa-card-grid">

                    <!-- LEFT VISUAL -->
                    <section class="mpesa-visual-panel">

                        <div class="mpesa-animation-area">

                            <div class="mpesa-spinner-wrap" id="spinnerWrap">
                                <div class="mpesa-spinner-ring"></div>
                                <div class="mpesa-spinner-core">M</div>
                            </div>

                            <div class="mpesa-success-animation" id="successAnimation">
                                <div class="mpesa-success-check"></div>
                            </div>

                            <div class="mpesa-failed-animation" id="failedAnimation">
                                ×
                            </div>

                        </div>

                        <div class="mpesa-phone-shell">
                            <div class="mpesa-phone-notch"></div>

                            <div class="mpesa-phone-screen" id="phoneScreen">
                                <p id="phoneText">M-Pesa Request Sent</p>
                                <h3>Order #<%= orderId %></h3>
                                <span id="phoneStatus" class="fade-pulse">
                                    Awaiting PIN confirmation...
                                </span>
                            </div>
                        </div>

                    </section>

                    <!-- RIGHT DETAILS -->
                    <section class="mpesa-status-panel">

                        <div class="mpesa-status-main">
                            <h2 id="mainTitle">Waiting for Payment Confirmation</h2>
                            <p id="mainSubtext">
                                An STK Push has been sent to your Safaricom phone.
                                Enter your M-Pesa PIN on your device to authorize the payment.
                            </p>
                        </div>

                        <div class="mpesa-meta-row">
                            <div>
                                <span>Order Number</span>
                                <strong>#<%= orderId %></strong>
                            </div>

                            <div>
                                <span>Payment Method</span>
                                <strong>M-Pesa STK Push</strong>
                            </div>

                            <div>
                                <span>Current Status</span>
                                <strong id="statusChipMeta">Pending</strong>
                            </div>
                        </div>

                        <div class="mpesa-live-box">
                            <h3 id="statusText">Waiting for payment confirmation...</h3>
                            <p id="smallText">
                                Do not close or refresh this page while we verify your payment.
                            </p>
                            <span id="timerText">Elapsed time: 0s</span>
                        </div>

                        <div class="mpesa-info-box" id="infoBox">
                            <strong>Tip:</strong>
                            If you do not see the prompt immediately, wait a few seconds and confirm
                            that your phone is online and able to receive M-Pesa prompts.
                        </div>

                        <div class="mpesa-actions">
                            <a id="ordersBtn" class="mpesa-primary-action hidden" href="myOrders.jsp">
                                View My Orders
                            </a>

                            <a id="detailsBtn" class="mpesa-secondary-action hidden" href="orderDetails.jsp?orderId=<%= orderId %>">
                                View Order Details
                            </a>

                            <a id="retryBtn" class="mpesa-warning-action hidden" href="payment.jsp?orderId=<%= orderId %>">
                                Try Again
                            </a>
                        </div>

                    </section>

                </div>

                <!-- PROGRESS STEPS -->
                <section class="mpesa-progress-section">
                    <div class="mpesa-section-title">
                        <h2>Payment Progress</h2>
                        <p>Your order will update automatically after confirmation.</p>
                    </div>

                    <div class="mpesa-step-grid">

                        <div class="mpesa-step-card done" id="step1">
                            <div class="mpesa-step-number" id="step1Badge">✓</div>
                            <h4>STK Push Sent</h4>
                            <p>A payment request has been sent to your Safaricom number.</p>
                        </div>

                        <div class="mpesa-step-card active" id="step2">
                            <div class="mpesa-step-number" id="step2Badge">2</div>
                            <h4>Authorize Payment</h4>
                            <p>Enter your M-Pesa PIN on your phone to approve the transaction.</p>
                        </div>

                        <div class="mpesa-step-card" id="step3">
                            <div class="mpesa-step-number" id="step3Badge">3</div>
                            <h4>Confirming Payment</h4>
                            <p>AgriBridge will verify the transaction and update your order.</p>
                        </div>

                    </div>
                </section>

            </section>

        </div>

    </main>

</div>

<aside class="mpesa-mobile-summary">
    <div>
        <span>Status</span>
        <strong id="mobileStatusText">Pending</strong>
    </div>

    <a href="orderDetails.jsp?orderId=<%= orderId %>">
        Details
    </a>
</aside>

<!-- MOBILE BOTTOM NAV -->
<nav class="mpesa-bottom-nav">
    <a href="customerDashboard.jsp">
        <span>⌂</span>
        Home
    </a>

    <a href="myOrders.jsp" class="active">
        <span>📦</span>
        Orders
    </a>

    <a href="products.jsp">
        <span>🛒</span>
        Shop
    </a>

    <a href="profile.jsp">
        <span>👤</span>
        Profile
    </a>
</nav>

<script>
    const orderId = "<%= orderId %>";
    let seconds = 0;
    let finished = false;

    const timerInterval = setInterval(updateTimer, 1000);

    function setStatusText(value) {
        const statusChip = document.getElementById("statusChip");
        const statusChipMeta = document.getElementById("statusChipMeta");
        const mobileStatusText = document.getElementById("mobileStatusText");

        if (statusChip) statusChip.innerText = value;
        if (statusChipMeta) statusChipMeta.innerText = value;
        if (mobileStatusText) mobileStatusText.innerText = value;
    }

    function updateTimer() {
        if (finished) return;

        seconds++;
        document.getElementById("timerText").innerText = "Elapsed time: " + seconds + "s";

        if (seconds === 8) {
            markConfirmingStep();
        }

        if (seconds === 90) {
            showLongWaitMessage();
        }
    }

    function markConfirmingStep() {
        if (finished) return;

        document.getElementById("step2").classList.remove("active");
        document.getElementById("step2").classList.add("done");
        document.getElementById("step2Badge").innerText = "✓";

        document.getElementById("step3").classList.add("active");

        document.getElementById("statusText").innerText = "Confirming transaction...";
        document.getElementById("smallText").innerText = "We are checking the M-Pesa payment response.";
        document.getElementById("phoneStatus").innerText = "Confirming payment...";

        setStatusText("Confirming");
    }

    function showLongWaitMessage() {
        if (finished) return;

        document.getElementById("smallText").innerText =
            "This is taking longer than usual. If you completed payment, please wait a little longer or check My Orders.";
    }

    function markSuccess() {
        finished = true;
        clearInterval(timerInterval);

        document.getElementById("spinnerWrap").classList.add("hidden");
        document.getElementById("successAnimation").style.display = "flex";

        document.getElementById("pendingHeader").classList.add("success");
        document.getElementById("headerTitle").innerText = "Payment Successful";
        document.getElementById("headerSubtitle").innerText =
            "Your transaction has been verified and your order has been updated.";

        document.getElementById("mainTitle").innerText = "Payment Confirmed";
        document.getElementById("mainSubtext").innerText =
            "Thank you. Your M-Pesa payment has been confirmed successfully.";

        document.getElementById("statusText").innerText = "Payment successful";
        document.getElementById("statusText").classList.add("status-success");
        document.getElementById("smallText").innerText = "Redirecting you to your order details...";

        setStatusText("Paid");

        document.getElementById("phoneText").innerText = "Payment Successful";
        document.getElementById("phoneStatus").innerText = "Transaction confirmed";
        document.getElementById("phoneStatus").classList.remove("fade-pulse");

        document.getElementById("phoneScreen").classList.add("success");

        document.getElementById("step1").classList.add("done");
        document.getElementById("step1Badge").innerText = "✓";

        document.getElementById("step2").classList.remove("active");
        document.getElementById("step2").classList.add("done");
        document.getElementById("step2Badge").innerText = "✓";

        document.getElementById("step3").classList.remove("active");
        document.getElementById("step3").classList.add("done");
        document.getElementById("step3Badge").innerText = "✓";

        document.getElementById("infoBox").innerHTML =
            "<strong>Success:</strong> Your payment has been received. Your order is now ready for processing.";

        document.getElementById("ordersBtn").classList.remove("hidden");
        document.getElementById("detailsBtn").classList.remove("hidden");

        setTimeout(() => {
            window.location.href = "orderDetails.jsp?orderId=" + orderId;
        }, 3500);
    }

    function markFailed() {
        finished = true;
        clearInterval(timerInterval);

        document.getElementById("spinnerWrap").classList.add("hidden");
        document.getElementById("failedAnimation").style.display = "flex";

        document.getElementById("pendingHeader").classList.add("failed");
        document.getElementById("headerTitle").innerText = "Payment Failed";
        document.getElementById("headerSubtitle").innerText =
            "The transaction was cancelled, timed out, or not completed.";

        document.getElementById("mainTitle").innerText = "Payment Not Completed";
        document.getElementById("mainSubtext").innerText =
            "Your M-Pesa payment could not be confirmed. You can retry the payment below.";

        document.getElementById("statusText").innerText = "Payment failed or cancelled";
        document.getElementById("statusText").classList.add("status-failed");
        document.getElementById("smallText").innerText =
            "Please retry the transaction or select another payment option.";

        setStatusText("Failed");

        document.getElementById("phoneText").innerText = "Payment Failed";
        document.getElementById("phoneStatus").innerText = "Transaction not completed";
        document.getElementById("phoneStatus").classList.remove("fade-pulse");

        document.getElementById("phoneScreen").classList.add("failed");

        document.getElementById("step2").classList.remove("active");
        document.getElementById("step3").classList.remove("active");
        document.getElementById("step3").classList.add("failed");
        document.getElementById("step3Badge").innerText = "×";

        document.getElementById("infoBox").innerHTML =
            "<strong>Notice:</strong> The payment was not completed. You can send another STK Push request.";

        document.getElementById("retryBtn").classList.remove("hidden");
        document.getElementById("ordersBtn").classList.remove("hidden");
    }

    function checkPaymentStatus() {
        if (finished) return;

        fetch("paymentStatus?orderId=" + orderId)
            .then(response => {
                if (!response.ok) {
                    throw new Error("Could not check payment status");
                }

                return response.json();
            })
            .then(data => {
                const status = (data.status || "PENDING").toUpperCase();

                if (status === "PAID" || status === "COMPLETED") {
                    markSuccess();

                } else if (status === "FAILED" || status === "CANCELLED") {
                    markFailed();

                } else {
                    setTimeout(checkPaymentStatus, 3000);
                }
            })
            .catch(error => {
                console.log("Status check error:", error);
                setTimeout(checkPaymentStatus, 5000);
            });
    }

    checkPaymentStatus();
</script>

</body>
</html>
