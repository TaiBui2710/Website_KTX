package model.bean;

import java.time.LocalDateTime;

public class Feedback {
    private int id;
    private int userId;
    private String content;
    private String reply;              // admin tra loi, co the null
    private String status;             // new | replied
    private boolean published;         // cot is_published: true = guest thay
    private LocalDateTime createdAt;
    private LocalDateTime repliedAt;   // co the null
    private String fullName;           // lay tu JOIN users
    private String studentCode;        // lay tu JOIN users

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getReply() { return reply; }
    public void setReply(String reply) { this.reply = reply; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public boolean isPublished() { return published; }
    public void setPublished(boolean published) { this.published = published; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getRepliedAt() { return repliedAt; }
    public void setRepliedAt(LocalDateTime repliedAt) { this.repliedAt = repliedAt; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getStudentCode() { return studentCode; }
    public void setStudentCode(String studentCode) { this.studentCode = studentCode; }

    // tien cho JSP / BO: da duoc admin tra loi chua
    public boolean isReplied() { return "replied".equals(status); }
}