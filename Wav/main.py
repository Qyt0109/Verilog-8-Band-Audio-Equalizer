import numpy as np
from scipy import signal
from scipy.io import wavfile

from fir_filter import get_LPF_hn, get_HPF_hn, get_BPF_hn, get_BSF_hn
from fir import lpf, hpf, bpf, plot_frequency_response
from wav import Wav

def fil_wav(wav:Wav, hn):
    wav.audio_data = np.convolve(wav.audio_data, hn, mode='same')    # Assumming 16-bit PCM wav format
    wav.audio_data = np.asarray(wav.audio_data, dtype=np.int16)  # Ensure 16-bit PCM format

if __name__ == "__main__":
    file_path = "./tft.wav"

    # Resampling file
    save_path = "./resampled_tft.wav"
    target_sample_rate = 16000 # (Hz)
    wav = Wav(file_path=file_path)
    wav.print()
    wav.resample(target_sample_rate=target_sample_rate)
    wav.save_as(save_path=save_path)

    # Save as txt
    save_path = "./tft.txt"
    wav = Wav(file_path=file_path)
    wav.save_as_txt(save_path=save_path)

    # Filtering data
    # LPF
    save_path = "./lpf_filtered_tft.wav"
    wav = Wav(file_path=file_path)
    hn = lpf(N=1023, fl=1000, fs=wav.sample_rate, window='hamming')
    fil_wav(wav=wav, hn=hn)
    wav.save_as(save_path=save_path)
    plot_frequency_response(h=hn, fs=wav.sample_rate)
    # HPF
    save_path = "./hpf_filtered_tft.wav"
    wav = Wav(file_path=file_path)
    hn = hpf(N=1023, fh=7000, fs=wav.sample_rate, window='hamming')
    fil_wav(wav=wav, hn=hn)
    wav.save_as(save_path=save_path)
    plot_frequency_response(h=hn, fs=wav.sample_rate)
    # BPF
    save_path = "./bpf_filtered_tft.wav"
    wav = Wav(file_path=file_path)
    hn = bpf(N=1023, fl=3000, fh=5000, fs=wav.sample_rate, window='hamming')
    fil_wav(wav=wav, hn=hn)
    wav.save_as(save_path=save_path)
    plot_frequency_response(h=hn, fs=wav.sample_rate)