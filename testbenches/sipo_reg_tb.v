// testbenches/sipo_reg_tb.v
// Testbench for the sipo_reg module.

`timescale 1ns / 1ps

module sipo_reg_tb;

    // Inputs
    reg clk;
    reg reset;
    reg serial_in;

    // Outputs
    wire [7:0] parallel_out;

    // Instantiate the Unit Under Test (UUT)
    sipo_reg uut (
        .clk(clk),
        .reset(reset),
        .serial_in(serial_in),
        .parallel_out(parallel_out)
    );

    // Clock generation (simulating a baud_tick)
    initial begin
        clk = 0;
        forever #4340 clk = ~clk; // ~8.68 us period
    end

    // Test sequence
    initial begin
        // Initialize
        reset = 1;
        serial_in = 0;
        #10000;

        // Release reset
        reset = 0;
        #10000;

        // Shift in a byte: 8'b11010110 (D6)
        // We send MSB first for this test.
        // Change input between clock edges to avoid race conditions.
        @(negedge clk) serial_in = 1;
        @(negedge clk) serial_in = 1;
        @(negedge clk) serial_in = 0;
        @(negedge clk) serial_in = 1;
        @(negedge clk) serial_in = 0;
        @(negedge clk) serial_in = 1;
        @(negedge clk) serial_in = 1;
        @(negedge clk) serial_in = 0;

        @(negedge clk); // Allow last bit to be clocked in

        #10000;

        // Shift in a few more bits to see the window slide
        @(negedge clk) serial_in = 1;
        @(negedge clk) serial_in = 0;
        @(negedge clk) serial_in = 1;

        #20000;

        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time = %0t ns, serial_in = %b, parallel_out = %h",
                 $time, serial_in, parallel_out);
    end

    // Dump waves
    initial begin
        $dumpfile("var_dumps/sipo_reg.vcd");
        $dumpvars(0, sipo_reg_tb);
    end

endmodule
