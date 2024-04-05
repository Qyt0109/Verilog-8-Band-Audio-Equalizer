module compute (
    input clk,
    input rst,
    input clk_enable,

    input signed [15:0] input_mux,  // input_mux from delay_pipeline
    
    input signed [15:0] product_mux,  // product_mux from coeffs_control

    input phase_0,  // phase_0 from phase_check
    input phase_63,  // phase_63 from phase_check

    output reg signed [15:0] filtered_sample
);

  /*
  wire signed [15:0] inputmux_1;  // sfix16_En15
  reg signed [32:0] acc_final;  // sfix33_En31
  reg signed [32:0] acc_out_1;  // sfix33_En31
  wire signed [30:0] product_1;  // sfix31_En31
  wire signed [15:0] product_1_mux;  // sfix16_En15
  wire signed [31:0] mul_temp;  // sfix32_En30
  wire signed [32:0] prod_typeconvert_1;  // sfix33_En31
  wire signed [32:0] acc_sum_1;  // sfix33_En31
  wire signed [32:0] acc_in_1;  // sfix33_En31
  wire signed [32:0] add_signext;  // sfix33_En31
  wire signed [32:0] add_signext_1;  // sfix33_En31
  wire signed [33:0] add_temp;  // sfix34_En31
  wire signed [15:0] output_typeconvert;  // sfix16_En31
  reg signed [15:0] output_register;  // sfix16_En31
  */

  // Product
  wire signed [31:0] mul_temp;
  wire signed [30:0] product;

  assign mul_temp = input_mux * product_mux;
  assign product  = $signed({{2{mul_temp[29:0], 1'b0}}});

  wire signed [32:0] sign_extended_product;
  // sign extended 30 --> 32 bit
  assign sign_extended_product = $signed({{2{product[30]}}, product});

  // Add Acc
  wire signed [33:0] add_temp;  // signed fixed 34.31
  wire signed [32:0] acc_sum;  // signed fixed 33.31
  wire signed [32:0] acc_in;  // signed fixed 33.31
  reg signed  [32:0] acc_out;  // signed sixed 33.31

  wire signed [32:0] sign_extended_add;  // signed fixed 33.31
  wire signed [32:0] w_acc_out;  // signed fixed 33.31

  assign sign_extended_add = sign_extended_product;
  assign w_acc_out = acc_out;
  assign add_temp = sign_extended_add + w_acc_out;
  assign acc_sum = add_temp[32:0];  // Cutoff 1 overflow bit

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

  reg signed [32:0] acc_final;  // signed fixed 33.31

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
      (acc_final[32] == 0 & acc_final[31:15] != 17'b00000000000000000) ?
            16'b0111111111111111 : // Max positive
      // else if sign = 1 and 17 msb of acc_final's fraction part != Min positive value (0) => output_typeconvert = Min negative value (1_000...0)
      (acc_final[32] == 1 && acc_final[31:15] != 17'b11111111111111111) ?
            16'b1000000000000000 : // Min negative
      // else
      acc_final[15:0];  // value in range

  always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
      filtered_sample <= 0;
    end else begin
      if (phase_63 == 1) begin
        filtered_sample <= output_typeconvert;
      end
    end
  end

endmodule  //compute
