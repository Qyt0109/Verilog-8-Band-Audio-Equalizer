module coeffs #(
    parameter COUNTER_BITS = 6,
    parameter NUMBER_OF_TAPS = 64,
    parameter COEFF_BITS = 16
) (
    input [COUNTER_BITS-1:0] current_count,  // current_count from counter to select which coeff slot to output back
    input [COEFF_BITS*NUMBER_OF_TAPS-1:0] coeffs,

    output signed [COEFF_BITS-1:0] coeff
);
  // region coeffs storage

  wire signed [COEFF_BITS-1:0] r_coeffs[0:NUMBER_OF_TAPS-1];

  genvar r_coeffs_index;
  generate
    for (
        r_coeffs_index = 0; r_coeffs_index < NUMBER_OF_TAPS; r_coeffs_index = r_coeffs_index + 1
    ) begin : gen_r_coeffs
      assign r_coeffs[r_coeffs_index] = coeffs[(r_coeffs_index+1)*COEFF_BITS-1:r_coeffs_index*COEFF_BITS];
    end
  endgenerate


  // endregion coeffs storage

  // MUX based on current_count to select coeff from coeffs
  assign coeff = r_coeffs[current_count];
endmodule  //coeffs
