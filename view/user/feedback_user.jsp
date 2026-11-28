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
        <div class="container feedback-container">
            <h2 class="section-title">Gửi Phản Hồi & Góp Ý</h2>
            <p class="feedback-subtitle">
                Mọi ý kiến đóng góp về cơ sở vật chất, thái độ phục vụ hoặc thắc mắc về thủ tục xin gửi về Ban Quản Lý.
            </p>

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

            <form id="feedbackForm" action="${pageContext.request.contextPath}/user/send-feedback" method="POST"
                  style="background: var(--bg-light); padding: 30px; border-radius: 8px; border: 1px solid var(--border-color);">
                <div style="margin-bottom: 15px;">
                    <label style="display: block; font-weight: 600; margin-bottom: 5px;">Tiêu đề / Chủ đề góp ý *</label>
                    <input type="text" name="title" id="fb_title" maxlength="200" required
                           placeholder="VD: Góp ý về hệ thống Wifi khu B..."
                           style="width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px;">
                </div>
                <div style="margin-bottom: 20px;">
                    <label style="display: block; font-weight: 600; margin-bottom: 5px;">Nội dung góp ý *</label>
                    <textarea name="content" id="fb_content" rows="5" required
                              placeholder="Nhập nội dung phản hồi chi tiết..."
                              style="width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px;"></textarea>
                </div>
                <button type="submit" class="btn btn-blue" style="width: 100%;">Gửi Phản Hồi</button>
            </form>
        </div>
    </section>

    <script>
        document.getElementById('feedbackForm').addEventListener('submit', function (e) {
            const titleInput = document.getElementById('fb_title');
            const contentInput = document.getElementById('fb_content');

            const title = titleInput.value.trim();
            const content = contentInput.value.trim();

            if (title.length < 5 || title.length > 200) {
                alert('Tiêu đề góp ý phải từ 5 đến 200 ký tự (không tính khoảng trắng thừa)!');
                titleInput.focus();
                e.preventDefault();
                return;
            }

            if (content.length < 10) {
                alert('Nội dung góp ý phải có ít nhất 10 ký tự!');
                contentInput.focus();
                e.preventDefault();
                return;
            }

            titleInput.value = title;
            contentInput.value = content;
        });
    </script>
</body>
</html>