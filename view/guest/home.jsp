<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/guest.css">
</head>
<body>
    <!-- 1. ẢNH KTX + TIÊU ĐỀ & GIỚI THIỆU NGẮN ĐÈ LÊN ẢNH -->
    <section class="hero-banner" id="gioi-thieu">
        <div class="hero-overlay"></div>
        <div class="container hero-content">
            <h2>Ký Túc Xá Sinh Viên Bách Khoa</h2>
            <p>Không gian lưu trú hiện đại, an ninh 24/7, đầy đủ tiện nghi học tập và sinh hoạt ngay trong khuôn viên nhà trường.</p>
            <a href="#bang-gia" class="btn btn-yellow">Xem bảng giá phòng</a>
        </div>
    </section>

    <!-- 2. THÔNG BÁO MỚI NHẤT (ĐỔ TỪ BẢNG POSTS) -->
    <section class="section-padding notice-section">
        <div class="container">
            <h2 class="section-title">Thông Báo Mới Nhất</h2>
            <div class="notice-grid">
                <c:forEach var="p" items="${postList}">
                    <div class="notice-card">
                        <span class="notice-date">${p.createdAt}</span>
                        <h4>${p.title}</h4>
                        <p>${p.content}</p>
                    </div>
                </c:forEach>

                <%-- Dữ liệu mẫu hiển thị khi chưa truyền postList từ Servlet --%>
                <c:if test="${empty postList}">
                    <div class="notice-card">
                        <span class="notice-date">25/11/2026</span>
                        <h4>Thông báo kế hoạch tiếp nhận tân sinh viên ở nội trú học kỳ II</h4>
                        <p>Sinh viên chuẩn bị đầy đủ hồ sơ theo mục Biểu mẫu và nộp tại văn phòng BQL trước ngày 15/12.</p>
                    </div>
                    <div class="notice-card">
                        <span class="notice-date">18/11/2026</span>
                        <h4>Quy định về giờ giấc ra vào và đảm bảo an toàn PCCC</h4>
                        <p>Cổng KTX đóng lúc 23h00 hàng ngày. Tuyệt đối không sử dụng thiết bị đun nấu công suất lớn trong phòng.</p>
                    </div>
                    <div class="notice-card">
                        <span class="notice-date">10/11/2026</span>
                        <h4>Lịch bảo trì hệ thống Wifi và máy lọc nước các khu nhà</h4>
                        <p>Bộ phận kỹ thuật tiến hành nâng cấp băng thông mạng tại khu A và khu B vào sáng Chủ nhật.</p>
                    </div>
                </c:if>
            </div>
        </div>
    </section>

    <!-- 3. ẢNH PHÒNG & 5 ẢNH MÔ TẢ CƠ SỞ VẬT CHẤT (KIỂU KHUNG TRÒN NGHỆ THUẬT) -->
    <section class="section-padding circle-showcase-section">
        <div class="container">
            <h2 class="section-title">Không Gian & Cơ Sở Vật Chất</h2>
            <p class="section-subtitle">Môi trường sống tiện nghi, hiện đại và an toàn dành cho sinh viên nội trú</p>
            
            <div class="circle-gallery-wrapper">
                <!-- Ảnh tròn 1: Bên trái (Vừa) -->
                <div class="circle-item item-1">
                    <div class="circle-img-box">
                        <img src="${pageContext.request.contextPath}/assets/images/phong-tu-hoc.jpg" alt="Phòng tự học">
                    </div>
                    <div class="circle-badge">Phòng tự học</div>
                </div>

                <!-- Ảnh tròn 2: Phía trên giữa (Nhỏ) -->
                <div class="circle-item item-2">
                    <div class="circle-img-box">
                        <img src="${pageContext.request.contextPath}/assets/images/phong-o.jpg" alt="Phòng ở tiêu chuẩn">
                    </div>
                    <div class="circle-badge">Phòng ở<br>tiêu chuẩn</div>
                </div>

                <!-- Ảnh tròn 3: Trung tâm (Lớn nhất - Điểm nhấn) -->
                <div class="circle-item item-3">
                    <div class="circle-img-box">
                        <img src="${pageContext.request.contextPath}/assets/images/khuon-vien2.jpg" alt="Khuôn viên KTX">
                    </div>
                    <div class="circle-badge">Khuôn viên<br>xanh - sạch - đẹp</div>
                </div>

                <!-- Ảnh tròn 4: Phía dưới giữa (Nhỏ) -->
                <div class="circle-item item-4">
                    <div class="circle-img-box">
                        <img src="${pageContext.request.contextPath}/assets/images/khuon-vien.jpg" alt="Khuôn viên KTX">
                    </div>
                    <div class="circle-badge">Khu bóng chuyền</div>
                </div>

                <!-- Ảnh tròn 5: Bên phải (Vừa) -->
                <div class="circle-item item-5">
                    <div class="circle-img-box">
                        <img src="${pageContext.request.contextPath}/assets/images/cong-ktx.jpg" alt="Cổng KTX">
                    </div>
                    <div class="circle-badge">Cổng vào KTX</div>
                </div>
            </div>
        </div>
    </section>

    <!-- 4. VỊ TRÍ TRÊN BẢN ĐỒ -->
    <section class="section-padding map-section">
        <div class="container">
            <h2 class="section-title">Vị Trí Ký Túc Xá</h2>
            <div class="map-container">
                <iframe 
                    src="https://maps.google.com/maps?q=16.073149838147735, 108.15345566284255&hl=vi&z=16&output=embed" 
                    width="100%" 
                    height="380" 
                    style="border:0;" 
                    allowfullscreen="" 
                    loading="lazy">
                </iframe>
            </div>
        </div>
    </section>

    <!-- 5. THÔNG TIN GIÁ PHÒNG & DỊCH VỤ -->
    <section class="section-padding" id="bang-gia">
        <div class="container">
            <h2 class="section-title">Thông Tin Phòng & Bảng Giá Niêm Yết</h2>
            
            <div id="admin-editable-content">
                <table class="pricing-table">
                    <thead>
                        <tr>
                            <th>Loại phòng / Dịch vụ</th>
                            <th>Sức chứa</th>
                            <th>Trang thiết bị đi kèm</th>
                            <th>Mức phí (VNĐ/tháng)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><strong>Phòng Tiêu chuẩn (Tòa A, B)</strong></td>
                            <td>8 sinh viên/phòng</td>
                            <td>Giường tầng, bàn học, tủ cá nhân, quạt, WC chung</td>
                            <td class="price-highlight">250.000đ / sinh viên</td>
                        </tr>
                        <tr>
                            <td><strong>Phòng Chất lượng cao (Tòa A, B)</strong></td>
                            <td>4 sinh viên/phòng</td>
                            <td>Điều hòa, bình nóng lạnh, giường gỗ, tủ đồ, WC riêng</td>
                            <td class="price-highlight">500.000đ / sinh viên</td>
                        </tr>
                        <tr>
                            <td><strong>Chi phí Điện & Nước sinh hoạt</strong></td>
                            <td>Tính theo đồng hồ</td>
                            <td>Định mức theo quy định hiện hành của Nhà nước</td>
                            <td class="price-highlight">Điện: 2.500đ/kWh | Nước: 6.000đ/m³</td>
                        </tr>
                        <tr>
                            <td><strong>Phí gửi xe (Xe đạp / Xe máy)</strong></td>
                            <td>Theo tháng</td>
                            <td>Nhà xe có mái che, thẻ từ ra vào và bảo vệ trực 24/24</td>
                            <td class="price-highlight">Xe đạp: 20.000đ | Xe máy: 50.000đ</td>
                        </tr>
                    </tbody>
                </table>
                <p style="margin-top: 15px; font-size: 13px; color: var(--text-gray);">
                    * Lưu ý: Bảng giá trên được Ban Quản lý Ký túc xá cập nhật theo từng năm học. Sinh viên đóng phí theo học kỳ (5 tháng/đợt).
                </p>
            </div>
        </div>
    </section>

    <!-- 6. Ý KIẾN & ĐÁNH GIÁ TỪ SINH VIÊN (FEEDBACK) -->
    <section class="section-padding" id="feedback">
        <div class="container feedback-container">
            <h2 class="section-title">Ý Kiến & Đánh Giá Từ Sinh Viên</h2>
            <p class="feedback-subtitle">
                Tổng hợp các phản hồi thực tế từ sinh viên đang lưu trú tại Ký túc xá.
            </p>

            <div class="feedback-list">
                <c:forEach var="fb" items="${feedbackList}">
                    <div class="feedback-card">
                        <div class="feedback-header">
                            <strong class="feedback-author">👤 ${fb.title}</strong>
                            <span class="feedback-date">${fb.createdAt}</span>
                        </div>
                        <p class="feedback-content">"${fb.content}"</p>
                    </div>
                </c:forEach>

                <c:if test="${empty feedbackList}">
                    <div class="feedback-card">
                        <div class="feedback-header">
                            <strong class="feedback-author">👤 Sinh viên Khu B (Phòng B204)</strong>
                            <span class="feedback-date">24/11/2026</span>
                        </div>
                        <p class="feedback-content">
                            "Không gian phòng ở sạch sẽ, thoáng mát, các bác bảo vệ trực cổng rất nhiệt tình và hỗ trợ sinh viên chu đáo."
                        </p>
                    </div>

                    <div class="feedback-card">
                        <div class="feedback-header">
                            <strong class="feedback-author">👤 Tân sinh viên K26</strong>
                            <span class="feedback-date">20/11/2026</span>
                        </div>
                        <p class="feedback-content">
                            "Phòng tự học chung có điều hòa hoạt động ổn định, rất thuận tiện cho việc ôn thi cuối kỳ của tụi em."
                        </p>
                    </div>

                    <div class="feedback-card">
                        <div class="feedback-header">
                            <strong class="feedback-author">👤 Sinh viên Khu C</strong>
                            <span class="feedback-date">15/11/2026</span>
                        </div>
                        <p class="feedback-content">
                            "Khuôn viên nhiều cây xanh, có sân bóng chuyền và khu giặt sấy tự động nên sinh hoạt hằng ngày rất tiện lợi."
                        </p>
                    </div>
                </c:if>
            </div>
        </div>
    </section>
</body>
</html>