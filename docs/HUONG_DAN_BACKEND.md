# Hướng dẫn viết Backend Java cho Website_KTX

Tài liệu này hướng dẫn viết **từ đầu** phần backend (Java Servlet + JDBC) cho hệ thống đăng ký phòng ký túc xá, theo đúng mô hình MVC thầy đang dạy ở `BTHS4` / `MVCSample`:

```
JSP (View)  ──form──►  Servlet (Controller)  ──►  BO (nghiệp vụ)  ──►  DAO (SQL)  ──►  MySQL
    ▲                         │
    └──── forward / redirect ─┘
```

| Tầng | Package | Việc của tầng | Ví dụ ở BTHS4 |
|---|---|---|---|
| Bean | `model.bean` | Chỉ chứa dữ liệu (field + getter/setter) | `User.java` |
| DAO | `model.dao` | Chỉ chạy SQL, trả về bean / `ArrayList` / `boolean` | `UserDAO.java` |
| BO | `model.bo` | **Kiểm tra quy tắc nghiệp vụ**, gọi DAO | `UserBO.java` |
| Controller | `controller` | Đọc form, kiểm tra đăng nhập, gọi BO, chọn trang JSP | `SearchServlet.java` |
| Util | `util` | Hàm dùng chung (escape HTML, băm mật khẩu, đọc số/ngày) | `HtmlUtil.java` |

**Khác biệt so với BTHS4** (vì KTX lớn hơn, 5 bảng thay vì 1):

1. BO không còn "chuyển tiếp" sang DAO nữa mà là nơi chứa **toàn bộ quy tắc** (phòng còn chỗ không, đúng giới tính không, mỗi sinh viên 1 đơn…). Hàm BO trả về `String`: `null` = thành công, khác `null` = câu thông báo lỗi → Servlet chỉ việc đưa câu đó ra JSP (giống biến `thongbao` của thầy).
2. Kiểm tra đăng nhập/phân quyền gom vào **1 Filter** (`AuthFilter`) thay vì chép lại ở đầu từng Servlet. Filter vẫn giữ nguyên ý tưởng của thầy: *đọc lại quyền từ CSDL mỗi lần*, không tin session.
3. Mật khẩu được **băm SHA-256**, không lưu chữ thường.
4. DAO dùng `try (Connection conn = ...)` để kết nối luôn được đóng, kể cả khi có lỗi (xem mục 3.1 e).

---

## Bước 0 — Chuẩn bị

### 0.1. Tạo CSDL

1. Bật **MySQL** trong XAMPP Control Panel.
2. Vào phpMyAdmin → tab *Import* → chọn `database/dormitory.sql` → *Go*.
3. Dữ liệu demo đang dùng mật khẩu băm kiểu PHP (`$2y$10$...`, bcrypt). Java không có sẵn bcrypt, nên đổi sang SHA-256 (chạy trong tab *SQL*):

```sql
USE dormitory;
UPDATE users SET password = SHA2('123456', 256);
```

> Muốn lần sau import lại không phải chạy câu trên: trong `dormitory.sql` thay chuỗi `$2y$10$96dU...G7de` bằng
> `8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92` (là SHA-256 của `123456`) và sửa comment `-- password_hash()` thành `-- SHA-256 (hex)`.

### 0.2. Thư viện

- `WebContent/WEB-INF/lib/mysql-connector-j-8.4.0.jar` — **đã có** sẵn.
- `servlet-api.jar` của Tomcat 10.1 — dùng khi biên dịch (đã khai báo trong `build.bat` và `.vscode/settings.json`).
- Tomcat 10 dùng `jakarta.servlet.*` (**không phải** `javax.servlet.*` như tài liệu cũ trên mạng).

### 0.3. Sửa `build.bat`

Thêm `src\util\*.java` vào cuối dòng `javac`:

```bat
"C:\Program Files\Java\jdk-21\bin\javac" -encoding UTF-8 -cp "C:\xampp\tomcat\lib\servlet-api.jar" -d WebContent\WEB-INF\classes src\controller\*.java src\model\bean\*.java src\model\bo\*.java src\model\dao\*.java src\util\*.java
```

> `javac` báo lỗi `file not found: src\util\*.java` nếu thư mục **chưa có file .java nào** (chỉ có `.gitkeep`). Vì vậy hãy viết theo đúng thứ tự bên dưới, và chỉ chạy `build.bat` khi mọi thư mục đã có ít nhất 1 file.

### 0.4. Cấu trúc thư mục sau khi xong

```
Website_KTX/
├── build.bat
├── database/dormitory.sql
├── src/
│   ├── util/          HtmlUtil, PasswordUtil, WebUtil
│   ├── model/bean/    User, Room, Registration, RegistrationRequest, Post
│   ├── model/dao/     DBConnect, UserDAO, RoomDAO, RegistrationDAO, RequestDAO, PostDAO
│   ├── model/bo/      UserBO, RoomBO, RegistrationBO, RequestBO, PostBO
│   └── controller/    EncodingFilter, AuthFilter, *Servlet
└── WebContent/
    ├── guest/         index.jsp, post.jsp, rooms.jsp, login.jsp, signup.jsp
    ├── user/          rooms.jsp, my-registration.jsp
    ├── admin/         dashboard.jsp, rooms.jsp, room-form.jsp, registrations.jsp, requests.jsp, users.jsp, posts.jsp, post-form.jsp
    ├── account/       profile.jsp   (tạo thêm thư mục này: trang dùng chung cho user và admin)
    ├── layouts/       header.jsp, footer.jsp
    ├── assets/        css, js, images
    └── WEB-INF/lib/   mysql-connector-j-8.4.0.jar
```

**Thứ tự viết:** `util` → `bean` → `dao` → `bo` → `controller` → JSP. Tầng sau dùng tầng trước, nên viết theo thứ tự này thì lúc nào cũng biên dịch được.

---

## Bước 1 — Util

### `src/util/HtmlUtil.java`

Chép nguyên từ `BTHS4/src/util/HtmlUtil.java`. Mọi chuỗi do người dùng nhập, khi in ra JSP đều phải bọc `HtmlUtil.esc(...)` để chống XSS.

```java
package util;

public class HtmlUtil {
    public static String esc(String s)
    {
        if(s == null) return "";
        StringBuilder sb = new StringBuilder();
        for(int i = 0; i < s.length(); i++){
            char c = s.charAt(i);
            switch(c){
                case '<':  sb.append("&lt;");   break;
                case '>':  sb.append("&gt;");   break;
                case '&':  sb.append("&amp;");  break;
                case '"':  sb.append("&quot;"); break;
                case '\'': sb.append("&#39;");  break;
                default:   sb.append(c);
            }
        }
        return sb.toString();
    }
}
```

### `src/util/PasswordUtil.java`

```java
package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

public class PasswordUtil {
    // bam SHA-256, tra ve chuoi hex 64 ky tu (giong ham SHA2(..., 256) cua MySQL)
    public static String hash(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bytes = md.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    // so mat khau nguoi dung go voi chuoi da bam trong CSDL
    public static boolean check(String password, String hashed) {
        if (password == null || hashed == null) return false;
        return hashed.equals(hash(password));
    }
}
```

> SHA-256 không có "muối" (salt) nên chỉ đủ cho bài tập. Nếu thầy yêu cầu bảo mật thật, dùng bcrypt (thư viện jBCrypt) — khi đó giữ được luôn các hash `$2y$` trong file SQL (đổi tiền tố `$2y$` → `$2a$` trước khi kiểm tra).

### `src/util/WebUtil.java`

Gom mấy đoạn BTHS4 lặp lại nhiều lần: `try{ Integer.parseInt(...) }catch...`, `if(name == null) name = ""`, `sendRedirect(... + URLEncoder.encode(thongbao))`.

```java
package util;

import java.io.IOException;
import java.net.URLEncoder;
import java.time.LocalDate;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class WebUtil {
    // chuoi -> so, thieu hoac khong phai so thi tra ve 0 (giong UpdateServlet cua thay)
    public static int toInt(String s) {
        try { return Integer.parseInt(s.trim()); } catch (Exception e) { return 0; }
    }

    // gia tien: sai thi tra ve -1 de BO bao loi "gia khong hop le"
    public static long toLong(String s) {
        try { return Long.parseLong(s.trim()); } catch (Exception e) { return -1; }
    }

    // <input type="date"> gui len dang yyyy-MM-dd; sai/trong -> null
    public static LocalDate toDate(String s) {
        try { return LocalDate.parse(s.trim()); } catch (Exception e) { return null; }
    }

    // null -> "" va bo khoang trang 2 dau
    public static String trim(String s) {
        return s == null ? "" : s.trim();
    }

    // redirect ve 1 trang trong web, kem thong bao (loai = ok: chu xanh, loi: chu do)
    // path bat dau bang "/", vd "/admin/RoomServlet"
    public static void redirect(HttpServletRequest request, HttpServletResponse response,
                                String path, String loai, String thongbao) throws IOException {
        String url = request.getContextPath() + path;
        if (thongbao != null) {
            url += (path.contains("?") ? "&" : "?") + "loai=" + loai
                 + "&thongbao=" + URLEncoder.encode(thongbao, "UTF-8");
        }
        response.sendRedirect(url);
    }
}
```

> Vì sao dùng `request.getContextPath() + path`? Servlet admin nằm ở `/admin/...`, servlet user ở `/user/...`. Nếu redirect bằng đường dẫn tương đối như BTHS4 (`"SearchServlet?name="`) thì từ `/admin/X` sang `/user/Y` sẽ bị sai thư mục. Đường dẫn tuyệt đối (`/Website_KTX/user/Y`) luôn đúng.

---

## Bước 2 — Bean (`model.bean`)

Mỗi bảng 1 bean. Tên field viết kiểu Java (`fullName`), cột SQL viết kiểu `full_name` — DAO lo việc chuyển đổi. Kiểu dữ liệu:

| SQL | Java |
|---|---|
| `INT`, `TINYINT` | `int` |
| `DECIMAL(12,0)` (giá tiền) | `long` |
| `VARCHAR`, `TEXT`, `ENUM` | `String` |
| `DATE` | `java.time.LocalDate` |
| `DATETIME` | `java.time.LocalDateTime` |
| `BOOLEAN` | `boolean` |

Getter/setter: trong VS Code chuột phải vào class → *Source Action…* → *Generate Getters and Setters*. Ở đây viết gọn 1 dòng cho đỡ dài.

Ngoài cột của bảng, bean có thể có thêm **field lấy từ JOIN** (vd `Registration.fullName` lấy từ bảng `users`) để JSP in ra luôn, không phải truy vấn thêm.

### `src/model/bean/User.java`

