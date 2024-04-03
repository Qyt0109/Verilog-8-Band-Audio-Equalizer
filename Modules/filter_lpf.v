module filter_lpf (
    in clk,
    in clk_enable,
    in rst
);
  // counter
  wire [5:0] current_count;

  counter counter_inst (
      .clk(clk),
      .clk_enable(clk_enable),
      .rst(rst),
      .current_count(current_count)
  );
  // counter

  // phase_check
  wire phase_63, phase_0;

  phase_check phase_check_inst (
      .clk_enable(clk_enable),
      .current_count(current_count),
      .phase_63(phase_63),
      .phase_0(phase_0)
  );
  // phase_check

endmodule  //filter_lpf
