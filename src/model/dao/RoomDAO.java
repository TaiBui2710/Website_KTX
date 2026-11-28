package model.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import model.bean.Room;

public class RoomDAO {
    private static final String SELECT_ROOM = "select r.*, v.occupied, v.available from rooms r join v_room_occupancy v on v.id = r.id ";

    private Room mapRoom(ResultSet rs) throws SQLException{
        Room r = new Room();
        r.setId(rs.getInt("id"));
        r.setRoomNumber(rs.getString("room_number"));
        r.setBuilding(rs.getString("building"));
        r.setGenderType(rs.getString("gender_type"));
        r.setCapacity(rs.getInt("capacity"));
        r.setPrice(rs.getLong("price"));
        r.setStatus(rs.getString("status"));
        r.setDescription(rs.getString("description"));
        r.setOccupied(rs.getInt("occupied"));
        r.setAvailable(rs.getInt("available"));
        return r;
    }

    private ArrayList<Room> query(String sql, Object... params)
    {
        ArrayList<Room> result = new ArrayList<Room>();
        try(Connection conn = DBConnect.getConnection()){
            PreparedStatement pst = conn.prepareStatement(sql);
            DBConnect.setParams(pst, params);
            ResultSet rs = pst.executeQuery();
            while(rs.next()) result.add(mapRoom(rs));
        }catch(Exception e)
        {
            e.printStackTrace();
        }
        return result;
    }

    public ArrayList<Room> getRoomList(String building, String genderType, String status){
        return query(SELECT_ROOM + "where (?='' or r.building=?) and (?='' or r.gender_type=?) and (?='' or r.status=?)" + " order by r.building, r.room_number", building, building, genderType, genderType, status, status);
    }

    public ArrayList<Room> getAvailableRooms(String genderType)
    {
        return query(SELECT_ROOM + "where r.status='open' and r.gender_type=? and v.available > 0" + " order by r.building, r.room_number", genderType);
    }

    public Room getRoomById(int id){
        ArrayList<Room> list = query(SELECT_ROOM + "where r.id=?", id);
        return list.isEmpty() ? null : list.get(0);
    }

    public boolean isExistRoomNumber(String roomNumber, int excludeId)
    {
        return DBConnect.count("select count(*) from rooms where room_number=? and id<>?", roomNumber, excludeId) > 0 ;
    }

    public boolean insertRoom(Room r)
    {
        String sql = "insert into rooms (room_number, building, gender_type, capacity, price, status, description)" + " values(?, ?, ?, ?, ?, ?, ?)" ;
        return DBConnect.executeUpdate(sql, r.getRoomNumber(), r.getBuilding(), r.getGenderType(), r.getCapacity(), r.getPrice(), r.getStatus(), r.getDescription()) == 1;
    }

    public boolean updateRoom(Room r)
    {
        String sql = "update rooms set room_number=?, building=?, gender_type=?, capacity=?, price=?," + " status=?, description=? where id=?";
        return DBConnect.executeUpdate(sql, r.getRoomNumber(), r.getBuilding(), r.getGenderType(), r.getCapacity(), r.getPrice(), r.getStatus(), r.getDescription(), r.getId()) == 1;
    }

    public boolean deleteRoom(int id){
        return DBConnect.executeUpdate("delete from rooms where id=?", id) == 1;
    }
}