```java
package model.bean;

import java.time.LocalDateTime;

public class User {
    private int id;
    private String username;
    private String password;      // chuoi SHA-256, khong bao gio in ra JSP
    private String fullName;
    private String email;
    private String phone;
    private String gender;        // "male" | "female" | null (admin)
    private String studentCode;   // MSSV, admin = null
    private String role;          // "user" | "admin"
    private LocalDateTime createdAt;

    public boolean isAdmin() { return "admin".equals(role); }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public String getStudentCode() { return studentCode; }
    public void setStudentCode(String studentCode) { this.studentCode = studentCode; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
```

### `src/model/bean/Room.java`

```java
package model.bean;

public class Room {
    private int id;
    private String roomNumber;
    private String building;
    private String genderType;    // "male" | "female"
    private int capacity;
    private long price;           // gia / thang
    private String status;        // "open" | "closed"
    private String description;
    private int occupied;         // lay tu view v_room_occupancy (khong co trong bang rooms)
    private int available;        // = capacity - occupied

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }
    public String getBuilding() { return building; }
    public void setBuilding(String building) { this.building = building; }
    public String getGenderType() { return genderType; }
    public void setGenderType(String genderType) { this.genderType = genderType; }
    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }
    public long getPrice() { return price; }
    public void setPrice(long price) { this.price = price; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public int getOccupied() { return occupied; }
    public void setOccupied(int occupied) { this.occupied = occupied; }
    public int getAvailable() { return available; }
    public void setAvailable(int available) { this.available = available; }
}
```

### `src/model/bean/Registration.java`

```java
package model.bean;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class Registration {
    private int id;
    private int userId;
    private int roomId;
    private String status;            // pending | approved | rejected | cancelled
    private LocalDate checkInDate;    // admin nhap khi duyet
    private LocalDate checkOutDate;
    private String note;              // ghi chu cua sinh vien
    private String adminNote;         // phan hoi / ly do tu choi
    private LocalDateTime createdAt;
    // lay tu JOIN, chi de hien thi
    private String fullName;
    private String studentCode;
    private String roomNumber;
    private String building;

    // con hieu luc = dang cho duyet, hoac da duyet va chua het han (giong dieu kien trong view)
    public boolean isActive(LocalDate today) {
        return "pending".equals(status)
            || ("approved".equals(status) && checkOutDate != null && !checkOutDate.isBefore(today));
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getRoomId() { return roomId; }
    public void setRoomId(int roomId) { this.roomId = roomId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDate getCheckInDate() { return checkInDate; }
    public void setCheckInDate(LocalDate checkInDate) { this.checkInDate = checkInDate; }
    public LocalDate getCheckOutDate() { return checkOutDate; }
    public void setCheckOutDate(LocalDate checkOutDate) { this.checkOutDate = checkOutDate; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public String getAdminNote() { return adminNote; }
    public void setAdminNote(String adminNote) { this.adminNote = adminNote; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getStudentCode() { return studentCode; }
    public void setStudentCode(String studentCode) { this.studentCode = studentCode; }
    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }
    public String getBuilding() { return building; }
    public void setBuilding(String building) { this.building = building; }
}
```

### `src/model/bean/RegistrationRequest.java`

```java
package model.bean;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class RegistrationRequest {
    private int id;
    private int registrationId;
    private String type;               // extend | checkout | cancel
    private LocalDate requestedDate;   // extend: ngay tra moi, checkout: ngay muon tra, cancel: null
    private String reason;
    private String status;             // pending | approved | rejected
    private String adminNote;
    private LocalDateTime createdAt;
    private LocalDateTime processedAt;
    // lay tu JOIN
    private int userId;
    private String fullName;
    private String roomNumber;
    private LocalDate checkInDate;     // ngay nhan / tra hien tai cua don
    private LocalDate checkOutDate;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getRegistrationId() { return registrationId; }
    public void setRegistrationId(int registrationId) { this.registrationId = registrationId; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public LocalDate getRequestedDate() { return requestedDate; }
    public void setRequestedDate(LocalDate requestedDate) { this.requestedDate = requestedDate; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getAdminNote() { return adminNote; }
    public void setAdminNote(String adminNote) { this.adminNote = adminNote; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getProcessedAt() { return processedAt; }
    public void setProcessedAt(LocalDateTime processedAt) { this.processedAt = processedAt; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }
    public LocalDate getCheckInDate() { return checkInDate; }
    public void setCheckInDate(LocalDate checkInDate) { this.checkInDate = checkInDate; }
    public LocalDate getCheckOutDate() { return checkOutDate; }
    public void setCheckOutDate(LocalDate checkOutDate) { this.checkOutDate = checkOutDate; }
}
```

### `src/model/bean/Post.java`

```java
package model.bean;

import java.time.LocalDateTime;

public class Post {
    private int id;
    private String title;
    private String content;
    private String category;       // news | notice | rule
    private String image;          // ten file anh, co the null
    private boolean published;     // false = guest khong thay
    private int authorId;
    private LocalDateTime createdAt;
    private String authorName;     // lay tu JOIN users

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }
    public boolean isPublished() { return published; }
    public void setPublished(boolean published) { this.published = published; }
    public int getAuthorId() { return authorId; }
    public void setAuthorId(int authorId) { this.authorId = authorId; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public String getAuthorName() { return authorName; }
    public void setAuthorName(String authorName) { this.authorName = authorName; }
}
```

---

## Bước 3 — DAO (`model.dao`)

**Quy tắc của tầng DAO:** chỉ có SQL, không có `if` nghiệp vụ. Luôn dùng `PreparedStatement` với dấu `?` (chống SQL Injection), không bao giờ cộng chuỗi giá trị người dùng nhập vào câu SQL.

### 3.1. `src/model/dao/DBConnect.java` — kết nối dùng chung

#### a) Hàm kết nối của thầy

Trong `BTHS4/src/model/dao/UserDAO.java`, thầy viết hàm mở kết nối ngay trong DAO:

```text
private Connection getConnection() throws Exception
{
    Class.forName("com.mysql.cj.jdbc.Driver");
    String url = "jdbc:mysql://localhost:3306/bths4?useUnicode=true&characterEncoding=UTF-8";
    return DriverManager.getConnection(url, "root", "");
}
```

Ba dòng này làm 3 việc:

| Dòng | Ý nghĩa |
|---|---|
| `Class.forName("com.mysql.cj.jdbc.Driver")` | Nạp **driver MySQL**, tức file `mysql-connector-j-8.4.0.jar` trong `WEB-INF/lib`. Thiếu file jar thì dòng này báo `ClassNotFoundException`. |
| `String url = "jdbc:mysql://..."` | **Địa chỉ CSDL**, xem bên dưới. |
| `DriverManager.getConnection(url, "root", "")` | Mở kết nối với tài khoản `root`, mật khẩu rỗng (mặc định của XAMPP). |

Địa chỉ CSDL tách ra từng phần:

```text
jdbc:mysql://   localhost   :3306   /dormitory   ?characterEncoding=UTF-8
 loại CSDL      máy chủ     cổng    tên CSDL     đọc/ghi tiếng Việt
```

- So với URL của thầy, chỉ cần **đổi `bths4` thành `dormitory`**.
- `useUnicode=true` có thể bỏ: driver 8.x đã bật sẵn, nên `?characterEncoding=UTF-8` là đủ. Giữ nguyên như thầy cũng không sao, hai cách chạy như nhau.
- Bản trước của hướng dẫn có thêm `serverTimezone=...`. Không cần, vì MySQL và Tomcat chạy cùng một máy nên cùng múi giờ.

#### b) Vì sao tách ra class riêng

BTHS4 chỉ có 1 DAO. KTX có 5 DAO, nếu mỗi DAO tự có `getConnection()` thì đổi mật khẩu MySQL phải sửa 5 chỗ. Nên chuyển **nguyên hàm của thầy** sang class `DBConnect`, chỉ đổi 2 chỗ:

- `private` → `public static`: các DAO khác gọi được bằng `DBConnect.getConnection()`, không cần `new DBConnect()`.
- `bths4` → `dormitory`.

#### c) Ba hàm phụ cho DAO ngắn hơn

Hãy xem hàm `deleteUser` của thầy. Gần như **mọi** hàm thêm/sửa/xóa trong `UserDAO` đều lặp lại đúng khung này, chỉ khác câu SQL và các giá trị gán vào dấu `?`:

```text
public boolean deleteUser(int id)
{
    boolean ketqua = false;
    try{
        Connection conn = getConnection();                    // (1) mở kết nối
        String sql = "delete from admin where id=?";          //     <- chỉ phần này khác nhau
        PreparedStatement pst = conn.prepareStatement(sql);   // (2) chuẩn bị câu SQL
        pst.setInt(1, id);                                    //     <- và phần này
        if(pst.executeUpdate() > 0) ketqua = true;            // (3) chạy
        conn.close();                                         // (4) đóng kết nối
    } catch (Exception e){
        e.printStackTrace();
    }
    return ketqua;
}
```

Phần lặp lại (1)–(4) được gom vào hàm `DBConnect.executeUpdate(sql, các giá trị...)`. Khi đó mỗi hàm trong DAO chỉ còn 1 dòng, chỉ chứa phần khác nhau:

```text
public boolean deleteUser(int id) {
    return DBConnect.executeUpdate("delete from users where id=?", id) == 1;
}
```

| Hàm phụ | Thay cho đoạn code nào của thầy |
|---|---|
| `setParams(pst, a, b, c)` | Các dòng `pst.setString(1, a); pst.setInt(2, b); ...`. Hàm tự gán giá trị thứ 1 vào dấu `?` thứ 1, giá trị thứ 2 vào dấu `?` thứ 2, v.v. |
| `executeUpdate(sql, a, b, c)` | Cả khung insert/update/delete ở trên. Trả về số dòng bị ảnh hưởng (lỗi thì `-1`). |
| `count(sql, a, b)` | Khung `select count(*) ...` rồi `rs.getInt(1)`, dùng để kiểm tra "đã tồn tại chưa", "có bao nhiêu đơn". |

`Object... params` nghĩa là "truyền bao nhiêu giá trị cũng được". Gọi `executeUpdate(sql, a, b, c)` thì bên trong hàm, `params` là mảng `[a, b, c]`.

Ngoài ra có thêm 2 hàm đọc ngày giờ. `rs.getDate()` trả về kiểu cũ `java.sql.Date`, và trả `null` nếu cột NULL. Hai hàm `getDate` / `getDateTime` đổi sang `LocalDate` / `LocalDateTime` mà bean đang dùng, và không bị lỗi khi cột NULL (vd `check_in_date` của đơn chưa duyệt).

#### d) Code đầy đủ

