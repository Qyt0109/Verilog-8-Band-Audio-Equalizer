// python compile.py phase_check phase_check.v phase_check_tb.v counter.v
`timescale 1ns / 1ps

module filter_tb;

  reg                clk = 0;
  reg                rst = 0;
  reg                clk_enable = 1;

  reg signed [15:0] i_signal_sample;  // filter's i_signal_sample

  wire               i_write_enable;
  wire               i_write_done;
  wire        [ 5:0] i_write_address;
  wire signed [15:0] i_coeffs_in;

  filter uut (
      .clk(clk),
      .rst(rst),
      .clk_enable(clk_enable),

      .i_signal_sample(i_signal_sample),

      .i_write_enable(i_write_enable),
      .i_write_done(i_write_done),
      .i_write_address(i_write_address),
      .i_coeffs_in(i_coeffs_in)
  );

  parameter CLK_PERIOD = 10;  // 100MHz clock = 10ns period
  always #((CLK_PERIOD) / 2) clk = ~clk;

  initial begin
    $dumpfile("./Simulate/filter.vcd");
    $dumpvars;
    rst = 1;
    i_signal_sample = 0;
    #(CLK_PERIOD * 10);
    rst = 0;
    #(CLK_PERIOD * 20000);
    $finish;
  end

  always #(CLK_PERIOD * 1000) begin
    i_signal_sample = $signed($urandom_range(1, 200));
  end

endmodule  //counter_tb
