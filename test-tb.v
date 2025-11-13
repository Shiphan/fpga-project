`timescale 1ns / 1ns

module led_tb;

// Inputs
reg clk;
reg reset;

// Outputs
wire [7:0] segout;
wire [2:0] scanout;

// Instantiate the Unit Under Test (UUT)
led uut (
    .clk(clk),
    .reset(reset),
    .segout(segout),
    .scanout(scanout)
);

// Clock generation - 50MHz clock (20ns period)
initial begin
    clk = 0;
    forever #1 clk = ~clk;
end

// Test stimulus
initial begin
    // Initialize waveform dump
    $dumpfile("led_tb.vcd");
    $dumpvars(0, led_tb);

    // Display header
    $display("===================================");
    $display("LED Module Testbench");
    $display("===================================");
    $display("Time\t\tReset\tScanout\tSegout");
    $display("-----------------------------------");

    // Initialize Inputs
    reset = 0;

    // Apply reset
    #5;
    reset = 1;
    $display("%0t ns\tReset asserted", $time);
    #100;
    reset = 0;
    $display("%0t ns\tReset deasserted", $time);

    // Run simulation for enough time to see several pattern transitions
    // Each slow clock cycle is 5000000 * 20ns = 100ms
    // We want to see at least a few complete cycles through group_a and group_b

    // Monitor output changes
    #20_000_000; // Run for 200ms to see pattern changes

    $display("-----------------------------------");
    $display("Simulation completed successfully");
    $display("===================================");
    $finish;
end

// Monitor scanout and segout changes
always @(scanout or segout) begin
    $display("%0t ns\t%b\t%b\t%b", $time, reset, scanout, segout);
end

// Optional: Monitor internal state changes
always @(posedge uut.clk1) begin
    $display("%0t ns\tSlow CLK: group=%0d, count=%0d", $time, uut.group, uut.count);
end

// Timeout watchdog
initial begin
    #6000000000; // 300ms timeout
    $display("WARNING: Simulation timeout reached");
    $finish;
end

endmodule
