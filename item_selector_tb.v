`timescale 1ns / 1ps
module item_selector_tb;parameter ITEM_ADDR_WIDTH = 10;
reg clk;
reg rstn;
reg [ITEM_ADDR_WIDTH-1:0] item_select;
reg item_select_valid;
wire [ITEM_ADDR_WIDTH-1:0] selected_item;
wire selection_ready;
// Instantiate the item_selector module
item_selector #(.ITEM_ADDR_WIDTH(ITEM_ADDR_WIDTH)) uut (
.clk(clk),
.rstn(rstn),
.item_select(item_select),
.item_select_valid(item_select_valid),
.selected_item(selected_item),
.selection_ready(selection_ready)
);
// Generate clk: 20ns period (50MHz)
always #10 clk = ~clk;
initial begin
$display("Starting item_selector test...");
clk = 0;rstn = 0;
item_select = 0;
item_select_valid = 0;
#25 rstn = 1; // Deassert reset
// Test: Select item 10
test_item_select(10);
#40;
// Test: Select item 25
test_item_select(25);
#40;
// Test: Select item 50
test_item_select(50);
#40;
$display("Test completed.");
$finish;
end
task test_item_select(input [ITEM_ADDR_WIDTH-1:0] select_item);
begin
item_select = select_item;
item_select_valid = 1;#5;
item_select_valid = 0;
$display("Item selected: %d | Selected Item = %d | Ready = %b", select_item,
selected_item, selection_ready);
wait (selection_ready == 0); // Wait until selection_ready goes low
end
endtask
endmodule