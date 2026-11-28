package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.bean.User;
import model.bo.FeedbackBO;
import util.WebUtil;

@WebServlet("/user/FeedbackServlet")
public class UserFeedbackServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getAttribute("currentUser");
        request.setAttribute("feedbackList", new FeedbackBO().getFeedbacksByUser(user.getId()));
        request.getRequestDispatcher("/user/feedback.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getAttribute("currentUser");
        FeedbackBO feedbackBO = new FeedbackBO();
        String action = WebUtil.trim(request.getParameter("action"));

        if (action.equals("send")) {
            String content = WebUtil.trim(request.getParameter("content"));
            String loi = feedbackBO.send(user, content);
            if (loi == null) {
                WebUtil.redirect(request, response, "/user/FeedbackServlet", "ok", "Đã gửi góp ý, cảm ơn bạn!");
            } else {
                request.setAttribute("thongbao", loi);
                request.setAttribute("content", content);     // giu lai noi dung vua go
                doGet(request, response);
            }
            return;
        }

        String loi;
        if (action.equals("delete")) loi = feedbackBO.deleteByUser(user, WebUtil.toInt(request.getParameter("id")));
        else loi = "Thao tác không hợp lệ!";

        if (loi == null) WebUtil.redirect(request, response, "/user/FeedbackServlet", "ok", "Đã xóa góp ý!");
        else WebUtil.redirect(request, response, "/user/FeedbackServlet", "loi", loi);
    }
}