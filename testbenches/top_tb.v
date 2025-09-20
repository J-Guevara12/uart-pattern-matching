// testbenches/top_tb.v
// Comprehensive testbench for the top-level module.

`timescale 1ns / 1ps

module top_tb;

    // Inputs
    reg sys_clk;
    reg reset;
    reg rx_in;

    // Outputs
    wire match;

    // Instantiate the Unit Under Test (UUT)
    top uut (
        .sys_clk(sys_clk),
        .reset(reset),
        .rx_in(rx_in),
        .match(match)
    );

    // Clock generation (25 MHz -> 40 ns period)
    initial begin
        sys_clk = 0;
        forever #20 sys_clk = ~sys_clk;
    end

    // UART bit period: 1 / 115200 bps ~= 8680 ns
    localparam BIT_PERIOD = 8680;
    localparam PATTERN = 4'b0110;

    // Task to send a UART frame
    task send_uart_frame;
        input [7:0] data;
        integer i;
        begin
            // Start bit
            rx_in = 0;
            #(BIT_PERIOD);

            // 8 Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx_in = data[i];
                #(BIT_PERIOD);
            end

            // Stop bit
            rx_in = 1;
            #(BIT_PERIOD);
        end
    endtask

    // Test sequence
    initial begin
        // Initialize
        reset = 1;
        rx_in = 1; // UART idle state
        #200;

        // Release reset
        reset = 0;
        #5000;

        // --- Test Cases ---
        $display("--- Starting Test Cases ---");
        $display("Pattern to detect: %b", PATTERN);

        // Test Case 1: Simple Match
        // Send a byte where the last 4 bits form the pattern.
        $display("Test 1: Sending byte with simple pattern at the end (10100110)");
        send_uart_frame(8'b10100110);
        #20000;

        // Test Case 2: No Match
        // Send a byte that does not contain the pattern.
        $display("Test 2: Sending byte with no pattern (11110000)");
        send_uart_frame(8'b11110000);
        #20000;

        // Test Case 3: Overlapping Match
        // Send a byte containing the pattern twice, where it overlaps.
        // The sequence `0110110` contains `0110` and `0110`.
        $display("Test 3: Sending byte with overlapping pattern (01101101)");
        send_uart_frame(8'b01101101); // Creates the stream 10110110...
        #30000;

        // Test Case 4: Back-to-Back Match (Across Frames)
        // Send two bytes that form the pattern at their boundary.
        // Byte 1 ends in `011`, Byte 2 starts with `0`.
        $display("Test 4: Sending two bytes to form a match at the boundary");
        send_uart_frame(8'b00001011); // Ends in 011
        send_uart_frame(8'b00000000); // Starts with 0
        #30000;

        // Test Case 5: Pattern in the Middle
        // The pattern appears in the middle of the 8 bits, so no match should be detected
        // from this byte alone.
        $display("Test 5: Sending byte with pattern in the middle (01101111)");
        send_uart_frame(8'b01101111);
        #20000;

        // Test Case 6: Noise/Glitch on Start Bit
        // Simulate a short glitch on the rx_in line. The sampler should ignore it.
        $display("Test 6: Simulating a short glitch on the rx_in line");
        rx_in = 0;
        #(BIT_PERIOD / 4); // Glitch is much shorter than a real start bit
        rx_in = 1;
        #40000; // Wait to see if any false reception occurs

        // Test Case 7: Reset During Reception
        // Assert reset in the middle of a UART frame. The FSM should reset to IDLE.
        $display("Test 7: Asserting reset during a UART transmission");
        // Start sending a frame
        rx_in = 0;
        #(BIT_PERIOD);
        rx_in = 1;
        #(BIT_PERIOD);
        rx_in = 0;
        #(BIT_PERIOD);
        // Assert reset
        reset = 1;
        #200;
        reset = 0;
        rx_in = 1; // Return line to idle
        #40000; // Wait to ensure the system is idle and no match is flagged

        $display("--- All tests complete ---");
        $finish;
    end

    // Monitor for match signal
    always @(posedge sys_clk) begin
        if (match) begin
            $display("SUCCESS: Pattern detected at time %0t ns", $time);
        end
    end

    // Dump waves
    initial begin
        $dumpfile("var_dumps/top.vcd");
        $dumpvars(0, top_tb);
    end

endmodule
