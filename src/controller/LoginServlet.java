package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.bean.User;
import model.bo.UserBO;
import util.WebUtil;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/guest/login.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = WebUtil.trim(request.getParameter("username"));
        String password = request.getParameter("password");
        User user = new UserBO().login(username, password);

        if (user == null) {
            // sai: quay lai form, giu lai username da go
            request.setAttribute("thongbao", "Sai tên đăng nhập hoặc mật khẩu!");
            request.setAttribute("username", username);
            request.getRequestDispatcher("/guest/login.jsp").forward(request, response);
            return;
        }
        // dung: xoa session cu, tao session moi (giong CheckLoginServlet cua thay)
        request.getSession().invalidate();
        HttpSession session = request.getSession();
        session.setAttribute("userId", user.getId());          // chi luu id, quyen doc lai o AuthFilter
        session.setAttribute("fullName", user.getFullName());  // de header trang guest chao ten

        if (user.isAdmin()) WebUtil.redirect(request, response, "/admin/DashboardServlet", null, null);
        else WebUtil.redirect(request, response, "/user/RegistrationServlet", null, null);
    }
}