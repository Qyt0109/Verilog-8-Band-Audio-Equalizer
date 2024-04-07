module coeffs (
    input [5:0] current_count,  // current_count from counter to select which coeff slot to output back

    output signed [15:0] coeff
);
  // region coeffs storage
  // Store the coefficients internally
  localparam NUMBER_OF_TAPS = 63;

  // Each coeff is signed fixed-point 16.16. [-0.5, 0.5 - 1.52587890625e-05]
  parameter signed [15:0] coeff_1 = 16'b1111111111110110;
  parameter signed [15:0] coeff_2 = 16'b1111111111100001;
  parameter signed [15:0] coeff_3 = 16'b1111111111001011;
  parameter signed [15:0] coeff_4 = 16'b1111111110111000;
  parameter signed [15:0] coeff_5 = 16'b1111111110101001;
  parameter signed [15:0] coeff_6 = 16'b1111111110100111;
  parameter signed [15:0] coeff_7 = 16'b1111111110110111;
  parameter signed [15:0] coeff_8 = 16'b1111111111100001;
  parameter signed [15:0] coeff_9 = 16'b0000000000100110;
  parameter signed [15:0] coeff_10 = 16'b0000000010000011;
  parameter signed [15:0] coeff_11 = 16'b0000000011101011;
  parameter signed [15:0] coeff_12 = 16'b0000000101001010;
  parameter signed [15:0] coeff_13 = 16'b0000000110000111;
  parameter signed [15:0] coeff_14 = 16'b0000000110000111;
  parameter signed [15:0] coeff_15 = 16'b0000000100110010;
  parameter signed [15:0] coeff_16 = 16'b0000000001111101;
  parameter signed [15:0] coeff_17 = 16'b1111111101101111;
  parameter signed [15:0] coeff_18 = 16'b1111111000100001;
  parameter signed [15:0] coeff_19 = 16'b1111110011000101;
  parameter signed [15:0] coeff_20 = 16'b1111101110011001;
  parameter signed [15:0] coeff_21 = 16'b1111101011101011;
  parameter signed [15:0] coeff_22 = 16'b1111101100000101;
  parameter signed [15:0] coeff_23 = 16'b1111110000100011;
  parameter signed [15:0] coeff_24 = 16'b1111111001101011;
  parameter signed [15:0] coeff_25 = 16'b0000000111011101;
  parameter signed [15:0] coeff_26 = 16'b0000011001010101;
  parameter signed [15:0] coeff_27 = 16'b0000101110000101;
  parameter signed [15:0] coeff_28 = 16'b0001000011111111;
  parameter signed [15:0] coeff_29 = 16'b0001011001000010;
  parameter signed [15:0] coeff_30 = 16'b0001101011001001;
  parameter signed [15:0] coeff_31 = 16'b0001111000011011;
  parameter signed [15:0] coeff_32 = 16'b0001111111011100;
  parameter signed [15:0] coeff_33 = 16'b0001111111011100;
  parameter signed [15:0] coeff_34 = 16'b0001111000011011;
  parameter signed [15:0] coeff_35 = 16'b0001101011001001;
  parameter signed [15:0] coeff_36 = 16'b0001011001000010;
  parameter signed [15:0] coeff_37 = 16'b0001000011111111;
  parameter signed [15:0] coeff_38 = 16'b0000101110000101;
  parameter signed [15:0] coeff_39 = 16'b0000011001010101;
  parameter signed [15:0] coeff_40 = 16'b0000000111011101;
  parameter signed [15:0] coeff_41 = 16'b1111111001101011;
  parameter signed [15:0] coeff_42 = 16'b1111110000100011;
  parameter signed [15:0] coeff_43 = 16'b1111101100000101;
  parameter signed [15:0] coeff_44 = 16'b1111101011101011;
  parameter signed [15:0] coeff_45 = 16'b1111101110011001;
  parameter signed [15:0] coeff_46 = 16'b1111110011000101;
  parameter signed [15:0] coeff_47 = 16'b1111111000100001;
  parameter signed [15:0] coeff_48 = 16'b1111111101101111;
  parameter signed [15:0] coeff_49 = 16'b0000000001111101;
  parameter signed [15:0] coeff_50 = 16'b0000000100110010;
  parameter signed [15:0] coeff_51 = 16'b0000000110000111;
  parameter signed [15:0] coeff_52 = 16'b0000000110000111;
  parameter signed [15:0] coeff_53 = 16'b0000000101001010;
  parameter signed [15:0] coeff_54 = 16'b0000000011101011;
  parameter signed [15:0] coeff_55 = 16'b0000000010000011;
  parameter signed [15:0] coeff_56 = 16'b0000000000100110;
  parameter signed [15:0] coeff_57 = 16'b1111111111100001;
  parameter signed [15:0] coeff_58 = 16'b1111111110110111;
  parameter signed [15:0] coeff_59 = 16'b1111111110100111;
  parameter signed [15:0] coeff_60 = 16'b1111111110101001;
  parameter signed [15:0] coeff_61 = 16'b1111111110111000;
  parameter signed [15:0] coeff_62 = 16'b1111111111001011;
  parameter signed [15:0] coeff_63 = 16'b1111111111100001;
  parameter signed [15:0] coeff_64 = 16'b1111111111110110;
  // endregion coeffs storage

  // MUX based on current_count to select coeff from coeffs
  assign coeff =  (current_count == 6'b000000) ? coeff_1 :
                  (current_count == 6'b000001) ? coeff_2 :
                  (current_count == 6'b000010) ? coeff_3 :
                  (current_count == 6'b000011) ? coeff_4 :
                  (current_count == 6'b000100) ? coeff_5 :
                  (current_count == 6'b000101) ? coeff_6 :
                  (current_count == 6'b000110) ? coeff_7 :
                  (current_count == 6'b000111) ? coeff_8 :
                  (current_count == 6'b001000) ? coeff_9 :
                  (current_count == 6'b001001) ? coeff_10 :
                  (current_count == 6'b001010) ? coeff_11 :
                  (current_count == 6'b001011) ? coeff_12 :
                  (current_count == 6'b001100) ? coeff_13 :
                  (current_count == 6'b001101) ? coeff_14 :
                  (current_count == 6'b001110) ? coeff_15 :
                  (current_count == 6'b001111) ? coeff_16 :
                  (current_count == 6'b010000) ? coeff_17 :
                  (current_count == 6'b010001) ? coeff_18 :
                  (current_count == 6'b010010) ? coeff_19 :
                  (current_count == 6'b010011) ? coeff_20 :
                  (current_count == 6'b010100) ? coeff_21 :
                  (current_count == 6'b010101) ? coeff_22 :
                  (current_count == 6'b010110) ? coeff_23 :
                  (current_count == 6'b010111) ? coeff_24 :
                  (current_count == 6'b011000) ? coeff_25 :
                  (current_count == 6'b011001) ? coeff_26 :
                  (current_count == 6'b011010) ? coeff_27 :
                  (current_count == 6'b011011) ? coeff_28 :
                  (current_count == 6'b011100) ? coeff_29 :
                  (current_count == 6'b011101) ? coeff_30 :
                  (current_count == 6'b011110) ? coeff_31 :
                  (current_count == 6'b011111) ? coeff_32 :
                  (current_count == 6'b100000) ? coeff_33 :
                  (current_count == 6'b100001) ? coeff_34 :
                  (current_count == 6'b100010) ? coeff_35 :
                  (current_count == 6'b100011) ? coeff_36 :
                  (current_count == 6'b100100) ? coeff_37 :
                  (current_count == 6'b100101) ? coeff_38 :
                  (current_count == 6'b100110) ? coeff_39 :
                  (current_count == 6'b100111) ? coeff_40 :
                  (current_count == 6'b101000) ? coeff_41 :
                  (current_count == 6'b101001) ? coeff_42 :
                  (current_count == 6'b101010) ? coeff_43 :
                  (current_count == 6'b101011) ? coeff_44 :
                  (current_count == 6'b101100) ? coeff_45 :
                  (current_count == 6'b101101) ? coeff_46 :
                  (current_count == 6'b101110) ? coeff_47 :
                  (current_count == 6'b101111) ? coeff_48 :
                  (current_count == 6'b110000) ? coeff_49 :
                  (current_count == 6'b110001) ? coeff_50 :
                  (current_count == 6'b110010) ? coeff_51 :
                  (current_count == 6'b110011) ? coeff_52 :
                  (current_count == 6'b110100) ? coeff_53 :
                  (current_count == 6'b110101) ? coeff_54 :
                  (current_count == 6'b110110) ? coeff_55 :
                  (current_count == 6'b110111) ? coeff_56 :
                  (current_count == 6'b111000) ? coeff_57 :
                  (current_count == 6'b111001) ? coeff_58 :
                  (current_count == 6'b111010) ? coeff_59 :
                  (current_count == 6'b111011) ? coeff_60 :
                  (current_count == 6'b111100) ? coeff_61 :
                  (current_count == 6'b111101) ? coeff_62 :
                  (current_count == 6'b111110) ? coeff_63 :
                  coeff_64;
endmodule  //coeffs
