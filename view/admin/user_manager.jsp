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
        <h3>Danh Sách Tài Khoản Hệ Thống (Users)</h3>
    </div>

    <div class="filter-bar">
        <input type="text" class="search-input" placeholder="Tìm theo username, MSSV, họ tên...">
        <select>
            <option value="">-- Lọc theo giới tính --</option>
            <option value="male">Nam (male)</option>
            <option value="female">Nữ (female)</option>
        </select>
        <input type="submit" value="Tìm kiếm" class="btn find-btn">
    </div>

    <div class="table-card">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Username</th>
                    <th>MSSV</th>
                    <th>Họ và tên</th>
                    <th>Giới tính</th>
                    <th>Email</th>
                    <th>Số điện thoại</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>2</td>
                    <td><strong>sv001</strong></td>
                    <td>2251010001</td>
                    <td>Nguyễn Văn An</td>
                    <td>Nam</td>
                    <td>an.nv@sv.edu.vn</td>
                    <td>0901000001</td>
                    <td class="action-btns">
                        <button type="button" class="btn-sm btn-edit"
                                data-id="2"
                                data-username="sv001"
                                data-studentcode="2251010001"
                                data-fullname="Nguyễn Văn An"
                                data-gender="male"
                                data-email="an.nv@sv.edu.vn"
                                data-phone="0901000001"
                                onclick="openEditUser(this)">Sửa</button>
                        <a href="${pageContext.request.contextPath}/admin/delete-user?id=2"
                           class="btn-sm btn-delete"
                           onclick="return confirm('Xóa tài khoản này?')">Xóa</a>
                    </td>
                </tr>
                <tr>
                    <td>3</td>
                    <td><strong>sv002</strong></td>
                    <td>2251010002</td>
                    <td>Trần Thị Bình</td>
                    <td>Nữ</td>
                    <td>binh.tt@sv.edu.vn</td>
                    <td>0901000002</td>
                    <td class="action-btns">
                        <button type="button" class="btn-sm btn-edit"
                                data-id="3"
                                data-username="sv002"
                                data-studentcode="2251010002"
                                data-fullname="Trần Thị Bình"
                                data-gender="female"
                                data-email="binh.tt@sv.edu.vn"
                                data-phone="0901000002"
                                onclick="openEditUser(this)">Sửa</button>
                        <a href="${pageContext.request.contextPath}/admin/delete-user?id=3"
                           class="btn-sm btn-delete"
                           onclick="return confirm('Xóa tài khoản này?')">Xóa</a>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

<div class="modal-backdrop" id="editUserModal">
    <div class="modal-box">
        <div class="modal-header">
            <h4 id="editUserTitle">Cập Nhật Thông Tin User</h4>
            <button type="button" class="btn-close" onclick="closeModal('editUserModal')">✕</button>
        </div>
        <form id="editUserForm" action="${pageContext.request.contextPath}/admin/update-user" method="POST">
            <input type="hidden" name="id" id="user_id">

            <div class="form-group">
                <label>Tên đăng nhập (Username)</label>
                <input type="text" class="input-readonly" name="username" id="user_username" readonly>
            </div>
            <div class="form-group">
                <label>Mã số sinh viên (student_code)</label>
                <input type="text" name="student_code" id="user_student_code" maxlength="20">
            </div>
            <div class="form-group">
                <label>Họ và tên (full_name) *</label>
                <input type="text" name="full_name" id="user_full_name" maxlength="100" required>
            </div>
            <div class="form-group">
                <label>Giới tính (gender)</label>
                <select name="gender" id="user_gender">
                    <option value="">-- Không xác định --</option>
                    <option value="male">Nam (male)</option>
                    <option value="female">Nữ (female)</option>
                </select>
            </div>
            <div class="form-group">
                <label>Email *</label>
                <input type="email" name="email" id="user_email" maxlength="100" required>
            </div>
            <div class="form-group">
                <label>Số điện thoại (phone)</label>
                <input type="text" name="phone" id="user_phone" maxlength="15">
            </div>
            <div class="modal-footer">
                <button type="button" class="btn" onclick="closeModal('editUserModal')">Hủy</button>
                <button type="submit" class="btn btn-blue">Lưu thay đổi</button>
            </div>
        </form>
    </div>
</div>

<script>
    function closeModal(id) {
        document.getElementById(id).classList.remove('show');
    }

    function openEditUser(btn) {
        const username = btn.dataset.username || '';
        document.getElementById('editUserTitle').innerText = 'Cập Nhật Thông Tin User: ' + username;

        document.getElementById('user_id').value = btn.dataset.id || '';
        document.getElementById('user_username').value = username;
        document.getElementById('user_student_code').value = btn.dataset.studentcode || '';
        document.getElementById('user_full_name').value = btn.dataset.fullname || '';
        document.getElementById('user_gender').value = btn.dataset.gender || '';
        document.getElementById('user_email').value = btn.dataset.email || '';
        document.getElementById('user_phone').value = btn.dataset.phone || '';

        document.getElementById('editUserModal').classList.add('show');
    }

    // Kiểm tra định dạng dữ liệu phía client trước khi submit
    document.getElementById('editUserForm').addEventListener('submit', function (e) {
        const studentCodeInput = document.getElementById('user_student_code');
        const fullNameInput = document.getElementById('user_full_name');
        const emailInput = document.getElementById('user_email');
        const phoneInput = document.getElementById('user_phone');

        const studentCode = studentCodeInput.value.trim();
        const fullName = fullNameInput.value.trim();
        const email = emailInput.value.trim();
        const phone = phoneInput.value.trim();

        // 1. Kiểm tra MSSV (nếu có nhập: chỉ chữ/số, tối đa 20 ký tự)
        if (studentCode !== '' && !/^[A-Za-z0-9]{5,20}$/.test(studentCode)) {
            alert('Mã số sinh viên chỉ gồm chữ và số (5 - 20 ký tự)!');
            studentCodeInput.focus();
            e.preventDefault();
            return;
        }

        // 2. Kiểm tra Họ và tên
        if (fullName.length < 2 || fullName.length > 100) {
            alert('Họ và tên phải từ 2 đến 100 ký tự!');
            fullNameInput.focus();
            e.preventDefault();
            return;
        }

        // 3. Kiểm tra định dạng Email
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            alert('Email không đúng định dạng!');
            emailInput.focus();
            e.preventDefault();
            return;
        }

        // 4. Kiểm tra định dạng Số điện thoại (nếu có nhập)
        if (phone !== '' && !/^0\d{8,10}$/.test(phone)) {
            alert('Số điện thoại không hợp lệ (phải bắt đầu bằng số 0 và gồm 9 - 11 chữ số)!');
            phoneInput.focus();
            e.preventDefault();
            return;
        }

        studentCodeInput.value = studentCode;
        fullNameInput.value = fullName;
        emailInput.value = email;
        phoneInput.value = phone;
    });

    document.getElementById('editUserModal').addEventListener('click', function (e) {
        if (e.target === this) closeModal('editUserModal');
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') closeModal('editUserModal');
    });
</script>

</body>
</html>