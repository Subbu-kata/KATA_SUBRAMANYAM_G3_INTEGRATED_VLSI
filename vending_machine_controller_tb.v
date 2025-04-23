`timescale 1ns / 1ps

module vending_machine_controller_tb;// Parameters
parameter ITEM_ADDR_WIDTH = 10;
parameter CURRENCY_WIDTH = 7;
// Inputs
reg clk;
reg rstn;
reg cfg_mode;
reg [ITEM_ADDR_WIDTH-1:0] item_select;
reg item_select_valid;
reg [CURRENCY_WIDTH-1:0] currency_value;
reg currency_valid;
reg pclk;
reg prstn;
reg [14:0] paddr;
reg psel;
reg penable;
reg pwrite;
reg [31:0] pwdata;
// Outputs
wire item_dispense_valid;
wire [ITEM_ADDR_WIDTH-1:0] item_dispense;
wire [CURRENCY_WIDTH-1:0] currency_change;
wire [31:0] prdata;
wire pready;// Instantiate the vending_machine_controller

vending_machine_controller uut (
.clk(clk),
.rstn(rstn),
.cfg_mode(cfg_mode),
.item_select(item_select),
.item_select_valid(item_select_valid),
.currency_value(currency_value),
.currency_valid(currency_valid),
.pclk(pclk),
.prstn(prstn),
.paddr(paddr),
.psel(psel),
.penable(penable),
.pwrite(pwrite),
.pwdata(pwdata),
.prdata(prdata),
.pready(pready),
.item_dispense_valid(item_dispense_valid),
.item_dispense(item_dispense),
.currency_change(currency_change)
);
// Clock Generation
always begin#5 clk = ~clk;
end
always begin #5 pclk = ~pclk;
end
// Initial Block
initial begin
// Initialize Inputs
clk = 0;
pclk = 0;
rstn = 0;
prstn = 0; // Reset APB interface
cfg_mode = 0;
item_select = 0;
item_select_valid = 0;
currency_value = 0;
currency_valid = 0;
paddr = 0;
psel = 0;
penable = 0;
pwrite = 0;
pwdata = 0;
// Apply Reset#10 rstn = 1;
#10 prstn = 1; // Release APB reset
#10 cfg_mode = 1;
// Test 1: Item Selection
#20 item_select = 10'd10; // Select item 10
item_select_valid = 1;
#10 item_select_valid = 0;
// Test 2: Currency Insertion
#20 currency_value = 7'd50; // Insert 50 currency
currency_valid = 1;
#10 currency_valid = 0;
// Test 3: APB Write Transaction to configure item price and availability
#20 psel = 1;
penable = 0;
pwrite = 1;
paddr = 15'h1000; // Assume item price at address 0x1000
pwdata = 32'h00000032; // Item price = 50 (example value)
#10 penable = 1;
// Test 4: APB Read Transaction to get item information
#20 psel = 1;
pwrite = 0;
paddr = 15'h1000; // Address for item price#10;
// Test 5: Dispense Item (check if system triggers dispense)
#20 item_select = 10'd10; // Select item 10 again
item_select_valid = 1;
currency_value = 7'd50; // Insert 50 currency
currency_valid = 1;
#10 item_select_valid = 0;
currency_valid = 0;
// Finish Simulation
#100 $finish;
end
// Monitoring
initial begin
$monitor("Time: %t, Item Selected: %d, Currency Inserted: %d, Item Dispensed: %d,Currency Change: %d",$time, item_select, currency_value, item_dispense, currency_change);
end
endmodule