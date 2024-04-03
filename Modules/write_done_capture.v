module write_done_capture (
    input clk,
    input rst,

    input i_write_done,         // from input_register's o_write_done
    input i_control_phase_bar,  // from phase_check's control_phase_bar
    input phase_63,             // from phase_check's phase63

    output reg o_write_done_capture,
    output reg o_write_done_edge,
    output coeffs_en
);

  wire w_write_done_capture_in, w_write_done_short, w_write_done_edge_bar; // write_done_capture's wires

  assign w_write_done_capture_in = (o_write_done_capture == 1) ? i_control_phase_bar : w_write_done_short;

  assign coeffs_en = phase63 & o_write_done_capture;

  assign w_write_done_edge_bar = ~(o_write_done_edge);

  assign w_write_done_short = i_write_done & w_write_done_edge_bar;

  always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
      o_write_done_capture <= 0;
      o_write_done_edge    <= 0;
    end else begin
      if (clk_enable == 1) begin
        o_write_done_capture <= w_write_done_capture_in;
        o_write_done_edge    <= i_write_done;
      end
    end
  end

endmodule  //write_done_capture
