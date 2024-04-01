from numpy import cos, sin, pi, absolute, arange, zeros
import scipy
from scipy.signal import hamming, firwin, freqz


def get_LPF_hn(N, fl, fs, window='boxcar', fh=None):
    """
    create h[n] of a low pass filter
    N: Filter order
    fl: Cutoff frequency
    fh: no use
    fs: Sampling frequency

    window:
    - boxcar: Also known as a rectangular window or Dirichlet window, this is equivalent to no window at all.
    - hamming
    - hann
    - ...
    """
    fnyq = 2 * fl  # Nyquist rate
    fnodco = fl/fs  # Normalized digital cut-off frequency
    fdco = (fnodco) * pi  # Digital cut-off frequency
    hn = firwin(N, fnodco, window=window)

    return hn


def get_HPF_hn(N, fh, fs, window='boxcar', fl=None):
    """
    create h[n] of a high pass filter
    N: Filter order
    fl: no use
    fh: Cutoff frequency
    fs: Sampling frequency

    window:
    - boxcar: Also known as a rectangular window or Dirichlet window, this is equivalent to no window at all.
    - hamming
    - hann
    - ...
    """
    fnyq = 2 * fh  # Nyquist rate
    fnodco = fh/fs  # Normalized digital cut-off frequency
    fdco = (fnodco) * pi  # Digital cut-off frequency
    hn = firwin(N, fnodco, window=window, pass_zero=False)

    return hn


def get_BPF_hn(N, fl, fh, fs, window='boxcar'):
    """
    create h[n] of a band pass filter
    N: Filter order
    fl: low frequency
    fh: high frequency
    fs: Sampling frequency

    window:
    - boxcar: Also known as a rectangular window or Dirichlet window, this is equivalent to no window at all.
    - hamming
    - hann
    - ...
    """
    fnyq = 2 * fh  # Nyquist rate
    # Normalized digital cut-off frequencies
    fnodco_l = fl/fs
    fnodco_h = fh/fs
    # Digital cut-off frequencies
    fdco_l = (fnodco_l) * pi
    fdco_h = (fnodco_h) * pi
    hn = firwin(N, (fnodco_l, fnodco_h), window=window, pass_zero=False)

    return hn


def get_BSF_hn(N, fl, fh, fs, window='boxcar'):
    """
    create h[n] of a band stop filter
    N: Filter order
    fl: low frequency
    fh: high frequency
    fs: Sampling frequency

    window:
    - boxcar: Also known as a rectangular window or Dirichlet window, this is equivalent to no window at all.
    - hamming
    - hann
    - ...
    """
    fnyq = 2 * fh  # Nyquist rate
    # Normalized digital cut-off frequencies
    fnodco_l = fl/fs
    fnodco_h = fh/fs
    # Digital cut-off frequencies
    fdco_l = (fnodco_l) * pi
    fdco_h = (fnodco_h) * pi
    hn = firwin(N, (fnodco_l, fnodco_h), window=window)

    return hn
