package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.bean.Room;
import model.bo.RoomBO;
import util.WebUtil;

@WebServlet("/admin/RoomServlet")
public class AdminRoomServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // GET: ?action=add | ?action=edit&id=.. | khong co action = danh sach
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RoomBO roomBO = new RoomBO();
        String action = WebUtil.trim(request.getParameter("action"));

        if (action.equals("add") || action.equals("edit")) {
            Room room = new Room();                             // them moi: form trong
            room.setStatus("open");
            if (action.equals("edit")) {
                room = roomBO.getRoomById(WebUtil.toInt(request.getParameter("id")));
                if (room == null) {
                    WebUtil.redirect(request, response, "/admin/RoomServlet", "loi", "Không tìm thấy phòng!");
                    return;
                }
            }
            request.setAttribute("room", room);
            request.getRequestDispatcher("/admin/room-form.jsp").forward(request, response);
            return;
        }

        request.setAttribute("roomList", roomBO.getRoomList(
                WebUtil.trim(request.getParameter("building")),
                WebUtil.trim(request.getParameter("genderType")),
                WebUtil.trim(request.getParameter("status"))));
        request.getRequestDispatcher("/admin/rooms.jsp").forward(request, response);
    }

    // POST: action=save (them/sua) | action=delete
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RoomBO roomBO = new RoomBO();
        String action = WebUtil.trim(request.getParameter("action"));

        if (action.equals("delete")) {
            String loi = roomBO.deleteRoom(WebUtil.toInt(request.getParameter("id")));
            if (loi == null) WebUtil.redirect(request, response, "/admin/RoomServlet", "ok", "Đã xóa phòng!");
            else WebUtil.redirect(request, response, "/admin/RoomServlet", "loi", loi);
            return;
        }

        // save: gom du lieu form vao 1 doi tuong Room (giong RegisterServlet cua thay)
        Room room = new Room();
        room.setId(WebUtil.toInt(request.getParameter("id")));          // input hidden, 0 = them moi
        room.setRoomNumber(WebUtil.trim(request.getParameter("roomNumber")).toUpperCase());
        room.setBuilding(WebUtil.trim(request.getParameter("building")));
        room.setGenderType(WebUtil.trim(request.getParameter("genderType")));
        room.setCapacity(WebUtil.toInt(request.getParameter("capacity")));
        room.setPrice(WebUtil.toLong(request.getParameter("price")));
        room.setStatus(WebUtil.trim(request.getParameter("status")));
        room.setDescription(WebUtil.trim(request.getParameter("description")));

        String loi = roomBO.saveRoom(room);
        if (loi != null) {
            // loi: quay lai form, giu nguyen du lieu da nhap
            request.setAttribute("thongbao", loi);
            request.setAttribute("room", room);
            request.getRequestDispatcher("/admin/room-form.jsp").forward(request, response);
            return;
        }
        WebUtil.redirect(request, response, "/admin/RoomServlet", "ok",
                room.getId() == 0 ? "Đã thêm phòng " + room.getRoomNumber() : "Đã cập nhật phòng " + room.getRoomNumber());
    }
}