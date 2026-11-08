# LAB 8: LOCAL DNS ATTACK - DNS SPOOFING & CACHE POISONING

- **Họ và tên:** Huỳnh Bảo Trân
- **MSSV:** 1150070045
- **Lớp:** 11_ĐH_TMĐT
- **Link YouTube:** https://youtu.be/qfkoA3jcjSg

---

## 1. Môi trường & Kiến trúc mạng

| Thiết bị | Vai trò | Địa chỉ IP | Ghi chú |
| :--- | :--- | :--- | :--- |
| **pfSense** | Gateway / Firewall | `10.9.0.1/24` (DNSLAB) | Định tuyến & cô lập mạng |
| **DNS-SERVER** | BIND9 Recursive/Cache Server | `10.9.0.10/24` | Forward `external.lab9.test` |
| **VICTIM** | Ubuntu Client | `10.9.0.100/24` | DNS trỏ về `10.9.0.10` |
| **ATTACKER** | Kali Linux | `10.9.0.200/24` | Scapy, Fake Web (Port 80) |
| **APP-TEST** | Authoritative DNS Simulator | `172.16.6.20/24` | Phản hồi chậm (delay 1.5s) |
| **DMZ-WEB** | Web Server hợp lệ | `172.16.6.10/24` | Phục vụ trang web gốc |

---

## 2. Tóm tắt các nội dung thực hành

1. **Chuẩn bị môi trường & Baseline:**
   - Dựng phân vùng mạng ảo `DNS-LAB (10.9.0.0/24)` sau pfSense.
   - Cài đặt và cấu hình dịch vụ BIND9 phân giải tên miền cục bộ `lab9.test` và forward tên miền ngoài `external.lab9.test`.
   - Kiểm tra baseline sạch: `www.lab9.test` và `www.external.lab9.test` đều trỏ chính xác về IP hợp lệ `172.16.6.10`.

2. **Task 1 - Local DNS Spoofing qua file `/etc/hosts`:**
   - Chỉnh sửa file `/etc/hosts` trên máy Victim trỏ `www.lab9.test` về IP của Attacker (`10.9.0.200`).
   - Kết quả: Các tiến trình hệ điều hành (`curl`, `getent`) truy cập thành công trang web giả mạo; trong khi truy vấn trực tiếp bằng `dig @10.9.0.10` vẫn giữ kết quả gốc do đi thẳng qua giao thức DNS (cổng UDP 53).

3. **Task 2 - Direct DNS Spoofing (On-Path Attack):**
   - Chạy script giả mạo `dns_spoof_lab9.py --mode victim` trên máy Kali Linux (bật Promiscuous Mode).
   - Khi Victim tạo truy vấn, Attacker sniff gói tin và gửi gói phản hồi DNS giả mạo có cùng Transaction ID và Port về trước server hợp lệ.
   - Kết quả: Victim bị điều hướng thành công sang IP của Attacker (`10.9.0.200`).

4. **Task 3 - DNS Cache Poisoning:**
   - Sử dụng `dns_spoof_lab9.py --mode resolver` để gửi gói tin phản hồi giả mạo tới chính Resolver (`10.9.0.10`).
   - Đánh lừa thành công BIND9 lưu bản ghi giả mạo vào bộ nhớ đệm (cache), ảnh hưởng đến toàn bộ client sử dụng chung resolver trong suốt thời gian TTL.
   - Kiểm tra cache bằng `rndc dumpdb -cache` và khôi phục hệ thống (`rndc flush`).

---

## 3. Biện pháp phòng thủ & Hardening

- Triển khai xác thực DNSSEC (`dnssec-validation auto;`) để đảm bảo tính toàn vẹn và chống giả mạo bản ghi DNS.
- Bật cơ chế DNS Cookie và ngẫu nhiên hóa cổng/Transaction ID (Source Port & TXID Randomization).
- Thiết lập luật tường lửa chặn xuất lượng DNS tự do (DNS Egress Filtering), ép buộc toàn bộ trạm client chỉ truy vấn qua Resolver hợp lệ.
- Phân đoạn mạng (Network Segmentation), tắt Promiscuous Mode và bật DHCP Snooping / Dynamic ARP Inspection trên switch để ngăn chặn kỹ thuật nghe lén on-path.
