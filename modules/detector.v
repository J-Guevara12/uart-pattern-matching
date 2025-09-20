// modules/detector.v
// Compares the 4 LSBs of the SIPO register to a target pattern.

module detector (
    input  wire [3:0] data_in, // 4 LSBs from the SIPO register
    output wire       match    // High when the pattern is detected
);

    // The pattern to detect is the last digit of the student ID: 6
    // 6 in 4-bit binary is 0110.
    localparam PATTERN = 4'b0110;

    // Combinational comparison
    assign match = (data_in == PATTERN);

endmodule
