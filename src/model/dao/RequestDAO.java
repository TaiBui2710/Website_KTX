package model.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import model.bean.RegistrationRequest;

public class RequestDAO
{
    private static final String SELECT_REQ = "select q.*, g.user_id, g.check_in_date, g.check_out_date, u.full_name, r.room_number" + " from registration_requests q join registrations g on g.id = q.registration_id" + " join users u on u.id = g.user_id join rooms r on r.id = g.room_id ";

    private RegistrationRequest mapRequest(ResultSet rs) throws SQLException{
        RegistrationRequest q = new RegistrationRequest();
        q.setId(rs.getInt("id"));
        q.setRegistrationId(rs.getInt("registration_id"));
        q.setType(rs.getString("type"));
        q.setRequestedDate(DBConnect.getDate(rs, "requested_date"));
        q.setReason(rs.getString("reason"));
        q.setStatus(rs.getString("status"));
        q.setAdminNote(rs.getString("admin_note"));
        q.setCreatedAt(DBConnect.getDateTime(rs, "created_at"));
        q.setProcessedAt(DBConnect.getDateTime(rs, "processed_at"));
        q.setUserId(rs.getInt("user_id"));
        q.setFullName(rs.getString("full_name"));
        q.setRoomNumber(rs.getString("room_number"));
        q.setCheckInDate(DBConnect.getDate(rs, "check_in_date"));
        q.setCheckOutDate(DBConnect.getDate(rs, "check_out_date"));
        return q;
    }

    private ArrayList<RegistrationRequest> query(String sql, Object... params) {
        ArrayList<RegistrationRequest> result = new ArrayList<RegistrationRequest>();
        try (Connection conn = DBConnect.getConnection()) {
            PreparedStatement pst = conn.prepareStatement(sql);
            DBConnect.setParams(pst, params);
            ResultSet rs = pst.executeQuery();
            while (rs.next()) result.add(mapRequest(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public RegistrationRequest getRequestById(int id) {
        ArrayList<RegistrationRequest> list = query(SELECT_REQ + "where q.id=?", id);
        return list.isEmpty() ? null : list.get(0);
    }

    // yeu cau dang cho cua 1 don (toi da 1), khong co -> null
    public RegistrationRequest getPendingRequest(int registrationId) {
        ArrayList<RegistrationRequest> list =
            query(SELECT_REQ + "where q.registration_id=? and q.status='pending'", registrationId);
        return list.isEmpty() ? null : list.get(0);
    }

    public ArrayList<RegistrationRequest> getRequestsByRegistration(int registrationId) {
        return query(SELECT_REQ + "where q.registration_id=? order by q.created_at desc", registrationId);
    }

    // admin: loc theo trang thai, rong = tat ca
    public ArrayList<RegistrationRequest> getRequestList(String status) {
        return query(SELECT_REQ + "where (?='' or q.status=?) order by q.created_at desc", status, status);
    }

    public boolean insertRequest(int registrationId, String type, LocalDate requestedDate, String reason) {
        return DBConnect.executeUpdate("insert into registration_requests (registration_id, type,"
            + " requested_date, reason) values (?, ?, ?, ?)", registrationId, type, requestedDate, reason) == 1;
    }

    public boolean reject(int id, String adminNote) {
        return DBConnect.executeUpdate("update registration_requests set status='rejected', admin_note=?,"
            + " processed_at=now() where id=? and status='pending'", adminNote, id) == 1;
    }

    // duyet yeu cau: sua 2 bang trong 1 transaction
    public boolean approve(RegistrationRequest q, String adminNote) {
        Connection conn = null;
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);                      // bat dau transaction

            // cau 1: danh dau yeu cau da duyet
            PreparedStatement p1 = conn.prepareStatement("update registration_requests set status='approved',"
                + " admin_note=?, processed_at=now() where id=? and status='pending'");
            DBConnect.setParams(p1, adminNote, q.getId());
            if (p1.executeUpdate() != 1) {                  // yeu cau da bi xu li truoc do
                conn.rollback();
                return false;
            }

            // cau 2: ap dung vao don dang ky
            PreparedStatement p2;
            if ("cancel".equals(q.getType())) {
                p2 = conn.prepareStatement("update registrations set status='cancelled' where id=?");
                DBConnect.setParams(p2, q.getRegistrationId());
            } else {                                        // extend / checkout: doi ngay tra phong
                p2 = conn.prepareStatement("update registrations set check_out_date=? where id=?");
                DBConnect.setParams(p2, q.getRequestedDate(), q.getRegistrationId());
            }
            if (p2.executeUpdate() != 1) {
                conn.rollback();
                return false;
            }

            conn.commit();                                  // ca 2 cau deu thanh cong
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (Exception ex) { }
            return false;
        } finally {
            try { if (conn != null) conn.close(); } catch (Exception ex) { }
        }
    }

    public int countByStatus(String status) {
        return DBConnect.count("select count(*) from registration_requests where status=?", status);
    }
}