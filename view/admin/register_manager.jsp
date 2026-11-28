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
    <!-- BẢNG 1: DUYỆT ĐƠN ĐĂNG KÝ PHÒNG MỚI -->
    <div class="page-header">
        <h3>1. Danh Sách Đơn Đăng Ký Phòng (Registrations)</h3>
    </div>

    <div class="table-card" style="margin-bottom: 30px;">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>Mã đơn</th>
                    <th>Sinh viên (MSSV)</th>
                    <th>Phòng đăng ký</th>
                    <th>Ngày nhận - Trả phòng</th>
                    <th>Ghi chú SV</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>#7</td>
                    <td><strong>Đỗ Quang Hùng</strong> (2251010005)</td>
                    <td>Tòa A - <strong>A101</strong></td>
                    <td><em>Chưa xếp lịch</em></td>
                    <td>Muốn ở cùng phòng bạn An</td>
                    <td><span class="badge badge-maintenance">Chờ duyệt</span></td>
                    <td class="action-btns">
                        <button type="button" class="btn-sm btn-edit"
                                data-id="7"
                                data-status="approved"
                                data-checkin="2026-12-01"
                                data-checkout="2027-06-30"
                                data-note=""
                                onclick="openRegModal(this)">Duyệt / Từ chối</button>
                    </td>
                </tr>
                <tr>
                    <td>#1</td>
                    <td><strong>Nguyễn Văn An</strong> (2251010001)</td>
                    <td>Tòa A - <strong>A101</strong></td>
                    <td>01/09/2026 - 20/12/2026</td>
                    <td>—</td>
                    <td><span class="badge badge-available">Đã duyệt</span></td>
                    <td class="action-btns">
                        <button type="button" class="btn-sm btn-edit"
                                data-id="1"
                                data-status="approved"
                                data-checkin="2026-09-01"
                                data-checkout="2026-12-20"
                                data-note=""
                                onclick="openRegModal(this)">Cập nhật</button>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>

    <!-- BẢNG 2: DUYỆT YÊU CẦU GIA HẠN / TRẢ PHÒNG SỚM / HỦY ĐƠN -->
    <div class="page-header">
        <h3>2. Yêu Cầu Gia Hạn / Trả Phòng Sớm / Hủy Đơn (Requests)</h3>
    </div>

    <div class="table-card">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Mã đơn / Sinh viên</th>
                    <th>Loại yêu cầu</th>
                    <th>Ngày đề xuất</th>
                    <th>Lý do của sinh viên</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>#4</td>
                    <td>Đơn #1 - <strong>Nguyễn Văn An</strong></td>
                    <td><strong>Gia hạn (extend)</strong></td>
                    <td>30/06/2027</td>
                    <td>Muốn ở tiếp học kỳ 2</td>
                    <td><span class="badge badge-maintenance">Chờ xử lý</span></td>
                    <td class="action-btns">
                        <button type="button" class="btn-sm btn-edit"
                                data-id="4"
                                data-type="Gia hạn"
                                onclick="openReqModal(this)">Xử lý yêu cầu</button>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

<!-- MODAL DUYỆT ĐƠN ĐĂNG KÝ PHÒNG -->
<div class="modal-backdrop" id="approveRegModal">
    <div class="modal-box">
        <div class="modal-header">
            <h4 id="regModalTitle">Xử Lý Đơn Đăng Ký Phòng</h4>
            <button type="button" class="btn-close" onclick="closeModal('approveRegModal')">✕</button>
        </div>
        <form id="approveRegForm" action="${pageContext.request.contextPath}/admin/process-registration" method="POST">
            <input type="hidden" name="id" id="reg_id">

            <div class="form-group">
                <label>Quyết định duyệt (status) *</label>
                <select name="status" id="regStatus" onchange="toggleRegDates()" required>
                    <option value="approved">Duyệt đơn (approved)</option>
                    <option value="rejected">Từ chối đơn (rejected)</option>
                    <option value="cancelled">Hủy đơn (cancelled)</option>
                </select>
            </div>
            <div id="regDatesGroup">
                <div class="form-group">
                    <label>Ngày nhận phòng (check_in_date) *</label>
                    <input type="date" name="check_in_date" id="checkInInput" required>
                </div>
                <div class="form-group">
                    <label>Ngày trả phòng (check_out_date) * <small>(Phải sau ngày nhận phòng)</small></label>
                    <input type="date" name="check_out_date" id="checkOutInput" required>
                </div>
            </div>
            <div class="form-group">
                <label>Phản hồi / Lý do từ chối của Admin (admin_note)</label>
                <input type="text" name="admin_note" id="reg_admin_note" maxlength="255" placeholder="Nhập ghi chú gửi sinh viên (nếu có)...">
            </div>
            <div class="modal-footer">
                <button type="button" class="btn" onclick="closeModal('approveRegModal')">Hủy</button>
                <button type="submit" class="btn btn-blue">Lưu kết quả duyệt</button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL XỬ LÝ YÊU CẦU GIA HẠN / TRẢ SỚM -->
