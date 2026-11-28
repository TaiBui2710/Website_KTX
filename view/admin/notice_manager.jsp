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
        <h3>Quản Lý Thông Báo, Tin Tức & Nội Quy (Posts)</h3>
        <button type="button" class="btn btn-blue" onclick="openAddPost()">+ Thêm mới</button>
    </div>

    <div class="filter-bar">
        <input type="text" class="search-input" placeholder="Tìm tiêu đề...">
        <select>
            <option value="">-- Tất cả chuyên mục --</option>
            <option value="notice">Thông báo (notice)</option>
            <option value="news">Tin tức (news)</option>
            <option value="rule">Nội quy (rule)</option>
        </select>
        <input type="submit" value="Tìm kiếm" class="btn find-btn">
    </div>

    <div class="table-card">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Chuyên mục</th>
                    <th>Tiêu đề</th>
                    <th>Trạng thái hiển thị</th>
                    <th>Ngày tạo</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>1</td>
                    <td><strong>Thông báo</strong></td>
                    <td>Mở đăng ký KTX học kỳ 2</td>
                    <td><span class="badge badge-available">Công khai</span></td>
                    <td>15/11/2026</td>
                    <td class="action-btns">
                        <button type="button" class="btn-sm btn-edit"
                                data-id="1"
                                data-title="Mở đăng ký KTX học kỳ 2"
                                data-category="notice"
                                data-content="Ký túc xá nhận đơn đăng ký học kỳ 2 từ 15/11 đến 15/12/2026."
                                data-published="true"
                                onclick="openEditPost(this)">Sửa</button>
                        <button type="button" class="btn-sm btn-delete" onclick="return confirm('Xóa mục này?')">Xóa</button>
                    </td>
                </tr>
                <tr>
                    <td>2</td>
                    <td><strong>Nội quy</strong></td>
                    <td>Nội quy ký túc xá</td>
                    <td><span class="badge badge-available">Công khai</span></td>
                    <td>01/08/2026</td>
                    <td class="action-btns">
                        <button type="button" class="btn-sm btn-edit"
                                data-id="2"
                                data-title="Nội quy ký túc xá"
                                data-category="rule"
                                data-content="Giờ đóng cửa 23h00. Không nấu ăn trong phòng."
                                data-published="true"
                                onclick="openEditPost(this)">Sửa</button>
                        <button type="button" class="btn-sm btn-delete" onclick="return confirm('Xóa mục này?')">Xóa</button>
                    </td>
                </tr>
                <tr>
                    <td>4</td>
                    <td><strong>Tin tức</strong></td>
                    <td>Kế hoạch sửa chữa phòng B102</td>
                    <td><span class="badge badge-full">Bản nháp</span></td>
                    <td>26/11/2026</td>
                    <td class="action-btns">
                        <button type="button" class="btn-sm btn-edit"
                                data-id="4"
                                data-title="Kế hoạch sửa chữa phòng B102"
                                data-category="news"
                                data-content="Bản nháp: dự kiến sửa chữa B102 trong tháng 12/2026."
                                data-published="false"
                                onclick="openEditPost(this)">Sửa</button>
                        <button type="button" class="btn-sm btn-delete" onclick="return confirm('Xóa mục này?')">Xóa</button>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

<div class="modal-backdrop" id="postModal">
    <div class="modal-box">
        <div class="modal-header">
            <h4 id="postModalTitle">Thêm Bài Viết Mới</h4>
            <button type="button" class="btn-close" onclick="closeModal('postModal')">✕</button>
        </div>
        <form id="postForm" method="POST">
            <input type="hidden" name="id" id="post_id">

            <div class="form-group">
                <label>Tiêu đề (title) *</label>
                <input type="text" name="title" id="post_title" maxlength="200" required>
            </div>
            <div class="form-group">
                <label>Chuyên mục (category) *</label>
                <select name="category" id="post_category" required>
                    <option value="notice">Thông báo (notice)</option>
                    <option value="news">Tin tức (news)</option>
                    <option value="rule">Nội quy (rule)</option>
                </select>
            </div>
            <div class="form-group">
                <label>Nội dung chi tiết (content) *</label>
                <textarea name="content" id="post_content" rows="5" required></textarea>
            </div>
            <div class="form-group">
                <label>
                    <input type="checkbox" name="is_published" id="post_published" value="true" checked style="width: auto; margin-right: 6px;">
                    Xuất bản công khai cho Guest xem (is_published)
                </label>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn" onclick="closeModal('postModal')">Hủy</button>
                <button type="submit" class="btn btn-blue">Lưu lại</button>
            </div>
        </form>
    </div>
</div>

<script>
    function closeModal(id) {
        document.getElementById(id).classList.remove('show');
    }

    function openAddPost() {
        document.getElementById('postModalTitle').innerText = 'Thêm Bài Viết Mới';
        document.getElementById('postForm').reset();
        document.getElementById('post_id').value = '';
        document.getElementById('post_published').checked = true;
        document.getElementById('postModal').classList.add('show');
    }

    function openEditPost(btn) {
        document.getElementById('postModalTitle').innerText = 'Sửa Bài Viết';
        document.getElementById('post_id').value = btn.dataset.id || '';
        document.getElementById('post_title').value = btn.dataset.title || '';
        document.getElementById('post_category').value = btn.dataset.category || 'notice';
        document.getElementById('post_content').value = btn.dataset.content || '';
        document.getElementById('post_published').checked = (btn.dataset.published === 'true');
        document.getElementById('postModal').classList.add('show');
    }

    // Kiểm tra định dạng dữ liệu phía client trước khi gửi form
    document.getElementById('postForm').addEventListener('submit', function (e) {
        const titleInput = document.getElementById('post_title');
        const contentInput = document.getElementById('post_content');
        const categorySelect = document.getElementById('post_category');

        const title = titleInput.value.trim();
        const content = contentInput.value.trim();

        if (title.length < 5 || title.length > 200) {
            alert('Tiêu đề phải từ 5 đến 200 ký tự (không tính khoảng trắng thừa)!');
            titleInput.focus();
            e.preventDefault();
            return;
        }

        if (!['notice', 'news', 'rule'].includes(categorySelect.value)) {
            alert('Chuyên mục không hợp lệ!');
            categorySelect.focus();
            e.preventDefault();
            return;
        }

        if (content.length < 10) {
            alert('Nội dung chi tiết phải có ít nhất 10 ký tự!');
            contentInput.focus();
            e.preventDefault();
            return;
        }

        titleInput.value = title;
        contentInput.value = content;
    });

    document.getElementById('postModal').addEventListener('click', function (e) {
        if (e.target === this) closeModal('postModal');
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') closeModal('postModal');
    });
</script>

</body>
</html>