package controller;

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.bean.User;
import model.bo.UserBO;
import util.WebUtil;

@WebFilter({"/user/*", "/admin/*", "/account/*"})
public class AuthFilter implements Filter {
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        // 1. chua dang nhap -> ve trang login
        HttpSession session = request.getSession(false);
        Integer userId = (session == null) ? null : (Integer) session.getAttribute("userId");
        if (userId == null) {
            WebUtil.redirect(request, response, "/LoginServlet", "loi", "Vui lòng đăng nhập!");
            return;
        }

        // 2. doc lai user tu CSDL moi lan (vua bi xoa / doi quyen thi biet ngay - giong y tuong cua thay)
        User user = new UserBO().getUserById(userId);
        if (user == null) {
            session.invalidate();
            WebUtil.redirect(request, response, "/LoginServlet", "loi", "Tài khoản không còn tồn tại!");
            return;
        }

        // 3. phan quyen theo tien to URL
        String path = request.getServletPath();
        if (path.startsWith("/admin/") && !user.isAdmin()) {
            WebUtil.redirect(request, response, "/user/RegistrationServlet", "loi", "Bạn không có quyền vào trang quản trị!");
            return;
        }
        if (path.startsWith("/user/") && user.isAdmin()) {
            WebUtil.redirect(request, response, "/admin/DashboardServlet", null, null);
            return;
        }

        // 4. hop le: gui user hien tai cho Servlet / JSP dung
        request.setAttribute("currentUser", user);
        chain.doFilter(req, res);
    }
}