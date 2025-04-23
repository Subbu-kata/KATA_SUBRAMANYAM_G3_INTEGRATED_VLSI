`timescale 1ns / 1ps

//testbench
module output_logic_tb;
// Parameters
parameter CURRENCY_WIDTH = 7;
parameter ITEM_ADDR_WIDTH = 10;
// Signals
reg clk;
reg rstn;
reg selection_ready;
reg currency_ready;
reg [CURRENCY_WIDTH-1:0] total_currency;
reg [15:0] item_price;
reg [7:0] avail_count;
reg [ITEM_ADDR_WIDTH-1:0] selected_item;
wire dispense_valid;
wire [ITEM_ADDR_WIDTH-1:0] item_dispensed;
wire [CURRENCY_WIDTH-1:0] currency_change;
wire trigger_dispense;
// Instantiate the output_logic module
output_logic #(.CURRENCY_WIDTH(CURRENCY_WIDTH),
.ITEM_ADDR_WIDTH(ITEM_ADDR_WIDTH)
) uut (
.clk(clk),
.rstn(rstn),
.selection_ready(selection_ready),
.currency_ready(currency_ready),
.total_currency(total_currency),
.item_price(item_price),
.avail_count(avail_count),
.selected_item(selected_item),
.dispense_valid(dispense_valid),
.item_dispensed(item_dispensed),
.currency_change(currency_change),
.trigger_dispense(trigger_dispense)
);
// Clock Generation
always #5 clk = ~clk; // 100MHz clock
// Test procedure
initial begin
// Initialize signals
clk = 0;
rstn = 0;
selection_ready = 0;currency_ready = 0;
total_currency = 0;
item_price = 0;
avail_count = 0;
selected_item = 0;
// Reset
#10 rstn = 1; // Release reset
// Test case 1: Item available, enough currency
#10 test_dispense(10, 50, 20, 1, 30, 1); // Expected trigger_dispense = 1
// Test case 2: Not enough currency
#10 test_dispense(10, 20, 30, 1, 30, 0); // Expected trigger_dispense = 0
// Test case 3: Item available but out of stock
#10 test_dispense(10, 50, 0, 1, 50, 0); // Expected trigger_dispense = 0, no item dispensed
// Test case 4: Item available, enough currency but currency return expected (item out of
//stock)
#10 test_dispense(10, 50, 20, 1, 50, 1); // Expected trigger_dispense = 1, item dispensed
//and change returned
// Test case 5: Item selected but unavailable
#10 test_dispense(20, 50, 0, 1, 50, 0); // Expected trigger_dispense = 0
// Test case 6: No selection or currency ready#10 test_dispense(10, 50, 20, 0, 30, 0); // Expected trigger_dispense = 0
$finish;
end
// Task to test the dispense logic
task test_dispense(
input [ITEM_ADDR_WIDTH-1:0] select_item,
input [CURRENCY_WIDTH-1:0] currency,
input [7:0] avail_count_in,
input selection_ready_in,
input [15:0] price,
input expected_trigger_dispense
);
begin
// Apply inputs
selected_item = select_item;
total_currency = currency;
avail_count = avail_count_in;
item_price = price;
selection_ready = selection_ready_in;
currency_ready = 1; // Always valid for currency
#10; // Wait for a cycle to process
// Display Results for Debugging$display("Test with Item %d | Currency = %d | Item Price = %d | Available Count = %d",
//select_item, currency, price, avail_count_in);
$display("selection_ready = %b | currency_ready = %b | avail_count = %d | total_currency =%d",selection_ready, currency_ready, avail_count_in, currency);
$display("dispense_valid = %b | item_dispensed = %d | currency_change = %d |trigger_dispense = %b",dispense_valid, item_dispensed, currency_change, trigger_dispense);
// Check if trigger_dispense matches expected value
if (trigger_dispense !== expected_trigger_dispense) begin
$display("Test FAILED: trigger_dispense mismatch at time %t", $time);
end
// Wait for dispense_valid to be deasserted
wait (dispense_valid == 0); // Wait until dispense_valid is deasserted
end
endtask
endmodule