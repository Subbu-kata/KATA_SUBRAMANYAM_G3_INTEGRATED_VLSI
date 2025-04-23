`timescale 1ns / 1ps
//configuration module
module config_module #(
parameter MAX_ITEMS = 1024,
parameter ITEM_ADDR_WIDTH = 10
)(
input wire pclk,
input wire prstn,
input wire [14:0] paddr,
input wire psel,
input wire penable,
input wire pwrite,
input wire [31:0] pwdata,
output reg [31:0] prdata,
output reg pready,
input wire cfg_mode,
input wire clk,
input wire rstn,
input wire [ITEM_ADDR_WIDTH-1:0] item_id,
output reg [7:0] avail_count,
output reg [15:0] item_price,
output wire item_ready,
input wire dispense
);
reg [ITEM_ADDR_WIDTH-1:0] no_of_items;
reg [15:0] item_val
[0:MAX_ITEMS-1];
reg [7:0] avail_items [0:MAX_ITEMS-1];
reg [7:0] disp_items [0:MAX_ITEMS-1];
wire is_main_cfg = (paddr == 15'h0000);
wire is_item_cfg = (paddr >= 15'h0004);
wire [ITEM_ADDR_WIDTH-1:0] addr_offset;
assign addr_offset = (paddr - 15'h0004) >> 2;
integer i;
// ---------------------
// APB Configuration
// ---------------------
always @(posedge pclk or negedge prstn) begin
if (!prstn) begin
pready <= 1'b0;
prdata <= 32'd0;
no_of_items <= 0;
for (i = 0; i < MAX_ITEMS; i = i + 1) begin
item_val[i] <= 0;avail_items[i] <= 0;
disp_items[i] <= 0;
end
end else if (cfg_mode && psel && penable) begin
pready <= 1'b1;
if (pwrite) begin
if (is_main_cfg) begin
no_of_items <= pwdata[ITEM_ADDR_WIDTH-1:0];
end else if (addr_offset < MAX_ITEMS) begin
item_val[addr_offset] <= pwdata[15:0];
avail_items[addr_offset] <= pwdata[23:16];
disp_items[addr_offset] <= 0;
end
end else begin
if (is_main_cfg) begin
prdata <= { {(32-ITEM_ADDR_WIDTH){1'b0}}, no_of_items };
end else if (addr_offset < MAX_ITEMS) begin
prdata <= { disp_items[addr_offset], avail_items[addr_offset], item_val[addr_offset] };
end else begin
prdata <= 32'd0;
end
end
end else begin
pready <= 1'b0;
end
end// -------------------------------
// Logic Domain: Item Query + Dispense
// -------------------------------
reg [7:0] avail_items_sync;
reg [15:0] item_val_sync;
always @(posedge clk or negedge rstn) begin
if (!rstn) begin
avail_items_sync <= 0;
item_val_sync <= 0;
avail_count<= 0;
item_price<= 0;
end else begin
avail_items_sync <= avail_items[item_id];
item_val_sync <= item_val[item_id];
avail_count <= avail_items_sync;
item_price <= item_val_sync;
if (dispense && avail_items_sync > 0) begin
avail_items[item_id] <= avail_items_sync - 1;
disp_items[item_id] <= disp_items[item_id] + 1;
end
end end
assign item_ready = (item_id < no_of_items);
endmodule
