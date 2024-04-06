from matplotlib import pyplot as plt
import numpy as np
from scipy import signal

from numberic import fixed_point_binary_to_float, float_to_fixed_point_binary

def lpf(N, fl, fs, window='hamming', fh=None):
    """
    Design a Low Pass Filter (LPF).

    Parameters:
        N (int): Filter length.
        fl (float): Cut-off frequency of the filter (in Hz).
        fs (float): Sampling frequency (in Hz).
        window (str): Type of window function. Default is 'hamming'.

    Returns:
        h (array): Impulse response of the LPF.
    """
    h = signal.firwin(N, fl / (fs / 2), window=window)
    return h

def hpf(N, fh, fs, window='hamming', fl=None):
    """
    Design a High Pass Filter (HPF).

    Parameters:
        N (int): Filter length.
        fh (float): Cut-off frequency of the filter (in Hz).
        fs (float): Sampling frequency (in Hz).
        window (str): Type of window function. Default is 'hamming'.

    Returns:
        h (array): Impulse response of the HPF.
    """
    h = signal.firwin(N, fh / (fs / 2), window=window, pass_zero=False)
    return h

def bpf(N, fl, fh, fs, window='hamming'):
    """
    Design a Band Pass Filter (BPF).

    Parameters:
        N (int): Filter length.
        fc_low (float): Lower cut-off frequency of the filter (in Hz).
        fc_high (float): Upper cut-off frequency of the filter (in Hz).
        fs (float): Sampling frequency (in Hz).
        window (str): Type of window function. Default is 'hamming'.

    Returns:
        h (array): Impulse response of the BPF.
    """
    h = signal.firwin(N, [fl / (fs / 2), fh / (fs / 2)],
                      pass_zero=False, window=window)
    return h

def bsf(N, fl, fh, fs, window='hamming'):
    """
    Design a Band Stop Filter (BPF).

    Parameters:
        N (int): Filter length.
        fc_low (float): Lower cut-off frequency of the filter (in Hz).
        fc_high (float): Upper cut-off frequency of the filter (in Hz).
        fs (float): Sampling frequency (in Hz).
        window (str): Type of window function. Default is 'hamming'.

    Returns:
        h (array): Impulse response of the BPF.
    """
    h = signal.firwin(N, [fl / (fs / 2), fh / (fs / 2)], window=window)
    return h

def plot_frequency_response(h, fs):
    w, H = signal.freqz(h, fs=fs)
    plt.figure()
    plt.plot(w, 20 * np.log10(np.abs(H)))
    plt.title('Frequency Response')
    plt.xlabel('Frequency (Hz)')
    plt.ylabel('Magnitude (dB)')
    plt.grid(True)
    plt.show()

def quantize_hn(hn, total_bits=16, fraction_bits=15, is_signed=True, as_binary=False):
    quantized_hn = []
    for h_index in range(0, len(hn)):
        hn_value = hn[h_index]
        quantized_hn_value_binary = float_to_fixed_point_binary(value=hn_value,
                                                                total_bits=total_bits,
                                                                fraction_bits=fraction_bits,
                                                                is_signed=is_signed)
        if as_binary:
            quantized_hn.append(quantized_hn_value_binary)
        else:
            quantized_hn_value = fixed_point_binary_to_float(value=quantized_hn_value_binary,
                                                            total_bits=total_bits,
                                                            fraction_bits=fraction_bits,
                                                            is_signed=is_signed)
            quantized_hn.append(quantized_hn_value)

    return quantized_hn

def save_list_as_txt(elements, save_path):
    try:
        with open(save_path, 'w') as f:
            # Read frames and write to text file
            # Write sample values to text file
            for element in elements:
                f.write(element)
                f.write("\n")
            print(f"Saved to {save_path}")
    except Exception as e:
        print(f"Error saving file: {e}")
