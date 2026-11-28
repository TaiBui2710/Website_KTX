package controller;

import java.io.IOException;
import java.net.URLEncoder;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.bo.RequestBO;
import util.WebUtil;

@WebServlet("/admin/RequestServlet")
public class AdminRequestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String status = request.getParameter("status");
        if (status == null) status = "pending";
        request.setAttribute("status", status);
        request.setAttribute("requestList", new RequestBO().getRequestList(status));
        request.getRequestDispatcher("/admin/requests.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestBO requestBO = new RequestBO();
        String action = WebUtil.trim(request.getParameter("action"));
        int id = WebUtil.toInt(request.getParameter("id"));
        String adminNote = WebUtil.trim(request.getParameter("adminNote"));
        String back = "/admin/RequestServlet?status="
                    + URLEncoder.encode(WebUtil.trim(request.getParameter("status")), "UTF-8");

        String loi;
        if (action.equals("approve")) loi = requestBO.approve(id, adminNote);
        else if (action.equals("reject")) loi = requestBO.reject(id, adminNote);
        else loi = "Thao tác không hợp lệ!";

        if (loi == null) WebUtil.redirect(request, response, back, "ok", "Đã xử lý yêu cầu #" + id);
        else WebUtil.redirect(request, response, back, "loi", loi);
    }
}