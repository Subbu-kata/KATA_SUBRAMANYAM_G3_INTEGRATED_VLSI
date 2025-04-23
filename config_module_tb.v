`timescale 1ns / 1ps

//testbench
module config_module_tb;
parameter MAX_ITEMS = 1024;
parameter ITEM_ADDR_WIDTH = 10;
reg pclk, prstn;
reg psel, penable, pwrite;
reg [14:0] paddr;
reg [31:0] pwdata;
wire [31:0] prdata;
wire pready;
reg clk, rstn;
reg [ITEM_ADDR_WIDTH-1:0] item_id;
wire [7:0] avail_count;
wire [15:0] item_price;
wire item_ready;
reg dispense;
reg cfg_mode;config_module #(MAX_ITEMS, ITEM_ADDR_WIDTH) dut (
.pclk(pclk), .prstn(prstn), .psel(psel), .penable(penable), .pwrite(pwrite),
.paddr(paddr), .pwdata(pwdata), .prdata(prdata), .pready(pready),
.cfg_mode(cfg_mode), .clk(clk), .rstn(rstn), .item_id(item_id),
.avail_count(avail_count), .item_price(item_price),
.item_ready(item_ready), .dispense(dispense)
);
// Clocks
always #50 pclk = ~pclk; // 10MHz
always #5 clk = ~clk; // 100MHz
initial begin
// Init
pclk = 0; clk = 0;
prstn = 0; rstn = 0;
psel = 0; penable = 0; pwrite = 0;
paddr = 0; pwdata = 0;
item_id = 0;
dispense = 0;
cfg_mode = 0;
#25 prstn = 1; rstn = 1;
#20 cfg_mode = 1;
// Write number of items = 3apb_write(15'h0000, 32'd3);
// Write item 0: price = 50, avail = 10
apb_write(15'h0004, {8'd10, 16'd50}); // [23:16]=avail, [15:0]=price
// Read item 0
apb_read(15'h0004);
// Wait for logic clk to pick up the update
#50;
item_id = 0;
#20;
$display("Item Ready: %0d | Price: %0d | Available: %0d", item_ready, item_price,
avail_count);
// Dispense item 0
dispense = 1;
#20 dispense = 0;
// Wait and read again
#50;
apb_read(15'h0004);
$display("Item Ready: %0d | Price: %0d | Available: %0d", item_ready, item_price,
avail_count);
#100 $finish;end
// Tasks
task apb_write(input [14:0] addr, input [31:0] data);
begin
@(posedge pclk);
paddr <= addr;
pwdata <= data;
pwrite <= 1;
psel <= 1;
penable <= 0;
@(posedge pclk);
penable <= 1;
@(posedge pclk);
while (!pready) @(posedge pclk);
psel <= 0;
penable <= 0;
pwrite <= 0;
end
endtask
task apb_read(input [14:0] addr);
begin@(posedge pclk);
paddr <= addr;
pwrite <= 0;
psel <= 1;
penable <= 0;
@(posedge pclk);
penable <= 1;
@(posedge pclk);
while (!pready) @(posedge pclk);
$display("READ [%04h] => %08h", addr, prdata);
psel <= 0;
penable <= 0;
end
endtask
endmodule
