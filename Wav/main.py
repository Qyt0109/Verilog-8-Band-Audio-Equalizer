import numpy as np
from scipy import signal
from scipy.io import wavfile

from freq_spec import plot_frequency_spectrum
from fir import lpf, hpf, bpf, plot_frequency_response
from wav import Wav

def fil_wav(wav:Wav, hn):
    wav.audio_data = np.convolve(wav.audio_data, hn, mode='same')    # Assumming 16-bit PCM wav format
    wav.audio_data = np.asarray(wav.audio_data, dtype=np.int16)  # Ensure 16-bit PCM format

if __name__ == "__main__":
    file_path = "./wavs/tft.wav"
    """
    # Resampling file
    save_path = "./wavs/resampled_tft.wav"
    target_sample_rate = 16000 # (Hz)
    wav = Wav(file_path=file_path)
    wav.print()
    wav.resample(target_sample_rate=target_sample_rate)
    wav.save_as(save_path=save_path)

    # Save as txt
    save_path = "./wavs/tft.txt"
    wav = Wav(file_path=file_path)
    wav.save_as_txt(save_path=save_path)

    # Filtering data
    # LPF
    save_path = "./wavs/lpf_filtered_tft.wav"
    wav = Wav(file_path=file_path)
    hn = lpf(N=1023, fl=1000, fs=wav.sample_rate, window='hamming')
    fil_wav(wav=wav, hn=hn)
    wav.save_as(save_path=save_path)
    plot_frequency_response(h=hn, fs=wav.sample_rate)
    # HPF
    save_path = "./wavs/hpf_filtered_tft.wav"
    wav = Wav(file_path=file_path)
    hn = hpf(N=1023, fh=7000, fs=wav.sample_rate, window='hamming')
    fil_wav(wav=wav, hn=hn)
    wav.save_as(save_path=save_path)
    plot_frequency_response(h=hn, fs=wav.sample_rate)
    # BPF
    save_path = "./wavs/bpf_filtered_tft.wav"
    wav = Wav(file_path=file_path)
    hn = bpf(N=1023, fl=3000, fh=5000, fs=wav.sample_rate, window='hamming')
    fil_wav(wav=wav, hn=hn)
    wav.save_as(save_path=save_path)
    plot_frequency_response(h=hn, fs=wav.sample_rate)
    """
    # LPF + HPF + BPF
    N = 63
    window = 'hamming'

    save_path = "./wavs/lpf_hpf_filtered_tft.wav"
    # LPF
    wav_lpf = Wav(file_path=file_path)
    # Before filtering
    plot_frequency_spectrum(wav_lpf)

    h_lpf = lpf(N=N, fl=1000, fs=wav_lpf.sample_rate, window=window)
    fil_wav(wav=wav_lpf, hn=h_lpf)
    #plot_frequency_spectrum(wav=wav_lpf)
    # BPF
    for i in range(1, 7):
        if i in [1, 6]:
            continue
        wav_bpf = Wav(file_path=file_path)
        h_bpf = bpf(N=N, fl=i*1000, fh=(i+1)*1000, fs=wav_lpf.sample_rate, window=window)
        # Combine effect to wav_lpf
        fil_wav(wav=wav_bpf, hn=h_bpf)
        wav_lpf.combine_wav(wav_bpf)
    # HPF
    wav_hpf = Wav(file_path=file_path)
    h_hpf = hpf(N=N, fh=7000, fs=wav_hpf.sample_rate, window=window)
    fil_wav(wav=wav_hpf, hn=h_hpf)
    # Combine effect to wav_lpf
    wav_lpf.combine_wav(wav_hpf)
    # Plot combined fir filters for 8 bands
    plot_frequency_spectrum(wav_lpf)