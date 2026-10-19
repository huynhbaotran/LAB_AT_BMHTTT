# THỰC HÀNH AN TOÀN HỆ THỐNG THÔNG TIN - LAB 3: THIẾT LẬP MÔ HÌNH TƯỜNG LỬA pfSense

## 1. Thông tin sinh viên
- **Họ và tên:** Huỳnh Bảo Trân
- **MSSV:** 1150070045
- **Lớp:** 11_ĐH_TMĐT
- **Môn học:** An toàn Hệ thống Thông tin
- **Link youtube:** https://www.youtube.com/watch?v=Yn0mo3a62Qg

---

## 2. Mục tiêu bài lab
- Xây dựng và triển khai mô hình mạng ba vùng phân tách (WAN, LAN, DMZ) sử dụng tường lửa **pfSense Community Edition**.
- Cấu hình và quản lý địa chỉ IP, chuyển đổi địa chỉ mạng (Hybrid Outbound NAT).
- Thiết lập, phân tích và kiểm thử các chính sách tường lửa (Firewall Rules) theo thứ tự ưu tiên (Top-down, First-match).
- Thực hành cô lập vùng mạng DMZ khỏi mạng nội bộ LAN và giám sát lưu lượng thông qua nhật ký tường lửa (Firewall Logs).

---

## 3. Môi trường thực hành & Tối ưu hóa tài nguyên
- **Nền tảng ảo hóa:** VMware Workstation
- **Hệ thống máy ảo triển khai (Tối ưu nhẹ máy, thay thế Windows Server):**
  - **Firewall:** pfSense CE 2.7.2 (FreeBSD 64-bit, 1 GB RAM, 2 vCPU).
  - **Host LAN (thay Windows Server DC):** Ubuntu Server (CLI, minimal, 1 GB RAM).
  - **Host Test / DMZ Host:** Kali Linux (GUI, 2 GB RAM - dùng làm LAN-Test và chuyển vùng sang DMZ-Host).
  - **Trạm quản trị:** Máy vật lý (Host OS Windows) kết nối qua card mạng ảo `VMnet1`.

---

## 4. Địa chỉ IP 

| Thiết bị / Máy ảo | Giao diện mạng (Interface) | Địa chỉ IP | Subnet Mask | Default Gateway | DNS Server | VMware Virtual Network |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **pfSense** | WAN (`em0`) | DHCP / NAT | — | Upstream | Upstream / 8.8.8.8 | Bridged / NAT |
| **pfSense** | LAN (`em1`) | `10.0.0.1` | `255.0.0.0` (/8) | — | — | `VMnet1` (Host-only) |
| **pfSense** | DMZ (`em2`) | `172.16.0.1` | `255.255.0.0` (/16) | — | — | `VMnet2` (Host-only) |
| **Máy thật quản trị** | Host-only Adapter | `10.0.0.100` | `255.0.0.0` (/8) | *(Bỏ trống)* | *(Bỏ trống)* | `VMnet1` |
| **Ubuntu (LAN Host)** | LAN (`ens33`) | `10.0.0.2` | `255.0.0.0` (/8) | `10.0.0.1` | `8.8.8.8` | `VMnet1` |
| **Kali (LAN-Test)** | LAN (`eth0`) | `10.0.0.3` | `255.0.0.0` (/8) | `10.0.0.1` | `8.8.8.8` | `VMnet1` *(Tình huống 2)* |
| **Kali (DMZ Host)** | DMZ (`eth0`) | `172.16.0.2` | `255.255.0.0` (/16) | `172.16.0.1` | `8.8.8.8` | `VMnet2` *(Tình huống 3)* |

---

## 5. Tóm tắt kết quả các tình huống thực hành

### Tình huống 1: Chặn ICMP (Ping) nhưng cho phép duyệt Web (HTTP/HTTPS) và DNS
- **Cấu hình (tab LAN):**
  1. `Block | ICMP | LAN subnets -> Any` *(Log enabled)*
  2. `Pass | TCP/UDP | LAN subnets -> Any:53 (DNS)`
  3. `Pass | TCP | LAN subnets -> Any:80,443 (HTTP/HTTPS)`
- **Kết quả:** Lệnh `ping 8.8.8.8` từ máy Ubuntu bị chặn (`100% packet loss`), trong khi `nslookup example.com` và `curl -I https://example.com` (`HTTP/2 200 OK`) hoạt động bình thường.

### Tình huống 2: Chỉ cho phép một Host cụ thể ra Internet
- **Cấu hình (tab LAN):**
  1. `Pass | Any | 10.0.0.2 -> Any` *(Ưu tiên đặt ở trên)*
  2. `Block | Any | LAN subnets -> Any` *(Đặt phía dưới)*
- **Kết quả:** Máy Ubuntu (`10.0.0.2`) ping ra Internet (`8.8.8.8`) thành công (`0% packet loss`); máy Kali (`10.0.0.3`) bị chặn hoàn toàn (`100% packet loss`).

### Tình huống 3: Cô lập vùng DMZ khỏi mạng LAN nội bộ
- **Baseline (Trước khi chặn):** Máy Kali trong DMZ (`172.16.0.2`) ping thông sang máy Ubuntu trong LAN (`10.0.0.2`) với rule `Pass DMZ subnets -> Any`.
- **Cấu hình sau khi chặn (tab DMZ):**
  1. `Block | Any | DMZ subnets -> 10.0.0.0/8 (LAN net)` *(Log enabled)*
  2. `Pass | Any | DMZ subnets -> Any`
- **Kết quả:** Kali không thể ping tới Ubuntu trong LAN (`100% packet loss`), nhưng vẫn ping ra Internet (`8.8.8.8`) bình thường (`0% packet loss`).

### Tình huống 5: Phân tích nhật ký tường lửa (Firewall Logs)
- Ghi nhận đầy đủ bản ghi chặn tại `Status > System Logs > Firewall`: Gói tin `ICMP` từ nguồn `172.16.0.2` tới đích `10.0.0.2` bị gắn cờ đỏ hủy gói bởi chính sách `USER_RULE` (`Block DMZ to LAN`).
