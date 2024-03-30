module amplifier (
    input  clk,
    input  rst,
    input  inc,
    input  dec,
    input  signal,
    output amplified_signal
);
  parameter DEFAULT_FACTOR = 1;
  reg [1:0] factor = DEFAULT_FACTOR;  // 0 1 2 3

  assign amplified_signal = signal * factor;

  always @(posedge clk or posedge rst) begin
    if (rst) factor <= DEFAULT_FACTOR;
    else if (inc == 1) begin
      factor <= (factor == 3) ? 3 : factor + 1;
    end else if (dec == 1) begin
      factor <= (factor == 0) ? 0 : factor - 1;
    end
  end

endmodule  //amplifier
