import numpy as np
from scipy import signal
from scipy.io import wavfile

from freq_spec import plot_frequency_spectrum
from fir import lpf, hpf, bpf, plot_frequency_response
from wav import Wav

if __name__ == "__main__":
    IS_COMBINE_TEST = False
    IS_GAIN_TEST = False
    N = 1023
    window = 'hamming'

    file_path = "./wavs/tft.wav"
    save_path = "./wavs/lpf_hpf_filtered_tft.wav"

    # open file for LPF
    wav_lpf = Wav(file_path=file_path)
    # Show before apply any filter
    plot_frequency_spectrum(wav=wav_lpf)
    # LPF filter
    h_lpf = lpf(N=N, fl=1000, fs=wav_lpf.sample_rate, window=window)
    wav_lpf.apply_filter(hn=h_lpf)
    # Show apply only LPF
    plot_frequency_spectrum(wav=wav_lpf)

    # open file for HPF
    wav_hpf = Wav(file_path=file_path)
    # HPF filter
    h_hpf = hpf(N=N, fh=7000, fs=wav_lpf.sample_rate, window=window)
    wav_hpf.apply_filter(hn=h_hpf)
    if IS_GAIN_TEST == True:
        # Mul in frequency domain
        wav_hpf.gain(100)
    else:
        # Mul in time domain
        wav_hpf.mul(100)
    # Show apply only HPF
    plot_frequency_spectrum(wav=wav_hpf)

    if IS_COMBINE_TEST == True:
        # Combine 2 wav file (merge hpf to lpf)
        wav_lpf.combine_wav(other_wav=wav_hpf)
        print("COMBINE TEST")
    else:
        # Sum 2 wav file (merge hpf to lpf)
        wav_lpf.sum_wav(other_wav=wav_hpf)
        print("SUM TEST")

    # Show combined file frequency domain
    plot_frequency_spectrum(wav=wav_lpf)