```java
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

    // ===== 1. MO KET NOI: giong het ham getConnection() cua thay, chi doi ten CSDL =====
    public static Connection getConnection() throws Exception
    {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/dormitory?characterEncoding=UTF-8";
        return DriverManager.getConnection(url, "root", "");
    }

    // ===== 2. HAM PHU: gom phan code lap lai o moi ham DAO =====

    // gan gia tri vao cac dau ?: dau ? thu 1 = params[0], dau ? thu 2 = params[1], ...
    // setObject tu nhan kieu (int, long, String, LocalDate, boolean, null) -> khong can setInt / setString
    public static void setParams(PreparedStatement pst, Object... params) throws SQLException
    {
        for (int i = 0; i < params.length; i++)
            pst.setObject(i + 1, params[i]);
    }

    // insert / update / delete: tra ve so dong bi anh huong, -1 neu loi
    public static int executeUpdate(String sql, Object... params)
    {
        int ketqua = -1;
        try (Connection conn = getConnection()) {                  // (1) mo ket noi, ra khoi try tu dong (4)
            PreparedStatement pst = conn.prepareStatement(sql);     // (2)
            setParams(pst, params);
            ketqua = pst.executeUpdate();                           // (3)
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ketqua;
    }

    // select count(*) ...: tra ve con so, loi thi 0
    public static int count(String sql, Object... params)
    {
        int ketqua = 0;
        try (Connection conn = getConnection()) {
            PreparedStatement pst = conn.prepareStatement(sql);
            setParams(pst, params);
            ResultSet rs = pst.executeQuery();
            if (rs.next()) ketqua = rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ketqua;
    }

    // ===== 3. DOC NGAY GIO: cot NULL thi tra ve null =====
    public static LocalDate getDate(ResultSet rs, String column) throws SQLException
    {
        java.sql.Date d = rs.getDate(column);
        return d == null ? null : d.toLocalDate();
    }

    public static LocalDateTime getDateTime(ResultSet rs, String column) throws SQLException
    {
        Timestamp t = rs.getTimestamp(column);
        return t == null ? null : t.toLocalDateTime();
    }
}
```

#### e) `try (Connection conn = getConnection()) { ... }` khác gì cách của thầy?

```text
Cách của thầy:                          Cách mới (try-with-resources):

try{                                    try (Connection conn = getConnection()) {
    Connection conn = getConnection();      ...
    ...                                 } catch (Exception e) {
    conn.close();                           e.printStackTrace();
} catch (Exception e){                  }
    e.printStackTrace();                // Java TU goi conn.close() khi ra khoi try,
}                                       // ke ca khi co loi
```

Hai cách làm cùng một việc. Khác ở chỗ: với cách của thầy, nếu câu SQL lỗi thì chương trình nhảy thẳng xuống `catch`, dòng `conn.close()` không chạy, và kết nối bị bỏ treo. Mỗi lần lỗi lại treo thêm 1 kết nối, đến khi MySQL báo `Too many connections`. Cách mới luôn đóng kết nối. `PreparedStatement` và `ResultSet` cũng được đóng theo khi kết nối đóng.

### 3.2. Mẫu chung của 1 DAO

Mỗi DAO có 3 phần:

1. `mapXxx(ResultSet rs)` — chuyển **1 dòng** kết quả thành bean (BTHS4 chép đoạn này ở 3 hàm `getUserList`, `getUserById`, `getUserByUsername`; ở đây viết 1 lần).
2. `query(sql, params...)` — chạy SELECT, trả về `ArrayList` bean.
3. Các hàm công khai: mỗi hàm 1 câu SQL. Hàm lấy 1 dòng thì gọi `query(...)` rồi lấy phần tử đầu (không có thì `null`, giống `getUserById` của thầy).

### 3.3. `src/model/dao/UserDAO.java`

```java
package model.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import model.bean.User;

public class UserDAO {
    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setUsername(rs.getString("username"));
        u.setPassword(rs.getString("password"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setGender(rs.getString("gender"));
        u.setStudentCode(rs.getString("student_code"));
        u.setRole(rs.getString("role"));
        u.setCreatedAt(DBConnect.getDateTime(rs, "created_at"));
        return u;
    }

    private ArrayList<User> query(String sql, Object... params) {
        ArrayList<User> result = new ArrayList<User>();
        try (Connection conn = DBConnect.getConnection()) {
            PreparedStatement pst = conn.prepareStatement(sql);
            DBConnect.setParams(pst, params);
            ResultSet rs = pst.executeQuery();
            while (rs.next()) result.add(mapUser(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public User getUserByUsername(String username) {
        ArrayList<User> list = query("select * from users where username=?", username);
        return list.isEmpty() ? null : list.get(0);
    }

    public User getUserById(int id) {
        ArrayList<User> list = query("select * from users where id=?", id);
        return list.isEmpty() ? null : list.get(0);
    }

    // tim theo ho ten / username / MSSV, keyword rong = lay het
    public ArrayList<User> getUserList(String keyword) {
        String k = "%" + keyword + "%";
        return query("select * from users where full_name like ? or username like ? or student_code like ?"
                   + " order by role, id", k, k, k);
    }

    // gia tri da co o nguoi khac chua (excludeId = id cua chinh minh khi sua, 0 khi them moi)
    // column chi duoc la 1 trong 3 cot ben duoi (khong lay tu form) -> khong bi SQL Injection
    public boolean isExist(String column, String value, int excludeId) {
        if (!column.equals("username") && !column.equals("email") && !column.equals("student_code"))
            return false;
        return DBConnect.count("select count(*) from users where " + column + "=? and id<>?",
                               value, excludeId) > 0;
    }

    // dang ki: luon la role 'user'
    public boolean insertUser(User u) {
        String sql = "insert into users (username, password, full_name, email, phone, gender, student_code, role)"
                   + " values (?, ?, ?, ?, ?, ?, ?, 'user')";
        return DBConnect.executeUpdate(sql, u.getUsername(), u.getPassword(), u.getFullName(),
                u.getEmail(), u.getPhone(), u.getGender(), u.getStudentCode()) == 1;
    }

    // tu sua ho so: khong sua username, MSSV, role
    public boolean updateProfile(User u) {
        String sql = "update users set full_name=?, email=?, phone=?, gender=? where id=?";
        return DBConnect.executeUpdate(sql, u.getFullName(), u.getEmail(), u.getPhone(),
                u.getGender(), u.getId()) == 1;
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
```

> `updateProfile` trả về `== 1`: nếu người dùng bấm Lưu mà **không đổi gì**, MySQL vẫn báo 1 dòng "matched" (Connector/J mặc định đếm dòng khớp, không phải dòng thay đổi), nên vẫn là thành công.

### 3.4. `src/model/dao/RoomDAO.java`

Số người đang ở **không lưu trong bảng** `rooms` mà tính bằng view `v_room_occupancy`. Mọi câu SELECT phòng đều JOIN với view để có sẵn `occupied`, `available`.

```java
package model.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import model.bean.Room;

public class RoomDAO {
    private static final String SELECT_ROOM =
        "select r.*, v.occupied, v.available from rooms r join v_room_occupancy v on v.id = r.id ";

    private Room mapRoom(ResultSet rs) throws SQLException {
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

    private ArrayList<Room> query(String sql, Object... params) {
        ArrayList<Room> result = new ArrayList<Room>();
        try (Connection conn = DBConnect.getConnection()) {
            PreparedStatement pst = conn.prepareStatement(sql);
            DBConnect.setParams(pst, params);
            ResultSet rs = pst.executeQuery();
            while (rs.next()) result.add(mapRoom(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    // loc cho admin: tham so rong = khong loc theo tieu chi do
    public ArrayList<Room> getRoomList(String building, String genderType, String status) {
        return query(SELECT_ROOM
            + "where (?='' or r.building=?) and (?='' or r.gender_type=?) and (?='' or r.status=?)"
            + " order by r.building, r.room_number",
            building, building, genderType, genderType, status, status);
    }

    // phong sinh vien dang ky duoc: dang mo, dung gioi tinh, con cho
    public ArrayList<Room> getAvailableRooms(String genderType) {
        return query(SELECT_ROOM + "where r.status='open' and r.gender_type=? and v.available > 0"
                   + " order by r.building, r.room_number", genderType);
    }

    public Room getRoomById(int id) {
        ArrayList<Room> list = query(SELECT_ROOM + "where r.id=?", id);
        return list.isEmpty() ? null : list.get(0);
    }

    public boolean isExistRoomNumber(String roomNumber, int excludeId) {
        return DBConnect.count("select count(*) from rooms where room_number=? and id<>?",
                               roomNumber, excludeId) > 0;
    }

    public boolean insertRoom(Room r) {
        String sql = "insert into rooms (room_number, building, gender_type, capacity, price, status, description)"
                   + " values (?, ?, ?, ?, ?, ?, ?)";
        return DBConnect.executeUpdate(sql, r.getRoomNumber(), r.getBuilding(), r.getGenderType(),
                r.getCapacity(), r.getPrice(), r.getStatus(), r.getDescription()) == 1;
    }

    public boolean updateRoom(Room r) {
        String sql = "update rooms set room_number=?, building=?, gender_type=?, capacity=?, price=?,"
                   + " status=?, description=? where id=?";
        return DBConnect.executeUpdate(sql, r.getRoomNumber(), r.getBuilding(), r.getGenderType(),
                r.getCapacity(), r.getPrice(), r.getStatus(), r.getDescription(), r.getId()) == 1;
    }

    public boolean deleteRoom(int id) {
        return DBConnect.executeUpdate("delete from rooms where id=?", id) == 1;
    }
}
```

> Mẹo `(?='' or r.building=?)`: nếu `building` rỗng thì vế đầu đúng → bỏ qua điều kiện lọc. Nhờ đó 1 câu SQL dùng được cho mọi kiểu lọc, không phải cộng chuỗi `where`.

### 3.5. `src/model/dao/RegistrationDAO.java`

Chú ý điều kiện `and status='pending'` trong `approve` / `reject`: nếu 2 admin cùng bấm duyệt 1 đơn, người thứ 2 sẽ cập nhật 0 dòng → hàm trả `false` → không bị duyệt 2 lần.

