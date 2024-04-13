module equalizer_8band #(
    parameter FILTER_IN_BITS = 16,
    parameter FILTER_OUT_BITS = 16,
    parameter NUMBER_OF_FILTERS = 8,
    parameter GAIN_BITS = 2,
    parameter GAIN_FRAC_BITS = 0,
    parameter COUNTER_MIN = 6'b000000,
    parameter COUNTER_MAX = 6'b111111,
    parameter COUNTER_BITS = $clog2(COUNTER_MAX),

    parameter NUMBER_OF_TAPS = 64,
    parameter COEFF_BITS = 16,
    parameter COEFF_FRAC_BITS = 16,

    parameter FILTER_COEFFS_TXT = "./filter_coeffs/filters_coeffs.txt"
) (
    // system signal ports
    input clk,
    input clk_enable,
    input rst,

    input amplifier_enable,
    input [NUMBER_OF_FILTERS*GAIN_BITS-1:0] amplifier_gains,

    // filter module ports
    input signed [FILTER_IN_BITS-1:0] filter_in,  // signed integer 16. [-32768, 32768 - 1]

    output reg signed [FILTER_OUT_BITS-1:0] filter_out  // signed integer 16. [-32768, 32768 - 1]
);
  // region parameters

  // endregion parameters

  // region counter

  wire [COUNTER_BITS-1:0] current_count;
  wire phase_min;

  counter #(
      .COUNTER_MIN(COUNTER_MIN),
      .COUNTER_MAX(COUNTER_MAX)
  ) counter_inst (
      .clk(clk),
      .clk_enable(clk_enable),
      .rst(rst),

      .current_count(current_count),
      .phase_min(phase_min)
  );
  // endregion counter

  // region amplifier
  wire [NUMBER_OF_FILTERS*FILTER_IN_BITS-1:0] amplified_filter_ins;
  wire [FILTER_IN_BITS-1:0] v_amplified_filter_ins[0:NUMBER_OF_FILTERS-1];

  amplifier #(
      .NUMBER_OF_FILTERS(NUMBER_OF_FILTERS),
      .GAIN_BITS(GAIN_BITS),
      .GAIN_FRAC_BITS(GAIN_FRAC_BITS),
      .FILTER_IN_BITS(FILTER_IN_BITS)
  ) amplifier_inst (
      .en(amplifier_enable),
      .gains(amplifier_gains),
      .filter_in(filter_in),
      .amplified_filter_ins(amplified_filter_ins)
  );
  // endregion amplifier

  // region delay_pipeline
  wire signed [FILTER_IN_BITS-1:0] delay_filter_in[0:NUMBER_OF_FILTERS-1];
  // endregion delay_pipeline

  // region coeffs
  reg [COEFF_BITS*NUMBER_OF_TAPS-1:0] coeffs[0:NUMBER_OF_FILTERS-1];
  wire signed [COEFF_BITS-1:0] coeff[0:NUMBER_OF_FILTERS-1];

  initial begin
    // read coeffs for each filter from text file
    $readmemb(FILTER_COEFFS_TXT, coeffs);
  end
  // endregion coeffs

  // region compute
  wire signed [FILTER_OUT_BITS-1:0] filtered_out[0:NUMBER_OF_FILTERS-1];
  // endregion compute

  // region generate filters
  generate
    genvar filter_index;
    for (
        filter_index = 0; filter_index < NUMBER_OF_FILTERS; filter_index = filter_index + 1
    ) begin : gen_filters

      // region amplifier generate
      assign v_amplified_filter_ins[filter_index] = amplified_filter_ins[(filter_index+1)*FILTER_IN_BITS-1:filter_index*FILTER_IN_BITS];
      // endregion amplifier generate

      // region filter generate
      filter #(
          .FILTER_IN_BITS(FILTER_IN_BITS),
          .FILTER_OUT_BITS(FILTER_OUT_BITS),
          .COUNTER_BITS(COUNTER_BITS),
          .NUMBER_OF_TAPS(NUMBER_OF_TAPS),
          .COEFF_BITS(COEFF_BITS),
          .COEFF_FRAC_BITS(COEFF_FRAC_BITS)
      ) filter_inst (
          .clk(clk),
          .rst(rst),
          .clk_enable(clk_enable),
          .phase_min(phase_min),
          .amplified_filter_in(v_amplified_filter_ins[filter_index]),
          .current_count(current_count),
          .coeffs_feed(coeffs[filter_index]),
          .filtered_out(filtered_out[filter_index])
      );

      // endregion filter generate
    end
  endgenerate
  // region generate filters
  integer filter_out_index;
  always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
      filter_out <= 0;
    end else begin
      filter_out = filtered_out[0];
      for (
          filter_out_index = 1;
          filter_out_index < NUMBER_OF_FILTERS;
          filter_out_index = filter_out_index + 1
      ) begin
        filter_out = filter_out + filtered_out[filter_out_index];
      end
    end
  end
endmodule  // equalizer_8band
