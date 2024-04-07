module delay_pipeline (
    input clk,
    input rst,

    input phase_0,  // phase_0 from counter to trigger a new sample of filter_in to be shifted in
    input [5:0] current_count,  // current_count from counter to select a filter_in at specific time delay

    input signed [15:0] filter_in,  // filter_in from filter

    output signed [15:0] delay_filter_in  // same as filter_input datatype. signed integer 16 bit. [-32768, 32768 - 1]
);

  localparam NUMBER_OF_PIPE = 64;
  integer pipe_index;

  // Hold up to NUMBER_OF_PIPE = 64 present and past filter_in values from filter
  // Same datatype as filter_in. Signed integer 16. [-32768, 32768 - 1]
  reg signed [15:0] delay_pipeline[0:NUMBER_OF_PIPE-1];

  always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
      // Reset shift registers
      for (pipe_index = 0; pipe_index < NUMBER_OF_PIPE; pipe_index = pipe_index + 1) begin
        delay_pipeline[pipe_index] <= 0;
      end
    end else begin
      // New shift to hold new filter_in value if phase_0 is triggered
      if (phase_0 == 1) begin
        // Load new sample into the first stage
        delay_pipeline[0] <= filter_in;
        // Shift data through the pipeline
        for (pipe_index = 1; pipe_index < NUMBER_OF_PIPE; pipe_index = pipe_index + 1) begin
          delay_pipeline[pipe_index] <= delay_pipeline[pipe_index-1];
        end
      end
    end
  end

  // MUX
  // current_count loop through any delay_pipeline, which is current and in the past input samples
  // delay_filter_in return each delay_pipeline at current_count index, which is the input sample in a specific delayed time
  assign delay_filter_in = delay_pipeline[current_count];

endmodule  //delay_pipeline
