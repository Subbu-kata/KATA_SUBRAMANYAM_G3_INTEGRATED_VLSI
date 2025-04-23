`timescale 1ns / 1ps
module pulse_sync_tb;
reg clk_dst;
reg rstn;
reg pulse_src;
wire pulse_dst;
// Instantiate pulse_sync
pulse_sync uut (
.clk_dst(clk_dst),
.rstn(rstn),
.pulse_src(pulse_src),
.pulse_dst(pulse_dst)
);
// Generate clk_dst: 20ns period (50MHz)
always #10 clk_dst = ~clk_dst;
initial begin
$display("Starting pulse_sync test...");
clk_dst = 0;
rstn = 0;
pulse_src = 0;
#25 rstn = 1;// Send pulse 1
send_pulse();
#100;
// Send pulse 2
send_pulse();
#100;
// Send quick repeated pulses
send_pulse();
#20;
send_pulse();
#100;
$display("Test completed.");
$finish;
end
task send_pulse();
begin
pulse_src = 1;
#5;
pulse_src = 0;
$display("Async pulse sent at time %t", $time);
end
endtask
endmodule
