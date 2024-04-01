import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile

from wav import Wav

def plot_frequency_spectrum(wav:Wav):
    # Take the absolute value of the FFT result
    fft_result = np.abs(np.fft.fft(wav.audio_data))
    
    # Create frequency axis
    freq_axis = np.fft.fftfreq(len(fft_result), 1/wav.sample_rate)
    
    # Plot
    plt.figure(figsize=(10, 4))
    plt.plot(freq_axis[:len(freq_axis)//2], fft_result[:len(freq_axis)//2])
    plt.title('Frequency Spectrum')
    plt.xlabel('Frequency (Hz)')
    plt.ylabel('Magnitude')
    plt.title(wav.file_path)
    plt.grid(True)
    plt.show()

if __name__ == "__main__":
    # Example usage
    file_path = "./wavs/tft.wav"
    wav = Wav(file_path=file_path)
    plot_frequency_spectrum(wav=wav)

    file_path = "./wavs/lpf_filtered_tft.wav"
    wav = Wav(file_path=file_path)
    plot_frequency_spectrum(wav=wav)

    file_path = "./wavs/hpf_filtered_tft.wav"
    wav = Wav(file_path=file_path)
    plot_frequency_spectrum(wav=wav)

    file_path = "./wavs/bpf_filtered_tft.wav"
    wav = Wav(file_path=file_path)
    plot_frequency_spectrum(wav=wav)