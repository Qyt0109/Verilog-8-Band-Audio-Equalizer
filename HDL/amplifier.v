module amplifier #(
    parameter NUMBER_OF_FILTERS = 8,
    parameter GAIN_BITS = 2,
    parameter FILTER_IN_BITS = 16,
    parameter FILTER_OUT_BITS = 16
) (
    input en,

    input [NUMBER_OF_FILTERS*GAIN_BITS-1:0] gains,
    input [FILTER_IN_BITS-1:0] filter_in,
    output [NUMBER_OF_FILTERS*FILTER_IN_BITS-1:0] amplified_filter_ins
);
  wire [GAIN_BITS-1:0] w_gains[0:NUMBER_OF_FILTERS];
  wire signed [FILTER_IN_BITS-1:0] w_amplified_filter_ins[0:NUMBER_OF_FILTERS];

  genvar filter_index;
  generate
    for (
        filter_index = 0; filter_index < NUMBER_OF_FILTERS; filter_index = filter_index + 1
    ) begin : gen_amplifier
      assign w_gains[filter_index] = gains[(filter_index+1)*GAIN_BITS-1:filter_index*GAIN_BITS];
      assign w_amplified_filter_ins[filter_index] = filter_in * w_gains[filter_index];
      assign amplified_filter_ins[(filter_index+1)*FILTER_IN_BITS-1:filter_index*FILTER_IN_BITS] = (en == 1) ? w_amplified_filter_ins[filter_index] : filter_in;
    end
  endgenerate

endmodule  //amplifier
