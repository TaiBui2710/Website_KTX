package controller;

import java.io.IOException;
import java.net.URLEncoder;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.bo.FeedbackBO;
import util.WebUtil;

@WebServlet("/admin/FeedbackServlet")
public class AdminFeedbackServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String status = request.getParameter("status");
        if (status == null) status = "new";                    // "" = tat ca
        request.setAttribute("status", status);
        request.setAttribute("feedbackList", new FeedbackBO().getFeedbackList(status));
        request.getRequestDispatcher("/admin/feedbacks.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        FeedbackBO feedbackBO = new FeedbackBO();
        String action = WebUtil.trim(request.getParameter("action"));
        int id = WebUtil.toInt(request.getParameter("id"));
        String back = "/admin/FeedbackServlet?status="
                    + URLEncoder.encode(WebUtil.trim(request.getParameter("status")), "UTF-8");

        String loi;
        if (action.equals("reply")) loi = feedbackBO.reply(id, WebUtil.trim(request.getParameter("reply")));
        else if (action.equals("publish")) loi = feedbackBO.setPublished(id, true);
        else if (action.equals("hide")) loi = feedbackBO.setPublished(id, false);
        else if (action.equals("delete")) loi = feedbackBO.deleteFeedback(id);
        else loi = "Thao tác không hợp lệ!";

        if (loi == null) WebUtil.redirect(request, response, back, "ok", "Đã xử lý góp ý #" + id);
        else WebUtil.redirect(request, response, back, "loi", loi);
    }
}