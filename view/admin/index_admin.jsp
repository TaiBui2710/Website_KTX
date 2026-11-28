<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Trị Ký Túc Xá - Admin Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">
</head>
<body>

<div class="admin-layout">
    <aside class="admin-sidebar">
        <div class="sidebar-brand">
            <img src="${pageContext.request.contextPath}/assets/images/logo-bk.png" alt="Logo BK">
            <div>
                <h2>Admin KTX</h2>
                <span>Hệ thống quản trị</span>
            </div>
        </div>

        <nav class="sidebar-menu">
            <div class="menu-label">Quản lý nội trú</div>
            <a href="${pageContext.request.contextPath}/admin/users" target="admin-frame" class="active" onclick="setActive(this, 'QUẢN LÝ NGƯỜI DÙNG')">Quản lý người dùng</a>
            <a href="${pageContext.request.contextPath}/admin/rooms" target="admin-frame" onclick="setActive(this, 'QUẢN LÝ PHÒNG')">Quản lý phòng</a>
            <a href="${pageContext.request.contextPath}/admin/registrations" target="admin-frame" onclick="setActive(this, 'ĐƠN ĐĂNG KÝ & YÊU CẦU')">Đơn đăng ký & Yêu cầu</a>

            <div class="menu-label">Nội dung công khai</div>
            <a href="${pageContext.request.contextPath}/admin/notices" target="admin-frame" onclick="setActive(this, 'THÔNG BÁO & NỘI QUY')">Thông báo & Nội quy</a>
            <a href="${pageContext.request.contextPath}/admin/forms" target="admin-frame" onclick="setActive(this, 'BIỂU MẪU VÀ ĐƠN TỪ')">Biểu mẫu và đơn từ</a>

            <div class="menu-label">Tài khoản</div>
            <a href="${pageContext.request.contextPath}/admin/profile" target="admin-frame" onclick="setActive(this, 'CHỈNH SỬA THÔNG TIN CÁ NHÂN')">Hồ sơ cá nhân</a>
        </nav>
    </aside>

    <div class="admin-main">
        <header class="admin-topbar">
            <div class="topbar-title" id="page-title">QUẢN LÝ NGƯỜI DÙNG</div>
            <div class="admin-user-info">
                <span>Xin chào, <strong>${not empty sessionScope.user ? sessionScope.user.fullName : 'Quản trị viên'}</strong></span>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Đăng xuất</a>
            </div>
        </header>

        <iframe src="${pageContext.request.contextPath}/admin/users" name="admin-frame" id="admin-frame"></iframe>
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