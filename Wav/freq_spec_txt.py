from freq_spec import plot_frequency_spectrum
from wav import Wav

origin_txt_file_path = "../HDL/Test/o_tft_bin.txt"
txt_file_path = "../HDL/Test/o_amplifier_bin.txt"

wav_from_txt = Wav()
wav_from_txt.channels = 1
wav_from_txt.sample_rate = 16000
wav_from_txt.sample_width = 16
wav_from_txt.load_from_txt(txt_path=origin_txt_file_path)
plot_frequency_spectrum(wav=wav_from_txt)
wav_from_txt.load_from_txt(txt_path=txt_file_path)
plot_frequency_spectrum(wav=wav_from_txt)
