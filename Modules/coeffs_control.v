`timescale 1 ns / 1 ns

module coeffs_control (
    input clk,
    input rst,
    input clk_enable,

    input [5:0] current_count,  // current_count from counter

    input coeffs_en,  // coeffs_en from write_done_capture

    input        [ 5:0] write_address,  // o_write_address from input_register
    input signed [15:0] coeffs_in,      // o_coeffs_in from input_register
    input               write_enable,   // o_write_enable from input_register

    output signed [15:0] product_mux
);

  localparam NUMBER_OF_COEFFS = 64;

  // Coeffs registers
  // coeffs_assigned to assign coeffs_in at an address, else assign by coresponding coeffs_regs
  wire signed [15:0] coeffs_assigned[0:NUMBER_OF_COEFFS-1];
  wire signed [15:0] coeffs_temp    [0:NUMBER_OF_COEFFS-1];
  reg signed  [15:0] coeffs_regs    [0:NUMBER_OF_COEFFS-1];

  // Linking mem and address to storing new coeffs_in values
  genvar i;
  generate
    for (i = 0; i < 64; i = i + 1) begin : gen_coeffs_assigned
      // assign coeffs_assigned register with coresponding write_address to store coeffs_in value in it
      assign coeffs_assigned[i] = (write_address == i) ? coeffs_in : coeffs_regs[i];
      // if write_enable then coeffs_temp = coeffs_assigned else coeffs_regs
      assign coeffs_temp[i] = (write_enable == 1) ? coeffs_assigned[i] : coeffs_regs[i];
    end
  endgenerate

  reg [5:0] coeffs_regs_reset_index;
  reg [5:0] coeffs_regs_index;

  // Coeffs registers process
  always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
      // Reset all coeffs registers
      for (
          coeffs_regs_reset_index = 0;
          coeffs_regs_reset_index < NUMBER_OF_COEFFS;
          coeffs_regs_reset_index = coeffs_regs_reset_index + 1
      ) begin
        coeffs_regs[coeffs_regs_reset_index] <= 0;
      end
    end else begin
      // coeffs_regs <= coeffs_temp if clk_enable
      if (clk_enable == 1) begin
        for (
            coeffs_regs_index = 0;
            coeffs_regs_index < NUMBER_OF_COEFFS;
            coeffs_regs_index = coeffs_regs_index + 1
        ) begin
          coeffs_regs[coeffs_regs_index] <= coeffs_temp[coeffs_regs_index];
        end
      end
    end
  end

  // Coeffs shadow register
  reg signed [15:0] coeffs_shadow[0:NUMBER_OF_COEFFS-1];

  reg [5:0] coeffs_shadow_reset_index;
  reg [5:0] coeffs_shadow_index;

  always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
      // Reset all coeffs shadow registers
      for (
          coeffs_shadow_reset_index = 0;
          coeffs_shadow_reset_index < NUMBER_OF_COEFFS;
          coeffs_shadow_reset_index = coeffs_shadow_reset_index + 1
      ) begin
        coeffs_shadow[coeffs_shadow_reset_index] <= 0;
      end
    end else begin
      if (coeffs_en == 1) begin
        // coeffs_shadow <= coeffs_regs if coeffs_en
        for (
            coeffs_shadow_index = 0;
            coeffs_shadow_index < NUMBER_OF_COEFFS;
            coeffs_shadow_index = coeffs_shadow_index + 1
        ) begin
          coeffs_shadow[coeffs_shadow_index] <= coeffs_regs[coeffs_shadow_index];
        end
      end
    end
  end

  // MUXs
  // mux control

  assign product_mux = coeffs_shadow[current_count];

endmodule  //coeffs_control
