package controller;

import java.io.IOException;
import java.net.URLEncoder;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.bo.RegistrationBO;
import util.WebUtil;

@WebServlet("/admin/RegistrationServlet")
public class AdminRegistrationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // mac dinh hien don dang cho duyet; status = "" -> tat ca
        String status = request.getParameter("status");
        if (status == null) status = "pending";
        request.setAttribute("status", status);
        request.setAttribute("registrationList", new RegistrationBO().getRegistrationList(status));
        request.getRequestDispatcher("/admin/registrations.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RegistrationBO registrationBO = new RegistrationBO();
        String action = WebUtil.trim(request.getParameter("action"));
        int id = WebUtil.toInt(request.getParameter("id"));
        String adminNote = WebUtil.trim(request.getParameter("adminNote"));
        // quay ve dung bo loc dang xem
        String back = "/admin/RegistrationServlet?status="
                    + URLEncoder.encode(WebUtil.trim(request.getParameter("status")), "UTF-8");

        String loi;
        if (action.equals("approve")) {
            loi = registrationBO.approve(id,
                    WebUtil.toDate(request.getParameter("checkInDate")),
                    WebUtil.toDate(request.getParameter("checkOutDate")),
                    adminNote);
        } else if (action.equals("reject")) {
            loi = registrationBO.reject(id, adminNote);
        } else {
            loi = "Thao tác không hợp lệ!";
        }

        if (loi == null) WebUtil.redirect(request, response, back, "ok",
                action.equals("approve") ? "Đã duyệt đơn #" + id : "Đã từ chối đơn #" + id);
        else WebUtil.redirect(request, response, back, "loi", loi);
    }
}