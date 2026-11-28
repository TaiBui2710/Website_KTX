<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/user.css">
</head>
<body>

<div class="page-wrapper">
    <div class="page-header">
        <h3>Hồ Sơ Thông Tin Cá Nhân</h3>
    </div>

    <div class="table-card profile-card">
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

        <form id="userProfileForm" action="${pageContext.request.contextPath}/user/update-profile" method="POST">
            <div class="profile-grid">
                <div class="form-group">
                    <label>Tên đăng nhập (username)</label>
                    <input type="text" class="input-readonly" name="username"
                           value="${not empty sessionScope.user ? sessionScope.user.username : 'sv001'}" readonly>
                </div>
                <div class="form-group">
                    <label>Mã số sinh viên (student_code)</label>
                    <input type="text" class="input-readonly" name="student_code"
                           value="${not empty sessionScope.user ? sessionScope.user.studentCode : '2251010001'}" readonly>
                </div>
                <div class="form-group">
                    <label>Họ và tên (full_name) *</label>
                    <input type="text" name="full_name" id="user_fullname" maxlength="100"
                           value="${not empty sessionScope.user ? sessionScope.user.fullName : 'Nguyễn Văn An'}" required>
                </div>
                <div class="form-group">
                    <label>Giới tính (gender)</label>
                    <select name="gender" id="user_gender">
                        <option value="male" ${sessionScope.user.gender == 'male' || empty sessionScope.user ? 'selected' : ''}>Nam (male)</option>
                        <option value="female" ${sessionScope.user.gender == 'female' ? 'selected' : ''}>Nữ (female)</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Email liên hệ (email) *</label>
                    <input type="email" name="email" id="user_email" maxlength="100"
                           value="${not empty sessionScope.user ? sessionScope.user.email : 'an.nv@sv.edu.vn'}" required>
                </div>
                <div class="form-group">
                    <label>Số điện thoại (phone)</label>
                    <input type="text" name="phone" id="user_phone" maxlength="15"
                           value="${not empty sessionScope.user ? sessionScope.user.phone : '0901000001'}">
                </div>
                <div class="form-group col-full">
                    <label>Mật khẩu mới (Bỏ trống nếu không đổi)</label>
                    <input type="password" name="new_password" id="user_password" placeholder="Nhập mật khẩu mới (tối thiểu 6 ký tự)...">
                </div>
            </div>

            <div class="profile-footer-btns" style="justify-content: flex-end;">
                <button type="submit" class="btn btn-blue">Lưu cập nhật</button>
            </div>
        </form>
    </div>
</div>

<script>
    document.getElementById('userProfileForm').addEventListener('submit', function (e) {
        const fullnameInput = document.getElementById('user_fullname');
        const emailInput = document.getElementById('user_email');
        const phoneInput = document.getElementById('user_phone');
        const passwordInput = document.getElementById('user_password');

        const fullname = fullnameInput.value.trim();
        const email = emailInput.value.trim();
        const phone = phoneInput.value.trim();
        const password = passwordInput.value;

        // 1. Kiểm tra họ và tên
        if (fullname.length < 2 || fullname.length > 100) {
            alert('Họ và tên phải từ 2 đến 100 ký tự!');
            fullnameInput.focus();
            e.preventDefault();
            return;
        }

        // 2. Kiểm tra định dạng email
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            alert('Email không đúng định dạng!');
            emailInput.focus();
            e.preventDefault();
            return;
        }

        // 3. Kiểm tra định dạng số điện thoại (nếu có nhập)
        if (phone !== '' && !/^0\d{8,10}$/.test(phone)) {
            alert('Số điện thoại không hợp lệ (phải bắt đầu bằng số 0 và gồm 9 - 11 chữ số)!');
            phoneInput.focus();
            e.preventDefault();
            return;
        }

        // 4. Kiểm tra mật khẩu mới (nếu có nhập)
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