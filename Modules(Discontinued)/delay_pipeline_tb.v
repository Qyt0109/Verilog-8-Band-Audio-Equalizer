// python compile.py phase_check phase_check.v phase_check_tb.v counter.v
`timescale 1ns / 1ps

module delay_pipeline_tb;

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

  wire phase_63, phase_0;

  phase_check phase_check_inst (
      .clk_enable(clk_enable),
      .current_count(current_count),
      .phase_63(phase_63),
      .phase_0(phase_0)
  );

  localparam NUMBER_OF_PIPE = 64;

  reg signed  [15:0] i_signal_sample;
  wire signed [15:0] o_delayed_sample;

  delay_pipeline uut (
      .clk(clk),
      .rst(rst),
      .phase_0(phase_0),
      .phase_63(phase_63),
      .i_signal_sample(i_signal_sample),
      .o_delayed_sample(o_delayed_sample)
  );

  parameter CLK_PERIOD = 10;  // 100MHz clock = 10ns period
  always #((CLK_PERIOD) / 2) clk = ~clk;

  initial begin
    $dumpfile("./Simulate/delay_pipeline.vcd");
    $dumpvars;
    rst = 1;
    i_signal_sample = 0;
    #(CLK_PERIOD * 10);
    rst = 0;
    #(CLK_PERIOD * 20000);
    $finish;
  end

  always @(posedge phase_0) begin
    i_signal_sample = $signed($urandom_range(1, 200));
  end

endmodule  //counter_tb
