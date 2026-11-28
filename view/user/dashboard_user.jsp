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
        <h3>Tổng Quan Nội Trú & Lệ Phí Định Kỳ</h3>
        <button type="button" class="btn btn-blue" onclick="openModal('reqModal')">+ Gửi yêu cầu Gia hạn / Trả phòng / Hủy</button>
    </div>

    <div class="user-dashboard-grid" style="margin-bottom: 25px;">
        <!-- BẢNG 1: ĐẾM NGƯỢC HẠN ĐÓNG TIỀN (CHU KỲ 4 THÁNG / LẦN) -->
        <div class="dash-card countdown-panel">
            <div class="dash-card-header">
                <h4>⏳ Đếm Ngược Hạn Đóng Tiền Phòng</h4>
            </div>
            <p class="deadline-text">
                Hạn đóng tiền đợt tiếp theo (Chu kỳ 4 tháng/lần):
                <strong>${not empty deadlineDisplay ? deadlineDisplay : '01/01/2027 - 23:59'}</strong>
            </p>

            <div class="countdown-grid">
                <div class="cd-box">
                    <span class="cd-val" id="cd-days">00</span>
                    <span class="cd-lbl">Ngày</span>
                </div>
                <div class="cd-box">
                    <span class="cd-val" id="cd-hours">00</span>
                    <span class="cd-lbl">Giờ</span>
                </div>
                <div class="cd-box">
                    <span class="cd-val" id="cd-minutes">00</span>
                    <span class="cd-lbl">Phút</span>
                </div>
                <div class="cd-box">
                    <span class="cd-val" id="cd-seconds">00</span>
                    <span class="cd-lbl">Giây</span>
                </div>
            </div>
        </div>

        <!-- BẢNG 2: THÔNG TIN PHÒNG & SỐ TIỀN ĐÓNG ĐỢT NÀY (4 THÁNG) -->
        <div class="dash-card fee-panel">
            <div class="dash-card-header">
                <h4>💳 Chi Phí Phòng Đợt Này (4 Tháng)</h4>
                <span class="badge badge-full">Chưa thanh toán</span>
            </div>

            <div class="fee-line">
                <span>Phòng đang ở / đăng ký:</span>
                <strong>${not empty currentReg ? currentReg.building.concat(' - Phòng ').concat(currentReg.roomNumber) : 'Tòa A - Phòng A101 (Nam)'}</strong>
            </div>
            <div class="fee-line">
                <span>Thời hạn hợp đồng ở:</span>
                <strong>${not empty currentReg ? currentReg.checkInDate.concat(' - ').concat(currentReg.checkOutDate) : '01/09/2026 - 30/06/2027'}</strong>
            </div>
            <div class="fee-line">
                <span>Đơn giá phòng / tháng:</span>
                <strong>${not empty currentReg ? currentReg.priceFormatted : '500.000đ / tháng'}</strong>
            </div>
            <div class="fee-line">
                <span>Kỳ thanh toán hiện tại:</span>
                <strong>${not empty currentPeriod ? currentPeriod : 'Đợt 2 (4 tháng: 01/2027 - 04/2027)'}</strong>
            </div>

            <div class="fee-summary">
                <span>Số tiền phải đóng đợt này:</span>
                <span class="fee-amount">${not empty periodFeeFormatted ? periodFeeFormatted : '2.000.000 VNĐ'}</span>
            </div>
        </div>
    </div>

    <!-- BẢNG 3: LỊCH SỬ YÊU CẦU THAY ĐỔI (REGISTRATION_REQUESTS) -->
    <div class="page-header">
        <h3>Lịch Sử Yêu Cầu Gia Hạn / Trả Phòng Sớm</h3>
    </div>

    <div class="table-card">
        <table class="admin-table">
            <thead>
                <tr>
                    <th>Mã YC</th>
                    <th>Loại yêu cầu</th>
                    <th>Ngày đề xuất</th>
                    <th>Lý do của bạn</th>
                    <th>Phản hồi của Admin</th>
                    <th>Trạng thái</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="req" items="${requestList}">
                    <tr>
                        <td>#${req.id}</td>
                        <td><strong>${req.typeLabel}</strong></td>
                        <td>${not empty req.requestedDate ? req.requestedDate : '—'}</td>
                        <td>${req.reason}</td>
                        <td><em>${not empty req.adminNote ? req.adminNote : 'Đang chờ xét duyệt'}</em></td>
                        <td>
                            <c:choose>
                                <c:when test="${req.status == 'approved'}"><span class="badge badge-available">Đã duyệt</span></c:when>
                                <c:when test="${req.status == 'rejected'}"><span class="badge badge-full">Từ chối</span></c:when>
                                <c:otherwise><span class="badge badge-maintenance">Chờ duyệt</span></c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty requestList}">
                    <tr>
                        <td>#4</td>
                        <td><strong>Gia hạn ở (extend)</strong></td>
                        <td>30/06/2027</td>
                        <td>Muốn ở tiếp học kỳ 2</td>
                        <td><em>Đang chờ xét duyệt</em></td>
                        <td><span class="badge badge-maintenance">Chờ duyệt</span></td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<!-- MODAL GỬI YÊU CẦU (REGISTRATION_REQUESTS) -->
