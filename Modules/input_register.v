`timescale 1 ns / 1 ns

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
    output reg [5:0] o_write_address,
    output reg signed [15:0] o_coeffs_in
);
  always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
      o_write_enable <= 0;
      o_write_done <= 0;
      o_write_address <= 0;
      o_coeffs_in <= 0;
    end else begin
      if (clk_enable == 1) begin
        o_write_enable <= i_write_enable;
        o_write_done <= i_write_done;
        o_write_address <= i_write_address;
        o_coeffs_in <= i_coeffs_in;
      end
    end
  end

endmodule  //input_register
