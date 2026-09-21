`timescale 1ns / 1ps

module uart_rx_tb;

    reg clk;
    reg rst;
    reg rx;

    wire [7:0] data_out;
    wire data_valid;
    wire busy;

    uart_rx uut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data_out(data_out),
        .data_valid(data_valid),
        .busy(busy)
    );

    // 50 MHz clock
    always #10 clk = ~clk;

    // Send one UART bit
    task send_bit;
        input bit_value;
        begin
            rx = bit_value;
            #104170;
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        rx  = 1;

        #100;
        rst = 0;

        // Send 8'b10110010
        // UART sends LSB first
        send_bit(0); // Start bit
        send_bit(0); // Bit 0
        send_bit(1); // Bit 1
        send_bit(0); // Bit 2
        send_bit(0); // Bit 3
        send_bit(1); // Bit 4
        send_bit(1); // Bit 5
        send_bit(0); // Bit 6
        send_bit(1); // Bit 7
        send_bit(1); // Stop bit

        #200000;
        $finish;
    end

endmodule