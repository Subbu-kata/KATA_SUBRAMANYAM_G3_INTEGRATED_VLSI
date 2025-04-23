`timescale 1ns / 1ps
//test bench
module currency_handler_tb;
parameter CURRENCY_WIDTH = 7;
reg clk, rstn;
reg [CURRENCY_WIDTH-1:0] currency_value;reg currency_valid;
wire [CURRENCY_WIDTH-1:0] total_currency;
wire currency_ready;
currency_handler #(.CURRENCY_WIDTH(CURRENCY_WIDTH)) uut (
.clk(clk),
.rstn(rstn),
.currency_value(currency_value),
.currency_valid(currency_valid),
.total_currency(total_currency),
.currency_ready(currency_ready)
);
// Clock generation: 50MHz
always #10 clk = ~clk;
initial begin
$display("Starting currency_handler test...");
clk = 0;
rstn = 0;
currency_value = 0;
currency_valid = 0;
#25 rstn = 1; // Deassert reset
// First currency input: 10insert_currency(7'd10);
#40;
// Second currency input: 25
insert_currency(7'd25);
#40;
// Third currency input: 5
insert_currency(7'd5);
#40;
$display("Final Total Currency = %d", total_currency);
#50;
$finish;
end
task insert_currency(input [CURRENCY_WIDTH-1:0] value);
begin
currency_value = value;
currency_valid = 1;
#7;
// async pulse
currency_valid = 0;
wait (currency_ready == 1);
$display("Currency Inserted: %0d | Total = %0d", value, total_currency);
wait (currency_ready == 0);
end
endtask
endmodule
