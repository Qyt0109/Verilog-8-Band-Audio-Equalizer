`timescale 1 ns / 1 ns

module compute (
    input clk,
    input rst,
    input clk_enable,

    input signed [15:0] input_mux,  // input_mux from delay_pipeline, which is the sample at a specific time. signed integer 16 bit. [-32768, 32768 - 1]

    input signed [15:0] product_mux,  // product_mux from coeffs_control, which is the corespponding coeff at a specific slot. signed fixed-point 16 bit, 18 frac. [-0.125, 0,125 - 3.814697265625e-06]

    input phase_0,  // phase_0 from phase_check
    input phase_63, // phase_63 from phase_check

    output reg signed [15:0] filter_out  // output
);

  // Product
  wire signed [31:0] mul_temp;  // signed fixed-point 32 bit, 18 frac. [-8192, 8192 - 3.814697265625e-06]
  wire signed [33:0] product;   // signed fixed-point 34 bit, 18 frac. [-32768, 32768 - 3.814697265625e-06]

  assign mul_temp = input_mux * product_mux;  // = sample x coeff = x(n - current_count) x h(n - current_count)
  /* EX: expected product = 0.01923751831
  input_mux = delay_pipeline[current_count] = -123 = (1)111111110000101. = 111111110000101
  product_mux = coeffs_shadow[current_count] = -0.000156402587890625 = .uu(1)111111111010111 = 111111111010111
  sign = (1) xor (1) = (0)
  mul_temp = input_mux * product_mux = 111111110000101 * 111111111010111 = 0111111101011100001001110110011 = (0)0111111101011.100001001110110011

  product  = $signed({{2{mul_temp[31]}}, mul_temp}) = (0)(0) (0)0111111101011.100001001110110011 = 0000111111101011100001001110110011

  sign_extended_product = $signed({{2{product[33]}}, product}) = (0)(0) 0000111111101011100001001110110011 = 00[0000111111101011]100001001110110011
  */
  // sign extended 32 --> 34 bit
  assign product  = $signed({{2{mul_temp[31]}}, mul_temp}); // sign extended of mul_temp

  wire signed [35:0] sign_extended_product; // signed fixed 36.18
  // sign extended 34 --> 36 bit
  assign sign_extended_product = $signed({{2{product[33]}}, product});

  // Add Acc
  wire signed [36:0] add_temp;  // signed fixed 37.18
  wire signed [35:0] acc_sum;  //signed fixed 36.18
  wire signed [35:0] acc_in;  // signed fixed 36.18
  reg signed  [35:0] acc_out;  // signed fixed 36.18

  wire signed [32:0] sign_extended_add;  // signed fixed 33.31
  wire signed [32:0] w_acc_out;  // signed fixed 33.31

  assign sign_extended_add = sign_extended_product;
  assign w_acc_out = acc_out;
  assign add_temp = sign_extended_add + w_acc_out;
  assign acc_sum = add_temp[35:0];  // Cutoff 1 overflow bit from add_temp

  assign acc_in = (phase_0 == 1) ? sign_extended_product : acc_sum;

  always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
      acc_out <= 0;
    end else begin
      if (clk_enable == 1) begin
        acc_out <= acc_in;
      end
    end
  end

  reg signed [35:0] acc_final;  // signed fixed 36.18

  // final sum
  always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
      acc_final <= 0;
    end else begin
      if (phase_0 == 1) begin
        acc_final <= acc_out;
      end
    end
  end

  // Saturate value if overflow
  wire signed [15:0] output_typeconvert;
  assign output_typeconvert =
      // if sign = 0 and 17 msb of acc_final's fraction part != Min positive value (0) => output_typeconvert = Max positive value (0_111...1)
      (acc_final[35] == 0 & acc_final[34:33] != 2'b00) ?
            16'b0111111111111111 : // Max positive
      // else if sign = 1 and 17 msb of acc_final's fraction part != Min positive value (0) => output_typeconvert = Min negative value (1_000...0)
      (acc_final[35] == 1 && acc_final[34:13] != 2'b11) ?
            16'b1000000000000000 : // Min negative
      // else
      acc_final[33:18];  // value in range

  always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
      filter_out <= 0;
    end else begin
      if (phase_63 == 1) begin
        filter_out <= output_typeconvert;
      end
    end
  end

endmodule  //compute
