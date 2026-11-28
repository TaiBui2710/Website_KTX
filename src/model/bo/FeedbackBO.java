package model.bo;

import java.util.ArrayList;
import model.bean.Feedback;
import model.bean.User;
import model.dao.FeedbackDAO;

public class FeedbackBO {
    public static final int MAX_LENGTH = 1000;
    FeedbackDAO feedbackDAO = new FeedbackDAO();

    public ArrayList<Feedback> getPublishedFeedbacks() { return feedbackDAO.getPublishedFeedbacks(); }
    public ArrayList<Feedback> getFeedbacksByUser(int userId) { return feedbackDAO.getFeedbacksByUser(userId); }
    public ArrayList<Feedback> getFeedbackList(String status) { return feedbackDAO.getFeedbackList(status); }
    public int countNew() { return feedbackDAO.countByStatus("new"); }

    // sinh vien gui gop y
    public String send(User user, String content) {
        if (user.isAdmin()) return "Admin không gửi góp ý!";
        if (content.isEmpty()) return "Vui lòng nhập nội dung góp ý!";
        if (content.length() > MAX_LENGTH) return "Góp ý tối đa " + MAX_LENGTH + " ký tự!";
        Feedback f = new Feedback();
        f.setUserId(user.getId());
        f.setContent(content);
        return feedbackDAO.insertFeedback(f) ? null : "Gửi góp ý thất bại!";
    }

    // sinh vien xoa gop y cua minh, chi khi admin chua tra loi
    public String deleteByUser(User user, int id) {
        Feedback f = feedbackDAO.getFeedbackById(id);
        if (f == null || f.getUserId() != user.getId()) return "Không tìm thấy góp ý!";
        if (f.isReplied()) return "Góp ý đã được trả lời, không thể xóa!";
        return feedbackDAO.deleteFeedback(id) ? null : "Xóa góp ý thất bại!";
    }

    // admin tra loi (tra loi lai thi ghi de cau cu)
    public String reply(int id, String reply) {
        if (feedbackDAO.getFeedbackById(id) == null) return "Không tìm thấy góp ý!";
        if (reply.isEmpty()) return "Vui lòng nhập nội dung trả lời!";
        if (reply.length() > MAX_LENGTH) return "Trả lời tối đa " + MAX_LENGTH + " ký tự!";
        return feedbackDAO.reply(id, reply) ? null : "Trả lời thất bại!";
    }

    // admin bat / tat hien thi cho guest
    public String setPublished(int id, boolean published) {
        Feedback f = feedbackDAO.getFeedbackById(id);
        if (f == null) return "Không tìm thấy góp ý!";
        if (published && !f.isReplied()) return "Chỉ công khai được góp ý đã trả lời!";
        return feedbackDAO.updatePublished(id, published) ? null : "Cập nhật thất bại!";
    }

    // admin xoa (vd gop y spam)
    public String deleteFeedback(int id) {
        if (feedbackDAO.getFeedbackById(id) == null) return "Không tìm thấy góp ý!";
        return feedbackDAO.deleteFeedback(id) ? null : "Xóa góp ý thất bại!";
    }
}