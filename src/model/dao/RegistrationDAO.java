package model.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import model.bean.Registration;

public class RegistrationDAO {
    private static final String SELECT_REG = "select g.*, u.full_name, u.student_code, r.room_number, r.building from registrations g" + " join users u on u.id = g.user_id join rooms r on r.id = g.room_id ";
    
    private Registration mapRegistration(ResultSet rs) throws SQLException{
        Registration g = new Registration();
        g.setId(rs.getInt("id"));
        g.setUserId(rs.getInt("user_id"));
        g.setRoomId(rs.getInt("room_id"));
        g.setStatus(rs.getString("status"));
        g.setCheckInDate(DBConnect.getDate(rs, "check_in_date"));
        g.setCheckOutDate(DBConnect.getDate(rs, "check_out_date"));
        g.setNote(rs.getString("note"));
        g.setAdminNote(rs.getString("admin_note"));
        g.setCreatedAt(DBConnect.getDateTime(rs, "created_at"));
        g.setFullName(rs.getString("full_name"));
        g.setStudentCode(rs.getString("student_code"));
        g.setRoomNumber(rs.getString("room_number"));
        g.setBuilding(rs.getString("building"));
        return g;
    }

    private ArrayList<Registration> query(String sql, Object... params){
        ArrayList<Registration> result = new ArrayList<Registration>();
        try(Connection conn = DBConnect.getConnection()){
            PreparedStatement pst = conn.prepareStatement(sql);
            DBConnect.setParams(pst, params);
            ResultSet rs = pst.executeQuery();
            while(rs.next()) result.add(mapRegistration(rs));
        }catch(Exception e){
            e.printStackTrace();
        }
        return result;
    }

    public Registration getActiveRegistration(int userId)
    {
        ArrayList<Registration> list = query(SELECT_REG + "where g.user_id=? and (g.status='pending'" + " or (g.status='approved' and g.check_out_date >= curdate())) order by g.id desc limit 1",userId);
        return list.isEmpty() ? null : list.get(0);
    }

    public ArrayList<Registration> getRegistrationsByUser(int userId)
    {
        return query(SELECT_REG + "where g.user_id=? order by g.created_at desc", userId);
    }

    public ArrayList<Registration> getRegistrationList(String status){
        return query(SELECT_REG + "where (?='' or g.status=?) order by g.created_at desc", status, status);
    }

    public Registration getRegistrationById(int id)
    {
        ArrayList<Registration> list = query(SELECT_REG + "where g.id=?", id);
        return list.isEmpty() ? null : list.get(0);
    }

    public boolean insertRegistration(int userId, int roomId, String note)
    {
        return DBConnect.executeUpdate("insert into registrations (user_id, room_id, note) values(?, ?, ?)", userId, roomId, note) == 1;
    }

    public boolean approve(int id, LocalDate checkIn, LocalDate checkOut, String adminNote)
    {
        return DBConnect.executeUpdate("update registrations set status='approved', check_in_date=?," + " check_out_date=?, admin_note=? where id=? and status='pending'", checkIn, checkOut, adminNote, id) == 1;
    }

    public boolean reject(int id, String adminNote)
    {
        return DBConnect.executeUpdate("update registrations set status='rejected', admin_note=?" + " where id=? and status='pending'", adminNote, id) == 1;
    }

    public boolean cancel(int id)
    {
        return DBConnect.executeUpdate("update registrations set status='cancelled'" + " where id=? and status in ('pending', 'approved')", id) == 1;
    }

    public int countByUser(int userId)
    {
        return DBConnect.count("select count(*) from registrations where user_id=?", userId);
    }

    public int countByRoom(int roomId)
    {
        return DBConnect.count("select count(*) from registrations where room_id=?", roomId);
    }

    public int countByStatus(String status)
    {
        return DBConnect.count("select count(*) from registrations where status=?", status);
    }
}
