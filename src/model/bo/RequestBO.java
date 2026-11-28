package model.bo;

import java.time.LocalDate;
import java.util.ArrayList;
import model.bean.Registration;
import model.bean.RegistrationRequest;
import model.bean.User;
import model.dao.RegistrationDAO;
import model.dao.RequestDAO;

public class RequestBO {
    RequestDAO requestDAO = new RequestDAO();
    RegistrationDAO registrationDAO = new RegistrationDAO();

    public ArrayList<RegistrationRequest> getRequestList(String status) { return requestDAO.getRequestList(status); }
    public ArrayList<RegistrationRequest> getRequestsByRegistration(int registrationId) {
        return requestDAO.getRequestsByRegistration(registrationId);
    }
    public RegistrationRequest getPendingRequest(int registrationId) { return requestDAO.getPendingRequest(registrationId); }
    public int countByStatus(String status) { return requestDAO.countByStatus(status); }

    // R5: yeu cau co hop le voi don hien tai khong (dung ca luc sinh vien gui va luc admin duyet)
    private String checkRequest(Registration reg, String type, LocalDate date) {
        LocalDate today = LocalDate.now();
        if (reg == null || !"approved".equals(reg.getStatus()) || !reg.isActive(today))
            return "Chỉ gửi yêu cầu cho đơn đã duyệt và còn hiệu lực!";
        boolean daNhanPhong = !reg.getCheckInDate().isAfter(today);        // ngay nhan <= hom nay
        switch (type == null ? "" : type) {
            case "extend":
                if (date == null) return "Vui lòng chọn ngày trả phòng mới!";
                if (!date.isAfter(reg.getCheckOutDate()))
                    return "Ngày gia hạn phải sau ngày trả phòng hiện tại (" + reg.getCheckOutDate() + ")!";
                if (date.isAfter(reg.getCheckOutDate().plusYears(1))) return "Mỗi lần chỉ gia hạn tối đa 1 năm!";
                return null;
            case "checkout":
                if (!daNhanPhong) return "Bạn chưa nhận phòng, hãy dùng chức năng hủy đơn!";
                if (date == null) return "Vui lòng chọn ngày muốn trả phòng!";
                if (date.isBefore(today)) return "Ngày trả phòng không được ở quá khứ!";
                if (!date.isAfter(reg.getCheckInDate())) return "Ngày trả phòng phải sau ngày nhận phòng!";
                if (!date.isBefore(reg.getCheckOutDate()))
                    return "Ngày trả sớm phải trước ngày trả phòng hiện tại (" + reg.getCheckOutDate() + ")!";
                return null;
            case "cancel":
                if (daNhanPhong) return "Bạn đã nhận phòng, hãy gửi yêu cầu trả phòng sớm!";
                return null;
            default:
                return "Loại yêu cầu không hợp lệ!";
        }
    }

    // sinh vien gui yeu cau gia han / tra som / huy
    public String createRequest(User user, int registrationId, String type, LocalDate date, String reason) {
        if (reason == null) reason = "";
        reason = reason.trim();
        Registration reg = registrationDAO.getRegistrationById(registrationId);
        if (reg == null || reg.getUserId() != user.getId()) return "Không tìm thấy đơn đăng ký!";
        if (reason.isEmpty()) return "Vui lòng nhập lý do!";
        if (reason.length() > 255) return "Lý do tối đa 255 ký tự!";
        if (requestDAO.getPendingRequest(registrationId) != null)
            return "Bạn đang có một yêu cầu chờ xử lý, vui lòng đợi admin phản hồi!";
        String loi = checkRequest(reg, type, date);
        if (loi != null) return loi;
        if ("cancel".equals(type)) date = null;                            // huy thi khong luu ngay
        if (!requestDAO.insertRequest(registrationId, type, date, reason)) return "Gửi yêu cầu thất bại, vui lòng thử lại!";
        return null;
    }

    // R6: admin duyet
    public String approve(int requestId, String adminNote) {
        if (adminNote == null) adminNote = "";
        adminNote = adminNote.trim();
        if (adminNote.length() > 255) return "Ghi chú tối đa 255 ký tự!";
        RegistrationRequest q = requestDAO.getRequestById(requestId);
        if (q == null) return "Không tìm thấy yêu cầu!";
        if (!"pending".equals(q.getStatus())) return "Yêu cầu này đã được xử lý!";
        Registration reg = registrationDAO.getRegistrationById(q.getRegistrationId());
        String loi = checkRequest(reg, q.getType(), q.getRequestedDate());
        if (loi != null) return "Không thể duyệt: " + loi;
        if (!requestDAO.approve(q, adminNote.isEmpty() ? null : adminNote)) return "Duyệt thất bại, vui lòng thử lại!";
        return null;
    }

    public String reject(int requestId, String adminNote) {
        if (adminNote == null || adminNote.trim().isEmpty()) return "Vui lòng nhập lý do từ chối!";
        if (adminNote.length() > 255) return "Lý do tối đa 255 ký tự!";
        RegistrationRequest q = requestDAO.getRequestById(requestId);
        if (q == null) return "Không tìm thấy yêu cầu!";
        if (!"pending".equals(q.getStatus())) return "Yêu cầu này đã được xử lý!";
        if (!requestDAO.reject(requestId, adminNote.trim())) return "Từ chối thất bại!";
        return null;
    }
}