<div class="modal-backdrop" id="reqModal">
    <div class="modal-box">
        <div class="modal-header">
            <h4>Gửi Yêu Cầu Thay Đổi Lưu Trú</h4>
            <button type="button" class="btn-close" onclick="closeModal('reqModal')">✕</button>
        </div>
        <form id="requestForm" action="${pageContext.request.contextPath}/user/send-request" method="POST">
            <input type="hidden" name="registration_id" value="${not empty currentReg ? currentReg.id : ''}">

            <div class="form-group">
                <label>Loại yêu cầu (type) *</label>
                <select name="type" id="reqType" onchange="toggleDateField()" required>
                    <option value="extend">Gia hạn thời gian ở (extend)</option>
                    <option value="checkout">Trả phòng sớm (checkout)</option>
                    <option value="cancel">Hủy đơn đăng ký (cancel)</option>
                </select>
            </div>
            <div class="form-group" id="dateFieldGroup">
                <label>Ngày đề xuất mới (requested_date) *</label>
                <input type="date" name="requested_date" id="reqDateInput" required>
            </div>
            <div class="form-group">
                <label>Lý do gửi yêu cầu (reason) *</label>
                <textarea name="reason" id="reqReasonInput" rows="3" maxlength="255" placeholder="VD: Muốn ở tiếp học kỳ 2..." required></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn" onclick="closeModal('reqModal')">Hủy</button>
                <button type="submit" class="btn btn-blue">Gửi yêu cầu</button>
            </div>
        </form>
    </div>
</div>

<script>
    // Mốc hạn đóng tiền đợt 4 tháng tiếp theo (Servlet truyền chuỗi ISO yyyy-MM-ddTHH:mm:ss)
    const deadlineStr = "${not empty paymentDeadlineIso ? paymentDeadlineIso : '2027-01-01T23:59:59'}";
    const paymentDeadline = new Date(deadlineStr).getTime();

    function updateCountdown() {
        const now = new Date().getTime();
        const distance = paymentDeadline - now;

        if (distance > 0) {
            document.getElementById("cd-days").innerText = String(Math.floor(distance / (1000 * 60 * 60 * 24))).padStart(2, '0');
            document.getElementById("cd-hours").innerText = String(Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))).padStart(2, '0');
            document.getElementById("cd-minutes").innerText = String(Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60))).padStart(2, '0');
            document.getElementById("cd-seconds").innerText = String(Math.floor((distance % (1000 * 60)) / 1000)).padStart(2, '0');
        }
    }
    updateCountdown();
    setInterval(updateCountdown, 1000);

    function openModal(id) { document.getElementById(id).classList.add('show'); }
    function closeModal(id) { document.getElementById(id).classList.remove('show'); }

    // Ẩn ô chọn ngày khi chọn Hủy đơn (khớp ràng buộc chk_req_date trong DB)
    function toggleDateField() {
        const type = document.getElementById('reqType').value;
        const dateGroup = document.getElementById('dateFieldGroup');
        const dateInput = document.getElementById('reqDateInput');
        if (type === 'cancel') {
            dateGroup.style.display = 'none';
            dateInput.required = false;
            dateInput.value = '';
        } else {
            dateGroup.style.display = 'block';
            dateInput.required = true;
        }
    }

    // Kiểm tra định dạng ngày đề xuất & lý do phía client trước khi submit
    document.getElementById('requestForm').addEventListener('submit', function (e) {
        const type = document.getElementById('reqType').value;
        const dateInput = document.getElementById('reqDateInput');
        const reasonInput = document.getElementById('reqReasonInput');

        const reason = reasonInput.value.trim();
        const today = new Date().toISOString().split('T')[0];

        if ((type === 'extend' || type === 'checkout')) {
            if (!dateInput.value) {
                alert('Vui lòng chọn Ngày đề xuất mới!');
                dateInput.focus();
                e.preventDefault();
                return;
            }
            if (dateInput.value <= today) {
                alert('Ngày đề xuất phải sau ngày hôm nay!');
                dateInput.focus();
                e.preventDefault();
                return;
            }
        }

        if (reason.length < 5 || reason.length > 255) {
            alert('Lý do gửi yêu cầu phải từ 5 đến 255 ký tự!');
            reasonInput.focus();
            e.preventDefault();
            return;
        }

        reasonInput.value = reason;
    });

    document.getElementById('reqModal').addEventListener('click', function (e) {
        if (e.target === this) closeModal('reqModal');
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') closeModal('reqModal');
    });
</script>

</body>
</html>