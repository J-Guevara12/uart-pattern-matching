// testbenches/detector_tb.v
// Testbench for the detector module.

`timescale 1ns / 1ps

module detector_tb;

    // Inputs
    reg [3:0] data_in;

    // Outputs
    wire match;

    // Instantiate the Unit Under Test (UUT)
    detector uut (
        .data_in(data_in),
        .match(match)
    );

    // Test sequence
    initial begin
        // Initialize
        data_in = 4'b0000;
        #10;

        // Test case 1: Match
        // The pattern is 0110
        data_in = 4'b0110;
        #10;
        if (match !== 1) begin
            $display("TEST FAILED: Match not detected for pattern 0110");
            $finish;
        end

        // Test case 2: No match
        data_in = 4'b1111;
        #10;
        if (match !== 0) begin
            $display("TEST FAILED: Match incorrectly detected for pattern 1111");
            $finish;
        end
        
        // Test case 3: Another no match
        data_in = 4'b0111;
        #10;
        if (match !== 0) begin
            $display("TEST FAILED: Match incorrectly detected for pattern 0111");
            $finish;
        end

        $display("All tests passed!");
        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time = %0t ns, data_in = %b, match = %b",
                 $time, data_in, match);
    end

    // Dump waves
    initial begin
        $dumpfile("var_dumps/detector.vcd");
        $dumpvars(0, detector_tb);
    end

endmodule
