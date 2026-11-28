<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Nhập - Ký Túc Xá Bách Khoa</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css">
</head>
<body>

<div class="auth-container">
    <div class="auth-header">
        <img src="${pageContext.request.contextPath}/assets/images/logo-bk.png" alt="Logo Đại học Bách Khoa">
        <h2>Đăng Nhập Hệ Thống</h2>
        <p>Cổng thông tin Ký túc xá Sinh viên</p>
    </div>

    <c:if test="${not empty error}">
        <div style="background:#fee2e2; color:#991b1b; padding:10px 12px; border-radius:5px; font-size:13px; margin-bottom:15px; border:1px solid #fca5a5;">
            ${error}
        </div>
    </c:if>

    <c:if test="${not empty success}">
        <div style="background:#dcfce7; color:#166534; padding:10px 12px; border-radius:5px; font-size:13px; margin-bottom:15px; border:1px solid #86efac;">
            ${success}
        </div>
    </c:if>

    <form id="loginForm" action="${pageContext.request.contextPath}/login" method="POST">
        <div class="auth-group">
            <label for="username">Tên đăng nhập (Username) *</label>
            <input type="text" id="username" name="username" maxlength="50"
                   value="${param.username}" placeholder="VD: sv001 hoặc admin" required>
        </div>

        <div class="auth-group">
            <label for="password">Mật khẩu *</label>
            <input type="password" id="password" name="password" placeholder="Nhập mật khẩu..." required>
        </div>

        <button type="submit" class="btn btn-blue btn-auth">Đăng nhập</button>
    </form>

    <div class="auth-links">
        <span>Chưa có tài khoản sinh viên? <a href="${pageContext.request.contextPath}/view/auth/register.jsp">Đăng ký ngay</a></span>
        <a href="${pageContext.request.contextPath}/view/guest/index_guest.html" class="back-home">← Quay lại trang chủ (Guest)</a>
    </div>
</div>

<script>
    document.getElementById('loginForm').addEventListener('submit', function (e) {
        const usernameInput = document.getElementById('username');
        const passwordInput = document.getElementById('password');

        const username = usernameInput.value.trim();
        if (username === '') {
            alert('Vui lòng nhập tên đăng nhập!');
            usernameInput.focus();
            e.preventDefault();
            return;
        }
        if (passwordInput.value === '') {
            alert('Vui lòng nhập mật khẩu!');
            passwordInput.focus();
            e.preventDefault();
            return;
        }
        usernameInput.value = username;
    });
</script>

</body>
</html>