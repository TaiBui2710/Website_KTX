<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">
</head>
<body>

<div class="page-wrapper">
    <div class="page-header">
        <h3>Hồ Sơ Thông Tin Cá Nhân Quản Trị Viên</h3>
    </div>

    <div class="table-card" style="max-width: 750px; padding: 25px;">
        <c:if test="${not empty success}">
            <div style="background:#dcfce7; color:#166534; padding:10px 14px; border-radius:6px; margin-bottom:15px;">
                ${success}
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div style="background:#fee2e2; color:#991b1b; padding:10px 14px; border-radius:6px; margin-bottom:15px;">
                ${error}
            </div>
        </c:if>

        <form id="adminProfileForm" action="${pageContext.request.contextPath}/admin/update-profile" method="POST">
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                <div class="form-group">
                    <label>Tên đăng nhập (username)</label>
                    <input type="text" class="input-readonly" name="username"
                           value="${not empty sessionScope.user ? sessionScope.user.username : 'admin'}" readonly>
                </div>
                <div class="form-group">
                    <label>Vai trò hệ thống (role)</label>
                    <input type="text" class="input-readonly" value="Quản trị viên (admin)" readonly>
                </div>
                <div class="form-group">
                    <label>Họ và tên (full_name) *</label>
                    <input type="text" name="full_name" id="admin_fullname" maxlength="100"
                           value="${not empty sessionScope.user ? sessionScope.user.fullName : 'Quản trị viên'}" required>
                </div>
                <div class="form-group">
                    <label>Giới tính (gender)</label>
                    <select name="gender" id="admin_gender">
                        <option value="" ${empty sessionScope.user.gender ? 'selected' : ''}>-- Không bắt buộc --</option>
                        <option value="male" ${sessionScope.user.gender == 'male' ? 'selected' : ''}>Nam (male)</option>
                        <option value="female" ${sessionScope.user.gender == 'female' ? 'selected' : ''}>Nữ (female)</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Email liên hệ (email) *</label>
                    <input type="email" name="email" id="admin_email" maxlength="100"
                           value="${not empty sessionScope.user ? sessionScope.user.email : 'admin@ktx.edu.vn'}" required>
                </div>
                <div class="form-group">
                    <label>Số điện thoại (phone)</label>
                    <input type="text" name="phone" id="admin_phone" maxlength="15"
                           value="${not empty sessionScope.user ? sessionScope.user.phone : '0900000000'}">
                </div>
                <div class="form-group" style="grid-column: span 2;">
                    <label>Mật khẩu mới (Bỏ trống nếu không đổi)</label>
                    <input type="password" name="new_password" id="admin_password" placeholder="Nhập mật khẩu mới (tối thiểu 6 ký tự)...">
                </div>
            </div>

            <div class="modal-footer">
                <button type="submit" class="btn btn-blue">Lưu thông tin cá nhân</button>
            </div>
        </form>
    </div>
</div>

<script>
    document.getElementById('adminProfileForm').addEventListener('submit', function (e) {
        const fullnameInput = document.getElementById('admin_fullname');
        const emailInput = document.getElementById('admin_email');
        const phoneInput = document.getElementById('admin_phone');
        const passwordInput = document.getElementById('admin_password');

        const fullname = fullnameInput.value.trim();
        const email = emailInput.value.trim();
        const phone = phoneInput.value.trim();
        const password = passwordInput.value;

        // 1. Kiểm tra họ tên
        if (fullname.length < 2 || fullname.length > 100) {
            alert('Họ và tên phải từ 2 đến 100 ký tự!');
            fullnameInput.focus();
            e.preventDefault();
            return;
        }

        // 2. Kiểm tra định dạng email
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            alert('Email không đúng định dạng!');
            emailInput.focus();
            e.preventDefault();
            return;
        }

        // 3. Kiểm tra định dạng số điện thoại (nếu có nhập)
        if (phone !== '' && !/^0\d{8,10}$/.test(phone)) {
            alert('Số điện thoại không hợp lệ (phải bắt đầu bằng số 0 và gồm 9-11 chữ số)!');
            phoneInput.focus();
            e.preventDefault();
            return;
        }

        // 4. Kiểm tra mật khẩu mới (chỉ kiểm tra nếu người dùng có nhập)
        if (password !== '' && password.length < 6) {
            alert('Mật khẩu mới phải có ít nhất 6 ký tự!');
            passwordInput.focus();
            e.preventDefault();
            return;
        }

        fullnameInput.value = fullname;
        emailInput.value = email;
        phoneInput.value = phone;
    });
</script>

</body>
</html>