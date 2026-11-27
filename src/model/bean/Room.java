package model.bean;

public class Room {
    private int id;
    private String roomNumber;
    private String building;
    private String genderType;
    private int capacity;
    private long price;
    private String status;
    private String description;
    
    private int occupied;
    private int available;
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public String getRoomNumber() {
        return roomNumber;
    }
    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }
    public String getBuilding() {
        return building;
    }
    public void setBuilding(String building) {
        this.building = building;
    }
    public String getGenderType() {
        return genderType;
    }
    public void setGenderType(String genderType) {
        this.genderType = genderType;
    }
    public int getCapacity() {
        return capacity;
    }
    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }
    public long getPrice() {
        return price;
    }
    public void setPrice(long price) {
        this.price = price;
    }
    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }
    public int getOccupied() {
        return occupied;
    }
    public void setOccupied(int occupied) {
        this.occupied = occupied;
    }
    public int getAvailable() {
        return available;
    }
    public void setAvailable(int available) {
        this.available = available;
    }
}