```java
package model.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import model.bean.Registration;

public class RegistrationDAO {
    private static final String SELECT_REG =
        "select g.*, u.full_name, u.student_code, r.room_number, r.building from registrations g"
      + " join users u on u.id = g.user_id join rooms r on r.id = g.room_id ";

    private Registration mapRegistration(ResultSet rs) throws SQLException {
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

    private ArrayList<Registration> query(String sql, Object... params) {
        ArrayList<Registration> result = new ArrayList<Registration>();
        try (Connection conn = DBConnect.getConnection()) {
            PreparedStatement pst = conn.prepareStatement(sql);
            DBConnect.setParams(pst, params);
            ResultSet rs = pst.executeQuery();
            while (rs.next()) result.add(mapRegistration(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    // don con hieu luc cua 1 sinh vien (toi da 1 don), khong co -> null
    public Registration getActiveRegistration(int userId) {
        ArrayList<Registration> list = query(SELECT_REG + "where g.user_id=? and (g.status='pending'"
            + " or (g.status='approved' and g.check_out_date >= curdate())) order by g.id desc limit 1", userId);
        return list.isEmpty() ? null : list.get(0);
    }

    // lich su don cua 1 sinh vien
    public ArrayList<Registration> getRegistrationsByUser(int userId) {
        return query(SELECT_REG + "where g.user_id=? order by g.created_at desc", userId);
    }

    // admin: loc theo trang thai, rong = tat ca
    public ArrayList<Registration> getRegistrationList(String status) {
        return query(SELECT_REG + "where (?='' or g.status=?) order by g.created_at desc", status, status);
    }

    public Registration getRegistrationById(int id) {
        ArrayList<Registration> list = query(SELECT_REG + "where g.id=?", id);
        return list.isEmpty() ? null : list.get(0);
    }

    public boolean insertRegistration(int userId, int roomId, String note) {
        return DBConnect.executeUpdate("insert into registrations (user_id, room_id, note) values (?, ?, ?)",
                                       userId, roomId, note) == 1;
    }

    public boolean approve(int id, LocalDate checkIn, LocalDate checkOut, String adminNote) {
        return DBConnect.executeUpdate("update registrations set status='approved', check_in_date=?,"
            + " check_out_date=?, admin_note=? where id=? and status='pending'",
            checkIn, checkOut, adminNote, id) == 1;
    }

    public boolean reject(int id, String adminNote) {
        return DBConnect.executeUpdate("update registrations set status='rejected', admin_note=?"
            + " where id=? and status='pending'", adminNote, id) == 1;
    }

    public boolean cancel(int id) {
        return DBConnect.executeUpdate("update registrations set status='cancelled'"
            + " where id=? and status in ('pending','approved')", id) == 1;
    }

    // dung de kiem tra truoc khi xoa user / phong (khoa ngoai ON DELETE RESTRICT)
    public int countByUser(int userId) {
        return DBConnect.count("select count(*) from registrations where user_id=?", userId);
    }

    public int countByRoom(int roomId) {
        return DBConnect.count("select count(*) from registrations where room_id=?", roomId);
    }

    public int countByStatus(String status) {
        return DBConnect.count("select count(*) from registrations where status=?", status);
    }
}
```

### 3.6. `src/model/dao/RequestDAO.java` — có **transaction**

Duyệt 1 yêu cầu phải sửa **2 bảng cùng lúc**: đánh dấu yêu cầu `approved` **và** đổi ngày trả phòng (hoặc hủy đơn). Nếu câu 1 chạy xong mà câu 2 lỗi thì dữ liệu sai lệch → phải bọc trong transaction: tắt auto-commit, chạy 2 câu, cùng thành công mới `commit()`, có lỗi thì `rollback()`.

```java
package model.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import model.bean.RegistrationRequest;

public class RequestDAO {
    private static final String SELECT_REQ =
        "select q.*, g.user_id, g.check_in_date, g.check_out_date, u.full_name, r.room_number"
      + " from registration_requests q join registrations g on g.id = q.registration_id"
      + " join users u on u.id = g.user_id join rooms r on r.id = g.room_id ";

    private RegistrationRequest mapRequest(ResultSet rs) throws SQLException {
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
```

### 3.7. `src/model/dao/PostDAO.java`

```java
package model.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import model.bean.Post;

public class PostDAO {
    private static final String SELECT_POST =
        "select p.*, u.full_name as author_name from posts p join users u on u.id = p.author_id ";

    private Post mapPost(ResultSet rs) throws SQLException {
        Post p = new Post();
        p.setId(rs.getInt("id"));
        p.setTitle(rs.getString("title"));
        p.setContent(rs.getString("content"));
        p.setCategory(rs.getString("category"));
        p.setImage(rs.getString("image"));
        p.setPublished(rs.getBoolean("is_published"));
        p.setAuthorId(rs.getInt("author_id"));
        p.setCreatedAt(DBConnect.getDateTime(rs, "created_at"));
        p.setAuthorName(rs.getString("author_name"));
        return p;
    }

    private ArrayList<Post> query(String sql, Object... params) {
        ArrayList<Post> result = new ArrayList<Post>();
        try (Connection conn = DBConnect.getConnection()) {
            PreparedStatement pst = conn.prepareStatement(sql);
            DBConnect.setParams(pst, params);
            ResultSet rs = pst.executeQuery();
            while (rs.next()) result.add(mapPost(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    // guest: chi bai da xuat ban; category rong = tat ca
    public ArrayList<Post> getPublishedPosts(String category) {
        return query(SELECT_POST + "where p.is_published = true and (?='' or p.category=?)"
                   + " order by p.created_at desc", category, category);
    }

    // admin: tat ca, ke ca ban nhap
    public ArrayList<Post> getAllPosts() {
        return query(SELECT_POST + "order by p.created_at desc");
    }

    public Post getPostById(int id) {
        ArrayList<Post> list = query(SELECT_POST + "where p.id=?", id);
        return list.isEmpty() ? null : list.get(0);
    }

    public boolean insertPost(Post p) {
        return DBConnect.executeUpdate("insert into posts (title, content, category, image, is_published, author_id)"
            + " values (?, ?, ?, ?, ?, ?)", p.getTitle(), p.getContent(), p.getCategory(), p.getImage(),
            p.isPublished(), p.getAuthorId()) == 1;
    }

    public boolean updatePost(Post p) {
        return DBConnect.executeUpdate("update posts set title=?, content=?, category=?, image=?, is_published=?"
            + " where id=?", p.getTitle(), p.getContent(), p.getCategory(), p.getImage(),
            p.isPublished(), p.getId()) == 1;
    }

    public boolean deletePost(int id) {
        return DBConnect.executeUpdate("delete from posts where id=?", id) == 1;
    }

    public int countByAuthor(int userId) {
        return DBConnect.count("select count(*) from posts where author_id=?", userId);
    }
}
```

---

## Bước 4 — BO (`model.bo`) — nơi chứa quy tắc nghiệp vụ

### 4.1. Quy tắc nghiệp vụ cần cài

Lấy từ chú thích trong `dormitory.sql`, cộng thêm những điều hiển nhiên phải chặn:

**Đơn "còn hiệu lực"** = `pending`, hoặc `approved` có `check_out_date >= hôm nay`.
**Chiếm chỗ** = `approved` có `check_out_date >= hôm nay` (đúng như view — kể cả đơn đã duyệt nhưng chưa đến ngày nhận phòng, tức là "đang giữ chỗ").

| # | Chức năng | Quy tắc | Hàm BO |
|---|---|---|---|
| R1 | SV đăng ký phòng | Không phải admin; đã khai giới tính; **chưa có đơn còn hiệu lực**; phòng tồn tại, `open`, **đúng giới tính**, `available > 0` | `RegistrationBO.registerRoom` |
| R2 | SV hủy đơn | Đơn của chính mình; `pending` → hủy luôn; `approved` chưa nhận phòng và còn ≥ 3 ngày → hủy luôn; còn < 3 ngày → phải gửi **yêu cầu cancel**; đã nhận phòng → phải gửi yêu cầu trả phòng | `RegistrationBO.cancelByUser` |
| R3 | Admin duyệt đơn | Đơn đang `pending`; có đủ 2 ngày, ngày trả > ngày nhận, ngày trả chưa qua; phòng vẫn `open` và **còn chỗ** (kiểm tra lại lúc duyệt) | `RegistrationBO.approve` |
| R4 | Admin từ chối đơn | Đơn đang `pending`; **bắt buộc nhập lý do** | `RegistrationBO.reject` |
| R5 | SV gửi yêu cầu | Đơn của mình, `approved`, còn hiệu lực; **chưa có yêu cầu nào đang chờ**; có lý do. `extend`: ngày mới > ngày trả hiện tại (tối đa +1 năm). `checkout`: đã nhận phòng, hôm nay ≤ ngày muốn trả < ngày trả hiện tại. `cancel`: chưa nhận phòng | `RequestBO.createRequest` |
| R6 | Admin duyệt yêu cầu | Yêu cầu đang `pending`; **kiểm tra lại R5** (tình hình có thể đã đổi); cập nhật 2 bảng trong 1 transaction | `RequestBO.approve` |
| R7 | Phòng | Số phòng không trùng; sức chứa 1–20; giá ≥ 0; sức chứa mới ≥ số người đang ở; phòng đang có người thì không đổi nam/nữ; phòng đã có đơn thì **không xóa** (chỉ đóng) | `RoomBO` |
| R8 | Tài khoản | Username/email/MSSV không trùng; mật khẩu ≥ 6 ký tự; không đổi giới tính khi đang có đơn; admin không tự xóa / tự hạ quyền mình; không xóa user đã có đơn hoặc đã viết bài | `UserBO` |
| R9 | Bài viết | Guest chỉ xem bài `is_published = true` | `PostBO` |

> Vì sao kiểm tra ở BO mà không chỉ dựa vào CSDL? CSDL có `CHECK`, `UNIQUE`, khóa ngoại, nhưng khi vi phạm thì chỉ ném `SQLException` khó hiểu. BO kiểm tra trước để trả về câu thông báo tiếng Việt rõ ràng; ràng buộc của CSDL là lớp bảo vệ cuối cùng.

### 4.2. `src/model/bo/UserBO.java`

```java
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
```

### 4.3. `src/model/bo/RoomBO.java`

```java
package model.bo;

import java.util.ArrayList;
import model.bean.Room;
import model.dao.RegistrationDAO;
import model.dao.RoomDAO;

public class RoomBO {
    RoomDAO roomDAO = new RoomDAO();
    RegistrationDAO registrationDAO = new RegistrationDAO();

    public ArrayList<Room> getRoomList(String building, String genderType, String status) {
        return roomDAO.getRoomList(building, genderType, status);
    }

    public ArrayList<Room> getAvailableRooms(String genderType) {
        if (genderType == null) return new ArrayList<Room>();     // chua khai gioi tinh -> khong co phong
        return roomDAO.getAvailableRooms(genderType);
    }

    public Room getRoomById(int id) { return roomDAO.getRoomById(id); }

    // id = 0: them moi, id > 0: sua. null = thanh cong
    public String saveRoom(Room r) {
        if (r.getRoomNumber().isEmpty() || r.getRoomNumber().length() > 10) return "Số phòng 1–10 ký tự!";
        if (r.getBuilding().isEmpty() || r.getBuilding().length() > 20) return "Tên tòa 1–20 ký tự!";
        if (!r.getGenderType().equals("male") && !r.getGenderType().equals("female")) return "Vui lòng chọn loại phòng nam/nữ!";
        if (r.getCapacity() < 1 || r.getCapacity() > 20) return "Sức chứa phải từ 1 đến 20!";
        if (r.getPrice() < 0) return "Giá phòng không hợp lệ!";
        if (!r.getStatus().equals("open") && !r.getStatus().equals("closed")) return "Trạng thái không hợp lệ!";
        if (roomDAO.isExistRoomNumber(r.getRoomNumber(), r.getId())) return "Số phòng " + r.getRoomNumber() + " đã tồn tại!";

        if (r.getId() == 0) {
            return roomDAO.insertRoom(r) ? null : "Thêm phòng thất bại!";
        }
        Room old = roomDAO.getRoomById(r.getId());
        if (old == null) return "Không tìm thấy phòng!";
        if (r.getCapacity() < old.getOccupied())
            return "Sức chứa không được nhỏ hơn số người đang ở (" + old.getOccupied() + ")!";
        if (old.getOccupied() > 0 && !old.getGenderType().equals(r.getGenderType()))
            return "Phòng đang có người ở, không thể đổi loại phòng nam/nữ!";
        return roomDAO.updateRoom(r) ? null : "Cập nhật phòng thất bại!";
    }

    public String deleteRoom(int id) {
        if (roomDAO.getRoomById(id) == null) return "Không tìm thấy phòng!";
        if (registrationDAO.countByRoom(id) > 0)
            return "Phòng đã có đơn đăng ký, không thể xóa. Hãy chuyển trạng thái sang Đóng.";
        return roomDAO.deleteRoom(id) ? null : "Xóa phòng thất bại!";
    }
}
```

