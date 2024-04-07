module counter (
    input clk,
    input clk_enable,
    input rst,

    output reg [5:0] current_count  // unsigned integer 6 bit. [0, 64 - 1]
);
  localparam COUNTER_MAX_COUNT = 6'b111111;
  localparam COUNTER_MIN_COUNT = 6'b000000;

  always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
      // reset to min count
      current_count <= COUNTER_MIN_COUNT;
    end else begin
      if (clk_enable == 1) begin
        if (current_count >= COUNTER_MAX_COUNT) begin
          current_count <= COUNTER_MIN_COUNT;
        end else begin
          current_count <= current_count + 1;
        end
      end
    end
  end

endmodule
