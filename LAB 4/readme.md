# LAB4 - Thực hành Nmap và rà soát dịch vụ mạng

**- Họ và tên: Huỳnh Bảo Trân
- MSSV: 1150070045
- Lớp: 11_ĐH_TMĐT**
- Link video youtube: https://youtu.be/CzIkmYYfXsw **

## Môi trường thực hành

- VMware Workstation
- Kali Linux
- Nmap 7.99
- Metasploitable 2
- Mạng lab: 192.168.43.0/24
- Kali: 192.168.43.131
- Metasploitable 2: 192.168.43.132

## Cách dựng môi trường

Các máy ảo được cấu hình trong VMware Workstation và đặt trong
mạng lab riêng. Kali Linux được sử dụng làm máy quét và
Metasploitable 2 được sử dụng làm máy đích.

Kiểm tra kết nối giữa các máy trước khi thực hiện quét Nmap.

## Các tình huống đã thực hiện

- Host discovery trong mạng lab
- TCP Connect Scan (-sT)
- SYN Scan (-sS)
- FIN Scan (-sF)
- Xmas Scan (-sX)
- NULL Scan (-sN)
- ACK Scan (-sA)
- UDP Scan (-sU)
- Service/Version Detection (-sV)
- OS Detection (-O)
- Aggressive Scan (-A)
- NSE script với SMB
- Quét cổng 445 trên subnet
- Xuất kết quả Nmap ra XML
- Chuyển kết quả XML sang HTML

## Kết quả

PASS - Kali Linux có thể phát hiện và quét máy Metasploitable 2.

PASS - Phát hiện nhiều dịch vụ đang mở trên Metasploitable 2.

PASS - Nmap nhận diện được phiên bản của nhiều dịch vụ.

PASS - Nmap thực hiện được OS detection trên máy đích.

PASS - Aggressive Scan thu thập được thông tin dịch vụ, hệ điều hành,
NSE script và traceroute.

PASS - Cổng TCP/445 trên Metasploitable 2 được phát hiện ở trạng thái open.

PASS - NSE smb-os-discovery thu thập được thông tin SMB của máy đích.

FAIL/Không xác định - Script smb-vuln-ms17-010 không trả về kết quả
VULNERABLE, vì vậy không kết luận máy đích bị ảnh hưởng chỉ dựa trên
lần kiểm tra này.

## Lỗi gặp phải và cách khắc phục

### Một số scan trả về open|filtered

FIN/Xmas/NULL scan có thể không nhận được phản hồi rõ ràng từ máy đích.

Cách xử lý: đối chiếu với SYN Scan, TCP Connect Scan và Service
Detection để đánh giá kết quả.

### NSE không trả về kết quả mong đợi

Không tự suy diễn rằng máy an toàn hoặc có lỗ hổng khi script không
đưa ra kết luận rõ ràng. Chỉ kết luận khi có bằng chứng từ output.

## Lưu ý an toàn

Toàn bộ quá trình thực hành được thực hiện trong môi trường máy ảo
phục vụ học tập. Các output/log được kiểm tra và làm sạch trước khi
đưa lên repository.