### 4.4. `src/model/bo/RegistrationBO.java`

```java
package model.bo;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import model.bean.Registration;
import model.bean.Room;
import model.bean.User;
import model.dao.RegistrationDAO;
import model.dao.RequestDAO;
import model.dao.RoomDAO;

public class RegistrationBO {
    // con it hon so ngay nay truoc ngay nhan phong thi khong tu huy duoc, phai gui yeu cau 'cancel'
    public static final int CANCEL_DEADLINE_DAYS = 3;

    RegistrationDAO registrationDAO = new RegistrationDAO();
    RoomDAO roomDAO = new RoomDAO();
    RequestDAO requestDAO = new RequestDAO();

    public Registration getActiveRegistration(int userId) { return registrationDAO.getActiveRegistration(userId); }
    public ArrayList<Registration> getRegistrationsByUser(int userId) { return registrationDAO.getRegistrationsByUser(userId); }
    public ArrayList<Registration> getRegistrationList(String status) { return registrationDAO.getRegistrationList(status); }
    public Registration getRegistrationById(int id) { return registrationDAO.getRegistrationById(id); }
    public int countByStatus(String status) { return registrationDAO.countByStatus(status); }

    // JSP goi ham nay de biet hien nut "Huy don" (true) hay "Gui yeu cau huy" (false)
    public boolean canCancelDirectly(Registration reg) {
        if (reg == null) return false;
        if ("pending".equals(reg.getStatus())) return true;
        if ("approved".equals(reg.getStatus()) && reg.getCheckInDate() != null) {
            long days = ChronoUnit.DAYS.between(LocalDate.now(), reg.getCheckInDate());
            return days >= CANCEL_DEADLINE_DAYS;
        }
        return false;
    }

    // ===================== SINH VIEN =====================

    // R1: dang ky phong. null = thanh cong
    public String registerRoom(User user, int roomId, String note) {
        if (note == null) note = "";
        if (user.isAdmin()) return "Tài khoản admin không đăng ký phòng!";
        if (user.getGender() == null) return "Vui lòng cập nhật giới tính trong hồ sơ trước khi đăng ký phòng!";
        if (registrationDAO.getActiveRegistration(user.getId()) != null)
            return "Bạn đang có một đơn đăng ký còn hiệu lực, không thể đăng ký thêm!";
        Room room = roomDAO.getRoomById(roomId);
        if (room == null) return "Không tìm thấy phòng!";
        if (!"open".equals(room.getStatus())) return "Phòng " + room.getRoomNumber() + " đang tạm đóng!";
        if (!room.getGenderType().equals(user.getGender()))
            return "Phòng " + room.getRoomNumber() + " không dành cho giới tính của bạn!";
        if (room.getAvailable() <= 0) return "Phòng " + room.getRoomNumber() + " đã hết chỗ!";
        if (note.length() > 255) return "Ghi chú tối đa 255 ký tự!";
        if (!registrationDAO.insertRegistration(user.getId(), roomId, note.isEmpty() ? null : note))
            return "Đăng ký thất bại, vui lòng thử lại!";
        return null;
    }

    // R2: sinh vien tu huy don
    public String cancelByUser(User user, int registrationId) {
        Registration reg = registrationDAO.getRegistrationById(registrationId);
        if (reg == null || reg.getUserId() != user.getId()) return "Không tìm thấy đơn đăng ký!";
        LocalDate today = LocalDate.now();
        if (!reg.isActive(today)) return "Đơn này đã kết thúc, không thể hủy!";
        if ("approved".equals(reg.getStatus()) && !reg.getCheckInDate().isAfter(today))
            return "Bạn đã nhận phòng, hãy gửi yêu cầu trả phòng sớm thay vì hủy đơn!";
        if (!canCancelDirectly(reg))
            return "Còn dưới " + CANCEL_DEADLINE_DAYS + " ngày đến ngày nhận phòng, vui lòng gửi yêu cầu hủy để admin xét duyệt!";
        if (requestDAO.getPendingRequest(reg.getId()) != null)
            return "Đơn đang có yêu cầu chờ xử lý, không thể hủy lúc này!";
        if (!registrationDAO.cancel(reg.getId())) return "Hủy đơn thất bại, vui lòng thử lại!";
        return null;
    }

    // ===================== ADMIN =====================

    // R3: duyet don
    public String approve(int registrationId, LocalDate checkIn, LocalDate checkOut, String adminNote) {
        if (adminNote == null) adminNote = "";
        Registration reg = registrationDAO.getRegistrationById(registrationId);
        if (reg == null) return "Không tìm thấy đơn!";
        if (!"pending".equals(reg.getStatus())) return "Đơn này đã được xử lý!";
        if (checkIn == null || checkOut == null) return "Vui lòng nhập ngày nhận và ngày trả phòng!";
        if (!checkOut.isAfter(checkIn)) return "Ngày trả phòng phải sau ngày nhận phòng!";
        if (checkOut.isBefore(LocalDate.now())) return "Ngày trả phòng đã qua!";
        if (adminNote.length() > 255) return "Ghi chú tối đa 255 ký tự!";
        // kiem tra lai luc duyet: tu luc sinh vien gui don den gio phong co the da day / bi dong
        Room room = roomDAO.getRoomById(reg.getRoomId());
        if (!"open".equals(room.getStatus())) return "Phòng " + room.getRoomNumber() + " đang đóng, hãy từ chối đơn này!";
        if (room.getAvailable() <= 0) return "Phòng " + room.getRoomNumber() + " đã đủ người!";
        if (!registrationDAO.approve(registrationId, checkIn, checkOut, adminNote.isEmpty() ? null : adminNote))
            return "Duyệt thất bại (có thể đơn vừa được người khác xử lý)!";
        return null;
    }

    // R4: tu choi don, bat buoc co ly do
    public String reject(int registrationId, String adminNote) {
        if (adminNote == null || adminNote.trim().isEmpty()) return "Vui lòng nhập lý do từ chối!";
        if (adminNote.length() > 255) return "Lý do tối đa 255 ký tự!";
        Registration reg = registrationDAO.getRegistrationById(registrationId);
        if (reg == null) return "Không tìm thấy đơn!";
        if (!"pending".equals(reg.getStatus())) return "Đơn này đã được xử lý!";
        if (!registrationDAO.reject(registrationId, adminNote.trim())) return "Từ chối thất bại!";
        return null;
    }
}
```

> Hai admin cùng duyệt 2 đơn khác nhau vào **chỗ trống cuối cùng** của 1 phòng trong cùng 1 giây vẫn có thể lọt (cả 2 cùng thấy `available = 1`). Với bài tập thì chấp nhận được; muốn chặn tuyệt đối thì dùng transaction + `SELECT ... FOR UPDATE` khóa dòng phòng trước khi đếm.

### 4.5. `src/model/bo/RequestBO.java`

```java
package model.bo;

import java.time.LocalDate;
import java.util.ArrayList;
import model.bean.Registration;
import model.bean.RegistrationRequest;
import model.bean.User;
import model.dao.RegistrationDAO;
import model.dao.RequestDAO;

public class RequestBO {
    RequestDAO requestDAO = new RequestDAO();
    RegistrationDAO registrationDAO = new RegistrationDAO();

    public ArrayList<RegistrationRequest> getRequestList(String status) { return requestDAO.getRequestList(status); }
    public ArrayList<RegistrationRequest> getRequestsByRegistration(int registrationId) {
        return requestDAO.getRequestsByRegistration(registrationId);
    }
    public RegistrationRequest getPendingRequest(int registrationId) { return requestDAO.getPendingRequest(registrationId); }
    public int countByStatus(String status) { return requestDAO.countByStatus(status); }

    // R5: yeu cau co hop le voi don hien tai khong (dung ca luc sinh vien gui va luc admin duyet)
    private String checkRequest(Registration reg, String type, LocalDate date) {
        LocalDate today = LocalDate.now();
        if (reg == null || !"approved".equals(reg.getStatus()) || !reg.isActive(today))
            return "Chỉ gửi yêu cầu cho đơn đã duyệt và còn hiệu lực!";
        boolean daNhanPhong = !reg.getCheckInDate().isAfter(today);        // ngay nhan <= hom nay
        switch (type == null ? "" : type) {
            case "extend":
                if (date == null) return "Vui lòng chọn ngày trả phòng mới!";
                if (!date.isAfter(reg.getCheckOutDate()))
                    return "Ngày gia hạn phải sau ngày trả phòng hiện tại (" + reg.getCheckOutDate() + ")!";
                if (date.isAfter(reg.getCheckOutDate().plusYears(1))) return "Mỗi lần chỉ gia hạn tối đa 1 năm!";
                return null;
            case "checkout":
                if (!daNhanPhong) return "Bạn chưa nhận phòng, hãy dùng chức năng hủy đơn!";
                if (date == null) return "Vui lòng chọn ngày muốn trả phòng!";
                if (date.isBefore(today)) return "Ngày trả phòng không được ở quá khứ!";
                if (!date.isAfter(reg.getCheckInDate())) return "Ngày trả phòng phải sau ngày nhận phòng!";
                if (!date.isBefore(reg.getCheckOutDate()))
                    return "Ngày trả sớm phải trước ngày trả phòng hiện tại (" + reg.getCheckOutDate() + ")!";
                return null;
            case "cancel":
                if (daNhanPhong) return "Bạn đã nhận phòng, hãy gửi yêu cầu trả phòng sớm!";
                return null;
            default:
                return "Loại yêu cầu không hợp lệ!";
        }
    }

    // sinh vien gui yeu cau gia han / tra som / huy
    public String createRequest(User user, int registrationId, String type, LocalDate date, String reason) {
        if (reason == null) reason = "";
        reason = reason.trim();
        Registration reg = registrationDAO.getRegistrationById(registrationId);
        if (reg == null || reg.getUserId() != user.getId()) return "Không tìm thấy đơn đăng ký!";
        if (reason.isEmpty()) return "Vui lòng nhập lý do!";
        if (reason.length() > 255) return "Lý do tối đa 255 ký tự!";
        if (requestDAO.getPendingRequest(registrationId) != null)
            return "Bạn đang có một yêu cầu chờ xử lý, vui lòng đợi admin phản hồi!";
        String loi = checkRequest(reg, type, date);
        if (loi != null) return loi;
        if ("cancel".equals(type)) date = null;                            // huy thi khong luu ngay
        if (!requestDAO.insertRequest(registrationId, type, date, reason)) return "Gửi yêu cầu thất bại, vui lòng thử lại!";
        return null;
    }

    // R6: admin duyet
    public String approve(int requestId, String adminNote) {
        if (adminNote == null) adminNote = "";
        adminNote = adminNote.trim();
        if (adminNote.length() > 255) return "Ghi chú tối đa 255 ký tự!";
        RegistrationRequest q = requestDAO.getRequestById(requestId);
        if (q == null) return "Không tìm thấy yêu cầu!";
        if (!"pending".equals(q.getStatus())) return "Yêu cầu này đã được xử lý!";
        Registration reg = registrationDAO.getRegistrationById(q.getRegistrationId());
        String loi = checkRequest(reg, q.getType(), q.getRequestedDate());
        if (loi != null) return "Không thể duyệt: " + loi;
        if (!requestDAO.approve(q, adminNote.isEmpty() ? null : adminNote)) return "Duyệt thất bại, vui lòng thử lại!";
        return null;
    }

    public String reject(int requestId, String adminNote) {
        if (adminNote == null || adminNote.trim().isEmpty()) return "Vui lòng nhập lý do từ chối!";
        if (adminNote.length() > 255) return "Lý do tối đa 255 ký tự!";
        RegistrationRequest q = requestDAO.getRequestById(requestId);
        if (q == null) return "Không tìm thấy yêu cầu!";
        if (!"pending".equals(q.getStatus())) return "Yêu cầu này đã được xử lý!";
        if (!requestDAO.reject(requestId, adminNote.trim())) return "Từ chối thất bại!";
        return null;
    }
}
```

