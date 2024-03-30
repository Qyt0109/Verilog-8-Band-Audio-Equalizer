module z_block (
    input         clk,
    input         rst,
    input  [15:0] data_in,
    output reg [15:0] data_out
);

  always @(posedge clk or posedge rst) begin
    if (rst) data_out <= 0;
    else begin
      data_out <= data_in;
    end
  end

endmodule  //z_block
