module input_register (
    input clk,
    input rst,
    input clk_enable,

    input               i_write_enable,
    input               i_write_done,
    input        [ 5:0] i_write_address,
    input signed [15:0] i_coeffs_in,

    output reg o_write_enable,
    output reg o_write_done,
    output reg [5:0] o_write_address, // unsigned integer 6 bit. [0, 64 - 1]
    output reg signed [15:0] o_coeffs_in // same as filter's coeffs_in datatype. signed fixed-point 16 bit, 18 frac. [-0.125, 0.125 - 3.814697265625e-06]
);
  always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
      // reset to default values
      o_write_enable <= 0;
      o_write_done <= 0;
      o_write_address <= 0;
      o_coeffs_in <= 0;
    end else begin
      if (clk_enable == 1) begin
        o_write_enable  <= i_write_enable;
        o_write_done    <= i_write_done;
        o_write_address <= i_write_address;
        o_coeffs_in     <= i_coeffs_in;
      end
    end
  end

endmodule  //input_register
