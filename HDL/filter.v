module filter #(
    parameter FILTER_IN_BITS = 16,
    parameter FILTER_OUT_BITS = 16,
    parameter NUMBER_OF_FILTERS = 8,
    parameter GAIN_BITS = 2,
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

    output reg signed [FILTER_OUT_BITS-1:0] filter_out,  // signed integer 16. [-32768, 32768 - 1]
    // TODO: Remove this region (TEST ONLY)
    output signed [FILTER_OUT_BITS-1:0] filter_lpf_1000hz,
    output signed [FILTER_OUT_BITS-1:0] filter_bpf_1000hz2000hz,
    output signed [FILTER_OUT_BITS-1:0] filter_bpf_2000hz3000hz,
    output signed [FILTER_OUT_BITS-1:0] filter_bpf_3000hz4000hz,
    output signed [FILTER_OUT_BITS-1:0] filter_bpf_4000hz5000hz,
    output signed [FILTER_OUT_BITS-1:0] filter_bpf_5000hz6000hz,
    output signed [FILTER_OUT_BITS-1:0] filter_bpf_6000hz7000hz,
    output signed [FILTER_OUT_BITS-1:0] filter_hpf_7000hz
    // TODO: Remove this region (TEST ONLY)
);
  // region parameters

  // endregion parameters

  // region counter

  wire [COUNTER_BITS-1:0] current_count;
  wire phase_min;
  wire phase_max;

  counter #(
      .COUNTER_MIN(COUNTER_MIN),
      .COUNTER_MAX(COUNTER_MAX)
  ) counter_inst (
      .clk(clk),
      .clk_enable(clk_enable),
      .rst(rst),

      .current_count(current_count),
      .phase_min(phase_min),
      .phase_max(phase_max)
  );
  // endregion counter

  // region amplifier
  wire [NUMBER_OF_FILTERS*FILTER_IN_BITS-1:0] amplified_filter_ins;
  wire [FILTER_IN_BITS-1:0] v_amplified_filter_ins[0:NUMBER_OF_FILTERS-1];

  amplifier #(
      .NUMBER_OF_FILTERS(NUMBER_OF_FILTERS),
      .GAIN_BITS(GAIN_BITS),
      .FILTER_IN_BITS(FILTER_IN_BITS),
      .FILTER_OUT_BITS(FILTER_OUT_BITS)
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
  wire [COEFF_BITS*NUMBER_OF_TAPS-1:0] coeffs[0:NUMBER_OF_FILTERS-1];
  reg [COEFF_BITS-1:0] r_coeffs[0:NUMBER_OF_FILTERS-1][0:NUMBER_OF_TAPS-1];
  wire signed [COEFF_BITS-1:0] coeff[0:NUMBER_OF_FILTERS-1];

  initial begin
    // read coeffs for each filter from text file
    $readmemb(FILTER_COEFFS_TXT, r_coeffs);
  end
  // endregion coeffs

  // region compute
  wire signed [FILTER_OUT_BITS-1:0] filtered_out[0:NUMBER_OF_FILTERS-1];
  wire [NUMBER_OF_FILTERS*FILTER_OUT_BITS-1:0] filtered_outs;
  // endregion compute

  // region generate filters
  generate
    for (
        genvar filter_index = 0; filter_index < NUMBER_OF_FILTERS; filter_index = filter_index + 1
    ) begin
      // region amplifier generate
      assign v_amplified_filter_ins[filter_index] = amplified_filter_ins[(filter_index+1)*FILTER_IN_BITS-1:filter_index*FILTER_IN_BITS];
      // endregion amplifier generate

      // region delay_pipeline generate
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

          .filter_in(v_amplified_filter_ins[filter_index]),

          .delay_filter_in(delay_filter_in[filter_index])
      );
      // endregion delay_pipeline generate

      // region coeffs generate
      for (
          genvar coeffs_lpf_1000hz_index = 0;
          coeffs_lpf_1000hz_index < NUMBER_OF_TAPS;
          coeffs_lpf_1000hz_index = coeffs_lpf_1000hz_index + 1
      ) begin : gen_coeffs_lpf_1000hz
        assign coeffs[filter_index][(coeffs_lpf_1000hz_index+1)*COEFF_BITS-1:coeffs_lpf_1000hz_index*COEFF_BITS] = r_coeffs[filter_index][coeffs_lpf_1000hz_index];
      end

      coeffs #(
          .COUNTER_BITS(COUNTER_BITS),
          .NUMBER_OF_TAPS(NUMBER_OF_TAPS),
          .COEFF_BITS(COEFF_BITS)
      ) coeffs_inst (
          .current_count(current_count),
          .coeffs(coeffs[filter_index]),

          .coeff(coeff[filter_index])
      );
      // endregion coeffs generate

      // region compute generate
      assign filtered_outs[(filter_index+1)*FILTER_OUT_BITS-1:filter_index*FILTER_OUT_BITS] = filtered_out[filter_index];

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

          .delay_filter_in(delay_filter_in[filter_index]),

          .coeff(coeff[filter_index]),

          .phase_min(phase_min),

          .filter_out(filtered_out[filter_index])
      );
      // endregion computer generate
    end
  endgenerate
  // region generate filters

  always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
      filter_out <= 0;
    end else begin
      filter_out = filtered_out[0];
      for(integer filter_out_index = 1; filter_out_index < NUMBER_OF_FILTERS; filter_out_index = filter_out_index + 1) begin
        filter_out = filter_out + filtered_out[filter_out_index];
      end
    end
  end

  // TODO: Remove this region (TEST ONLY)
  assign filter_lpf_1000hz = filtered_out[0];
  assign filter_bpf_1000hz2000hz = filtered_out[1];
  assign filter_bpf_2000hz3000hz = filtered_out[2];
  assign filter_bpf_3000hz4000hz = filtered_out[3];
  assign filter_bpf_4000hz5000hz = filtered_out[4];
  assign filter_bpf_5000hz6000hz = filtered_out[5];
  assign filter_bpf_6000hz7000hz = filtered_out[6];
  assign filter_hpf_7000hz = filtered_out[7];
  // TODO: Remove this region (TEST ONLY)

endmodule
