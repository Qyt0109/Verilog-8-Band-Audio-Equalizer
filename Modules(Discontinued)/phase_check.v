module phase_check (
    input clk_enable,

    input [5:0] current_count,  // current_count from counter

    output phase_63,
    output phase_0,
    output control_phase_bar
);
  localparam COUNTER_MAX_COUNT = 6'b111111;
  localparam COUNTER_MIN_COUNT = 6'b000000;

  assign phase_63          = ((current_count == COUNTER_MAX_COUNT) && (clk_enable == 1)) ? 1 : 0;
  assign phase_0           = ((current_count == COUNTER_MIN_COUNT) && (clk_enable == 1)) ? 1 : 0;
  assign control_phase_bar = ~(phase_63);

endmodule  //phase_check
