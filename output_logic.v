`timescale 1ns / 1ps

//output logic
module output_logic #(
parameter CURRENCY_WIDTH = 7,
parameter ITEM_ADDR_WIDTH = 10
)(
input wire clk,
input wire rstn,
input wire selection_ready,
input wire currency_ready,
input wire [CURRENCY_WIDTH-1:0] total_currency,
input wire [15:0] item_price,
input wire [7:0] avail_count,
input wire [ITEM_ADDR_WIDTH-1:0] selected_item,
output reg dispense_valid,
output reg [ITEM_ADDR_WIDTH-1:0] item_dispensed,
output reg [CURRENCY_WIDTH-1:0] currency_change,
output reg trigger_dispense
);
always @(posedge clk or negedge rstn) begin
if (!rstn) begin
dispense_valid <= 0;
item_dispensed <= 0;currency_change <= 0;
trigger_dispense <= 0;
end else begin
dispense_valid <= 0;
trigger_dispense <= 0;
if (selection_ready && currency_ready) begin
if (avail_count > 0 && total_currency >= item_price) begin
dispense_valid <= 1;
item_dispensed <= selected_item;
currency_change <= total_currency - item_price;
trigger_dispense <= 1; // Item dispensed and change given
end else if (avail_count == 0) begin
dispense_valid <= 1;
item_dispensed <= selected_item; // No item but currency returned
currency_change <= total_currency;
trigger_dispense <= 0; // No dispense action
end else if (total_currency < item_price) begin
// Add a case for insufficient funds (you can customize this case if needed)
dispense_valid <= 0;
item_dispensed <= 0;
currency_change <= total_currency;
trigger_dispense <= 0; // No dispense action
end
end
end end
endmodule
