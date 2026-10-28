# LAB 7: XÂY DỰNG CHÍNH SÁCH WEB PROTECTION TRÊN MÔ HÌNH pfSense + WEB PROXY


---

## 1. THÔNG TIN CÁ NHÂN & MÔI TRƯỜNG THỰC HÀNH

* **Họ tên:** Huỳnh Bảo Trân
* **Lớp:** 11_ĐH_TMĐT
* **MSSV:** 1150070045
* **Link Youtube:** https://youtu.be/BbgcJTvJFNE
* **Môi trường:** VMware Workstation
* **Hệ điều hành sử dụng:**
  * **pfSense CE 2.7.2-RELEASE (amd64):** Firewall / Routing / NAT / Gateway
  * **WEB-PROXY (Ubuntu Server 24.04 LTS CLI):** E2Guardian (:8080) + Squid (:3128) + ClamAV
  * **DMZ-WEB (Ubuntu Server 24.04 LTS CLI):** Nginx hosting 13 virtual host mô phỏng (`.lab7.test`)
  * **Client-A (Ubuntu CLI):** Máy trạm kiểm thử chính sách trong vùng LAN
  * **DC01 (Windows Server 2025):** Active Directory Domain Controller & Internal DNS Server

---

## 2. ĐỊA CHỈ IP

Mô hình phân vùng mạng cô lập qua các card mạng ảo nội bộ (VMnet), ngăn chặn tuyệt đối các luồng truy cập web trực tiếp từ LAN ra ngoài mà không qua proxy.

| Thiết bị / Máy ảo | Giao diện mạng | Địa chỉ IP / Subnet | Default Gateway | Chức năng & Dịch vụ |
| :--- | :--- | :--- | :--- | :--- |
| **pfSense Firewall** | `em0` (WAN)<br>`em1` (LAN)<br>`em2` (MGMT)<br>`em3` (DMZ) | `192.168.250.128/24`<br>`10.6.0.1/24`<br>`192.168.56.254/24`<br>`172.16.6.1/24` | DHCP từ Host<br>—<br>—<br>— | Định tuyến, quản lý trạng thái phiên, kiểm soát cổng L3/L4, ép proxy |
| **WEB-PROXY** | `ens33` (LAN - VMnet4) | `10.6.0.30/24` | `10.6.0.1` | E2Guardian (:8080), Squid upstream (:3128), ClamAV daemon |
| **DMZ-WEB** | `ens33` (DMZ - VMnet5) | `172.16.6.10/24` | `172.16.6.1` | Nginx web server mô phỏng các website phân loại (.lab7.test) |
| **Client-A** | `ens33` (LAN - VMnet4) | `10.6.0.21/24` | `10.6.0.1` | Máy trạm gửi request kiểm thử (Explicit Proxy `10.6.0.30:8080`) |
| **DC01** | `Ethernet0` (LAN - VMnet4) | `10.6.0.10/24` | `10.6.0.1` | Phân giải DNS nội bộ cho zone `lab7.test` |
| **Máy Quản trị** | Card Host-Only (VMnet3) | `192.168.56.1/24` | — | Truy cập WebGUI pfSense qua `https://192.168.56.254` |

---

## 3. THIẾT LẬP FIREWALL RULES TRÊN pfSense (LAN INTERFACE)

```text
[LAN Interface Ruleset]
│
├── 1. [Pass] Anti-Lockout Rule: Quản trị WebGUI pfSense (Port 80, 443)
├── 2. [Pass] DNS Access: LAN subnets -> 10.6.0.10 (Port 53 TCP/UDP)
├── 3. [Pass] Proxy Access: LAB7_CLIENTS -> LAB7_PROXY (Port 8080 TCP)
├── 4. [Pass] Mail Services: LAN subnets -> Any (MAIL_PORTS: 25, 465, 587, 110, 995, 143, 993)
├── 5. [Block] Anti-Bypass: LAB7_CLIENTS -> Any (WEB_PORTS: 80, 443 TCP) ──> CHỐNG VƯỢT PROXY
├── 6. [Pass] Proxy Outbound: LAB7_PROXY -> Any (WEB_PORTS: 80, 443 TCP)
├── 7. [Pass] Proxy to DMZ: LAB7_PROXY -> 172.16.6.10 (Port 80 TCP)
└── 8. [Block] Default Deny: LAN subnets -> Any (All protocols/ports)
