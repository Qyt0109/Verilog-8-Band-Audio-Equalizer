from fir import quantize_hn, lpf, hpf, bpf, bsf, save_list_as_txt

if __name__ == "__main__":
    hn_hpf = hpf(N=63, fl=None, fh=7000, fs=16000, window='hamming')
    print(hn_hpf)
    quantized_hn_binary = quantize_hn(hn=hn_hpf, total_bits=16, fraction_bits=15, is_signed=True, as_binary=True)
    quantized_hn = quantize_hn(hn=hn_hpf, total_bits=16, fraction_bits=15, is_signed=True, as_binary=False)
    print(quantized_hn_binary)
    print(quantized_hn)
    
    save_list_as_txt(elements=quantized_hn_binary, save_path="./wavs/hn_hpf.txt")

    """ Example Output
    [-0.01970142  0.0876456  -0.23563719  0.31403158 -0.23563719  0.0876456 -0.01970142]
    ['1111110101111011', '0000101100110111', '1110000111010111', '0010100000110010', '1110000111010111', '0000101100110111', '1111110101111011']
    [-0.019683837890625, 0.087615966796875, -0.235626220703125, 0.31402587890625, -0.235626220703125, 0.087615966796875, -0.019683837890625]
    """