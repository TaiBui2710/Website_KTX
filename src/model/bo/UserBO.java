package model.bo;

import java.util.ArrayList;
import java.util.Objects;
import model.bean.User;
import model.dao.PostDAO;
import model.dao.RegistrationDAO;
import model.dao.UserDAO;
import util.PasswordUtil;

public class UserBO {
    UserDAO userDAO = new UserDAO();
    RegistrationDAO registrationDAO = new RegistrationDAO();
    PostDAO postDAO = new PostDAO();

    // dang nhap dung -> tra ve User, sai -> null
    public User login(String username, String password) {
        User user = userDAO.getUserByUsername(username);
        if (user != null && PasswordUtil.check(password, user.getPassword())) return user;
        return null;
    }

    public User getUserById(int id) { return userDAO.getUserById(id); }

    public ArrayList<User> getUserList(String keyword) { return userDAO.getUserList(keyword); }

    // kiem tra cac o chung cua form dang ki va form sua ho so
    private String checkProfile(User u, int excludeId) {
        if (u.getFullName().isEmpty()) return "Vui lòng nhập họ tên!";
        if (u.getFullName().length() > 100) return "Họ tên tối đa 100 ký tự!";
        if (!u.getEmail().matches("^[\\w.+-]+@[\\w-]+(\\.[\\w-]+)+$")) return "Email không hợp lệ!";
        if (userDAO.isExist("email", u.getEmail(), excludeId)) return "Email đã được sử dụng!";
        if (!u.getPhone().isEmpty() && !u.getPhone().matches("0\\d{9,10}")) return "Số điện thoại không hợp lệ!";
        if (u.getGender() != null && !u.getGender().equals("male") && !u.getGender().equals("female"))
            return "Giới tính không hợp lệ!";
        return null;
    }

    private String checkPassword(String password, String confirm) {
        if (password.length() < 6) return "Mật khẩu phải có ít nhất 6 ký tự!";
        if (!password.equals(confirm)) return "Mật khẩu nhập lại không khớp!";
        return null;
    }

    // dang ki tai khoan sinh vien. null = thanh cong
    public String signup(User u, String password, String confirm) {
        if (!u.getUsername().matches("[a-zA-Z0-9_]{4,50}"))
            return "Tên đăng nhập 4–50 ký tự, chỉ gồm chữ, số và dấu _";
        if (userDAO.isExist("username", u.getUsername(), 0)) return "Tên đăng nhập đã tồn tại!";
        if (!u.getStudentCode().matches("\\d{6,20}")) return "MSSV không hợp lệ!";
        if (userDAO.isExist("student_code", u.getStudentCode(), 0)) return "MSSV đã được đăng ký!";
        if (u.getGender() == null) return "Vui lòng chọn giới tính!";
        String loi = checkProfile(u, 0);
        if (loi == null) loi = checkPassword(password, confirm);
        if (loi != null) return loi;
        u.setPassword(PasswordUtil.hash(password));
        if (!userDAO.insertUser(u)) return "Đăng ký thất bại, vui lòng thử lại!";
        return null;
    }

    // tu sua ho so: current = du lieu trong CSDL, form = du lieu vua nhap
    public String updateProfile(User current, User form) {
        form.setId(current.getId());
        String loi = checkProfile(form, current.getId());
        if (loi != null) return loi;
        if (!current.isAdmin() && form.getGender() == null) return "Vui lòng chọn giới tính!";
        if (!Objects.equals(current.getGender(), form.getGender())
                && registrationDAO.getActiveRegistration(current.getId()) != null)
            return "Không thể đổi giới tính khi đang có đơn đăng ký phòng!";
        if (!userDAO.updateProfile(form)) return "Cập nhật thất bại, vui lòng thử lại!";
        return null;
    }

    public String changePassword(User current, String oldPassword, String newPassword, String confirm) {
        if (!PasswordUtil.check(oldPassword, current.getPassword())) return "Mật khẩu cũ không đúng!";
        String loi = checkPassword(newPassword, confirm);
        if (loi != null) return loi;
        if (!userDAO.updatePassword(current.getId(), PasswordUtil.hash(newPassword)))
            return "Đổi mật khẩu thất bại, vui lòng thử lại!";
        return null;
    }

    // admin doi quyen nguoi khac
    public String changeRole(User admin, int targetId, String role) {
        if (!role.equals("user") && !role.equals("admin")) return "Quyền không hợp lệ!";
        if (targetId == admin.getId()) return "Không thể tự đổi quyền của chính mình!";
        if (userDAO.getUserById(targetId) == null) return "Không tìm thấy tài khoản!";
        if (!userDAO.updateRole(targetId, role)) return "Đổi quyền thất bại!";
        return null;
    }

    public String deleteUser(User admin, int targetId) {
        if (targetId == admin.getId()) return "Không thể xóa tài khoản của chính mình!";
        if (userDAO.getUserById(targetId) == null) return "Không tìm thấy tài khoản!";
        if (registrationDAO.countByUser(targetId) > 0) return "Tài khoản đã có đơn đăng ký phòng, không thể xóa!";
        if (postDAO.countByAuthor(targetId) > 0) return "Tài khoản đã viết bài, không thể xóa!";
        if (!userDAO.deleteUser(targetId)) return "Xóa thất bại, vui lòng thử lại!";
        return null;
    }
}