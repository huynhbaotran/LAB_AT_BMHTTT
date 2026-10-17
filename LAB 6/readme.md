# LAB 6: XÁC THỰC ACTIVE DIRECTORY VÀ CHÍNH SÁCH TRUY CẬP TRÊN pfSense

- **Môn học:** An Toàn Bảo Mật Hệ Thống Thông Tin
- **Họ tên:** Huỳnh Bảo Trân
- **MSSV:** 1150070045
- **Lớp:** 11_ĐH_TMĐT
- **Link Video Demo (YouTube):** https://youtu.be/Eiihn4rvSPs 

---

##  1. MỤC TIÊU BÀI LAB
- Thiết lập tường lửa pfSense với mô hình mạng 4 phân vùng độc lập (WAN, MGMT, LAN, DMZ).
- Tích hợp cơ chế xác thực người dùng tập trung qua Active Directory / LDAP và Captive Portal.
- Quản lý đối tượng mạng bằng Firewall Aliases và kiểm soát khung giờ truy cập bằng Schedules.
- Xây dựng và kiểm chứng các kịch bản chính sách (Firewall Rules): chặn site theo máy trạm, chặn nhóm danh mục, giới hạn cổng dịch vụ trong giờ hành chính và cô lập vùng DMZ khỏi LAN.

---

##  2. MÔI TRƯỜNG & PHIÊN BẢN THỰC HIỆN
- **Nền tảng:** VMware Workstation
- **Firewall Appliance:** pfSense CE 2.7.2-RELEASE (FreeBSD)
- **Domain Controller (DC01):** Windows Server 2025 (AD DS, DNS lab6.test)
- **Client trạm:** Windows 11 Enterprise (Client-A, Client-B)
- **Máy chủ DMZ:** Ubuntu Server 24.04 LTS (Python HTTP Server / Nginx)

---

##  3. BẢNG THÔNG SỐ CẤU HÌNH MẠNG & THIẾT BỊ

| Thiết bị / Phân vùng | Card mạng ảo (VMware) | Interface pfSense | Địa chỉ IPv4 | Vai trò |
| :--- | :--- | :--- | :--- | :--- |
| **pfSense WAN** | VMnet8 (NAT) | em0 (Adapter 1) | DHCP (192.168.250.x/24) | Kết nối mạng ngoài / NAT |
| **pfSense MGMT** | VMnet3 (Host-Only) | em1 (Adapter 2) | 192.168.56.254/24 | Cổng WebGUI quản trị an toàn |
| **Máy thật quản trị** | VMware VMnet3 | — | 192.168.56.1/24 | Trình duyệt truy cập WebGUI pfSense |
| **pfSense LAN** | VMnet4 (Custom) | em2 (Adapter 3) | 10.6.0.1/24 | Default Gateway cho mạng LAN |
| **DC01** | VMnet4 (Custom) | — | 10.6.0.10/24 | Active Directory, DNS Server |
| **Client-A** | VMnet4 (Custom) | — | 10.6.0.21/24 | Máy trạm người dùng A |
| **Client-B** | VMnet4 (Custom) | — | 10.6.0.22/24 | Máy trạm người dùng B |
| **pfSense DMZ** | VMnet5 (Custom) | em3 (Adapter 4) | 172.16.6.1/24 | Default Gateway cho DMZ |
| **DMZ-WEB (Ubuntu)**| VMnet5 (Custom) | — | 172.16.6.10/24 | Web server mô phỏng (IP phụ: .20, .30, .40) |

---

