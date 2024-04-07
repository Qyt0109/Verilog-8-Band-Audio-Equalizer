module filter (
    // system signal ports
    input clk,
    input clk_enable,
    input rst,

    // filter module ports
    input signed [15:0] filter_in,  // signed integer 16. [-32768, 32768 - 1]

    output signed [15:0] filter_out  // signed integer 16. [-32768, 32768 - 1]
);

  // region counter
  wire [5:0] current_count;
  wire phase_0;

  counter counter_inst (
      .clk(clk),
      .clk_enable(clk_enable),
      .rst(rst),

      .current_count(current_count),
      .phase_0(phase_0)
  );
  // endregion counter

  // region delay_pipeline
  wire signed [15:0] delay_filter_in;

  delay_pipeline delay_pipeline_inst (
      .clk(clk),
      .rst(rst),

      .phase_0(phase_0),
      .current_count(current_count),

      .filter_in(filter_in),

      .delay_filter_in(delay_filter_in)
  );
  // endregion delay_pipeline

  // region coeffs
  wire signed [15:0] coeff;

  coeffs coeffs_inst (
      .current_count(current_count),

      .coeff(coeff)
  );
  // endregion coeffs

  // region compute
  compute compute_inst (
      .clk(clk),
      .rst(rst),
      .clk_enable(clk_enable),

      .delay_filter_in(delay_filter_in),

      .coeff(coeff),

      .phase_0(phase_0),

      .filter_out(filter_out)
  );

  // endregion compute

endmodule
