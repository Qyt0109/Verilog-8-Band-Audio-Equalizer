from freq_spec import plot_frequency_spectrum
from wav import Wav


if __name__ == "__main__":
    file_path = "../HDL/Test8Band/"

    files = [
        "o_lpf_1000hz",
        "o_bpf_1000hz2000hz",
        "o_bpf_2000hz3000hz",
        "o_bpf_3000hz4000hz",
        "o_bpf_4000hz5000hz",
        "o_bpf_5000hz6000hz",
        "o_bpf_6000hz7000hz",
        "o_hpf_7000hz",
        "o_filter_out"
    ]

    wav_from_txt = Wav()
    wav_from_txt.channels = 1
    wav_from_txt.sample_rate = 16000
    wav_from_txt.sample_width = 16

    # while True:
    try:
        for file in files:
            wav_from_txt.load_from_txt(txt_path=f"{file_path}output_txt/{file}.txt")
            plot_frequency_spectrum(wav=wav_from_txt,
                                    save_path=f"{file_path}images/{file}",
                                    is_show=False)
    except Exception as e:
        print("error\n")
