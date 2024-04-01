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
## 2. Xác định các tham số, thông số file WAV
### 2.1. File format
<img src="./Wav/imgs/wav_structure.png">

Với yêu cầu sử dụng định dạng <b>wav</b> để làm việc cùng, chúng ta cũng cần xác định được các thông số đặc trưng:
- <b>encoding</b>: Cách mã hoá
  <b>=> PCM</b>
- <b>channels</b>: Số kênh âm thanh (1 cho mono, 2 cho stereo)
  <b>=> mono (Đơn âm sắc)</b>
- <b>sample_width/bit_depth</b>: Số byte cho mỗi mẫu âm thanh
  <b>=> 2 bytes (16 bit)</b>
- <b>frame_rate</b>: Tần số mẫu (số mẫu âm thanh trên giây)
  <b>=> 16 KHz (16000 mẫu/giây)</b>
- <b>num_frames</b>: Số frame âm thanh
  <b>=> Tuỳ file</b>
- <b>duration = num_frames / frame_rate</b>: Thời lượng (giây)
  <b>=> Tuỳ file</b>
- <b>is_signed</b>: Giá trị có dấu hay không có dấu
  <b>=> Có dấu</b>
- <b>is_integer</b>: Giá trị nguyên hay thực
  <b>=> Nguyên</b>
- <b>is_fixedpoint</b>: Giá trị dấu phẩy tĩnh hay dấu phẩy động (nếu là số thực)
  <b>=> Không tĩnh không động</b>
- ...

## 3. Hệ số bộ lọc
Để có một bộ lọc tốt cần cân bằng giữa các yếu tố và thường là có sự đánh đổi lẫn nhau như chất lượng bộ lọc cao sẽ có độ trễ và độ phức tạp tính toán cao, khó triển khai phần cứng,...

Các tham số bộ lọc sẽ phụ thuộc vào tính chất của tín hiệu. VD: tín hiệu có băng tần rộng thì khi chia 8 dải tầng sẽ thoải mái hơn cho việc rò rỉ, ISI giữa các vùng đáp ứng xung của các bộ lọc với nhau. Tín hiệu có độ tập trung năng lượng cao vào vùng tần số nào thì chất lượng của bộ lọc tại vùng tần số đó cần được đảm bảo hơn...

Để cho đơn giản, chúng ta sẽ cố gắng thiết kế các bộ lọc với số lượng mẫu phản ứng xung giống nhau và số mẫu này là tối thiểu sao cho vẫn giữ được đặc tính cũ của tín hiệu gốc (ở mức độ tương đối, không tệ quá là được hehee). Việc này sẽ giúp việc thiết kế trên phần cứng sử dụng ngôn ngữ mô tả phần cứng dễ dàng hơn, dễ dàng tính toán, tuỳ chỉnh tổ hợp các mẫu phản ứng xung trên từng bộ lọc.
### 3.1. Phân tích phổ tín hiệu, phổ tần số
#### 3.1.1. File gốc
![](./Wav/wavs/tft.wav)
<img src="./Wav/imgs/tft_sig_freq.png">
<img src="./Wav/imgs/tft.png">

#### 3.1.2. Sử dụng các bộ lọc
##### 3.1.2.1. Các bộ lọc chất lượng cao, thực hiện trên phần mềm viết bằng Python
Với chất lượng bộ lọc tốt, số lượng mẫu phản ứng xung (impulse response taps) N = 1023, cửa sổ Hamming.
###### a) LPF
Lọc thông thấp (Low Pass Filter) với tần số cắt fc = 1000 (Hz)
Đáp ứng xung (Frequency Response):
<img src="./Wav/imgs/lpf.png">

Tín hiệu sau lọc có phổ giới hạn tối đa tương ứng với tần số cắt, gần như không có sự rò rỉ tần số:
<img src="./Wav/imgs/lpf_tft.png">

###### b) HPF
Lọc thông cao (High Pass Filter) với tần số cắt fc = 7000 (Hz)
Đáp ứng xung (Frequency Response):
<img src="./Wav/imgs/hpf.png">

Tín hiệu sau lọc có phổ giới hạn tối thiểu tương ứng với tần số cắt, gần như không có sự rò rỉ tần số:
<img src="./Wav/imgs/hpf_tft.png">

###### b) BPF
Lọc thông dải (Band Pass Filter) với tần số cắt fc = (fc_l, fc_h)  = (3000, 5000) (Hz)
Đáp ứng xung (Frequency Response):
<img src="./Wav/imgs/bpf.png">

Tín hiệu sau lọc có phổ giới hạn tương ứng với tần số cắt, gần như không có sự rò rỉ tần số:
<img src="./Wav/imgs/bpf_tft.png">