package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.bean.User;
import model.bo.RegistrationBO;
import model.bo.RoomBO;
import util.WebUtil;

@WebServlet("/user/RoomServlet")
public class UserRoomServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getAttribute("currentUser");
        request.setAttribute("roomList", new RoomBO().getAvailableRooms(user.getGender()));
        // co don hieu luc roi thi JSP an nut "Dang ky"
        request.setAttribute("activeRegistration", new RegistrationBO().getActiveRegistration(user.getId()));
        request.getRequestDispatcher("/user/rooms.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getAttribute("currentUser");
        int roomId = WebUtil.toInt(request.getParameter("roomId"));
        String note = WebUtil.trim(request.getParameter("note"));

        String loi = new RegistrationBO().registerRoom(user, roomId, note);
        if (loi == null)
            WebUtil.redirect(request, response, "/user/RegistrationServlet", "ok", "Đã gửi đơn đăng ký, vui lòng chờ admin duyệt!");
        else
            WebUtil.redirect(request, response, "/user/RoomServlet", "loi", loi);
    }
}