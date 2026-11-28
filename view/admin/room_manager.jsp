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
        <h3>Quản Lý Phòng Nội Trú (Rooms)</h3>
        <button type="button" class="btn btn-blue" onclick="openAddRoom()">+ Thêm phòng mới</button>
    </div>

    <div class="filter-bar">
        <input type="text" class="search-input" placeholder="Tìm số phòng (VD: A101)...">
        <select>
            <option value="">-- Lọc theo Tòa nhà --</option>
            <option value="Tòa A">Tòa A</option>
            <option value="Tòa B">Tòa B</option>
        </select>
        <select>
            <option value="">-- Lọc theo Giới tính --</option>
            <option value="male">Phòng Nam (male)</option>
            <option value="female">Phòng Nữ (female)</option>
        </select>
        <select>
            <option value="">-- Lọc theo Trạng thái --</option>
            <option value="open">Đang mở (open)</option>
            <option value="closed">Đang đóng (closed)</option>
        </select>
        <input type="submit" value="Tìm kiếm" class="btn find-btn">
    </div>

    <div class="table-card">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>Số phòng</th>
                    <th>Tòa nhà</th>
                    <th>Giới tính</th>
                    <th>Đang ở / Sức chứa</th>
                    <th>Chỗ trống</th>
                    <th>Giá / tháng</th>
                    <th>Trạng thái</th>
                    <th>Mô tả</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>A101</strong></td>
                    <td>Tòa A</td>
                    <td>Nam</td>
                    <td>1 / 4</td>
                    <td><strong>3</strong></td>
                    <td class="text-price">500.000đ</td>
                    <td><span class="badge badge-available">Đang mở</span></td>
                    <td>Phòng 4 người, điều hòa, WC riêng</td>
                    <td class="action-btns">
                        <button type="button" class="btn-sm btn-edit"
                                data-id="1"
                                data-roomnumber="A101"
                                data-building="Tòa A"
                                data-gendertype="male"
                                data-capacity="4"
                                data-price="500000"
                                data-status="open"
                                data-description="Phòng 4 người, điều hòa, WC riêng"
                                onclick="openEditRoom(this)">Sửa</button>
                        <a href="${pageContext.request.contextPath}/admin/delete-room?id=1"
                           class="btn-sm btn-delete"
                           onclick="return confirm('Xóa phòng A101?')">Xóa</a>
                    </td>
                </tr>
                <tr>
                    <td><strong>B102</strong></td>
                    <td>Tòa B</td>
                    <td>Nữ</td>
                    <td>0 / 8</td>
                    <td><strong>8</strong></td>
                    <td class="text-price">250.000đ</td>
                    <td><span class="badge badge-maintenance">Đang đóng</span></td>
                    <td>Phòng 8 người, đang sửa chữa</td>
                    <td class="action-btns">
                        <button type="button" class="btn-sm btn-edit"
                                data-id="4"
                                data-roomnumber="B102"
                                data-building="Tòa B"
                                data-gendertype="female"
                                data-capacity="8"
                                data-price="250000"
                                data-status="closed"
                                data-description="Phòng 8 người, đang sửa chữa"
                                onclick="openEditRoom(this)">Sửa</button>
                        <a href="${pageContext.request.contextPath}/admin/delete-room?id=4"
                           class="btn-sm btn-delete"
                           onclick="return confirm('Xóa phòng B102?')">Xóa</a>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

<div class="modal-backdrop" id="roomModal">
    <div class="modal-box">
        <div class="modal-header">
            <h4 id="roomModalTitle">Thêm Phòng Mới</h4>
            <button type="button" class="btn-close" onclick="closeModal('roomModal')">✕</button>
        </div>
        <form id="roomForm" method="POST">
            <input type="hidden" name="id" id="room_id">

            <div class="form-group">
                <label>Số phòng (room_number) *</label>
                <input type="text" name="room_number" id="room_number" maxlength="10" placeholder="VD: A101" required>
            </div>
            <div class="form-group">
                <label>Tòa nhà (building) *</label>
                <input type="text" name="building" id="room_building" maxlength="20" placeholder="VD: Tòa A" required>
            </div>
            <div class="form-group">
                <label>Loại phòng theo giới tính (gender_type) *</label>
                <select name="gender_type" id="room_gender_type" required>
                    <option value="male">Phòng Nam (male)</option>
                    <option value="female">Phòng Nữ (female)</option>
                </select>
            </div>
            <div class="form-group">
                <label>Sức chứa tối đa (capacity) *</label>
                <input type="number" name="capacity" id="room_capacity" value="4" min="1" max="50" required>
            </div>
            <div class="form-group">
                <label>Giá phòng / tháng (VNĐ) *</label>
                <input type="number" name="price" id="room_price" value="500000" min="0" step="10000" required>
            </div>
            <div class="form-group">
                <label>Trạng thái phòng (status) *</label>
                <select name="status" id="room_status" required>
                    <option value="open">Mở đăng ký (open)</option>
                    <option value="closed">Đóng / Sửa chữa (closed)</option>
                </select>
            </div>
            <div class="form-group">
                <label>Mô tả trang thiết bị (description)</label>
                <textarea name="description" id="room_description" rows="3" placeholder="VD: Phòng 4 người, điều hòa, WC riêng"></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn" onclick="closeModal('roomModal')">Hủy</button>
                <button type="submit" class="btn btn-blue">Lưu thông tin phòng</button>
            </div>
        </form>
    </div>
