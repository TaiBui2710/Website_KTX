package controller;

import java.io.IOException;
import java.util.ArrayList;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.bean.Room;
import model.bo.FeedbackBO;
import model.bo.RegistrationBO;
import model.bo.RequestBO;
import model.bo.RoomBO;

@WebServlet("/admin/DashboardServlet")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ArrayList<Room> rooms = new RoomBO().getRoomList("", "", "");
        int totalBeds = 0, occupied = 0;
        for (Room r : rooms) {
            totalBeds += r.getCapacity();
            occupied += r.getOccupied();
        }
        request.setAttribute("roomCount", rooms.size());
        request.setAttribute("totalBeds", totalBeds);
        request.setAttribute("occupied", occupied);
        request.setAttribute("pendingRegistrations", new RegistrationBO().countByStatus("pending"));
        request.setAttribute("pendingRequests", new RequestBO().countByStatus("pending"));
        request.setAttribute("newFeedbacks", new FeedbackBO().countNew());
        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }
}