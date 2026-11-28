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
        <h3>Quản Lý Kho Form Mẫu Đơn (PDF)</h3>
        <button type="button" class="btn btn-blue" onclick="openAddForm()">+ Thêm mẫu đơn PDF</button>
    </div>

    <div class="table-card">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Tên biểu mẫu</th>
                    <th>Mô tả đối tượng áp dụng</th>
                    <th>File đính kèm</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>1</td>
                    <td><strong>Đơn xin đăng ký ở nội trú Ký túc xá</strong></td>
                    <td>Dành cho tân sinh viên và sinh viên các khóa đăng ký mới</td>
                    <td><a href="${pageContext.request.contextPath}/assets/pdf/don-dang-ky-noi-tru.pdf" target="_blank" class="pdf-link">Xem PDF ↗</a></td>
                    <td class="action-btns">
                        <button type="button" class="btn-sm btn-edit"
                                data-id="1"
                                data-title="Đơn xin đăng ký ở nội trú Ký túc xá"
                                data-desc="Dành cho tân sinh viên và sinh viên các khóa đăng ký mới"
                                onclick="openEditForm(this)">Sửa</button>
                        <button type="button" class="btn-sm btn-delete" onclick="return confirm('Xóa mẫu đơn này?')">Xóa</button>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

<div class="modal-backdrop" id="formModal">
    <div class="modal-box">
        <div class="modal-header">
            <h4 id="formModalTitle">Thêm Mẫu Đơn Mới</h4>
            <button type="button" class="btn-close" onclick="closeModal('formModal')">✕</button>
        </div>
        <form id="pdfForm" method="POST" enctype="multipart/form-data">
            <input type="hidden" name="id" id="form_id">

            <div class="form-group">
                <label>Tên mẫu đơn *</label>
                <input type="text" name="title" id="form_title" maxlength="200" placeholder="VD: Đơn xin gia hạn lưu trú" required>
            </div>
            <div class="form-group">
                <label>Mô tả ngắn gọn *</label>
                <textarea name="description" id="form_desc" rows="3" required></textarea>
            </div>
            <div class="form-group">
                <label>Tải lên file PDF mẫu đơn *</label>
                <input type="file" name="pdfFile" id="form_file" accept=".pdf" required>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn" onclick="closeModal('formModal')">Hủy</button>
                <button type="submit" class="btn btn-blue">Lưu mẫu đơn</button>
            </div>
        </form>
    </div>
</div>

<script>
    function closeModal(id) {
        document.getElementById(id).classList.remove('show');
    }

    function openAddForm() {
        document.getElementById('formModalTitle').innerText = 'Thêm Mẫu Đơn Mới';
        const form = document.getElementById('pdfForm');
        form.action = 'add-form';
        form.reset();
        document.getElementById('form_id').value = '';
        document.getElementById('form_file').required = true;
        document.getElementById('formModal').classList.add('show');
    }

    function openEditForm(btn) {
        document.getElementById('formModalTitle').innerText = 'Cập Nhật Mẫu Đơn';
        const form = document.getElementById('pdfForm');
        form.action = 'update-form';

        document.getElementById('form_id').value = btn.dataset.id || '';
        document.getElementById('form_title').value = btn.dataset.title || '';
        document.getElementById('form_desc').value = btn.dataset.desc || '';

        document.getElementById('form_file').value = '';
        document.getElementById('form_file').required = false;

        document.getElementById('formModal').classList.add('show');
    }

    // Kiểm tra định dạng và dung lượng file PDF
    document.getElementById('form_file').addEventListener('change', function () {
        const file = this.files[0];
        if (!file) return;

        if (file.type !== 'application/pdf') {
            alert('Vui lòng chỉ chọn tệp định dạng PDF!');
            this.value = '';
            return;
        }

        if (file.size > 10 * 1024 * 1024) {
            alert('Dung lượng file PDF không được vượt quá 10MB!');
            this.value = '';
        }
    });

    // Kiểm tra định dạng chữ trước khi submit
    document.getElementById('pdfForm').addEventListener('submit', function (e) {
        const titleInput = document.getElementById('form_title');
        const descInput = document.getElementById('form_desc');

        const title = titleInput.value.trim();
        const desc = descInput.value.trim();

        if (title.length < 5 || title.length > 200) {
            alert('Tên mẫu đơn phải từ 5 đến 200 ký tự (không tính khoảng trắng thừa)!');
            titleInput.focus();
            e.preventDefault();
            return;
        }

        if (desc.length < 5) {
            alert('Mô tả ngắn gọn phải có ít nhất 5 ký tự!');
            descInput.focus();
            e.preventDefault();
            return;
        }

        titleInput.value = title;
        descInput.value = desc;
    });

    document.getElementById('formModal').addEventListener('click', function (e) {
        if (e.target === this) closeModal('formModal');
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') closeModal('formModal');
    });
</script>

</body>
</html>