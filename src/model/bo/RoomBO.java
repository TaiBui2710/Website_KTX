package model.bo;

import java.util.ArrayList;
import model.bean.Room;
import model.dao.RegistrationDAO;
import model.dao.RoomDAO;

public class RoomBO {
    RoomDAO roomDAO = new RoomDAO();
    RegistrationDAO registrationDAO = new RegistrationDAO();

    public ArrayList<Room> getRoomList(String building, String genderType, String status) {
        return roomDAO.getRoomList(building, genderType, status);
    }

    public ArrayList<Room> getAvailableRooms(String genderType) {
        if (genderType == null) return new ArrayList<Room>();     // chua khai gioi tinh -> khong co phong
        return roomDAO.getAvailableRooms(genderType);
    }

    public Room getRoomById(int id) { return roomDAO.getRoomById(id); }

    // id = 0: them moi, id > 0: sua. null = thanh cong
    public String saveRoom(Room r) {
        if (r.getRoomNumber().isEmpty() || r.getRoomNumber().length() > 10) return "Số phòng 1–10 ký tự!";
        if (r.getBuilding().isEmpty() || r.getBuilding().length() > 20) return "Tên tòa 1–20 ký tự!";
        if (!r.getGenderType().equals("male") && !r.getGenderType().equals("female")) return "Vui lòng chọn loại phòng nam/nữ!";
        if (r.getCapacity() < 1 || r.getCapacity() > 20) return "Sức chứa phải từ 1 đến 20!";
        if (r.getPrice() < 0) return "Giá phòng không hợp lệ!";
        if (!r.getStatus().equals("open") && !r.getStatus().equals("closed")) return "Trạng thái không hợp lệ!";
        if (roomDAO.isExistRoomNumber(r.getRoomNumber(), r.getId())) return "Số phòng " + r.getRoomNumber() + " đã tồn tại!";

        if (r.getId() == 0) {
            return roomDAO.insertRoom(r) ? null : "Thêm phòng thất bại!";
        }
        Room old = roomDAO.getRoomById(r.getId());
        if (old == null) return "Không tìm thấy phòng!";
        if (r.getCapacity() < old.getOccupied())
            return "Sức chứa không được nhỏ hơn số người đang ở (" + old.getOccupied() + ")!";
        if (old.getOccupied() > 0 && !old.getGenderType().equals(r.getGenderType()))
            return "Phòng đang có người ở, không thể đổi loại phòng nam/nữ!";
        return roomDAO.updateRoom(r) ? null : "Cập nhật phòng thất bại!";
    }

    public String deleteRoom(int id) {
        if (roomDAO.getRoomById(id) == null) return "Không tìm thấy phòng!";
        if (registrationDAO.countByRoom(id) > 0)
            return "Phòng đã có đơn đăng ký, không thể xóa. Hãy chuyển trạng thái sang Đóng.";
        return roomDAO.deleteRoom(id) ? null : "Xóa phòng thất bại!";
    }
}