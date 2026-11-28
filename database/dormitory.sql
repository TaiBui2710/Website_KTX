-- =====================================================================
--  HỆ THỐNG ĐĂNG KÝ PHÒNG KÝ TÚC XÁ
--  CSDL: MySQL 8.0.16+ (cần hỗ trợ CHECK và generated column)
--  Gồm 6 bảng: users, rooms, registrations, registration_requests, posts, feedbacks
--  + 1 view: v_room_occupancy (số người đang ở / chỗ trống của mỗi phòng)
--
--  Tài khoản demo: mật khẩu tất cả là 123456
--    admin  | sv001 (An) | sv002 (Bình) | sv003 (Cường) | sv004 (Dung) | sv005 (Hùng)
--  Dữ liệu demo lấy mốc "hôm nay" = 27/11/2026
-- =====================================================================

DROP DATABASE IF EXISTS dormitory;
CREATE DATABASE dormitory CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE dormitory;

-- ---------------------------------------------------------------------
-- 1. USERS: tài khoản + hồ sơ (admin và sinh viên)
-- ---------------------------------------------------------------------
CREATE TABLE users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    password      VARCHAR(255) NOT NULL,                       -- password_hash()
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    phone         VARCHAR(15),
    gender        ENUM('male','female') NULL,                  -- admin có thể để trống
    student_code  VARCHAR(20)  NULL UNIQUE,                    -- MSSV, admin để trống
    role          ENUM('user','admin') NOT NULL DEFAULT 'user',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. ROOMS: phòng ở
