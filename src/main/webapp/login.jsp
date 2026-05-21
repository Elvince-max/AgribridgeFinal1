<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html>
<head>
    <title>Login - Egerton AgriBridge Hub</title>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style-backup.css">
</head>
<body class="auth-body">

<div class="auth-page">

    <!-- LEFT BRAND PANEL -->
    <div class="auth-brand-panel">
        <div class="auth-visual-card">

            <div class="auth-image-box">
                <img src="<%= request.getContextPath() %>/uploads/milking_man.jpg" alt="Fresh dairy products">
            </div>

            <div class="auth-overlay">
                <p class="auth-eyebrow">WELCOME BACK</p>

                <h1>Egerton<br>AgriBridge Hub</h1>

                <p>
                    Login to continue shopping, track your orders, manage payments,
                    and stay connected to fresh farm products.
                </p>

                <div class="auth-mini-badges">
                    <span>✓ Fresh Products</span>
                    <span>✓ Secure Checkout</span>
                    <span>✓ Order Tracking</span>
                </div>

                <div class="auth-highlights">
                    <div>
                        <strong>Shop</strong>
                        <span>Browse products</span>
                    </div>

                    <div>
                        <strong>Pay</strong>
                        <span>M-Pesa support</span>
                    </div>

                    <div>
                        <strong>Track</strong>
                        <span>Order updates</span>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <!-- RIGHT FORM PANEL -->
    <div class="auth-form-panel">
        <div class="auth-card">

            <a href="index.jsp" class="auth-back">← Back to Home</a>

            <h2>Welcome Back</h2>
            <p class="auth-subtitle">Login to continue to your account.</p>

            <%
                if (request.getParameter("error") != null) {
            %>
                <div class="auth-error">
                    Invalid email or password. Please try again.
                </div>
            <%
                }
            %>

            <form action="login" method="post">
                <label>Email Address</label>
                <input type="email" name="email" placeholder="example@gmail.com" required>

                <label>Password</label>
                <div class="password-wrap">
                    <input id="loginPassword" type="password" name="password" placeholder="Enter your password" required>

                    <button type="button" class="password-toggle" onclick="togglePassword('loginPassword', this)" aria-label="Toggle password visibility">
                        <svg class="eye-open" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7S1 12 1 12z"></path>
                            <circle cx="12" cy="12" r="3"></circle>
                        </svg>

                        <svg class="eye-closed hidden" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M17.94 17.94A10.94 10.94 0 0 1 12 19C5 19 1 12 1 12a21.77 21.77 0 0 1 5.06-5.94"></path>
                            <path d="M9.9 4.24A10.94 10.94 0 0 1 12 5c7 0 11 7 11 7a21.79 21.79 0 0 1-3.22 4.22"></path>
                            <path d="M1 1l22 22"></path>
                            <path d="M10.58 10.58A2 2 0 0 0 12 14a2 2 0 0 0 1.42-.58"></path>
                        </svg>
                    </button>
                </div>

                <button class="auth-btn" type="submit">Login</button>
            </form>

            <p class="auth-switch">
                Don't have an account?
                <a href="register.jsp">Create Account</a>
            </p>

        </div>
    </div>

</div>

<script>
    function togglePassword(inputId, btn) {
        const input = document.getElementById(inputId);
        const eyeOpen = btn.querySelector(".eye-open");
        const eyeClosed = btn.querySelector(".eye-closed");

        if (input.type === "password") {
            input.type = "text";
            eyeOpen.classList.add("hidden");
            eyeClosed.classList.remove("hidden");
        } else {
            input.type = "password";
            eyeOpen.classList.remove("hidden");
            eyeClosed.classList.add("hidden");
        }
    }
</script>

</body>
</html>