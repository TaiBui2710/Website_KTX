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
    <section class="section-padding">
        <div class="container">
            <h2 class="section-title">Hệ Thống Biểu Mẫu Dành Cho Sinh Viên</h2>
            <p style="text-align: center; color: var(--text-gray); margin-bottom: 30px;">
                Nhấn vào từng biểu mẫu bên dưới để mở trang xem trực tiếp và tải về định dạng PDF.
            </p>

            <div class="form-list">
                <%-- Hiển thị danh sách động từ Servlet nếu có formList --%>
                <c:forEach var="f" items="${formList}" varStatus="loop">
                    <div class="form-list-item">
                        <div>
                            <h4 style="color: var(--primary-blue); margin-bottom: 5px;">${loop.index + 1}. ${f.title}</h4>
                            <p style="font-size: 13px; color: var(--text-gray);">${f.content}</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/${f.fileUrl}" target="_blank" class="btn btn-blue">Mở file PDF ↗</a>
                    </div>
                </c:forEach>

                <%-- Dữ liệu mẫu hiển thị khi chưa kết nối Servlet/DB --%>
                <c:if test="${empty formList}">
                    <div class="form-list-item">
                        <div>
                            <h4 style="color: var(--primary-blue); margin-bottom: 5px;">1. Đơn xin đăng ký ở nội trú Ký túc xá</h4>
                            <p style="font-size: 13px; color: var(--text-gray);">Dành cho tân sinh viên và sinh viên các khóa có nhu cầu đăng ký mới.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/assets/pdf/don-dang-ky-noi-tru.pdf" target="_blank" class="btn btn-blue">Mở file PDF ↗</a>
                    </div>

                    <div class="form-list-item">
                        <div>
                            <h4 style="color: var(--primary-blue); margin-bottom: 5px;">2. Đơn xin gia hạn thời gian lưu trú</h4>
                            <p style="font-size: 13px; color: var(--text-gray);">Dành cho sinh viên đang ở KTX muốn tiếp tục ở trong học kỳ tiếp theo hoặc dịp hè.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/assets/pdf/don-gia-han-luu-tru.pdf" target="_blank" class="btn btn-blue">Mở file PDF ↗</a>
                    </div>

                    <div class="form-list-item">
                        <div>
                            <h4 style="color: var(--primary-blue); margin-bottom: 5px;">3. Đơn xin miễn, giảm phí nội trú (Đối tượng chính sách)</h4>
                            <p style="font-size: 13px; color: var(--text-gray);">Kèm theo giấy xác nhận hộ nghèo, cận nghèo hoặc con thương binh liệt sĩ.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/assets/pdf/don-mien-giam-phi.pdf" target="_blank" class="btn btn-blue">Mở file PDF ↗</a>
                    </div>

                    <div class="form-list-item">
                        <div>
                            <h4 style="color: var(--primary-blue); margin-bottom: 5px;">4. Đơn xin thanh lý hợp đồng & Nhận lại tiền cược tài sản</h4>
                            <p style="font-size: 13px; color: var(--text-gray);">Dành cho sinh viên đã tốt nghiệp hoặc xin chuyển ra ngoài ở tự túc.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/assets/pdf/don-thanh-ly-hop-dong.pdf" target="_blank" class="btn btn-blue">Mở file PDF ↗</a>
                    </div>
                </c:if>
            </div>
        </div>
    </section>
</body>
</html>