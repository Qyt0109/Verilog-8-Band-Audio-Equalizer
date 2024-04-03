module counter (
    input            clk,
    input            clk_enable,
    input            rst,
    output reg [5:0] current_count
);
  always @(posedge clk or posedge rst) begin : p_count
    if (rst == 1) begin
      current_count <= 6'b111111;
    end else begin
      if (clk_enable == 1) begin
        if (current_count >= 6'b111111) begin
          current_count <= 0;
        end else begin
          current_count <= current_count + 1;
        end
      end
    end
  end

endmodule
