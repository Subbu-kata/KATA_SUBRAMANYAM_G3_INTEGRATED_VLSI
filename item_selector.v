`timescale 1ns / 1ps
//item_selector
module item_selector #(
parameter ITEM_ADDR_WIDTH = 10
)(
input wire clk,
input wire rstn,
input wire [ITEM_ADDR_WIDTH-1:0] item_select,
input wire item_select_valid,
output reg [ITEM_ADDR_WIDTH-1:0] selected_item,
output reg selection_ready
);
always @(posedge clk or negedge rstn) begin
if (!rstn) begin
selected_item <= 0;
selection_ready <= 0;
end else begin
if (item_select_valid) begin
selected_item <= item_select;
selection_ready <= 1;
end else begin
selection_ready <= 0;
end
end
end
endmodule
