`timescale 1ns / 1ps

module z_block_tb ();
  reg clk = 0, rst = 0;
  reg  [15:0] data_in = 0;
  wire [15:0] data_out;

  parameter CLK_PERIOD = 10;
  always #(CLK_PERIOD / 2) clk = ~clk;

  z_block dut (
      .clk(clk),
      .rst(rst),
      .data_in(data_in),
      .data_out(data_out)
  );

  initial begin
    $dumpfile("./Simulate/timer1hz.vcd");
    $dumpvars;
    rst = 1;
    #(CLK_PERIOD * 3);
    rst = 0;
    data_in = 69;
    #CLK_PERIOD;
    data_in = 88;
    #CLK_PERIOD;
    data_in = 99;
    #(CLK_PERIOD * 3);
    rst = 1;
    #(CLK_PERIOD * 3);
    rst = 0;
    data_in <= 123;
    #(CLK_PERIOD * 10);
    $finish;
  end

endmodule  //z_block_tb
