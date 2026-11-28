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
        <h3>Danh Sách Phòng Đang Mở Đăng Ký</h3>
    </div>

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

    <div class="filter-bar">
        <input type="text" class="search-input" id="searchRoomInput" placeholder="Tìm số phòng (VD: A101)...">
        <select id="filterBuildingSelect">
            <option value="">-- Lọc theo Tòa nhà --</option>
            <option value="Tòa A">Tòa A</option>
            <option value="Tòa B">Tòa B</option>
        </select>
        <button type="button" class="btn find-btn" onclick="filterRooms()">Tìm kiếm</button>
    </div>

    <div class="room-select-grid" id="roomGrid">
        <%-- Đổ dữ liệu động từ view v_room_occupancy qua Servlet --%>
        <c:forEach var="r" items="${roomList}">
            <div class="room-card" data-room="${r.roomNumber}" data-building="${r.building}">
                <div>
                    <div class="room-card-top">
                        <span class="room-name">${r.building} - Phòng ${r.roomNumber}</span>
                        <span class="badge badge-available">Còn trống: ${r.available} / ${r.capacity}</span>
                    </div>
                    <ul class="room-info-list">
                        <li><strong>Dành cho:</strong> ${r.genderType == 'male' ? 'Sinh viên Nam (male)' : 'Sinh viên Nữ (female)'}</li>
                        <li><strong>Mô tả:</strong> ${not empty r.description ? r.description : 'Phòng tiêu chuẩn KTX'}</li>
                    </ul>
                </div>
                <div>
                    <div class="room-cost">${r.price}đ / tháng</div>
                    <button type="button" class="btn btn-blue btn-full"
                            onclick="openRegModal('${r.id}', '${r.roomNumber}')">Đăng ký phòng này</button>
                </div>
            </div>
        </c:forEach>

        <%-- Dữ liệu mẫu hiển thị khi chưa truyền roomList từ Servlet --%>
        <c:if test="${empty roomList}">
            <div class="room-card" data-room="A101" data-building="Tòa A">
                <div>
                    <div class="room-card-top">
                        <span class="room-name">Tòa A - Phòng A101</span>
                        <span class="badge badge-available">Còn trống: 3 / 4</span>
                    </div>
                    <ul class="room-info-list">
                        <li><strong>Dành cho:</strong> Sinh viên Nam (male)</li>
                        <li><strong>Mô tả:</strong> Phòng 4 người, điều hòa, WC riêng</li>
                    </ul>
                </div>
                <div>
                    <div class="room-cost">500.000đ / tháng</div>
                    <button type="button" class="btn btn-blue btn-full" onclick="openRegModal('1', 'A101')">Đăng ký phòng này</button>
                </div>
            </div>

            <div class="room-card" data-room="A102" data-building="Tòa A">
                <div>
                    <div class="room-card-top">
                        <span class="room-name">Tòa A - Phòng A102</span>
                        <span class="badge badge-available">Còn trống: 7 / 8</span>
                    </div>
                    <ul class="room-info-list">
                        <li><strong>Dành cho:</strong> Sinh viên Nam (male)</li>
                        <li><strong>Mô tả:</strong> Phòng 8 người, quạt, WC chung</li>
                    </ul>
                </div>
                <div>
                    <div class="room-cost">250.000đ / tháng</div>
                    <button type="button" class="btn btn-blue btn-full" onclick="openRegModal('2', 'A102')">Đăng ký phòng này</button>
                </div>
            </div>
        </c:if>
    </div>
</div>

<!-- MODAL XÁC NHẬN ĐĂNG KÝ & NHẬP GHI CHÚ (NOTE) -->
<div class="modal-backdrop" id="regRoomModal">
    <div class="modal-box">
        <div class="modal-header">
            <h4 id="regModalTitle">Đăng Ký Phòng</h4>
            <button type="button" class="btn-close" onclick="closeModal('regRoomModal')">✕</button>
        </div>
        <form id="regRoomForm" action="${pageContext.request.contextPath}/user/register-room" method="POST">
            <input type="hidden" name="room_id" id="reg_room_id">

            <div class="form-group">
                <label>Ghi chú gửi Ban Quản Lý (note - Tùy chọn)</label>
                <textarea name="note" id="reg_note" rows="3" maxlength="255" placeholder="VD: Muốn ở cùng phòng bạn An..."></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn" onclick="closeModal('regRoomModal')">Hủy</button>
                <button type="submit" class="btn btn-blue">Gửi đơn đăng ký</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openRegModal(roomId, roomNumber) {
        document.getElementById('regModalTitle').innerText = 'Đăng Ký Phòng ' + roomNumber;
        document.getElementById('reg_room_id').value = roomId || '';
        document.getElementById('reg_note').value = '';
        document.getElementById('regRoomModal').classList.add('show');
    }

    function closeModal(id) {
        document.getElementById(id).classList.remove('show');
    }

    // Lọc nhanh danh sách phòng trên giao diện
    function filterRooms() {
        const keyword = document.getElementById('searchRoomInput').value.toLowerCase().trim();
        const building = document.getElementById('filterBuildingSelect').value;
        const cards = document.querySelectorAll('#roomGrid .room-card');

        cards.forEach(card => {
            const roomNum = (card.dataset.room || '').toLowerCase();
            const cardBuilding = card.dataset.building || '';

            const matchRoom = roomNum.includes(keyword);
            const matchBuilding = !building || cardBuilding === building;

            card.style.display = (matchRoom && matchBuilding) ? '' : 'none';
        });
    }

    document.getElementById('searchRoomInput').addEventListener('input', filterRooms);
    document.getElementById('filterBuildingSelect').addEventListener('change', filterRooms);

    // Kiểm tra định dạng ghi chú trước khi gửi đơn
    document.getElementById('regRoomForm').addEventListener('submit', function (e) {
        const roomId = document.getElementById('reg_room_id').value;
        const noteInput = document.getElementById('reg_note');
        const note = noteInput.value.trim();

        if (!roomId) {
            alert('Không xác định được phòng cần đăng ký!');
            e.preventDefault();
            return;
        }
        if (note.length > 255) {
            alert('Ghi chú không được vượt quá 255 ký tự!');
            noteInput.focus();
            e.preventDefault();
            return;
        }
        noteInput.value = note;
    });

    document.getElementById('regRoomModal').addEventListener('click', function (e) {
        if (e.target === this) closeModal('regRoomModal');
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') closeModal('regRoomModal');
    });
</script>

</body>
</html>