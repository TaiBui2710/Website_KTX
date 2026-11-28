package model.bo;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import model.bean.Registration;
import model.bean.Room;
import model.bean.User;
import model.dao.RegistrationDAO;
import model.dao.RequestDAO;
import model.dao.RoomDAO;

public class RegistrationBO {
    // con it hon so ngay nay truoc ngay nhan phong thi khong tu huy duoc, phai gui yeu cau 'cancel'
    public static final int CANCEL_DEADLINE_DAYS = 3;

    RegistrationDAO registrationDAO = new RegistrationDAO();
    RoomDAO roomDAO = new RoomDAO();
    RequestDAO requestDAO = new RequestDAO();

    public Registration getActiveRegistration(int userId) { return registrationDAO.getActiveRegistration(userId); }
    public ArrayList<Registration> getRegistrationsByUser(int userId) { return registrationDAO.getRegistrationsByUser(userId); }
    public ArrayList<Registration> getRegistrationList(String status) { return registrationDAO.getRegistrationList(status); }
    public Registration getRegistrationById(int id) { return registrationDAO.getRegistrationById(id); }
    public int countByStatus(String status) { return registrationDAO.countByStatus(status); }

    // JSP goi ham nay de biet hien nut "Huy don" (true) hay "Gui yeu cau huy" (false)
    public boolean canCancelDirectly(Registration reg) {
        if (reg == null) return false;
        if ("pending".equals(reg.getStatus())) return true;
        if ("approved".equals(reg.getStatus()) && reg.getCheckInDate() != null) {
            long days = ChronoUnit.DAYS.between(LocalDate.now(), reg.getCheckInDate());
            return days >= CANCEL_DEADLINE_DAYS;
        }
        return false;
    }

    // ===================== SINH VIEN =====================

    // R1: dang ky phong. null = thanh cong
    public String registerRoom(User user, int roomId, String note) {
        if (note == null) note = "";
        if (user.isAdmin()) return "Tài khoản admin không đăng ký phòng!";
        if (user.getGender() == null) return "Vui lòng cập nhật giới tính trong hồ sơ trước khi đăng ký phòng!";
        if (registrationDAO.getActiveRegistration(user.getId()) != null)
            return "Bạn đang có một đơn đăng ký còn hiệu lực, không thể đăng ký thêm!";
        Room room = roomDAO.getRoomById(roomId);
        if (room == null) return "Không tìm thấy phòng!";
        if (!"open".equals(room.getStatus())) return "Phòng " + room.getRoomNumber() + " đang tạm đóng!";
        if (!room.getGenderType().equals(user.getGender()))
            return "Phòng " + room.getRoomNumber() + " không dành cho giới tính của bạn!";
        if (room.getAvailable() <= 0) return "Phòng " + room.getRoomNumber() + " đã hết chỗ!";
        if (note.length() > 255) return "Ghi chú tối đa 255 ký tự!";
        if (!registrationDAO.insertRegistration(user.getId(), roomId, note.isEmpty() ? null : note))
            return "Đăng ký thất bại, vui lòng thử lại!";
        return null;
    }

    // R2: sinh vien tu huy don
    public String cancelByUser(User user, int registrationId) {
        Registration reg = registrationDAO.getRegistrationById(registrationId);
        if (reg == null || reg.getUserId() != user.getId()) return "Không tìm thấy đơn đăng ký!";
        LocalDate today = LocalDate.now();
        if (!reg.isActive(today)) return "Đơn này đã kết thúc, không thể hủy!";
        if ("approved".equals(reg.getStatus()) && !reg.getCheckInDate().isAfter(today))
            return "Bạn đã nhận phòng, hãy gửi yêu cầu trả phòng sớm thay vì hủy đơn!";
        if (!canCancelDirectly(reg))
            return "Còn dưới " + CANCEL_DEADLINE_DAYS + " ngày đến ngày nhận phòng, vui lòng gửi yêu cầu hủy để admin xét duyệt!";
        if (requestDAO.getPendingRequest(reg.getId()) != null)
            return "Đơn đang có yêu cầu chờ xử lý, không thể hủy lúc này!";
        if (!registrationDAO.cancel(reg.getId())) return "Hủy đơn thất bại, vui lòng thử lại!";
        return null;
    }

    // ===================== ADMIN =====================

    // R3: duyet don
    public String approve(int registrationId, LocalDate checkIn, LocalDate checkOut, String adminNote) {
        if (adminNote == null) adminNote = "";
        Registration reg = registrationDAO.getRegistrationById(registrationId);
        if (reg == null) return "Không tìm thấy đơn!";
        if (!"pending".equals(reg.getStatus())) return "Đơn này đã được xử lý!";
        if (checkIn == null || checkOut == null) return "Vui lòng nhập ngày nhận và ngày trả phòng!";
        if (!checkOut.isAfter(checkIn)) return "Ngày trả phòng phải sau ngày nhận phòng!";
        if (checkOut.isBefore(LocalDate.now())) return "Ngày trả phòng đã qua!";
        if (adminNote.length() > 255) return "Ghi chú tối đa 255 ký tự!";
        // kiem tra lai luc duyet: tu luc sinh vien gui don den gio phong co the da day / bi dong
        Room room = roomDAO.getRoomById(reg.getRoomId());
        if (!"open".equals(room.getStatus())) return "Phòng " + room.getRoomNumber() + " đang đóng, hãy từ chối đơn này!";
        if (room.getAvailable() <= 0) return "Phòng " + room.getRoomNumber() + " đã đủ người!";
        if (!registrationDAO.approve(registrationId, checkIn, checkOut, adminNote.isEmpty() ? null : adminNote))
            return "Duyệt thất bại (có thể đơn vừa được người khác xử lý)!";
        return null;
    }

    // R4: tu choi don, bat buoc co ly do
    public String reject(int registrationId, String adminNote) {
        if (adminNote == null || adminNote.trim().isEmpty()) return "Vui lòng nhập lý do từ chối!";
        if (adminNote.length() > 255) return "Lý do tối đa 255 ký tự!";
        Registration reg = registrationDAO.getRegistrationById(registrationId);
        if (reg == null) return "Không tìm thấy đơn!";
        if (!"pending".equals(reg.getStatus())) return "Đơn này đã được xử lý!";
        if (!registrationDAO.reject(registrationId, adminNote.trim())) return "Từ chối thất bại!";
        return null;
    }
}