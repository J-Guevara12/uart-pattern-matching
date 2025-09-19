// modules/uart_sampler.v
// Detects a UART start bit and samples the following 8 data bits.

module uart_sampler (
    input  wire       sys_clk,
    input  wire       reset,
    input  wire       baud_tick,
    input  wire       rx_in,
    output reg  [7:0] data_out,
    output reg        data_valid
);

    // State machine definitions
    localparam IDLE        = 2'b00;
    localparam START_BIT   = 2'b01;
    localparam SAMPLING    = 2'b10;
    localparam STOP_BIT    = 2'b11;

    reg [1:0] state;
    reg [2:0] bit_counter; // Counts from 0 to 7 for 8 bits

    // UART sends LSB first, this register reverses the bits during reception.
    reg [7:0] shift_reg;

    always @(posedge sys_clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            bit_counter <= 0;
            data_out <= 0;
            data_valid <= 0;
            shift_reg <= 0;
        end else begin
            // Default assignments
            data_valid <= 0;

            case (state)
                IDLE: begin
                    // A falling edge indicates a potential start bit.
                    if (~rx_in) begin
                        state <= START_BIT;
                    end
                end

                START_BIT: begin
                    // The first baud_tick after the falling edge synchronizes us.
                    // We are now in the middle of the start bit period.
                    // The next tick will be in the middle of the first data bit.
                    if (baud_tick) begin
                        bit_counter <= 0;
                        state <= SAMPLING;
                    end
                end

                SAMPLING: begin
                    if (baud_tick) begin
                        // Shift the received bit into the MSB. Since UART is LSB-first,
                        // the first bit (D0) will end up in the LSB position after 8 shifts.
                        shift_reg <= {rx_in, shift_reg[7:1]};
                        
                        if (bit_counter == 7) begin
                            state <= STOP_BIT;
                        end else begin
                            bit_counter <= bit_counter + 1;
                        end
                    end
                end

                STOP_BIT: begin
                    // Wait one more tick for the stop bit period to pass.
                    if (baud_tick) begin
                        data_out <= shift_reg;
                        data_valid <= 1;
                        state <= IDLE;
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule