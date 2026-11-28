<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Ký Tài Khoản - Ký Túc Xá Bách Khoa</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css">
</head>
<body>

<div class="auth-container register-box">
    <div class="auth-header">
        <img src="${pageContext.request.contextPath}/assets/images/logo-bk.png" alt="Logo Đại học Bách Khoa">
        <h2>Đăng Ký Tài Khoản Hệ Thống</h2>
        <p>Tạo tài khoản Sinh viên nội trú hoặc Quản trị viên KTX</p>
    </div>

    <c:if test="${not empty error}">
        <div style="background:#fee2e2; color:#991b1b; padding:10px 12px; border-radius:5px; font-size:13px; margin-bottom:15px; border:1px solid #fca5a5;">
            ${error}
        </div>
    </c:if>

    <form id="registerForm" action="${pageContext.request.contextPath}/register" method="POST">
        <div class="auth-grid">
            <div class="auth-group full-col">
                <label for="role">Loại tài khoản (role) *</label>
                <select id="role" name="role" onchange="toggleRoleFields()" required>
                    <option value="user" ${param.role != 'admin' ? 'selected' : ''}>Sinh viên nội trú (user)</option>
                    <option value="admin" ${param.role == 'admin' ? 'selected' : ''}>Quản trị viên KTX (admin)</option>
                </select>
            </div>

            <div class="auth-group">
                <label for="username">Tên đăng nhập (username) *</label>
                <input type="text" id="username" name="username" maxlength="50"
                       value="${param.username}" placeholder="VD: sv006 hoặc admin2" required>
            </div>

            <div class="auth-group" id="studentCodeGroup">
                <label for="student_code">Mã số sinh viên (student_code) *</label>
                <input type="text" id="student_code" name="student_code" maxlength="20"
                       value="${param.student_code}" placeholder="VD: 2251010006" required>
            </div>

            <div class="auth-group">
                <label for="full_name">Họ và tên (full_name) *</label>
                <input type="text" id="full_name" name="full_name" maxlength="100"
                       value="${param.full_name}" placeholder="Nguyễn Văn A" required>
            </div>

            <div class="auth-group">
                <label for="gender" id="genderLabel">Giới tính (gender) *</label>
                <select id="gender" name="gender" required>
                    <option value="">-- Chọn giới tính --</option>
                    <option value="male" ${param.gender == 'male' ? 'selected' : ''}>Nam</option>
                    <option value="female" ${param.gender == 'female' ? 'selected' : ''}>Nữ</option>
                </select>
            </div>

            <div class="auth-group">
                <label for="email">Email liên hệ (email) *</label>
                <input type="email" id="email" name="email" maxlength="100"
                       value="${param.email}" placeholder="example@ktx.edu.vn" required>
            </div>

            <div class="auth-group">
                <label for="phone">Số điện thoại (phone)</label>
                <input type="text" id="phone" name="phone" maxlength="15"
                       value="${param.phone}" placeholder="0901xxxxxx">
            </div>

            <div class="auth-group">
                <label for="password">Mật khẩu *</label>
                <input type="password" id="password" name="password" placeholder="Tối thiểu 6 ký tự" minlength="6" required>
            </div>

            <div class="auth-group">
                <label for="confirm_password">Nhập lại mật khẩu *</label>
                <input type="password" id="confirm_password" name="confirm_password" placeholder="Xác nhận mật khẩu" minlength="6" required>
            </div>
        </div>

        <button type="submit" class="btn btn-blue btn-auth">Đăng ký tài khoản</button>
    </form>

    <div class="auth-links">
        <span>Đã có tài khoản? <a href="${pageContext.request.contextPath}/view/auth/login.jsp">Đăng nhập tại đây</a></span>
        <a href="${pageContext.request.contextPath}/view/guest/index_guest.html" class="back-home">← Quay lại trang chủ (Guest)</a>
    </div>
</div>

<script>
    // Ẩn MSSV và bỏ bắt buộc Giới tính khi chọn Admin (khớp schema users trong DB)
    function toggleRoleFields() {
        const role = document.getElementById('role').value;
        const studentGroup = document.getElementById('studentCodeGroup');
        const studentInput = document.getElementById('student_code');
        const genderSelect = document.getElementById('gender');
        const genderLabel = document.getElementById('genderLabel');

        if (role === 'admin') {
            studentGroup.style.display = 'none';
            studentInput.required = false;
            studentInput.value = '';
            genderSelect.required = false;
            genderLabel.innerText = 'Giới tính (gender - Tùy chọn)';
        } else {
            studentGroup.style.display = 'block';
            studentInput.required = true;
            genderSelect.required = true;
            genderLabel.innerText = 'Giới tính (gender) *';
        }
    }

    // Kiểm tra định dạng toàn bộ form trước khi submit
    document.getElementById('registerForm').addEventListener('submit', function (e) {
        const role = document.getElementById('role').value;
        const usernameInput = document.getElementById('username');
        const studentInput = document.getElementById('student_code');
        const fullNameInput = document.getElementById('full_name');
        const emailInput = document.getElementById('email');
        const phoneInput = document.getElementById('phone');
        const pw = document.getElementById('password').value;
        const cpw = document.getElementById('confirm_password').value;

        const username = usernameInput.value.trim();
        const studentCode = studentInput.value.trim();
        const fullName = fullNameInput.value.trim();
        const email = emailInput.value.trim();
        const phone = phoneInput.value.trim();

        // 1. Username: chữ cái, số, gạch dưới (3 - 50 ký tự)
        if (!/^[a-zA-Z0-9_]{3,50}$/.test(username)) {
            alert('Tên đăng nhập chỉ gồm chữ cái, số hoặc dấu gạch dưới (3 - 50 ký tự)!');
            usernameInput.focus();
            e.preventDefault();
            return;
        }

        // 2. MSSV (bắt buộc nếu role = user)
        if (role === 'user' && !/^[A-Za-z0-9]{5,20}$/.test(studentCode)) {
            alert('Mã số sinh viên chỉ gồm chữ và số (5 - 20 ký tự)!');
            studentInput.focus();
            e.preventDefault();
            return;
        }

        // 3. Họ và tên
        if (fullName.length < 2 || fullName.length > 100) {
            alert('Họ và tên phải từ 2 đến 100 ký tự!');
            fullNameInput.focus();
            e.preventDefault();
            return;
        }

        // 4. Email
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            alert('Email không đúng định dạng!');
            emailInput.focus();
            e.preventDefault();
            return;
        }

        // 5. Số điện thoại (nếu có nhập)
        if (phone !== '' && !/^0\d{8,10}$/.test(phone)) {
            alert('Số điện thoại không hợp lệ (bắt đầu bằng số 0, gồm 9 - 11 chữ số)!');
            phoneInput.focus();
            e.preventDefault();
            return;
        }

        // 6. Mật khẩu & xác nhận mật khẩu
        if (pw.length < 6) {
            alert('Mật khẩu phải có ít nhất 6 ký tự!');
            document.getElementById('password').focus();
            e.preventDefault();
            return;
        }
        if (pw !== cpw) {
            alert('Mật khẩu nhập lại không khớp!');
            document.getElementById('confirm_password').focus();
            e.preventDefault();
            return;
        }

        usernameInput.value = username;
        studentInput.value = studentCode;
        fullNameInput.value = fullName;
        emailInput.value = email;
        phoneInput.value = phone;
    });

    // Giữ đúng trạng thái ẩn/hiện khi Servlet forward lại trang lúc báo lỗi
    window.addEventListener('DOMContentLoaded', toggleRoleFields);
</script>

</body>
</html>