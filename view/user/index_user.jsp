<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cổng Sinh Viên - Ký Túc Xá Bách Khoa</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">
</head>
<body>

<div class="admin-layout">
    <!-- SIDEBAR MENU GIỐNG ADMIN -->
    <aside class="admin-sidebar">
        <div class="sidebar-brand">
            <img src="${pageContext.request.contextPath}/assets/images/logo-bk.png" alt="Logo BK">
            <div>
                <h2>Sinh Viên KTX</h2>
                <span>Cổng thông tin nội trú</span>
            </div>
        </div>

        <nav class="sidebar-menu">
            <div class="menu-label">Nội trú cá nhân</div>
            <a href="${pageContext.request.contextPath}/user/dashboard" target="user-frame" class="active" onclick="setActive(this, 'TRANG CHỦ')">Trang chủ</a>
            <a href="${pageContext.request.contextPath}/user/rooms" target="user-frame" onclick="setActive(this, 'ĐĂNG KÝ PHÒNG')">Đăng ký phòng</a>
            <a href="${pageContext.request.contextPath}/user/feedback" target="user-frame" onclick="setActive(this, 'FEEDBACK')">Feedback</a>
            <a href="${pageContext.request.contextPath}/user/profile" target="user-frame" onclick="setActive(this, 'HỒ SƠ CÁ NHÂN')">Hồ sơ cá nhân</a>

            <div class="menu-label">Thông tin chung KTX</div>
            <a href="${pageContext.request.contextPath}/home" target="user-frame" onclick="setActive(this, 'THÔNG BÁO & GIỚI THIỆU')">Thông báo và giới thiệu</a>
            <a href="${pageContext.request.contextPath}/forms" target="user-frame" onclick="setActive(this, 'BIỂU MẪU VÀ ĐƠN TỪ')">Biểu mẫu và đơn từ</a>
        </nav>
    </aside>

    <!-- KHU VỰC CHÍNH BÊN PHẢI -->
    <div class="admin-main">
        <header class="admin-topbar">
            <div class="topbar-title" id="page-title">TRANG CHỦ</div>
            <div class="admin-user-info">
                <span>Xin chào, <strong>${not empty sessionScope.user ? sessionScope.user.fullName : 'Sinh viên'}</strong></span>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Đăng xuất</a>
            </div>
        </header>

        <iframe src="${pageContext.request.contextPath}/user/dashboard" name="user-frame" id="admin-frame"></iframe>
    </div>
</div>

<script>
    function setActive(element, title) {
        document.querySelectorAll('.sidebar-menu a').forEach(a => a.classList.remove('active'));
        element.classList.add('active');
        document.getElementById('page-title').innerText = title;
    }
</script>

</body>
</html>