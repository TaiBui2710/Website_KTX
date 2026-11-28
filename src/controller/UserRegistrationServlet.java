package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.bean.Registration;
import model.bean.User;
import model.bo.RegistrationBO;
import model.bo.RequestBO;
import util.WebUtil;

@WebServlet("/user/RegistrationServlet")
public class UserRegistrationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getAttribute("currentUser");
        RegistrationBO registrationBO = new RegistrationBO();
        RequestBO requestBO = new RequestBO();

        Registration active = registrationBO.getActiveRegistration(user.getId());
        request.setAttribute("activeRegistration", active);
        request.setAttribute("history", registrationBO.getRegistrationsByUser(user.getId()));
        if (active != null) {
            request.setAttribute("canCancel", registrationBO.canCancelDirectly(active));
            request.setAttribute("requestList", requestBO.getRequestsByRegistration(active.getId()));
            request.setAttribute("pendingRequest", requestBO.getPendingRequest(active.getId()));
        }
        request.getRequestDispatcher("/user/my-registration.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getAttribute("currentUser");
        String action = WebUtil.trim(request.getParameter("action"));
        int registrationId = WebUtil.toInt(request.getParameter("registrationId"));
        String loi;
        String thanhcong;

        if (action.equals("cancel")) {
            loi = new RegistrationBO().cancelByUser(user, registrationId);
            thanhcong = "Đã hủy đơn đăng ký!";
        } else if (action.equals("request")) {
            loi = new RequestBO().createRequest(user, registrationId,
                    request.getParameter("type"),
                    WebUtil.toDate(request.getParameter("requestedDate")),
                    request.getParameter("reason"));
            thanhcong = "Đã gửi yêu cầu, vui lòng chờ admin phản hồi!";
        } else {
            loi = "Thao tác không hợp lệ!";
            thanhcong = null;
        }

        if (loi == null) WebUtil.redirect(request, response, "/user/RegistrationServlet", "ok", thanhcong);
        else WebUtil.redirect(request, response, "/user/RegistrationServlet", "loi", loi);
    }
}