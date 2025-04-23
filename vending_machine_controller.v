`timescale 1ns / 1ps

module vending_machine_controller #(
parameter MAX_ITEMS = 1024,
parameter ITEM_ADDR_WIDTH = 10,parameter CURRENCY_WIDTH = 7
)(
input wire clk,
input wire rstn,
input wire cfg_mode,
// Item Selection Interface
input wire [ITEM_ADDR_WIDTH-1:0] item_select,
input wire item_select_valid,
// Currency Interface
input wire [CURRENCY_WIDTH-1:0] currency_value,
input wire currency_valid,
// APB Config Interface
input wire pclk,
input wire prstn,
input wire [14:0] paddr,
input wire psel,
input wire penable,
input wire pwrite,
input wire [31:0] pwdata,
output wire [31:0] prdata,
output wire pready,
// Output
output wire item_dispense_valid,
output wire [ITEM_ADDR_WIDTH-1:0] item_dispense,
output wire [CURRENCY_WIDTH-1:0] currency_change
);
// Internal wires
wire currency_valid_sync, item_select_valid_sync;
wire [CURRENCY_WIDTH-1:0] total_currency;
wire currency_ready, selection_ready;
wire [ITEM_ADDR_WIDTH-1:0] selected_item;
wire [15:0] item_price;
wire [7:0] avail_count;
wire item_ready;
wire trigger_dispense;
// CDC Sync
pulse_sync u_currency_sync (
.clk_dst(clk),
.rstn(rstn),
.pulse_src(currency_valid),
.pulse_dst(currency_valid_sync)
);
pulse_sync u_item_sync (
.clk_dst(clk),
.rstn(rstn),.pulse_src(item_select_valid),
.pulse_dst(item_select_valid_sync)
);
// Currency Handler
currency_handler #(
.CURRENCY_WIDTH(CURRENCY_WIDTH)
) u_currency (
.clk(clk),
.rstn(rstn),
.currency_value(currency_value),
.currency_valid(currency_valid_sync),
.total_currency(total_currency),
.currency_ready(currency_ready)
);
// Item Selector
item_selector #(
.ITEM_ADDR_WIDTH(ITEM_ADDR_WIDTH)
) u_item (
.clk(clk),
.rstn(rstn),
.item_select(item_select),
.item_select_valid(item_select_valid_sync),
.selected_item(selected_item),
.selection_ready(selection_ready));
// Config + Inventory Management
config_module #(
.MAX_ITEMS(MAX_ITEMS),
.ITEM_ADDR_WIDTH(ITEM_ADDR_WIDTH)
) u_config (
.pclk(pclk),
.prstn(prstn),
.paddr(paddr),
.psel(psel),
.penable(penable),
.pwrite(pwrite),
.pwdata(pwdata),
.prdata(prdata),
.pready(pready),
.cfg_mode(cfg_mode),
.clk(clk),
.rstn(rstn),
.item_id(selected_item),
.avail_count(avail_count),
.item_price(item_price),
.item_ready(item_ready),
.dispense(trigger_dispense)
);// Output Logic
output_logic #(
.CURRENCY_WIDTH(CURRENCY_WIDTH),
.ITEM_ADDR_WIDTH(ITEM_ADDR_WIDTH)
) u_output (
.clk(clk),
.rstn(rstn),
.selection_ready(selection_ready),
.currency_ready(currency_ready),
.total_currency(total_currency),
.item_price(item_price),
.avail_count(avail_count),
.selected_item(selected_item),
.dispense_valid(item_dispense_valid),
.item_dispensed(item_dispense),
.currency_change(currency_change),
.trigger_dispense(trigger_dispense)
);
endmodule