### 4.6. `src/model/bo/PostBO.java`

```java
package model.bo;

import java.util.ArrayList;
import model.bean.Post;
import model.dao.PostDAO;

public class PostBO {
    PostDAO postDAO = new PostDAO();

    public ArrayList<Post> getPublishedPosts(String category) { return postDAO.getPublishedPosts(category); }
    public ArrayList<Post> getAllPosts() { return postDAO.getAllPosts(); }
    public Post getPostById(int id) { return postDAO.getPostById(id); }

    // guest xem chi tiet: bai nhap coi nhu khong ton tai
    public Post getPublishedPost(int id) {
        Post p = postDAO.getPostById(id);
        return (p != null && p.isPublished()) ? p : null;
    }

    public String savePost(Post p) {
        if (p.getTitle().isEmpty() || p.getTitle().length() > 200) return "Tiêu đề 1–200 ký tự!";
        if (p.getContent().isEmpty()) return "Vui lòng nhập nội dung!";
        if (!p.getCategory().equals("news") && !p.getCategory().equals("notice") && !p.getCategory().equals("rule"))
            return "Chuyên mục không hợp lệ!";
        if (p.getId() == 0) return postDAO.insertPost(p) ? null : "Thêm bài thất bại!";
        if (postDAO.getPostById(p.getId()) == null) return "Không tìm thấy bài viết!";
        return postDAO.updatePost(p) ? null : "Cập nhật bài thất bại!";
    }

    public String deletePost(int id) {
        if (postDAO.getPostById(id) == null) return "Không tìm thấy bài viết!";
        return postDAO.deletePost(id) ? null : "Xóa bài thất bại!";
    }
}
```

---

## Bước 5 — Filter (thay cho đoạn "chưa đăng nhập thì về login" ở đầu mỗi Servlet)

Ở BTHS4, Servlet nào cũng mở đầu bằng:

```text
String userName = (String) session.getAttribute("userName");
if(userName == null){ response.sendRedirect("login.jsp"); return; }
int roles = userBO.getRoles(userName);   // doc lai quyen tu CSDL
```

KTX có ~15 Servlet → đưa đoạn này vào 1 **Filter**. Filter chạy **trước** mọi Servlet/JSP có URL khớp mẫu. Quy ước URL:

| Tiền tố URL | Ai được vào |
|---|---|
| `/LoginServlet`, `/HomeServlet`, … (không tiền tố) | Tất cả (guest) |
| `/account/*` | Đã đăng nhập (cả user và admin) — vd trang hồ sơ |
| `/user/*` | Chỉ sinh viên |
| `/admin/*` | Chỉ admin |

Filter này cũng bảo vệ luôn các file JSP nằm trong thư mục `WebContent/user/` và `WebContent/admin/` (vì URL của chúng cũng bắt đầu bằng `/user/`, `/admin/`).

### `src/controller/EncodingFilter.java`

Thay cho `request.setCharacterEncoding("UTF-8")` đầu mỗi `doPost` — quên dòng này là tiếng Việt từ form bị lỗi font.

```java
package controller;

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;

@WebFilter("/*")
public class EncodingFilter implements Filter {
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        chain.doFilter(request, response);       // cho di tiep toi Servlet / JSP
    }
}
```

### `src/controller/AuthFilter.java`

```java
package controller;

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.bean.User;
import model.bo.UserBO;
import util.WebUtil;

@WebFilter({"/user/*", "/admin/*", "/account/*"})
public class AuthFilter implements Filter {
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        // 1. chua dang nhap -> ve trang login
        HttpSession session = request.getSession(false);
        Integer userId = (session == null) ? null : (Integer) session.getAttribute("userId");
        if (userId == null) {
            WebUtil.redirect(request, response, "/LoginServlet", "loi", "Vui lòng đăng nhập!");
            return;
        }

        // 2. doc lai user tu CSDL moi lan (vua bi xoa / doi quyen thi biet ngay - giong y tuong cua thay)
        User user = new UserBO().getUserById(userId);
        if (user == null) {
            session.invalidate();
            WebUtil.redirect(request, response, "/LoginServlet", "loi", "Tài khoản không còn tồn tại!");
            return;
        }

        // 3. phan quyen theo tien to URL
        String path = request.getServletPath();
        if (path.startsWith("/admin/") && !user.isAdmin()) {
            WebUtil.redirect(request, response, "/user/RegistrationServlet", "loi", "Bạn không có quyền vào trang quản trị!");
            return;
        }
        if (path.startsWith("/user/") && user.isAdmin()) {
            WebUtil.redirect(request, response, "/admin/DashboardServlet", null, null);
            return;
        }

        // 4. hop le: gui user hien tai cho Servlet / JSP dung
        request.setAttribute("currentUser", user);
        chain.doFilter(req, res);
    }
}
```

Từ đây, trong mọi Servlet ở `/user/*`, `/admin/*`, `/account/*` chỉ cần:

```text
User user = (User) request.getAttribute("currentUser");
```

---

## Bước 6 — Controller (Servlet)

### 6.1. Khuôn mẫu chung (giống thầy)

- `@WebServlet("/duong-dan")` + `extends HttpServlet` + `serialVersionUID`.
- **`doGet`** = chỉ **xem** (hiện danh sách, mở form). Không sửa dữ liệu trong `doGet`.
- **`doPost`** = **thay đổi** dữ liệu (thêm/sửa/xóa/duyệt). Form dùng `method="post"`. (BTHS4 xóa bằng link GET; ở KTX nên dùng form POST để không bị xóa nhầm khi trình duyệt tải trước link.)
- 1 Servlet phụ trách 1 đối tượng, phân biệt thao tác bằng tham số `action` (`add`, `edit`, `save`, `delete`, `approve`, `reject`…) — thay vì 1 Servlet cho mỗi thao tác như BTHS4 (Search/Update/Delete), để số file không quá nhiều.
- Xử lý xong `doPost` → **redirect** (không forward) kèm `thongbao` → tránh việc bấm F5 gửi lại form (mô hình Post/Redirect/Get, thầy đã dùng ở `DeleteServlet`, `UpdateServlet`).
- Form nhập sai → **forward** lại JSP kèm dữ liệu vừa nhập để không phải gõ lại (như `RegisterServlet` của thầy).

### 6.2. Danh sách Servlet

| URL | Class | GET | POST (`action`) | JSP |
|---|---|---|---|---|
| `/HomeServlet` | `HomeServlet` | Bài đã xuất bản, lọc `category` | – | `/guest/index.jsp` |
| `/PostServlet?id=` | `PostServlet` | Chi tiết 1 bài (`PostBO.getPublishedPost`) | – | `/guest/post.jsp` |
| `/RoomListServlet` | `RoomListServlet` | Danh sách phòng đang mở cho khách xem | – | `/guest/rooms.jsp` |
| `/LoginServlet` | `LoginServlet` | Form đăng nhập | Kiểm tra đăng nhập | `/guest/login.jsp` |
| `/SignupServlet` | `SignupServlet` | Form đăng ký tài khoản | `UserBO.signup` | `/guest/signup.jsp` |
| `/LogoutServlet` | `LogoutServlet` | Xóa session | – | – |
| `/account/ProfileServlet` | `ProfileServlet` | Hồ sơ của mình | `save`, `password` | `/account/profile.jsp` |
| `/user/RoomServlet` | `UserRoomServlet` | Phòng đăng ký được | `register` | `/user/rooms.jsp` |
| `/user/RegistrationServlet` | `UserRegistrationServlet` | Đơn hiện tại + lịch sử + yêu cầu | `cancel`, `request` | `/user/my-registration.jsp` |
| `/admin/DashboardServlet` | `DashboardServlet` | Số đơn/yêu cầu chờ, tổng chỗ trống | – | `/admin/dashboard.jsp` |
| `/admin/RoomServlet` | `AdminRoomServlet` | Danh sách / form `add`, `edit` | `save`, `delete` | `/admin/rooms.jsp`, `/admin/room-form.jsp` |
| `/admin/RegistrationServlet` | `AdminRegistrationServlet` | Danh sách đơn, lọc `status` | `approve`, `reject` | `/admin/registrations.jsp` |
| `/admin/RequestServlet` | `AdminRequestServlet` | Danh sách yêu cầu, lọc `status` | `approve`, `reject` | `/admin/requests.jsp` |
| `/admin/UserServlet` | `AdminUserServlet` | Tìm tài khoản `keyword` | `role`, `delete` | `/admin/users.jsp` |
| `/admin/PostServlet` | `AdminPostServlet` | Danh sách / form `add`, `edit` | `save`, `delete` | `/admin/posts.jsp`, `/admin/post-form.jsp` |

