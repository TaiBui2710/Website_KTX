package model.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import model.bean.User;

public class UserDAO {
    private User mapUser(ResultSet rs) throws SQLException{
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setUsername(rs.getString("username"));
        u.setPassword(rs.getString("password"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setAddress(rs.getString("address"));
        u.setGender(rs.getString("gender"));
        u.setStudentCode(rs.getString("student_code"));
        u.setRole(rs.getString("role"));
        u.setCreatedAt(DBConnect.getDateTime(rs, "created_at"));
        return u;
    }

    private ArrayList<User> query(String sql, Object... params)
    {
        ArrayList<User> result = new ArrayList<User>();
        try(Connection conn = DBConnect.getConnection()){
            PreparedStatement pst = conn.prepareStatement(sql);
            DBConnect.setParams(pst, params);
            ResultSet rs = pst.executeQuery();
            while(rs.next()) 
                result.add(mapUser(rs));
        }catch (Exception e)
        {
            e.printStackTrace();
        }
        return result;
    }

    public User getUserByUsername(String username)
    {
        ArrayList<User> list = query("select * from users where username=?", username);
        return list.isEmpty() ? null : list.get(0);
    }

    public User getUserById(int id)
    {
        ArrayList<User> list = query("select * from users where id=?", id);
        return list.isEmpty() ? null : list.get(0);
    }

    public ArrayList<User> getUserList(String keyword)
    {
        String k = "%" + keyword + "%";
        return query("Select * from users where full_name like ? or username like ? or student_code like ?" + " order by role, id", k, k ,k);
    }

    public boolean isExist(String column, String value, int excludeId) {
        if (!column.equals("username") && !column.equals("email") && !column.equals("student_code"))
            return false;
        return DBConnect.count("select count(*) from users where " + column + "=? and id<>?",
                               value, excludeId) > 0;
    }

    public boolean insertUser(User u) {
        String sql = "insert into users (username, password, full_name, email, phone, address, gender, student_code, role)"
                   + " values (?, ?, ?, ?, ?, ?, ?, ?, 'user')";
        return DBConnect.executeUpdate(sql, u.getUsername(), u.getPassword(), u.getFullName(),
                u.getEmail(), u.getPhone(), u.getAddress(), u.getGender(), u.getStudentCode()) == 1;
    }

    public boolean updateProfile(User u) {
        String sql = "update users set full_name=?, email=?, phone=?, address=?, gender=? where id=?";
        return DBConnect.executeUpdate(sql, u.getFullName(), u.getEmail(), u.getPhone(),
                u.getAddress(), u.getGender(), u.getId()) == 1;
    }

    public boolean updatePassword(int id, String hashedPassword) {
        return DBConnect.executeUpdate("update users set password=? where id=?", hashedPassword, id) == 1;
    }

    public boolean updateRole(int id, String role) {
        return DBConnect.executeUpdate("update users set role=? where id=?", role, id) == 1;
    }

    public boolean deleteUser(int id) {
        return DBConnect.executeUpdate("delete from users where id=?", id) == 1;
    }
}
