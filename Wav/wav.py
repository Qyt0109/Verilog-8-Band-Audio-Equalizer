import numpy as np
from scipy.io import wavfile
import wave
from scipy.signal import resample
from scipy.fft import fft, ifft

class Wav:
    def __init__(self, file_path):
        self.open(file_path)

    def open(self, file_path):
        try:
            self.file_path = file_path
            self.sample_rate, self.audio_data = wavfile.read(file_path)
            with wave.open(file_path, 'rb') as f:
                self.channels = f.getnchannels()        # 1: mono, 2: stereo
                self.sample_width = f.getsampwidth()    # bytes
                self.frames = f.getnframes()            # number of audio frames
                # self.compression_type = f.getcomptype() # compression type ('NONE' is the only supported type).
                # self.compression_name = f.getcompname() # Usually 'not compressed' aka 'NONE'
        except FileNotFoundError:
            print(f"Error: File {file_path} not found.")
        except Exception as e:
            print(f"Error opening file: {e}")

    def save_as(self, save_path):
        try:
            wavfile.write(save_path, self.sample_rate, self.audio_data)
            print(f"Saved to {save_path}")
        except Exception as e:
            print(f"Error saving file: {e}")

    def print(self):
        print("Sample Rate:", self.sample_rate)
        print("Channels:", self.channels)
        print("Sample Width (bytes):", self.sample_width)
        print("Number of Frames:", self.frames)
        print("Duration (s):", self.frames / self.sample_rate)

    def resample(self, target_sample_rate):
        resampling_ratio = target_sample_rate / self.sample_rate
        self.audio_data = resample(self.audio_data, int(len(self.audio_data) * resampling_ratio))
        self.sample_rate = target_sample_rate

    def save_as_txt(self, save_path):
        try:
            with open(save_path, 'w') as f:
                # Read frames and write to text file
                # Write sample values to text file
                for data in self.audio_data:
                    binary_data = format(data if data >= 0 else (1 << (self.sample_width * 8)) + data, '0{}b'.format(self.sample_width * 8))
                    f.write(f"{binary_data}:{data}\n")
        except Exception as e:
            print(f"Error saving file: {e}")

    def combine_wav(self, other_wav):
        # Determine the maximum length among the audio signals
        this_audio = self.audio_data
        other_audio = other_wav.audio_data
        max_length = max(len(this_audio), len(other_audio))
        # Ensure both signals have the same length
        this_audio = np.pad(this_audio[:max_length], (0, max(0, max_length - len(this_audio))), 'constant')
        other_audio = np.pad(other_audio[:max_length], (0, max(0, max_length - len(other_audio))), 'constant')
        # Perform Fourier transform
        this_fft = fft(this_audio)
        other_fft = fft(other_audio)
        # Add frequency representations
        combined_fft = this_fft + other_fft
        # Take inverse Fourier transform
        combined_audio = np.real(ifft(combined_fft))
        self.audio_data = combined_audio

if __name__ == "__main__":
    # Example usage:
    file_path = './wavs/tft.wav'  # Change this to your WAV file's path
    wav = Wav(file_path=file_path)
    wav.print()

    """ Example output:
    Sample Rate: 48000
    Channels: 1
    Sample Width (bytes): 2
    Number of Frames: 256000
    """