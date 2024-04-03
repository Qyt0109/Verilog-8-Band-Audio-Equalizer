from matplotlib import pyplot as plt
import numpy as np
from scipy import signal

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
    h = signal.firwin(N, [fl / (fs / 2), fh / (fs / 2)], pass_zero=False, window=window)
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