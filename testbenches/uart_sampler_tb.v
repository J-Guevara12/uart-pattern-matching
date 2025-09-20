// testbenches/uart_sampler_tb.v
// Testbench for the uart_sampler module.

`timescale 1ns / 1ps

module uart_sampler_tb;

    // Inputs
    reg sys_clk;
    reg reset;
    reg rx_in;

    // Outputs
    wire [7:0] data_out;
    wire       data_valid;

    // Internal signals
    wire baud_tick;

    // Instantiate the Baud Rate Generator
    baud_gen baud_gen_inst (
        .sys_clk(sys_clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

    wire serial_out;
    wire serial_valid;

    // Instantiate the Unit Under Test (UUT)
    uart_sampler uut (
        .sys_clk(sys_clk),
        .reset(reset),
        .baud_tick(baud_tick),
        .rx_in(rx_in),
        .data_out(data_out),
        .data_valid(data_valid),
        .serial_out(serial_out),
        .serial_valid(serial_valid)
    );

    // Clock generation (25 MHz -> 40 ns period)
    initial begin
        sys_clk = 0;
        forever #20 sys_clk = ~sys_clk;
    end

    // UART bit period: 1 / 115200 bps ~= 8680 ns
    localparam BIT_PERIOD = 8680;

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
        #100;

        // Release reset
        reset = 0;
        #5000;

        // Send a byte
        send_uart_frame(8'b11010110); // Send 0xD6

        #20000; // Wait for reception

        // Send another byte
        send_uart_frame(8'b00110101); // Send 0x35

        #20000;

        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time = %0t ns, rx_in = %b, data_out = %h, data_valid = %b, serial_out = %b, serial_valid = %b",
                 $time, rx_in, data_out, data_valid, serial_out, serial_valid);
    end

    // Dump waves
    initial begin
        $dumpfile("var_dumps/uart_sampler.vcd");
        $dumpvars(0, uart_sampler_tb);
    end

endmodule