Dưới đây là code đầy đủ của các Servlet tiêu biểu; những Servlet còn lại viết theo đúng khuôn của Servlet cùng loại (ghi trong cột cuối của bảng ở mục 6.12).

### 6.3. `src/controller/LoginServlet.java`

```java
package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.bean.User;
import model.bo.UserBO;
import util.WebUtil;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/guest/login.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = WebUtil.trim(request.getParameter("username"));
        String password = request.getParameter("password");
        User user = new UserBO().login(username, password);

        if (user == null) {
            // sai: quay lai form, giu lai username da go
            request.setAttribute("thongbao", "Sai tên đăng nhập hoặc mật khẩu!");
            request.setAttribute("username", username);
            request.getRequestDispatcher("/guest/login.jsp").forward(request, response);
            return;
        }
        // dung: xoa session cu, tao session moi (giong CheckLoginServlet cua thay)
        request.getSession().invalidate();
        HttpSession session = request.getSession();
        session.setAttribute("userId", user.getId());          // chi luu id, quyen doc lai o AuthFilter
        session.setAttribute("fullName", user.getFullName());  // de header trang guest chao ten

        if (user.isAdmin()) WebUtil.redirect(request, response, "/admin/DashboardServlet", null, null);
        else WebUtil.redirect(request, response, "/user/RegistrationServlet", null, null);
    }
}
```

### 6.4. `src/controller/LogoutServlet.java`

```java
package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.WebUtil;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getSession().invalidate();
        WebUtil.redirect(request, response, "/HomeServlet", null, null);
    }
}
```

### 6.5. `src/controller/UserRoomServlet.java` — sinh viên xem phòng & đăng ký

```java
package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.bean.User;
import model.bo.RegistrationBO;
import model.bo.RoomBO;
import util.WebUtil;

@WebServlet("/user/RoomServlet")
public class UserRoomServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getAttribute("currentUser");
        request.setAttribute("roomList", new RoomBO().getAvailableRooms(user.getGender()));
        // co don hieu luc roi thi JSP an nut "Dang ky"
        request.setAttribute("activeRegistration", new RegistrationBO().getActiveRegistration(user.getId()));
        request.getRequestDispatcher("/user/rooms.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getAttribute("currentUser");
        int roomId = WebUtil.toInt(request.getParameter("roomId"));
        String note = WebUtil.trim(request.getParameter("note"));

        String loi = new RegistrationBO().registerRoom(user, roomId, note);
        if (loi == null)
            WebUtil.redirect(request, response, "/user/RegistrationServlet", "ok", "Đã gửi đơn đăng ký, vui lòng chờ admin duyệt!");
        else
            WebUtil.redirect(request, response, "/user/RoomServlet", "loi", loi);
    }
}
```

### 6.6. `src/controller/UserRegistrationServlet.java` — đơn của tôi, hủy, gửi yêu cầu

```java
package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.bean.Registration;
import model.bean.User;
import model.bo.RegistrationBO;
import model.bo.RequestBO;
import util.WebUtil;

@WebServlet("/user/RegistrationServlet")
public class UserRegistrationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getAttribute("currentUser");
        RegistrationBO registrationBO = new RegistrationBO();
        RequestBO requestBO = new RequestBO();

        Registration active = registrationBO.getActiveRegistration(user.getId());
        request.setAttribute("activeRegistration", active);
        request.setAttribute("history", registrationBO.getRegistrationsByUser(user.getId()));
        if (active != null) {
            request.setAttribute("canCancel", registrationBO.canCancelDirectly(active));
            request.setAttribute("requestList", requestBO.getRequestsByRegistration(active.getId()));
            request.setAttribute("pendingRequest", requestBO.getPendingRequest(active.getId()));
        }
        request.getRequestDispatcher("/user/my-registration.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getAttribute("currentUser");
        String action = WebUtil.trim(request.getParameter("action"));
        int registrationId = WebUtil.toInt(request.getParameter("registrationId"));
        String loi;
        String thanhcong;

        if (action.equals("cancel")) {
            loi = new RegistrationBO().cancelByUser(user, registrationId);
            thanhcong = "Đã hủy đơn đăng ký!";
        } else if (action.equals("request")) {
            loi = new RequestBO().createRequest(user, registrationId,
                    request.getParameter("type"),
                    WebUtil.toDate(request.getParameter("requestedDate")),
                    request.getParameter("reason"));
            thanhcong = "Đã gửi yêu cầu, vui lòng chờ admin phản hồi!";
        } else {
            loi = "Thao tác không hợp lệ!";
            thanhcong = null;
        }

        if (loi == null) WebUtil.redirect(request, response, "/user/RegistrationServlet", "ok", thanhcong);
        else WebUtil.redirect(request, response, "/user/RegistrationServlet", "loi", loi);
    }
}
```

### 6.7. `src/controller/AdminRegistrationServlet.java` — admin duyệt / từ chối đơn

```java
package controller;

import java.io.IOException;
import java.net.URLEncoder;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.bo.RegistrationBO;
import util.WebUtil;

@WebServlet("/admin/RegistrationServlet")
public class AdminRegistrationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // mac dinh hien don dang cho duyet; status = "" -> tat ca
        String status = request.getParameter("status");
        if (status == null) status = "pending";
        request.setAttribute("status", status);
        request.setAttribute("registrationList", new RegistrationBO().getRegistrationList(status));
        request.getRequestDispatcher("/admin/registrations.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RegistrationBO registrationBO = new RegistrationBO();
        String action = WebUtil.trim(request.getParameter("action"));
        int id = WebUtil.toInt(request.getParameter("id"));
        String adminNote = WebUtil.trim(request.getParameter("adminNote"));
        // quay ve dung bo loc dang xem
        String back = "/admin/RegistrationServlet?status="
                    + URLEncoder.encode(WebUtil.trim(request.getParameter("status")), "UTF-8");

        String loi;
        if (action.equals("approve")) {
            loi = registrationBO.approve(id,
                    WebUtil.toDate(request.getParameter("checkInDate")),
                    WebUtil.toDate(request.getParameter("checkOutDate")),
                    adminNote);
        } else if (action.equals("reject")) {
            loi = registrationBO.reject(id, adminNote);
        } else {
            loi = "Thao tác không hợp lệ!";
        }

        if (loi == null) WebUtil.redirect(request, response, back, "ok",
                action.equals("approve") ? "Đã duyệt đơn #" + id : "Đã từ chối đơn #" + id);
        else WebUtil.redirect(request, response, back, "loi", loi);
    }
}
```

### 6.8. `src/controller/AdminRequestServlet.java`

```java
package controller;

import java.io.IOException;
import java.net.URLEncoder;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.bo.RequestBO;
import util.WebUtil;

@WebServlet("/admin/RequestServlet")
public class AdminRequestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String status = request.getParameter("status");
        if (status == null) status = "pending";
        request.setAttribute("status", status);
        request.setAttribute("requestList", new RequestBO().getRequestList(status));
        request.getRequestDispatcher("/admin/requests.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestBO requestBO = new RequestBO();
        String action = WebUtil.trim(request.getParameter("action"));
        int id = WebUtil.toInt(request.getParameter("id"));
        String adminNote = WebUtil.trim(request.getParameter("adminNote"));
        String back = "/admin/RequestServlet?status="
                    + URLEncoder.encode(WebUtil.trim(request.getParameter("status")), "UTF-8");

        String loi;
        if (action.equals("approve")) loi = requestBO.approve(id, adminNote);
        else if (action.equals("reject")) loi = requestBO.reject(id, adminNote);
        else loi = "Thao tác không hợp lệ!";

        if (loi == null) WebUtil.redirect(request, response, back, "ok", "Đã xử lý yêu cầu #" + id);
        else WebUtil.redirect(request, response, back, "loi", loi);
    }
}
```

### 6.9. `src/controller/AdminRoomServlet.java` — mẫu CRUD đầy đủ

Đây là khuôn cho mọi trang quản lý dạng "danh sách + form thêm/sửa + xóa" (`AdminPostServlet` viết y hệt, thay `Room` bằng `Post`).

```java
package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.bean.Room;
import model.bo.RoomBO;
import util.WebUtil;

@WebServlet("/admin/RoomServlet")
public class AdminRoomServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // GET: ?action=add | ?action=edit&id=.. | khong co action = danh sach
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RoomBO roomBO = new RoomBO();
        String action = WebUtil.trim(request.getParameter("action"));

        if (action.equals("add") || action.equals("edit")) {
            Room room = new Room();                             // them moi: form trong
            room.setStatus("open");
            if (action.equals("edit")) {
                room = roomBO.getRoomById(WebUtil.toInt(request.getParameter("id")));
                if (room == null) {
                    WebUtil.redirect(request, response, "/admin/RoomServlet", "loi", "Không tìm thấy phòng!");
                    return;
                }
            }
            request.setAttribute("room", room);
            request.getRequestDispatcher("/admin/room-form.jsp").forward(request, response);
            return;
        }

        request.setAttribute("roomList", roomBO.getRoomList(
                WebUtil.trim(request.getParameter("building")),
                WebUtil.trim(request.getParameter("genderType")),
                WebUtil.trim(request.getParameter("status"))));
        request.getRequestDispatcher("/admin/rooms.jsp").forward(request, response);
    }

    // POST: action=save (them/sua) | action=delete
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RoomBO roomBO = new RoomBO();
        String action = WebUtil.trim(request.getParameter("action"));

        if (action.equals("delete")) {
            String loi = roomBO.deleteRoom(WebUtil.toInt(request.getParameter("id")));
            if (loi == null) WebUtil.redirect(request, response, "/admin/RoomServlet", "ok", "Đã xóa phòng!");
            else WebUtil.redirect(request, response, "/admin/RoomServlet", "loi", loi);
            return;
        }

        // save: gom du lieu form vao 1 doi tuong Room (giong RegisterServlet cua thay)
        Room room = new Room();
        room.setId(WebUtil.toInt(request.getParameter("id")));          // input hidden, 0 = them moi
        room.setRoomNumber(WebUtil.trim(request.getParameter("roomNumber")).toUpperCase());
        room.setBuilding(WebUtil.trim(request.getParameter("building")));
        room.setGenderType(WebUtil.trim(request.getParameter("genderType")));
        room.setCapacity(WebUtil.toInt(request.getParameter("capacity")));
        room.setPrice(WebUtil.toLong(request.getParameter("price")));
        room.setStatus(WebUtil.trim(request.getParameter("status")));
        room.setDescription(WebUtil.trim(request.getParameter("description")));

        String loi = roomBO.saveRoom(room);
        if (loi != null) {
            // loi: quay lai form, giu nguyen du lieu da nhap
            request.setAttribute("thongbao", loi);
            request.setAttribute("room", room);
            request.getRequestDispatcher("/admin/room-form.jsp").forward(request, response);
            return;
        }
        WebUtil.redirect(request, response, "/admin/RoomServlet", "ok",
                room.getId() == 0 ? "Đã thêm phòng " + room.getRoomNumber() : "Đã cập nhật phòng " + room.getRoomNumber());
    }
}
```

