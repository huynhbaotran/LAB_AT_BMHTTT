**LAB 4 -- KHẢO SÁT VÀ ĐÁNH GIÁ BỀ MẶT MẠNG BẰNG NMAP**
**Họ tên: Huỳnh Bảo Trân
MSSV: 1150070045
Lớp: 11_ĐH_TMDT**

**1. Mục tiêu**
- Hiểu mô hình host/guest.
- Cài đặt và kiểm tra Nmap trên Windows và Kali Linux.
- Thiết lập môi trường mạng Host-Only an toàn.
- Xác định địa chỉ IP của các máy trong mô hình.
- Thực hiện host discovery, quét TCP/UDP, nhận diện dịch vụ và hệ điều
  hành.
- Sử dụng NSE để kiểm tra thông tin và dấu hiệu lỗ hổng SMB trong môi
  trường lab.
- Xuất kết quả quét và lưu bằng chứng.
- Thực hiện so sánh trước và sau khi hardening.
**2. Môi trường thực hành**
- VMware Workstation
- Kali Linux VM -- máy quét
- Metasploitable 2 VM -- máy đích
- Windows 11 VM -- máy đích đối chiếu
- Nmap / Npcap
- Mạng VMware Host-Only (VMnet1)
**3. Nội dung thực hành**
3.1. Kiểm tra Nmap
Kiểm tra Nmap trên Windows và Kali Linux, ghi nhận phiên bản và chụp màn
hình minh chứng.
3.2. Thiết lập mạng Host-Only
Cấu hình Kali Linux, Metasploitable 2 và Windows 11 VM trong cùng mạng
Host-Only. Ghi lại IP và subnet thực tế của từng máy.
3.3. Kiểm tra kết nối
Kiểm tra khả năng kết nối giữa Kali và các máy đích trước khi thực hiện
quét.
3.4. Phát hiện host đang hoạt động
Thực hiện host discovery trên dải mạng Host-Only và ghi nhận các host
được phát hiện.
3.5. Khảo sát cổng TCP
Thực hiện và so sánh: - TCP Connect scan (-sT) - SYN scan (-sS) - FIN
scan - Xmas scan - NULL scan - ACK scan
Ghi nhận và giải thích các trạng thái open, closed, filtered,
open|filtered và unfiltered phù hợp với từng kỹ thuật.
3.6. Quét UDP
Quét có kiểm soát các cổng UDP phổ biến và ghi nhận trạng thái, dịch vụ
và quan sát.
3.7. Nhận diện dịch vụ và hệ điều hành
Thực hiện: - Version detection (-sV) - OS detection (-O) - Aggressive
scan (-A)
Ghi nhận phiên bản dịch vụ, hệ điều hành được suy đoán và các thông tin
liên quan.
3.8. NSE -- SMB
- Thu thập thông tin SMB.
- Kiểm tra MS17-010 trong môi trường lab.
- Chỉ kết luận có dấu hiệu dễ bị ảnh hưởng khi kết quả script báo
  VULNERABLE.
3.9. Xuất kết quả
Lưu kết quả quét dưới các dạng: - Normal text - XML - Grepable - HTML
(nếu thực hiện chuyển đổi)
3.10. Before/After Hardening
Thực hiện một thay đổi phòng thủ trên máy Windows VM, quét trước và sau
thay đổi, sau đó so sánh số cổng, trạng thái cổng và dịch vụ.

**4. Kết luận**
Tóm tắt các host, cổng và dịch vụ phát hiện được; những khác biệt giữa
các kỹ thuật quét; kết quả kiểm tra NSE; và tác động của biện pháp
hardening.
Lưu ý: Bài thực hành chỉ được thực hiện trên các máy ảo do sinh
viên quản lý trong mạng Host-Only. Không quét hệ thống bên ngoài khi
chưa được phép.
