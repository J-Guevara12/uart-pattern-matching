// testbenches/baud_gen_tb.v
// Testbench for the baud_gen module.

`timescale 1ns / 1ps

module baud_gen_tb;

    // Inputs
    reg sys_clk;
    reg reset;

    // Outputs
    wire baud_tick;

    // Instantiate the Unit Under Test (UUT)
    baud_gen uut (
        .sys_clk(sys_clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

    // Clock generation (25 MHz -> 40 ns period)
    initial begin
        sys_clk = 0;
        forever #20 sys_clk = ~sys_clk;
    end

    // Test sequence
    initial begin
        // Initialize Inputs
        reset = 1;
        #200; // Wait for 100 ns

        // Release reset
        reset = 0;
        #10000; // Run for 10 us to observe a few ticks

        // Stop simulation
        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time = %0t ns, reset = %b, baud_tick = %b",
                 $time, reset, baud_tick);
    end

    // Dump waves
    initial begin
        $dumpfile("var_dumps/baud_gen.vcd");
        $dumpvars(0, baud_gen_tb);
    end

endmodule