### 6.10. `src/controller/DashboardServlet.java`

```java
package controller;

import java.io.IOException;
import java.util.ArrayList;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.bean.Room;
import model.bo.RegistrationBO;
import model.bo.RequestBO;
import model.bo.RoomBO;

@WebServlet("/admin/DashboardServlet")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ArrayList<Room> rooms = new RoomBO().getRoomList("", "", "");
        int totalBeds = 0, occupied = 0;
        for (Room r : rooms) {
            totalBeds += r.getCapacity();
            occupied += r.getOccupied();
        }
        request.setAttribute("roomCount", rooms.size());
        request.setAttribute("totalBeds", totalBeds);
        request.setAttribute("occupied", occupied);
        request.setAttribute("pendingRegistrations", new RegistrationBO().countByStatus("pending"));
        request.setAttribute("pendingRequests", new RequestBO().countByStatus("pending"));
        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }
}
```

### 6.11. `src/controller/HomeServlet.java` — trang chủ cho guest

```java
package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.bo.PostBO;
import util.WebUtil;

@WebServlet("/HomeServlet")
public class HomeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String category = WebUtil.trim(request.getParameter("category"));   // "" = tat ca
        request.setAttribute("category", category);
        request.setAttribute("postList", new PostBO().getPublishedPosts(category));
        request.getRequestDispatcher("/guest/index.jsp").forward(request, response);
    }
}
```

### 6.12. Các Servlet còn lại — tự viết theo khuôn

| Servlet | Viết giống | Ghi chú |
|---|---|---|
| `PostServlet` | `HomeServlet` | `PostBO.getPublishedPost(id)`; `null` → redirect `/HomeServlet` kèm lỗi "Không tìm thấy bài viết" |
| `RoomListServlet` | `HomeServlet` | `RoomBO.getRoomList("", "", "open")` |
| `SignupServlet` | `LoginServlet` + phần "save" của `AdminRoomServlet` | Gom form vào `User` (`username`, `fullName`, `email`, `phone`, `gender`, `studentCode`), gọi `UserBO.signup(user, password, confirm)`; lỗi → forward lại form kèm `user`; đúng → redirect `/LoginServlet` "Đăng ký thành công". `gender` rỗng thì `setGender(null)` |
| `ProfileServlet` (`/account/ProfileServlet`) | `UserRegistrationServlet` | GET: `currentUser` → JSP. POST `action=save` → `UserBO.updateProfile(currentUser, formUser)`; `action=password` → `UserBO.changePassword(...)`. Nhớ cập nhật `session.fullName` sau khi đổi tên |
| `AdminUserServlet` | `AdminRequestServlet` | GET: `UserBO.getUserList(keyword)`. POST `action=role` → `changeRole(currentUser, id, role)`; `action=delete` → `deleteUser(currentUser, id)` |
| `AdminPostServlet` | `AdminRoomServlet` | Gom form vào `Post`; `authorId` = `currentUser.getId()` khi thêm mới; checkbox `published`: `"on".equals(request.getParameter("published"))` |

> **Upload ảnh bài viết** (không bắt buộc): thêm `@MultipartConfig` lên `AdminPostServlet`, form dùng `enctype="multipart/form-data"`, đọc file bằng `request.getPart("image")`, lưu vào `getServletContext().getRealPath("/assets/images/uploads")` với tên mới (vd `System.currentTimeMillis() + ".jpg"`), chỉ nhận đuôi `.jpg/.png/.webp`. Thư mục `uploads/` đã được `.gitignore`.

---

## Bước 7 — "Hợp đồng" giữa Servlet và JSP

Phần backend xong khi mỗi JSP biết **nhận gì** và **gửi gì**. Bảng này để bạn (hoặc bạn cùng nhóm làm giao diện) viết JSP khớp tên:

| JSP | Nhận (`request.getAttribute`) | Form gửi về (`name=`) |
|---|---|---|
| `guest/login.jsp` | `thongbao`, `username`; param `thongbao`, `loai` | `username`, `password` → POST `/LoginServlet` |
| `user/rooms.jsp` | `currentUser`, `roomList` (`ArrayList<Room>`), `activeRegistration` | `roomId`, `note` → POST `/user/RoomServlet` |
| `user/my-registration.jsp` | `activeRegistration`, `history`, `canCancel` (`Boolean`), `requestList`, `pendingRequest` | `action=cancel`, `registrationId` · hoặc `action=request`, `registrationId`, `type` (`extend`/`checkout`/`cancel`), `requestedDate` (`type="date"`), `reason` |
| `admin/registrations.jsp` | `status`, `registrationList` | `action=approve|reject`, `id`, `status`, `checkInDate`, `checkOutDate`, `adminNote` |
| `admin/requests.jsp` | `status`, `requestList` | `action=approve|reject`, `id`, `status`, `adminNote` |
| `admin/rooms.jsp` | `roomList` | `action=delete`, `id` |
| `admin/room-form.jsp` | `room`, `thongbao` | `action=save`, `id` (hidden), `roomNumber`, `building`, `genderType`, `capacity`, `price`, `status`, `description` |
| `admin/dashboard.jsp` | `roomCount`, `totalBeds`, `occupied`, `pendingRegistrations`, `pendingRequests` | – |

Mọi trang đọc thông báo sau redirect giống `search.jsp` của thầy:

```jsp
<%
    String thongbao = request.getParameter("thongbao");
    if (thongbao == null) thongbao = (String) request.getAttribute("thongbao");
    String loai = request.getParameter("loai");
    if (thongbao != null) {
%>
    <p style="color:<%= "ok".equals(loai) ? "green" : "red" %>"><b><%= HtmlUtil.esc(thongbao) %></b></p>
<% } %>
```

Link/action trong JSP luôn có context path, vì JSP nằm trong thư mục con:

```jsp
<form action="<%= request.getContextPath() %>/admin/RoomServlet" method="post">
<link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
```

---

## Bước 8 — Biên dịch, chạy, kiểm thử

1. Chạy `build.bat` → phải thấy `=== Bien dich xong ===`.
2. VS Code: chuột phải server Tomcat 10.x → *Publish Server (Full)* → Stop/Start.
3. Mở `http://localhost:8080/Website_KTX/HomeServlet`.

Kiểm thử theo dữ liệu demo (mật khẩu đều là `123456`, mốc "hôm nay" trong dữ liệu = 27/11/2026):

| Tài khoản | Làm gì | Kết quả đúng |
|---|---|---|
| `admin` / sai mật khẩu | Đăng nhập | "Sai tên đăng nhập hoặc mật khẩu!" |
| `sv001` | Vào `/admin/RoomServlet` | Bị đẩy về trang đơn của tôi, báo "không có quyền" |
| `sv001` (An) | Gửi thêm yêu cầu gia hạn | "Bạn đang có một yêu cầu chờ xử lý…" (đã có yêu cầu #4) |
| `sv003` (Cường) | Đăng ký phòng khác | "Bạn đang có một đơn đăng ký còn hiệu lực…" (đơn #4 giữ chỗ A102) |
| `sv003` | Hủy đơn #4 | Thành công (còn > 3 ngày đến 10/01/2027) |
| `sv004` (Dung, nữ) | Xem `/user/RoomServlet` | Chỉ thấy B101 (B102 đóng, A101/A102 là phòng nam) → đăng ký được |
| `sv005` (Hùng) | Đăng ký phòng | Bị chặn: đã có đơn #7 đang `pending` |
| `admin` | Duyệt đơn #7 (Hùng) vào A101, 01/12/2026 → 30/06/2027 | Thành công, A101 còn 2 chỗ |
| `admin` | Từ chối đơn mà để trống lý do | "Vui lòng nhập lý do từ chối!" |
| `admin` | Duyệt yêu cầu #4 (An gia hạn) | Đơn #1 đổi `check_out_date` thành 30/06/2027 (kiểm tra trong phpMyAdmin) |
| `admin` | Xóa phòng A101 | "Phòng đã có đơn đăng ký, không thể xóa…" |
| `admin` | (sau khi duyệt đơn Hùng, A101 có 2 người) Sửa A101 sức chứa = 1 | "Sức chứa không được nhỏ hơn số người đang ở (2)!" |
| `admin` | Xóa tài khoản chính mình | "Không thể xóa tài khoản của chính mình!" |
| guest | `/PostServlet?id=4` (bài nháp) | Không xem được |

---

## Lỗi thường gặp

| Lỗi | Nguyên nhân / cách sửa |
|---|---|
| `UnsupportedClassVersionError` | Biên dịch bằng JDK mới hơn JDK của Tomcat → dùng đúng `jdk-21` như `build.bat` và `.vscode/settings.json` |
| `package javax.servlet does not exist` | Tomcat 10 dùng `jakarta.servlet`, sửa lại `import` |
| `ClassNotFoundException: com.mysql.cj.jdbc.Driver` | Thiếu `mysql-connector-j-8.4.0.jar` trong `WebContent/WEB-INF/lib` |
| `file not found: src\...\*.java` khi build | Thư mục đó chưa có file `.java` nào |
| 404 khi mở Servlet | Chưa chạy `build.bat` / chưa Publish + restart; sai chữ hoa–thường trong `@WebServlet` |
| Sửa code mà web không đổi | Phải build + Publish + restart Tomcat sau **mỗi** lần sửa `.java` |
| Tiếng Việt từ form thành `Ã¡…` | Thiếu `EncodingFilter`; JSP thiếu `pageEncoding="UTF-8"` |
| Tiếng Việt từ CSDL thành `???` | URL JDBC thiếu `characterEncoding=UTF-8`, hoặc CSDL không phải `utf8mb4` |
| `NullPointerException` khi mở thẳng file JSP | JSP phải mở qua Servlet (Servlet mới `setAttribute` dữ liệu) |
| `Check constraint ... is violated` trong log | BO thiếu một bước kiểm tra → bổ sung vào BO |
| Đăng nhập đúng `123456` mà vẫn báo sai | Chưa chạy `UPDATE users SET password = SHA2('123456', 256);` |
| Đơn "hết hạn" sai ngày | Giờ máy chạy MySQL khác giờ máy chạy Tomcat (chỉ xảy ra khi MySQL ở máy khác) → thêm `&serverTimezone=Asia/Ho_Chi_Minh` vào cuối URL trong `DBConnect` |
