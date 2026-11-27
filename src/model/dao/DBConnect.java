package model.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class DBConnect {
    public static Connection getConnection() throws Exception
    {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/dormitory?characterEncoding=UTF-8";
        return DriverManager.getConnection(url, "root","");
    }

    public static void setParams(PreparedStatement pst, Object... params) throws SQLException
    {
        for(int i = 0; i < params.length; i++)
            pst.setObject(i + 1, params[i]);
    }

    public static int executeUpdate(String sql,Object... params)
    {
        int ketqua = -1;
        try(Connection conn = getConnection())
        {
            PreparedStatement pst = conn.prepareStatement(sql);
            setParams(pst,params);
            ketqua = pst.executeUpdate();
        }catch (Exception e)
        {
            e.printStackTrace();
        }
        return ketqua;
    }

    public static int count(String sql, Object... params){
        int ketqua = 0;
        try(Connection conn = getConnection())
        {
            PreparedStatement pst = conn.prepareStatement(sql);
            setParams(pst, params);
            ResultSet rs = pst.executeQuery();
            if(rs.next()) 
                ketqua = rs.getInt(1);
        }catch(Exception e)
        {
            e.printStackTrace();
        }
        return ketqua;
    }

    public static LocalDate getDate(ResultSet rs, String column) throws SQLException{
        java.sql.Date d = rs.getDate(column);
        return d == null ? null : d.toLocalDate();
    }

    public static LocalDateTime getDateTime(ResultSet rs, String column) throws SQLException{
        Timestamp t = rs.getTimestamp(column);
        return t == null ? null : t.toLocalDateTime();
    }
}