<div class="modal-backdrop" id="processReqModal">
    <div class="modal-box">
        <div class="modal-header">
            <h4 id="reqModalTitle">Xử Lý Yêu Cầu</h4>
            <button type="button" class="btn-close" onclick="closeModal('processReqModal')">✕</button>
        </div>
        <form id="processReqForm" action="${pageContext.request.contextPath}/admin/process-request" method="POST">
            <input type="hidden" name="id" id="req_id">

            <div class="form-group">
                <label>Trạng thái xử lý *</label>
                <select name="status" id="req_status" required>
                    <option value="approved">Đồng ý (approved)</option>
                    <option value="rejected">Từ chối (rejected)</option>
                </select>
            </div>
            <div class="form-group">
                <label>Phản hồi của Admin (admin_note)</label>
                <input type="text" name="admin_note" id="req_admin_note" maxlength="255" placeholder="VD: Đồng ý gia hạn đến 30/06/2027">
            </div>
            <div class="modal-footer">
                <button type="button" class="btn" onclick="closeModal('processReqModal')">Hủy</button>
                <button type="submit" class="btn btn-blue">Xác nhận</button>
            </div>
        </form>
    </div>
</div>

<script>
    function closeModal(id) {
        document.getElementById(id).classList.remove('show');
    }

    // Mở Modal duyệt đơn & đổ dữ liệu của đơn được chọn
    function openRegModal(btn) {
        const id = btn.dataset.id || '';
        document.getElementById('regModalTitle').innerText = 'Xử Lý Đơn Đăng Ký Phòng #' + id;
        document.getElementById('reg_id').value = id;
        document.getElementById('regStatus').value = btn.dataset.status || 'approved';
        document.getElementById('checkInInput').value = btn.dataset.checkin || '';
        document.getElementById('checkOutInput').value = btn.dataset.checkout || '';
        document.getElementById('reg_admin_note').value = btn.dataset.note || '';

        toggleRegDates();
        document.getElementById('approveRegModal').classList.add('show');
    }

    // Mở Modal xử lý yêu cầu gia hạn / trả sớm / hủy
    function openReqModal(btn) {
        const id = btn.dataset.id || '';
        const type = btn.dataset.type || 'Yêu cầu';
        document.getElementById('reqModalTitle').innerText = 'Xử Lý Yêu Cầu ' + type + ' #' + id;
        document.getElementById('req_id').value = id;
        document.getElementById('req_status').value = 'approved';
        document.getElementById('req_admin_note').value = '';

        document.getElementById('processReqModal').classList.add('show');
    }

    // Bắt buộc nhập ngày nhận/trả khi chọn Duyệt đơn (khớp ràng buộc chk_reg_approved_dates)
    function toggleRegDates() {
        const status = document.getElementById('regStatus').value;
        const group = document.getElementById('regDatesGroup');
        const checkIn = document.getElementById('checkInInput');
        const checkOut = document.getElementById('checkOutInput');
        if (status === 'approved') {
            group.style.display = 'block';
            checkIn.required = true;
            checkOut.required = true;
        } else {
            group.style.display = 'none';
            checkIn.required = false;
            checkOut.required = false;
        }
    }

    // Kiểm tra định dạng ngày & ràng buộc logic trước khi submit (khớp chk_reg_dates)
    document.getElementById('approveRegForm').addEventListener('submit', function (e) {
        const status = document.getElementById('regStatus').value;
        const checkIn = document.getElementById('checkInInput').value;
        const checkOut = document.getElementById('checkOutInput').value;
        const noteInput = document.getElementById('reg_admin_note');

        if (status === 'approved') {
            if (!checkIn || !checkOut) {
                alert('Vui lòng chọn đầy đủ Ngày nhận phòng và Ngày trả phòng!');
                e.preventDefault();
                return;
            }
            if (checkOut <= checkIn) {
                alert('Ngày trả phòng phải sau Ngày nhận phòng!');
                document.getElementById('checkOutInput').focus();
                e.preventDefault();
                return;
            }
        }

        if ((status === 'rejected' || status === 'cancelled') && noteInput.value.trim() === '') {
            alert('Vui lòng nhập lý do từ chối / hủy đơn vào ô Phản hồi của Admin!');
            noteInput.focus();
            e.preventDefault();
            return;
        }

        noteInput.value = noteInput.value.trim();
    });

    // Đóng modal khi bấm nền tối hoặc phím ESC
    ['approveRegModal', 'processReqModal'].forEach(modalId => {
        document.getElementById(modalId).addEventListener('click', function (e) {
            if (e.target === this) closeModal(modalId);
        });
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            closeModal('approveRegModal');
            closeModal('processReqModal');
        }
    });
</script>

</body>
</html>