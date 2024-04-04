module filter (
    input clk,
    input clk_enable,
    input rst,

    input signed [15:0] i_signal_sample,  // filter's i_signal_sample

    input               i_write_enable,
    input               i_write_done,
    input        [ 5:0] i_write_address,
    input signed [15:0] i_coeffs_in


);
  // counter
  wire [5:0] current_count;  // from counter's current_count

  counter counter_inst (
      .clk(clk),
      .clk_enable(clk_enable),
      .rst(rst),

      .current_count(current_count)
  );
  // counter

  // phase_check
  wire phase_63, phase_0, control_phase_bar; // from phase_check's phase_63, phase_0, control_phase_bar

  phase_check phase_check_inst (
      .clk_enable(clk_enable),

      .current_count(current_count),

      .phase_63(phase_63),
      .phase_0(phase_0),
      .control_phase_bar(control_phase_bar)
  );
  // phase_check

  // delay_pipeline
  delay_pipeline delay_pipeline_inst (
      .clk(clk),
      .rst(rst),

      .phase_63(phase_63),
      .i_signal_sample(i_signal_sample)
  );
  // delay_pipeline

  // input_register
  wire write_enable, write_done, write_address, coeffs_in; // from input_register's o_write_enable, o_write_done, o_write_address, o_coeffs_in

  input_register input_register_inst (
      .clk(clk),
      .rst(rst),
      .clk_enable(clk_enable),

      .i_write_enable(i_write_enable),
      .i_write_done(i_write_done),
      .i_write_address(i_write_address),
      .i_coeffs_in(i_coeffs_in),

      .o_write_enable(write_enable),
      .o_write_done(write_done),
      .o_write_address(write_address),
      .o_coeffs_in(coeffs_in)
  );

  // input_register

  // write_done_capture
  wire o_write_done_capture, o_write_done_edge, coeffs_en;  //write_done_capture's o_write_done_capture, o_write_done_edge, coeffs_en
  write_done_capture write_done_capture_inst (
      .clk(clk),
      .rst(rst),
      .clk_enable(clk_enable),

      .i_write_done(write_done),
      .i_control_phase_bar(control_phase_bar),
      .phase_63(phase_63),

      .o_write_done_capture(o_write_done_capture),
      .o_write_done_edge(o_write_done_edge),
      .coeffs_en(coeffs_en)
  );

  // write_done_capture

endmodule  //filter
