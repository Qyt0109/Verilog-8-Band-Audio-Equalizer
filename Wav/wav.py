from scipy.io import wavfile
import wave
from scipy.signal import resample

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


# Function to read WAV file and write sample values to a text file
def wav_to_text(wav_file, text_file):
    with wave.open(wav_file, 'rb') as wf:
        # Get parameters of the WAV file
        channels = wf.getnchannels()
        sample_width = wf.getsampwidth()
        frame_rate = wf.getframerate()
        num_frames = wf.getnframes()

        # Make sure it's a mono file
        if channels != 1:
            print("Error: Input WAV file is not mono.")
            return

        # Read sample data
        frames = wf.readframes(num_frames)

    # Extract sample values
    sample_values = []
    for i in range(0, len(frames), sample_width):
        sample = int.from_bytes(frames[i:i+sample_width], byteorder='little', signed=True)
        sample_values.append(sample)

    # Write sample values to text file
    with open(text_file, 'w') as txtf:
        for sample in sample_values:
            txtf.write(str(sample) + '\n')


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