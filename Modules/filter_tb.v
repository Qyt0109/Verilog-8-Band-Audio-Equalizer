// python compile.py phase_check phase_check.v phase_check_tb.v counter.v
`timescale 1ns / 1ps

module filter_tb;

  reg                clk = 0;
  reg                clk_enable = 1;
  reg                rst = 0;

  wire signed [15:0] i_signal_sample;  // filter's i_signal_sample

  wire               i_write_enable;
  wire               i_write_done;
  wire        [ 5:0] i_write_address;
  wire signed [15:0] i_coeffs_in;

  parameter CLK_PERIOD = 10;  // 100MHz clock = 10ns period
  always #((CLK_PERIOD) / 2) clk = ~clk;

  initial begin
    $dumpfile("./Simulate/filter.vcd");
    $dumpvars;
    rst = 1;
    #(CLK_PERIOD * 10);
    rst = 0;
    #(CLK_PERIOD * 100);
    rst = 1;
    #(CLK_PERIOD * 6);
    rst = 0;
    #(CLK_PERIOD * 200);
    $finish;
  end

endmodule  //counter_tb
