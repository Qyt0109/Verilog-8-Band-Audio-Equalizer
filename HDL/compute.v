module compute #(
    parameter FILTER_IN_BITS = 16,
    parameter FILTER_OUT_BITS = 16,
    parameter NUMBER_OF_TAPS = 64,
    parameter COEFF_BITS = 16,
    parameter COEFF_FRAC_BITS = 16
) (
    input clk,
    input rst,
    input clk_enable,

    input signed [FILTER_IN_BITS-1:0] delay_filter_in,  // input_mux from delay_pipeline, which is the sample at a specific time. signed integer 16 bit. [-32768, 32768 - 1]

    input signed [COEFF_BITS-1:0] coeff,  // product_mux from coeffs_control, which is the corespponding coeff at a specific slot. signed fixed-point 16 bit, 18 frac. [-0.125, 0,125 - 3.814697265625e-06]

    input phase_min,  // phase_min from phase_check

    output signed [FILTER_OUT_BITS-1:0] filter_out  // output
);
  parameter PRODUCT_BITS = FILTER_IN_BITS + COEFF_BITS;

  // signed fixed-point 32.16. [-32768, 32768 - 1.52587890625e-05]
  wire signed [PRODUCT_BITS-1:0] product = delay_filter_in * coeff;

  // signed fixed-point 34.16. [-131072, 131072 - 1.52587890625e-05]
  wire signed [PRODUCT_BITS-1 + 2:0] sign_extended_product = $signed(
      {{2{product[PRODUCT_BITS-1]}}, product}
  );
  wire signed [PRODUCT_BITS-1 + 2:0] next_value_to_add = acc_out;

  // signed fixed-point 35.16. [-262144, 262144 - 1.52587890625e-05]
  wire signed [PRODUCT_BITS-1 + 3:0] add_temp = sign_extended_product + next_value_to_add;

  // signed fixed-point 34.16. [-131072, 131072 - 1.52587890625e-05]
  wire signed [PRODUCT_BITS-1 + 2:0] acc_sum = add_temp[PRODUCT_BITS-1 + 2:0];  // Cut overflow bit off add_temp

  wire signed [PRODUCT_BITS-1 + 2:0] acc_in = (phase_min == 1) ? sign_extended_product : acc_sum;
  reg signed [PRODUCT_BITS-1 + 2:0] acc_out;

  reg signed [PRODUCT_BITS-1 + 2:0] acc_final;

  // push acc_in to acc_out on rising clk when clk_enable
  always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
      acc_out <= 0;
    end else begin
      if (clk_enable == 1) begin
        acc_out <= acc_in;
      end
    end
  end

  // caculate final sum (phase_min == 1 mean that a new loop begin, so now is the time for us to push acc_final)
  always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
      acc_final <= 0;
    end else begin
      if (phase_min == 1) begin
        acc_final <= acc_out;
      end
    end
  end

  /* rounding: floor, overflow: saturate
  ┌───────────────────────────────────────────────────────────────────────────┐
  │                                                                           │
  │    ◀─────16──────▶        ◀──8──▶          ◀──────────24─────────▶        │
  │   ┌┐                     ┌┐               ┌┐                              │
  │   S├┬┬┬┬┬┬┬┬┬┬┬┬┬┬┐      S├┬┬┬┬┬┬┐        S├┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┐       │
  │   └┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┘  *   └┴┴┴┴┴┤││    =   └┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┤││       │
  │     ◀────────────▶         ◀──▶└┴┘          ◀──────────────────▶└┴┘       │
  │           int              int ◀─▶                   int        ◀─▶       │
  │                               frac                             frac       │
  │                                                                           │
  │                                                                    frac   │
  │                                       ┌┐         ◀─────16──────▶    ◀─▶   │
  │                              ===>     S├┬┬┬┬┐   ┌┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┐   ┌┬┐   │
  │                                       └┴┴┴┴┴┘...└┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┘...│││   │
  │                                                  ◀─────────────▶    └┴┘   │
  │                                      overflow       coverted        ◀─▶   │
  │                                     (saturate)       result        round  │
  │                                                                   (floor) │
  │                                                                           │
  └───────────────────────────────────────────────────────────────────────────┘
  */
  localparam ACC_FINAL_BITS = PRODUCT_BITS + 2;  // = FILTER_IN_BITS + COEFF_BITS + 2
  localparam ACC_FINAL_SIGN_BIT = ACC_FINAL_BITS - 1;  // Location of Sign bit
  localparam ACC_FINAL_CHECK_BIT_HIGH = ACC_FINAL_SIGN_BIT - 1; // Location of high bit of check region
  localparam ACC_FINAL_CHECK_BIT_LOW = COEFF_FRAC_BITS + FILTER_OUT_BITS; // Location of low bit of check region
  localparam ACC_FINAL_CHECK_BITS = ACC_FINAL_CHECK_BIT_HIGH - ACC_FINAL_CHECK_BIT_LOW + 1; // Number of bits of check region

  localparam ACC_FINAL_CONVERTED_HIGH_BIT = COEFF_FRAC_BITS + FILTER_OUT_BITS - 1;
  localparam ACC_FINAL_CONVERTED_LOW_BIT = COEFF_FRAC_BITS;

  assign filter_out =
      // positive overflow => stay at max signed integer (saturate)
      ((acc_final[ACC_FINAL_SIGN_BIT] == 0) & (acc_final[ACC_FINAL_CHECK_BIT_HIGH:ACC_FINAL_CHECK_BIT_LOW] != {(ACC_FINAL_CHECK_BITS){1'b0}})) ? {1'b0, {(FILTER_OUT_BITS-1){1'b1}}}: // 01111...111
      // negative overflow => stay at min signed integer (saturate)
      ((acc_final[ACC_FINAL_SIGN_BIT] == 1) & (acc_final[ACC_FINAL_CHECK_BIT_HIGH:ACC_FINAL_CHECK_BIT_LOW] != {(ACC_FINAL_CHECK_BITS){1'b1}})) ? {1'b1, {(FILTER_OUT_BITS-1){1'b0}}}: // 10000...000
      // if not overflow, round down by cutoff all unnecessary bits (flooring)
      acc_final[ACC_FINAL_CONVERTED_HIGH_BIT:ACC_FINAL_CONVERTED_LOW_BIT];
endmodule  //compute
