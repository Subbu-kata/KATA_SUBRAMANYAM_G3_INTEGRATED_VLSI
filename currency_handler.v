`timescale 1ns / 1ps
//currency handler
module currency_handler #(
parameter CURRENCY_WIDTH = 7
)(
input wire clk,
input wire rstn,
// System Clock
input wire [CURRENCY_WIDTH-1:0] currency_value,
input wire
currency_valid, // async input
output reg [CURRENCY_WIDTH-1:0] total_currency,
output reg
currency_ready
);
reg currency_valid_sync_0, currency_valid_sync_1;
reg [CURRENCY_WIDTH-1:0] currency_value_latched;
// Synchronizer for valid signal
always @(posedge clk or negedge rstn) begin
if (!rstn) begin
currency_valid_sync_0 <= 0;
currency_valid_sync_1 <= 0;
end else begin
currency_valid_sync_0 <= currency_valid;
currency_valid_sync_1 <= currency_valid_sync_0;
end
end// Edge detect
wire rising_edge = currency_valid_sync_0 & ~currency_valid_sync_1;
always @(posedge clk or negedge rstn) begin
if (!rstn) begin
total_currency <= 0;
currency_ready <= 0;
end else begin
if (rising_edge) begin
total_currency <= total_currency + currency_value;
currency_ready <= 1;
end else begin
currency_ready <= 0;
end
end
end
endmodule
