<table>
    <th>
      << CHƯƠNG TRƯỚC
    </th>
    <th>
      0/3
    </th>
    <th>
      <a href="./chap1.md">CHƯƠNG SAU >></a>
    </th>
</table>

# Verilog-8-Band-Audio-Equalizer
Verilog project for a 8 Band Audio Equalizer implement on FPGAs

## 1. SPEC
```
Thiết kế bộ cân bằng âm thanh. 
Chi tiết về bộ Equalizer: Audio equalizer based on FIR filters. | controlpaths.com

Đầu vào: Âm thanh được lấy mẫu với tần số 16Khz, độ rộng bit là 16 bit.
Đầu vào: 8 hệ số khuếch đại cho 8 băng tần số cần cân bằng
Đầu ra: Tín hiệu âm thanh ra. 
Kết quả cần báo cáo:
Độ trễ từ đầu vào đến đầu ra. 
Số cell FPGA cần sử dụng. 
Cách mô phỏng chứng minh mạch hoạt động đúng
Dùng python đọc file wav, vẽ đồ thị phổ của file wav
Tạo file đầu vào là file text với mỗi hàng là 1 mẫu âm thanh lưu là 1 số HEX 16 bit
Testbench đọc file text âm thanh đầu vào vào mảng bộ nhớ 16bit và đưa vào mạch. 
Testbench lấy đầu ra của mạch và lưu vào file text output.txt mỗi hàng 1 là giá trị mẫu âm thanh 
Dùng python đọc file output.txt và chuyển thành file wav, vẽ đồ thị phổ
Dùng python tạo file outout_python.txt bằng cách dùng các hàm của python để tạo ra bộ Equalizer. So sánh kết quả output.txt với file output_python.txt
Tổng hợp mạch bằng FPGA báo cáo các resource cần sử dụng: số cell logic, số LUT, số DSP, số RAM
```

## <a href="./chap1.md"> >> 2. Làm việc với file WAV</a>

## <a href="./chap2.md"> >> 3. Bộ lọc</a>

## <a href="./chap3.md"> >> 4. Thiết kế phần cứng</a>

## <a href="./references.md"> >> References</a>