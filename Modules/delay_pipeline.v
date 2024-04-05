`timescale 1 ns / 1 ns

module delay_pipeline (
    input clk,
    input rst,

    input [5:0] current_count,  // current_count from counter

    input               phase_63,        // from phase_check's phase_63
    // signed fixed-point 16 bit with 15 bit for fraction. Value range [-1, 1)
    input signed [15:0] i_signal_sample, // from filter's i_signal_sample

    output signed [15:0] input_mux
);

  localparam NUMBER_OF_PIPE = 64;
  integer pipe_reset_index;
  integer pipe_index;

  // Define shift register
  reg signed [15:0] delay_pipeline[0:NUMBER_OF_PIPE-1];

  always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
      // Reset the shift register
      for (
          pipe_reset_index = 0;
          pipe_reset_index < NUMBER_OF_PIPE;
          pipe_reset_index = pipe_reset_index + 1
      ) begin
        delay_pipeline[pipe_reset_index] <= 0;
      end
    end else begin
      if (phase_63 == 1) begin
        // Shift data through the pipeline
        for (pipe_index = NUMBER_OF_PIPE - 1; pipe_index > 0; pipe_index = pipe_index - 1) begin
          delay_pipeline[pipe_index] <= delay_pipeline[pipe_index-1];
        end
        // Load new sample into the first stage
        delay_pipeline[0] <= i_signal_sample;
      end
    end
  end

  // MUXs
  // mux control
  assign input_mux = delay_pipeline[current_count];

endmodule  //delay_pipeline
