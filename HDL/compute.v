module compute (
    input clk,
    input rst,
    input clk_enable,

    input signed [15:0] delay_filter_in,  // input_mux from delay_pipeline, which is the sample at a specific time. signed integer 16 bit. [-32768, 32768 - 1]

    input signed [15:0] coeff,  // product_mux from coeffs_control, which is the corespponding coeff at a specific slot. signed fixed-point 16 bit, 18 frac. [-0.125, 0,125 - 3.814697265625e-06]

    input phase_0,  // phase_0 from phase_check

    output signed [15:0] filter_out  // output
);
  // signed fixed-point 32.16. [-32768, 32768 - 1.52587890625e-05]
  wire signed [31:0] product = delay_filter_in * coeff;

  // signed fixed-point 34.16. [-131072, 131072 - 1.52587890625e-05]
  wire signed [33:0] sign_extended_product = $signed({{2{product[31]}}, product});
  wire signed [33:0] next_value_to_add = acc_out;

  // signed fixed-point 35.16. [-262144, 262144 - 1.52587890625e-05]
  wire signed [34:0] add_temp = sign_extended_product + next_value_to_add;

  // signed fixed-point 34.16. [-131072, 131072 - 1.52587890625e-05]
  wire signed [33:0] acc_sum = add_temp[33:0];  // Cut overflow bit off add_temp

  wire signed [33:0] acc_in = (phase_0 == 1) ? sign_extended_product : acc_sum;
  reg signed  [33:0] acc_out;

  reg signed  [33:0] acc_final;

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

  // caculate final sum (phase_0 == 1 mean that a new loop begin, so now is the time for us to push acc_final)
  always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
      acc_final <= 0;
    end else begin
      if (phase_0 == 1) begin
        acc_final <= acc_out;
      end
    end
  end

  /*  Convert the output of the filter:
        - rounding: floor
        - overflow: saturate
  */
  assign filter_out =
      // positive overflow => stay at max signed integer 16 (saturate)
      ((acc_final[33] == 0) & (acc_final[32:31] != 2'b00)) ? 16'b0111111111111111 :
      // negative overflow => stay at min signed integer 16 (saturate)
      ((acc_final[33] == 1) & (acc_final[32:31] != 2'b11)) ? 16'b1000000000000000 :
      // if not overflow, only keep the 16 bit of signed integer (flooring)
      acc_final[31:16];

endmodule  //compute
