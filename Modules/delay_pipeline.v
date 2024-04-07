module delay_pipeline (
    input clk,
    input rst,

    input [5:0] current_count,  // current_count from counter

    input phase_63,  // phase_63 from phase_check

    input signed [15:0] filter_in,  // filter_in from filter

    output signed [15:0] input_mux  // same as filter_input datatype. signed integer 16 bit. [-32768, 32768 - 1]
);

  localparam NUMBER_OF_PIPE = 64;
  integer pipe_reset_index;
  integer pipe_index;

  // Define shift registers
  reg signed [15:0] delay_pipeline[0:NUMBER_OF_PIPE-1];

  always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
      // Reset shift registers
      for (
          pipe_reset_index = 0;
          pipe_reset_index < NUMBER_OF_PIPE;
          pipe_reset_index = pipe_reset_index + 1
      ) begin
        delay_pipeline[pipe_reset_index] <= 0;
      end
    end else begin
      // New shift if phase63 is triggered
      if (phase_63 == 1) begin
        // Shift data through the pipeline
        for (pipe_index = NUMBER_OF_PIPE - 1; pipe_index > 0; pipe_index = pipe_index - 1) begin
          delay_pipeline[pipe_index] <= delay_pipeline[pipe_index-1];
        end
        // Load new sample into the first stage
        delay_pipeline[0] <= filter_in;
      end
    end
  end

  // MUX
  // current_count loop through any delay_pipeline, which is current and in the past input samples
  // input_mux return each delay_pipeline at current_count index, which is the input sample in a specific delayed time
  assign input_mux = delay_pipeline[current_count];

endmodule  //delay_pipeline
