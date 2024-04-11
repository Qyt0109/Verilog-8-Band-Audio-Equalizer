module amplifier #(
    parameter NUMBER_OF_FILTERS = 8,
    parameter GAIN_BITS = 2,
    parameter GAIN_FRAC_BITS = 0,
    parameter FILTER_IN_BITS = 16
) (
    input en,

    input [NUMBER_OF_FILTERS*GAIN_BITS-1:0] gains,
    input signed [FILTER_IN_BITS-1:0] filter_in,
    output [NUMBER_OF_FILTERS*FILTER_IN_BITS-1:0] amplified_filter_ins
);
  /* rounding: floor, overflow: saturate
  ┌───────────────────────────────────────────────────────────────────────────┐
  │                                                                           │
  │    ◀─────16──────▶        ◀──8──▶          ◀──────────24─────────▶        │
  │   ┌┐                     ┌┐               ┌┐                              │
  │   S├┬┬┬┬┬┬┬┬┬┬┬┬┬┬┐      S├┬┬┬┬┬┬┐        S├┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┐       │
  │   └┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┘  *   └┴┴┴┴┴┤││    =   └┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┤││       │
  │     ◀────────────▶         ◀──▶└┴┘          ◀──────────────────▶└┴┘       │
  │           int              int ◀─▶                   int        ◀─▶       │
  │                               frac                             frac       │
  │                                                                           │
  │                                                                    frac   │
  │                                       ┌┐         ◀─────16──────▶    ◀─▶   │
  │                              ===>     S├┬┬┬┬┐   ┌┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┐   ┌┬┐   │
  │                                       └┴┴┴┴┴┘...└┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┘...│││   │
  │                                                  ◀─────────────▶    └┴┘   │
  │                                      overflow       coverted        ◀─▶   │
  │                                     (saturate)       result        round  │
  │                                                                   (floor) │
  │                                                                           │
  └───────────────────────────────────────────────────────────────────────────┘
  ┌────────────────────────────────────────────────────────────┐
  │(s)iii_iiii_iiii_iiii * (s)iii_ii.ff                        │
  │=                                                           │
  │(s)iii_ii|ii_iiii_iiii_iiii_ii|.ff                          │
  │                                                            │
  │if ((s == 0) & (iii_ii != 000_00)) => positive overflowed   │
  │=> |01_1111_1111_1111_11|                                   │
  │                                                            │
  │elsif ((s == 1) & (iii_ii) != 111_11) => negative overflowed│
  │=> |10_0000_0000_0000_00|                                   │
  │                                                            │
  │else => not overflowed                                      │
  │=> |ii_iiii_iiii_iiii_ii|                                   │
  └────────────────────────────────────────────────────────────┘
  */
  localparam PRODUCT_BITS = FILTER_IN_BITS + GAIN_BITS;
  localparam PRODUCT_SIGN_BIT = PRODUCT_BITS - 1;

  localparam PRODUCT_CHECK_BIT_HIGH = PRODUCT_SIGN_BIT - 1;
  localparam PRODUCT_CHECK_BIT_LOW = GAIN_FRAC_BITS + FILTER_IN_BITS;
  localparam PRODUCT_CHECK_BITS = PRODUCT_CHECK_BIT_HIGH - PRODUCT_CHECK_BIT_LOW + 1;

  localparam CONVERTED_PRODUCT_HIGH_BIT = GAIN_FRAC_BITS + FILTER_IN_BITS - 1;
  localparam CONVERTED_PRODUCT_LOW_BIT = GAIN_FRAC_BITS;

  wire signed [GAIN_BITS-1:0] w_gains[0:NUMBER_OF_FILTERS];
  wire signed [PRODUCT_BITS-1:0] product[0:NUMBER_OF_FILTERS];
  wire signed [PRODUCT_BITS-1:0] w_amplified_filter_ins[0:NUMBER_OF_FILTERS];
  wire signed [FILTER_IN_BITS-1:0] w_converted_amplified_filter_ins[0:NUMBER_OF_FILTERS];

  genvar filter_index;
  generate
    for (
        filter_index = 0; filter_index < NUMBER_OF_FILTERS; filter_index = filter_index + 1
    ) begin : gen_amplifier
      assign w_gains[filter_index] = gains[(filter_index+1)*GAIN_BITS-1:filter_index*GAIN_BITS];
      assign product[filter_index] = filter_in * w_gains[filter_index];
      assign w_amplified_filter_ins[filter_index] =
          // positive overflow => stay at max signed integer (saturate)
          ((product[filter_index][PRODUCT_SIGN_BIT] == 0) & (product[filter_index][PRODUCT_CHECK_BIT_HIGH:PRODUCT_CHECK_BIT_LOW] != {(PRODUCT_CHECK_BITS){1'b0}})) ? {1'b0, {(FILTER_IN_BITS-1){1'b1}}}: // 01111...111
          // negative overflow => stay at min signed integer (saturate)
          ((product[filter_index][PRODUCT_SIGN_BIT] == 1) & (product[filter_index][PRODUCT_CHECK_BIT_HIGH:PRODUCT_CHECK_BIT_LOW] != {(PRODUCT_CHECK_BITS){1'b1}})) ? {1'b1, {(FILTER_IN_BITS-1){1'b0}}}: // 10000...000
          // if not overflow, round down by cutoff all unnecessary bits (flooring)
          product[filter_index][CONVERTED_PRODUCT_HIGH_BIT:CONVERTED_PRODUCT_LOW_BIT];
      assign amplified_filter_ins[(filter_index+1)*FILTER_IN_BITS-1:filter_index*FILTER_IN_BITS] = (en == 1) ? w_amplified_filter_ins[filter_index] : filter_in;
    end
  endgenerate

endmodule  //amplifier
