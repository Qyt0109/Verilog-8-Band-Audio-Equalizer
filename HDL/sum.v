module sum #(
    parameter FILTER_OUT_BITS   = 16,
    parameter NUMBER_OF_FILTERS = 8
) (
    input clk,
    input rst,
    input [NUMBER_OF_FILTERS*FILTER_OUT_BITS-1:0] filtered_outs,
    output sum_filtered_outs
);
  wire signed filtered_out[0:NUMBER_OF_FILTERS];

  generate
    for (
        genvar filtered_out_index = 0;
        filtered_out_index < NUMBER_OF_FILTERS;
        filtered_out_index = filtered_out_index + 1
    ) begin : gen_filtered_out
      assign filtered_out[filtered_out_index] = filtered_outs[(filtered_out_index+1)*FILTER_OUT_BITS-1:filtered_out_index*FILTER_OUT_BITS];
    end
  endgenerate

endmodule
