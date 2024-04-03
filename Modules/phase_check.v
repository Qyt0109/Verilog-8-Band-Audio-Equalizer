module phase_check (
    input clk_enable,
    input [5:0] current_count,
    output phase_63,
    output phase_0
);

  assign phase_63 = ((current_count == 6'b111111) && (clk_enable == 1)) ? 1 : 0;
  assign phase_0  = ((current_count == 6'b000000) && (clk_enable == 1)) ? 1 : 0;

endmodule  //phase_check
