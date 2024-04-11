`timescale 1ns / 1ps

module counter_tb;

  reg        clk = 0;
  reg        clk_enable = 1;
  reg        rst = 1;
  wire [5:0] current_count;

  counter uut (
      .clk(clk),
      .clk_enable(clk_enable),
      .rst(rst),
      .current_count(current_count)
  );

  parameter CLK_PERIOD = 10;  // 100MHz clock = 10ns period
  always #((CLK_PERIOD) / 2) clk = ~clk;

  initial begin
    $dumpfile("./Simulate/counter.vcd");
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
