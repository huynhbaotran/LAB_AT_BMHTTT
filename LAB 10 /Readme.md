# LAB 10: REMOTE DNS CACHE POISONING TRONG MÔI TRƯỜNG pfSense CÔ LẬP

- **Họ và tên:** Huỳnh Bảo Trân
- **MSSV:** 1150070045
- **Lớp:** 11_ĐH_TMĐT
- **Link Youtube:** https://youtu.be/lTSa0PCdECA

---

## 1. Môi trường & Kiến trúc mạng

Hệ thống triển khai trên mô hình mạng ảo hóa nhiều phân vùng (multi-zone) được định tuyến và kiểm soát qua **pfSense Firewall**, cô lập hoàn toàn Attacker sang một subnet riêng biệt để ngăn chặn hành vi nghe lén (sniffing) tầng Layer 2:

| Thiết bị / Vùng mạng | Vai trò | Địa chỉ IP | Ghi chú cấu hình |
| :--- | :--- | :--- | :--- |
| **pfSense** | Gateway / Firewall | `10.9.0.1` (DNSLAB)<br>`10.10.0.1` (ATTACKNET)<br>`172.16.6.1` (DMZ) | Kiểm soát ACL, định tuyến giữa các subnet, ngăn cách Layer 3 |
| **DNS-SERVER** | BIND9 / Lab Resolver | `10.9.0.10/24` | Đóng vai trò Resolver đệm; chạy script mô phỏng cổng nguồn cố định `33333` |
| **VICTIM** | Ubuntu Client | `10.9.0.100/24` | Trạm làm việc của nạn nhân, cấu hình DNS trỏ về `10.9.0.10` |
| **ATTACKER** | Kali Linux | `10.10.0.200/24` | Subnet `ATTACKNET`, chạy Evil DNS (`:53`), Fake Web (`:80`) và script tấn công |
| **AUTH-DNS / RELAY** | Authoritative DNS Simulator | `172.16.6.20/24` | Phản hồi tên miền hợp lệ + Race harness lắng nghe batch TXID qua `UDP 5300` |
| **DMZ-WEB** | Web Server hợp lệ | `172.16.6.10/24` | Máy chủ web gốc phục vụ tên miền `www.example.lab10.test` |

---

## 2. Các bước triển khai & Kết quả thực nghiệm

### Bước 1: Thiết lập phân vùng và kiểm chứng tính Remote
- Bổ sung interface `ATTACKNET` (`10.10.0.1/24`) trên pfSense, chuyển card mạng của Kali sang switch ảo nội bộ riêng và thiết lập `Promiscuous Mode = Deny`.
- Kiểm tra baseline sạch từ VICTIM: truy vấn `resolvectl query www.example.lab10.test` trả về đúng IP gốc `172.16.6.10`.
- Chạy `tcpdump -ni any udp port 53` trên máy Kali và gửi truy vấn từ Victim: Kali hoàn toàn không bắt được gói tin giữa Resolver (`10.9.0.10`) và DMZ (`172.16.6.20`), xác nhận tính chất cô lập của tấn công từ xa (Remote Attack).

### Bước 2: Thiết lập Firewall Rules trên pfSense
Cấu hình ma trận firewall rules tối thiểu để bài lab vận hành:
- **DNSLAB:** Cho phép Victim truy vấn DNS tới Resolver (`UDP 53`), Resolver gửi truy vấn sang DMZ (`UDP 53`), và Victim truy cập Web giả mạo của Kali (`TCP 80`).
- **ATTACKNET:** Cho phép Kali gửi trigger query tới Resolver (`UDP 53`) và gửi các batch dự đoán Transaction ID tới Authoritative/Relay qua cổng `UDP 5300`.
- **DMZ (OPT2):** Bổ sung rule cho phép gói tin phản hồi giả mạo từ DMZ quay ngược trở lại Resolver trên cổng nguồn `UDP 33333`.

### Bước 3: Thực hiện tấn công Remote Cache Poisoning (Kaminsky Simulation)
- Trên DNS-SERVER: Dừng dịch vụ BIND9 và khởi chạy `vuln_resolver_lab10.py` (lắng nghe cổng 53, phát truy vấn upstream từ cổng cố định `33333`).
- Trên Kali:
  - Khởi động Authoritative DNS giả mạo: `sudo python3 ~/evil_dns_lab10.py` (lắng nghe `10.10.0.200:53`).
  - Khởi động Fake Web Server: `sudo python3 -m http.server 80 --directory ~/LAB10/fake_site`.
  - Thực thi kịch bản tấn công: `python3 ~/kaminsky_remote_lab10.py`.
- **Kết quả ghi nhận:**
  - Kịch bản liên tục tạo các subdomain ngẫu nhiên (bypass cache) và bắn các batch TXID sang cổng 5300 của relay.
  - Phía DMZ xuất hiện log: `[HIT] batch ... contains txid=...`.
  - Phía DNS-SERVER xuất hiện log: `[CACHE] delegation poisoned: example.lab10.test. NS ns.evil.example.lab10.test. -> 10.10.0.200`.
  - Kịch bản kiểm tra trên Kali in ra: `[VERIFY] www.example.lab10.test A = ['10.10.0.200']`.

### Bước 4: Kiểm chứng hậu quả trên máy VICTIM
- Thực hiện xóa bộ nhớ đệm: `sudo resolvectl flush-caches`.
- Kiểm tra phân giải tên miền:
  ```bash
  resolvectl query www.example.lab10.test
  # Kết quả trả về: 10.10.0.200 (IP của Kali Attacker)
