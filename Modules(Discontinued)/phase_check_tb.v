// python compile.py phase_check phase_check.v phase_check_tb.v counter.v
`timescale 1ns / 1ps

module phase_check_tb;

  reg        clk = 0;
  reg        clk_enable = 1;
  reg        rst = 1;

  wire [5:0] current_count;

  counter counter_inst (
      .clk(clk),
      .clk_enable(clk_enable),
      .rst(rst),
      .current_count(current_count)
  );

  wire phase_63, phase_0, control_phase_bar;

  phase_check uut (
      .clk_enable(clk_enable),
      .current_count(current_count),
      .phase_63(phase_63),
      .phase_0(phase_0),
      .control_phase_bar(control_phase_bar)
  );

  parameter CLK_PERIOD = 10;  // 100MHz clock = 10ns period
  always #((CLK_PERIOD) / 2) clk = ~clk;

  initial begin
    $dumpfile("./Simulate/phase_check.vcd");
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
