module filter #(
    parameter FILTER_IN_BITS = 16,
    parameter FILTER_OUT_BITS = 16,
    parameter COUNTER_BITS = 6,
    parameter NUMBER_OF_TAPS = 64,
    parameter COEFF_BITS = 16,
    parameter COEFF_FRAC_BITS = 16
) (
    input clk,
    input rst,
    input clk_enable,

    // delay_pipeline
    input                                        phase_min,
    input signed [           FILTER_IN_BITS-1:0] amplified_filter_in,
    // coeffs
    input        [             COUNTER_BITS-1:0] current_count,
    input        [COEFF_BITS*NUMBER_OF_TAPS-1:0] coeffs_feed,

    output signed [FILTER_OUT_BITS-1:0] filtered_out
);

  // region coeffs
  wire signed [COEFF_BITS-1:0] coeff;

  coeffs #(
      .COUNTER_BITS(COUNTER_BITS),
      .NUMBER_OF_TAPS(NUMBER_OF_TAPS),
      .COEFF_BITS(COEFF_BITS)
  ) coeffs_inst (
      .current_count(current_count),
      .coeffs(coeffs_feed),

      .coeff(coeff)
  );
  // endregion coeffs

  // region delay_pipeline
  wire signed [FILTER_IN_BITS-1:0] delay_filter_in;

  delay_pipeline #(
      .FILTER_IN_BITS(FILTER_IN_BITS),
      .FILTER_OUT_BITS(FILTER_OUT_BITS),
      .COUNTER_BITS(COUNTER_BITS),
      .NUMBER_OF_TAPS(NUMBER_OF_TAPS)
  ) delay_pipeline_inst (
      .clk(clk),
      .rst(rst),

      .phase_min(phase_min),
      .current_count(current_count),

      .filter_in(amplified_filter_in),

      .delay_filter_in(delay_filter_in)
  );
  // endregion delay_pipeline

  // region compute
  compute #(
      .FILTER_IN_BITS(FILTER_IN_BITS),
      .FILTER_OUT_BITS(FILTER_OUT_BITS),
      .NUMBER_OF_TAPS(NUMBER_OF_TAPS),
      .COEFF_BITS(COEFF_BITS),
      .COEFF_FRAC_BITS(COEFF_FRAC_BITS)
  ) compute_inst (
      .clk(clk),
      .rst(rst),
      .clk_enable(clk_enable),

      .delay_filter_in(delay_filter_in),

      .coeff(coeff),

      .phase_min(phase_min),

      .filter_out(filtered_out)
  );

  // endregion compute

endmodule  //filter
