# LAB 2: MÃ HÓA ĐỐI XỨNG HIỆN ĐẠI
**Môn:** An toàn và Bảo mật Hệ thống Thông tin

## Thông tin sinh viên
* **Họ và tên:** Huỳnh Bảo Trân
* **MSSV:** 1150070045
* **Lớp:**  11_ĐH_TMĐT
* **Link Youtube:** https://youtu.be/URpB2gxjNHs 

---



## Hướng dẫn cài đặt & chạy chương trình

### 1. Cấu hình SQL Server
1. Mở SQL Server Management Studio (SSMS), chạy lần lượt `01_Tao_CSDL.sql` và `02_Tao_Tai_Khoan_SQL.sql` để tạo database `LAB2_MaHoaHienDai` cùng tài khoản thực hành.
2. Đảm bảo đã bật **TCP/IP** trên cổng `14333` và bật chế độ xác thực **SQL Server and Windows Authentication mode**.

### 2. Chạy ứng dụng Java (Bài 2.1 – 2.6.1)
1. Mở project `LAB2_MaHoaHienDai` bằng **Apache NetBeans** (JDK 17+).
2. Nhấp phải vào project chọn **Clean and Build** (`Shift + F11`) để Maven tải thư viện `mssql-jdbc` và `bcprov-jdk18on`.
3. Nhấn **Run Project** (`F6`) để khởi chạy giao diện chính `week_02.frm_Menu`.
4. Chọn **Kết nối SQL Server** trên menu để kiểm tra kết nối trước khi thao tác các form thuật toán (DES, TripleDES, AES + Login, RC4, Twofish, AES-CTR).

### 3. Chạy ứng dụng Python (Bài 2.6.2 – AES-CBC)
Mở Command Prompt tại thư mục chứa tệp `aes_cbc_gui.py` và thực thi:
```bash
# Cài đặt thư viện mã hóa
py -m pip install cryptography

# Chạy tự kiểm thử (self-test)
py aes_cbc_gui.py --self-test

# Mở giao diện đồ họa
py aes_cbc_gui.py
