import numpy as np
from scipy.io import wavfile
import wave
from scipy.signal import resample
from scipy.fft import fft, ifft


class Wav:
    def __init__(self, file_path=None):
        if file_path:
            self.open(file_path)
        else:
            self.file_path = None
            self.sample_rate = None
            self.audio_data = None
            self.channels = None
            self.sample_width = None
            self.frames = None

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
        self.audio_data = resample(self.audio_data, int(
            len(self.audio_data) * resampling_ratio))
        self.sample_rate = target_sample_rate

    def save_as_txt(self, save_path, is_show_dec=False):
        try:
            with open(save_path, 'w') as f:
                # Read frames and write to text file
                if is_show_dec:
                    f.write(f"Sample Width (bit): {self.sample_width * 8}\n")
                    f.write(f"Number of Frames/Samples: {len(self.audio_data)}\n")
                    f.write(f"Max value: {max(self.audio_data)}\n")
                    f.write(f"Min value: {min(self.audio_data)}\n")
                    f.write(f"Max abs value: {max(abs(self.audio_data))}\n")
                    f.write(f"Min abs value: {min(abs(self.audio_data))}\n")
                # Write sample values to text file
                for data in self.audio_data:
                    binary_data = format(data if data >= 0 else (
                        1 << (self.sample_width * 8)) + data, '0{}b'.format(self.sample_width * 8))
                    f.write(f"{binary_data}")
                    if is_show_dec:
                        f.write(f":{data}")
                    f.write("\n")
                print(f"Saved to {save_path}")
        except Exception as e:
            print(f"Error saving file: {e}")

    def load_from_txt(self, txt_path):
        try:
            with open(txt_path, 'r') as f:
                lines = f.readlines()
                audio_samples = np.empty(len(lines), dtype=np.int16)
                for i, line in enumerate(lines):
                    binary_data = line.strip()
                    # Convert binary data back to audio sample
                    sample = int(binary_data, 2)
                    if sample >= 1 << (self.sample_width * 8 - 1):
                        sample -= 1 << (self.sample_width * 8)
                    audio_samples[i] = sample
                self.audio_data = audio_samples
                print(f"Loaded audio samples from {txt_path}")
        except FileNotFoundError:
            print(f"Error: File {txt_path} not found.")
        except Exception as e:
            print(f"Error loading file: {e}")

    def combine_wav(self, other_wav):
        # Determine the maximum length among the audio signals
        this_audio = self.audio_data
        other_audio = other_wav.audio_data
        max_length = max(len(this_audio), len(other_audio))
        # Ensure both signals have the same length
        this_audio = np.pad(this_audio[:max_length], (0, max(
            0, max_length - len(this_audio))), 'constant')
        other_audio = np.pad(other_audio[:max_length], (0, max(
            0, max_length - len(other_audio))), 'constant')
        # Perform Fourier transform
        this_fft = fft(this_audio)
        other_fft = fft(other_audio)
        # Add frequency representations
        combined_fft = this_fft + other_fft
        # Take inverse Fourier transform
        combined_audio = np.real(ifft(combined_fft))
        self.audio_data = combined_audio

    def sum_wav(self, other_wav):
        # Determine the maximum length among the audio signals
        this_audio = self.audio_data
        other_audio = other_wav.audio_data
        max_length = max(len(this_audio), len(other_audio))
        # Ensure both signals have the same length
        this_audio = np.pad(this_audio[:max_length], (0, max(
            0, max_length - len(this_audio))), 'constant')
        other_audio = np.pad(other_audio[:max_length], (0, max(
            0, max_length - len(other_audio))), 'constant')
        # Summing up samples
        sum_audio = this_audio + other_audio
        self.audio_data = sum_audio

    def apply_filter(self, hn):
        # Assumming 16-bit PCM wav format
        self.audio_data = np.convolve(self.audio_data, hn, mode='same')
        # Ensure 16-bit PCM format
        self.audio_data = np.asarray(self.audio_data, dtype=np.int16)

    def gain(self, factor: float):
        # Compute the Fourier transform of the audio data
        audio_fft = fft(self.audio_data)

        # Amplify the frequency domain by multiplying with the gain factor
        audio_fft *= factor

        # Perform the inverse Fourier transform to get the amplified audio data
        amplified_audio = np.real(ifft(audio_fft))

        # Update the audio data with the amplified version
        self.audio_data = amplified_audio

    def mul(self, factor: float):
        # Update the audio data with the amplified version
        self.audio_data *= factor


if __name__ == "__main__":
    """
    # Example usage:
    file_path = './wavs/tft.wav'  # Change this to your WAV file's path
    wav = Wav(file_path=file_path)
    # wav.print()
    wav.save_as_txt(save_path="./wavs/tft.txt", is_show_dec=False)
    wav.save_as_txt(save_path="./wavs/tft_value.txt", is_show_dec=True)
    """
    wav_from_txt = Wav()
    wav_from_txt.channels = 1
    wav_from_txt.sample_rate = 16000
    wav_from_txt.sample_width = 16
    wav_from_txt.load_from_txt(txt_path="./o_tft_x4_bin.txt")
    wav_from_txt.save_as(save_path="./o_tft_x4_bin.wav")
