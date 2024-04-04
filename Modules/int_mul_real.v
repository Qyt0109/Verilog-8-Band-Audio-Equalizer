module int_mul_real (
    input [15:0] i_int, // 16 bit int with 1 sign bit and 15 value bit
    input [15:0] i_real, // 16 bit real with 1 sign bit and 15 fraction bit
    output [30:0] o_product, // product of inputs, all fraction
    output [33:0] o_accumulate
);



endmodule //int_mul_real