</div>

<script>
    function closeModal(id) {
        document.getElementById(id).classList.remove('show');
    }

    function openAddRoom() {
        document.getElementById('roomModalTitle').innerText = 'Thêm Phòng Mới';
        const form = document.getElementById('roomForm');
        form.action = '${pageContext.request.contextPath}/admin/add-room';
        form.reset();
        document.getElementById('room_id').value = '';
        document.getElementById('roomModal').classList.add('show');
    }

    function openEditRoom(btn) {
        const roomNumber = btn.dataset.roomnumber || '';
        document.getElementById('roomModalTitle').innerText = 'Chỉnh Sửa Phòng ' + roomNumber;
        const form = document.getElementById('roomForm');
        form.action = '${pageContext.request.contextPath}/admin/update-room';

        document.getElementById('room_id').value = btn.dataset.id || '';
        document.getElementById('room_number').value = roomNumber;
        document.getElementById('room_building').value = btn.dataset.building || '';
        document.getElementById('room_gender_type').value = btn.dataset.gendertype || 'male';
        document.getElementById('room_capacity').value = btn.dataset.capacity || 4;
        document.getElementById('room_price').value = btn.dataset.price || 0;
        document.getElementById('room_status').value = btn.dataset.status || 'open';
        document.getElementById('room_description').value = btn.dataset.description || '';

        document.getElementById('roomModal').classList.add('show');
    }

    // Kiểm tra định dạng dữ liệu phía client trước khi gửi form
    document.getElementById('roomForm').addEventListener('submit', function (e) {
        const roomNumInput = document.getElementById('room_number');
        const buildingInput = document.getElementById('room_building');
        const capacityInput = document.getElementById('room_capacity');
        const priceInput = document.getElementById('room_price');

        const roomNum = roomNumInput.value.trim().toUpperCase();
        const building = buildingInput.value.trim();
        const capacity = parseInt(capacityInput.value, 10);
        const price = parseFloat(priceInput.value);

        // 1. Số phòng: chữ cái + số, không chứa ký tự đặc biệt, dài 2-10 ký tự
        if (!/^[A-Z0-9-]{2,10}$/.test(roomNum)) {
            alert('Số phòng chỉ gồm chữ cái, số hoặc dấu gạch ngang (2 - 10 ký tự, VD: A101)!');
            roomNumInput.focus();
            e.preventDefault();
            return;
        }

        // 2. Tòa nhà
        if (building.length < 2 || building.length > 20) {
            alert('Tên tòa nhà phải từ 2 đến 20 ký tự!');
            buildingInput.focus();
            e.preventDefault();
            return;
        }

        // 3. Sức chứa > 0 (khớp chk_rooms_capacity)
        if (isNaN(capacity) || capacity <= 0) {
            alert('Sức chứa tối đa phải lớn hơn 0!');
            capacityInput.focus();
            e.preventDefault();
            return;
        }

        // 4. Giá phòng >= 0 (khớp chk_rooms_price)
        if (isNaN(price) || price < 0) {
            alert('Giá phòng không được nhỏ hơn 0!');
            priceInput.focus();
            e.preventDefault();
            return;
        }

        roomNumInput.value = roomNum;
        buildingInput.value = building;
    });

    document.getElementById('roomModal').addEventListener('click', function (e) {
        if (e.target === this) closeModal('roomModal');
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') closeModal('roomModal');
    });
</script>

</body>
</html>