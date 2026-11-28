package model.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import model.bean.Feedback;

public class FeedbackDAO {
    private static final String SELECT_FEEDBACK =
        "select f.*, u.full_name, u.student_code from feedbacks f join users u on u.id = f.user_id ";

    private Feedback mapFeedback(ResultSet rs) throws SQLException {
        Feedback f = new Feedback();
        f.setId(rs.getInt("id"));
        f.setUserId(rs.getInt("user_id"));
        f.setContent(rs.getString("content"));
        f.setReply(rs.getString("reply"));
        f.setStatus(rs.getString("status"));
        f.setPublished(rs.getBoolean("is_published"));
        f.setCreatedAt(DBConnect.getDateTime(rs, "created_at"));
        f.setRepliedAt(DBConnect.getDateTime(rs, "replied_at"));
        f.setFullName(rs.getString("full_name"));
        f.setStudentCode(rs.getString("student_code"));
        return f;
    }

    private ArrayList<Feedback> query(String sql, Object... params) {
        ArrayList<Feedback> result = new ArrayList<Feedback>();
        try (Connection conn = DBConnect.getConnection()) {
            PreparedStatement pst = conn.prepareStatement(sql);
            DBConnect.setParams(pst, params);
            ResultSet rs = pst.executeQuery();
            while (rs.next()) result.add(mapFeedback(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    // guest: chi gop y da cong khai, moi tra loi len dau
    public ArrayList<Feedback> getPublishedFeedbacks() {
        return query(SELECT_FEEDBACK + "where f.is_published = true order by f.replied_at desc");
    }

    // sinh vien: gop y cua chinh minh
    public ArrayList<Feedback> getFeedbacksByUser(int userId) {
        return query(SELECT_FEEDBACK + "where f.user_id=? order by f.created_at desc", userId);
    }

    // admin: loc theo trang thai; status rong = tat ca
    public ArrayList<Feedback> getFeedbackList(String status) {
        return query(SELECT_FEEDBACK + "where (?='' or f.status=?) order by f.created_at desc", status, status);
    }

    public Feedback getFeedbackById(int id) {
        ArrayList<Feedback> list = query(SELECT_FEEDBACK + "where f.id=?", id);
        return list.isEmpty() ? null : list.get(0);
    }

    public boolean insertFeedback(Feedback f) {
        return DBConnect.executeUpdate("insert into feedbacks (user_id, content) values (?, ?)",
                f.getUserId(), f.getContent()) == 1;
    }

    // tra loi = luu cau tra loi + doi trang thai + ghi gio tra loi
    public boolean reply(int id, String reply) {
        return DBConnect.executeUpdate("update feedbacks set reply=?, status='replied', replied_at=now() where id=?",
                reply, id) == 1;
    }

    public boolean updatePublished(int id, boolean published) {
        return DBConnect.executeUpdate("update feedbacks set is_published=? where id=?", published, id) == 1;
    }

    public boolean deleteFeedback(int id) {
        return DBConnect.executeUpdate("delete from feedbacks where id=?", id) == 1;
    }

    public int countByStatus(String status) {
        return DBConnect.count("select count(*) from feedbacks where status=?", status);
    }
}