--    Không lưu số người đang ở (thuộc tính dẫn xuất) -> xem view bên dưới
-- ---------------------------------------------------------------------
CREATE TABLE rooms (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    room_number   VARCHAR(10)  NOT NULL UNIQUE,
    building      VARCHAR(20)  NOT NULL,
    gender_type   ENUM('male','female') NOT NULL,
    capacity      TINYINT UNSIGNED NOT NULL,
    price         DECIMAL(12,0) NOT NULL DEFAULT 0,             -- giá / tháng (VNĐ)
    status        ENUM('open','closed') NOT NULL DEFAULT 'open',
    description   TEXT,
    CONSTRAINT chk_rooms_capacity CHECK (capacity > 0),
    CONSTRAINT chk_rooms_price    CHECK (price >= 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. REGISTRATIONS: đơn đăng ký phòng (mỗi đơn = một lần ở)
--    Đơn đang hoạt động = pending, hoặc approved có check_out_date >= hôm nay
--    (quy tắc "mỗi user 1 đơn hoạt động" kiểm tra ở tầng BO vì phụ thuộc ngày)
-- ---------------------------------------------------------------------
CREATE TABLE registrations (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    room_id         INT NOT NULL,
    status          ENUM('pending','approved','rejected','cancelled') NOT NULL DEFAULT 'pending',
    check_in_date   DATE NULL,                                 -- admin nhập khi duyệt
    check_out_date  DATE NULL,
    note            VARCHAR(255) NULL,                         -- ghi chú của user
    admin_note      VARCHAR(255) NULL,                         -- phản hồi / lý do từ chối của admin
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_reg_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_reg_room FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE RESTRICT,

    -- ngày trả phòng phải sau ngày nhận phòng
    CONSTRAINT chk_reg_dates CHECK (
        check_in_date IS NULL OR check_out_date IS NULL OR check_out_date > check_in_date
    ),
    -- đơn đã duyệt bắt buộc có đủ 2 ngày
    CONSTRAINT chk_reg_approved_dates CHECK (
        status <> 'approved' OR (check_in_date IS NOT NULL AND check_out_date IS NOT NULL)
    ),

    INDEX idx_reg_room_status (room_id, status, check_out_date),
    INDEX idx_reg_user_status (user_id, status)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. REGISTRATION_REQUESTS: yêu cầu gia hạn / trả phòng sớm / hủy sát ngày
--    Mỗi đơn chỉ có tối đa 1 yêu cầu đang chờ (pending_flag + UNIQUE)
-- ---------------------------------------------------------------------
CREATE TABLE registration_requests (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    registration_id  INT NOT NULL,
    type             ENUM('extend','checkout','cancel') NOT NULL,
    requested_date   DATE NULL,                                -- extend: ngày trả mới | checkout: ngày muốn trả | cancel: NULL
    reason           VARCHAR(255) NOT NULL,                    -- lý do của user
    status           ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    admin_note       VARCHAR(255) NULL,                        -- phản hồi của admin
    created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at     DATETIME NULL,

    -- = 1 khi đang chờ, NULL khi đã xử lý -> UNIQUE chỉ chặn 2 yêu cầu chờ cùng lúc
    pending_flag     TINYINT GENERATED ALWAYS AS (IF(status = 'pending', 1, NULL)) STORED,
    UNIQUE KEY uq_one_pending_request (registration_id, pending_flag),

    CONSTRAINT fk_req_registration FOREIGN KEY (registration_id)
        REFERENCES registrations(id) ON DELETE CASCADE,

    -- extend / checkout bắt buộc có ngày, cancel thì không cần
    CONSTRAINT chk_req_date CHECK (type = 'cancel' OR requested_date IS NOT NULL)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. POSTS: nội dung công khai (tin tức, thông báo, nội quy)
-- ---------------------------------------------------------------------
CREATE TABLE posts (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    title         VARCHAR(200) NOT NULL,
    content       TEXT NOT NULL,
    category      ENUM('news','notice','rule') NOT NULL DEFAULT 'news',
    is_published  BOOLEAN NOT NULL DEFAULT FALSE,              -- false = guest không thấy
    author_id     INT NOT NULL,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_post_author FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE RESTRICT,
    INDEX idx_post_published (is_published, category)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. FEEDBACKS: góp ý của sinh viên, admin trả lời
--    is_published = TRUE -> hiện cho guest xem (giống posts)
-- ---------------------------------------------------------------------
CREATE TABLE feedbacks (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    user_id       INT NOT NULL,                                -- sinh viên gửi
    content       TEXT NOT NULL,
    reply         TEXT NULL,                                   -- admin trả lời
    status        ENUM('new','replied') NOT NULL DEFAULT 'new',
    is_published  BOOLEAN NOT NULL DEFAULT FALSE,              -- false = guest không thấy
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    replied_at    DATETIME NULL,

    CONSTRAINT fk_feedback_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_feedback_published (is_published, status)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- VIEW: số người đang ở và chỗ trống của từng phòng
--    Chiếm chỗ = đơn approved có check_out_date >= hôm nay
-- ---------------------------------------------------------------------
CREATE VIEW v_room_occupancy AS
SELECT
    r.id,
    r.room_number,
    r.building,
    r.gender_type,
    r.capacity,
    r.price,
    r.status,
    COUNT(g.id)              AS occupied,
    r.capacity - COUNT(g.id) AS available
FROM rooms r
LEFT JOIN registrations g
       ON g.room_id = r.id
      AND g.status = 'approved'
      AND g.check_out_date >= CURDATE()
GROUP BY r.id, r.room_number, r.building, r.gender_type, r.capacity, r.price, r.status;


-- =====================================================================
--  DỮ LIỆU DEMO
-- =====================================================================

-- mật khẩu: 123456
INSERT INTO users (id, username, password, full_name, email, phone, gender, student_code, role, created_at) VALUES
(1, 'admin', '$2y$10$96dUQRqOoHyq80.JSCjpF.e4gOpFia4B9G/.nM91qlGHDoYfzG7de', 'Quản trị viên',  'admin@ktx.edu.vn',   '0900000000', NULL,     NULL,         'admin', '2026-01-01 08:00:00'),
(2, 'sv001', '$2y$10$96dUQRqOoHyq80.JSCjpF.e4gOpFia4B9G/.nM91qlGHDoYfzG7de', 'Nguyễn Văn An',  'an.nv@sv.edu.vn',    '0901000001', 'male',   '2251010001', 'user',  '2026-02-10 09:00:00'),
(3, 'sv002', '$2y$10$96dUQRqOoHyq80.JSCjpF.e4gOpFia4B9G/.nM91qlGHDoYfzG7de', 'Trần Thị Bình',  'binh.tt@sv.edu.vn',  '0901000002', 'female', '2251010002', 'user',  '2026-02-11 09:00:00'),
(4, 'sv003', '$2y$10$96dUQRqOoHyq80.JSCjpF.e4gOpFia4B9G/.nM91qlGHDoYfzG7de', 'Lê Văn Cường',   'cuong.lv@sv.edu.vn', '0901000003', 'male',   '2251010003', 'user',  '2026-02-12 09:00:00'),
(5, 'sv004', '$2y$10$96dUQRqOoHyq80.JSCjpF.e4gOpFia4B9G/.nM91qlGHDoYfzG7de', 'Phạm Thị Dung',  'dung.pt@sv.edu.vn',  '0901000004', 'female', '2251010004', 'user',  '2026-02-13 09:00:00'),
(6, 'sv005', '$2y$10$96dUQRqOoHyq80.JSCjpF.e4gOpFia4B9G/.nM91qlGHDoYfzG7de', 'Đỗ Quang Hùng',  'hung.dq@sv.edu.vn',  '0901000005', 'male',   '2251010005', 'user',  '2026-11-20 09:00:00');

INSERT INTO rooms (id, room_number, building, gender_type, capacity, price, status, description) VALUES
(1, 'A101', 'Tòa A', 'male',   4, 500000, 'open',   'Phòng 4 người, điều hòa, WC riêng'),
(2, 'A102', 'Tòa A', 'male',   8, 250000, 'open',   'Phòng 8 người, quạt, WC chung'),
(3, 'B101', 'Tòa B', 'female', 4, 500000, 'open',   'Phòng 4 người, điều hòa, WC riêng'),
(4, 'B102', 'Tòa B', 'female', 8, 250000, 'closed', 'Phòng 8 người, đang sửa chữa');

INSERT INTO registrations (id, user_id, room_id, status, check_in_date, check_out_date, note, admin_note, created_at) VALUES
-- An: đang ở, còn 23 ngày -> đang có yêu cầu gia hạn
(1, 2, 1, 'approved',  '2026-09-01', '2026-12-20', NULL, NULL, '2026-08-10 10:00:00'),
-- Bình: đang ở, đã được duyệt trả phòng sớm (gốc 05/01/2027 -> 09/12/2026)
(2, 3, 3, 'approved',  '2026-09-01', '2026-12-09', NULL, NULL, '2026-08-11 10:00:00'),
-- Cường: đơn cũ bị từ chối
(3, 4, 1, 'rejected',  NULL, NULL, NULL, 'Hồ sơ thiếu thông tin', '2026-08-12 10:00:00'),
-- Cường: đã duyệt, chờ nhận phòng kỳ sau (đang giữ chỗ)
(4, 4, 2, 'approved',  '2027-01-10', '2027-06-30', NULL, NULL, '2026-11-18 10:00:00'),
-- Dung: đơn đã hủy
(5, 5, 3, 'cancelled', NULL, NULL, NULL, NULL, '2026-02-15 10:00:00'),
-- Dung: đã trả phòng (hết hạn ở), không còn chiếm chỗ
(6, 5, 3, 'approved',  '2026-03-01', '2026-06-30', NULL, NULL, '2026-02-20 10:00:00'),
-- Hùng: chờ duyệt
(7, 6, 1, 'pending',   NULL, NULL, 'Muốn ở cùng phòng bạn An', NULL, '2026-11-25 10:00:00');

INSERT INTO registration_requests (id, registration_id, type, requested_date, reason, status, admin_note, created_at, processed_at) VALUES
(1, 6, 'extend',   '2026-06-30', 'Ở thêm đến hết kỳ thi',  'approved', NULL,                              '2026-05-15 09:00:00', '2026-05-16 09:00:00'),
(2, 2, 'checkout', '2026-12-15', 'Về quê thực tập',        'rejected', 'Cần bàn giao phòng trước 10/12', '2026-11-18 09:00:00', '2026-11-19 09:00:00'),
(3, 2, 'checkout', '2026-12-10', 'Về quê thực tập',        'approved', 'Đồng ý, bàn giao ngày 09/12',    '2026-11-20 09:00:00', '2026-11-21 09:00:00'),
(4, 1, 'extend',   '2027-06-30', 'Muốn ở tiếp học kỳ 2',   'pending',  NULL,                              '2026-11-25 09:00:00', NULL);

INSERT INTO posts (id, title, content, category, is_published, author_id, created_at) VALUES
(1, 'Mở đăng ký KTX học kỳ 2',
    'Ký túc xá nhận đơn đăng ký học kỳ 2 từ 15/11 đến 15/12/2026. Sinh viên đăng nhập và chọn phòng phù hợp.',
    'notice', TRUE,  1, '2026-11-15 08:00:00'),
(2, 'Nội quy ký túc xá',
    'Giờ đóng cửa 23h00. Không nấu ăn trong phòng. Giữ gìn vệ sinh chung. Khách đến thăm phải đăng ký với bảo vệ.',
    'rule',   TRUE,  1, '2026-08-01 08:00:00'),
(3, 'Lịch cắt điện tòa A ngày 28/11',
    'Tòa A cắt điện từ 8h00 đến 11h00 ngày 28/11/2026 để bảo trì hệ thống.',
    'news',   TRUE,  1, '2026-11-25 08:00:00'),
(4, 'Kế hoạch sửa chữa phòng B102',
    'Bản nháp: dự kiến sửa chữa B102 trong tháng 12/2026.',
    'news',   FALSE, 1, '2026-11-26 08:00:00');

INSERT INTO feedbacks (id, user_id, content, reply, status, is_published, created_at, replied_at) VALUES
(1, 2, 'Wifi tầng 2 tòa A yếu vào buổi tối.',
    'Đã báo kỹ thuật lắp thêm bộ phát, dự kiến xong ngày 05/12.', 'replied', TRUE,  '2026-11-20 20:00:00', '2026-11-21 08:30:00'),
(2, 3, 'Đề nghị mở cửa muộn hơn vào cuối tuần.',
    NULL,                                                          'new',     FALSE, '2026-11-26 21:15:00', NULL);


-- =====================================================================
--  MỘT SỐ TRUY VẤN KIỂM TRA (chạy thử sau khi import)
-- =====================================================================
-- Số người ở / chỗ trống từng phòng:
--   SELECT * FROM v_room_occupancy;
--
-- Phòng còn chỗ cho sinh viên nam:
--   SELECT * FROM v_room_occupancy WHERE status = 'open' AND gender_type = 'male' AND available > 0;
--
-- Yêu cầu đang chờ admin xử lý:
--   SELECT q.*, u.full_name, r.room_number
--   FROM registration_requests q
--   JOIN registrations g ON g.id = q.registration_id
--   JOIN users u ON u.id = g.user_id
--   JOIN rooms r ON r.id = g.room_id
--   WHERE q.status = 'pending';
--
-- Bài viết guest được xem:
--   SELECT * FROM posts WHERE is_published = TRUE ORDER BY created_at DESC;
--
-- Feedback guest được xem:
--   SELECT f.*, u.full_name FROM feedbacks f JOIN users u ON u.id = f.user_id
--   WHERE f.is_published = TRUE ORDER BY f.created_at DESC;