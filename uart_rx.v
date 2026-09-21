module uart_rx (
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,
    output reg [7:0]  data_out,
    output reg        data_valid,
    output reg        busy
);

    // 50 MHz clock, 9600 baud
    localparam integer BAUD_COUNT = 5208;
    localparam integer HALF_BAUD_COUNT = 2604;

    // FSM states
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0]  state;
    reg [12:0] baud_counter;
    reg [2:0]  bit_count;
    reg [7:0]  shift_reg;

    // Synchronize asynchronous RX input
    reg rx_sync1;
    reg rx_sync2;

    always @(posedge clk or posedge rst) begin

        if (rst) begin
            state        <= IDLE;
            baud_counter <= 13'd0;
            bit_count    <= 3'd0;
            shift_reg    <= 8'd0;
            data_out     <= 8'd0;
            data_valid   <= 1'b0;
            busy         <= 1'b0;
            rx_sync1     <= 1'b1;
            rx_sync2     <= 1'b1;
        end

        else begin

            // Synchronize RX signal
            rx_sync1 <= rx;
            rx_sync2 <= rx_sync1;

            // data_valid is a one-clock pulse
            data_valid <= 1'b0;

            case (state)

                // ---------------- IDLE ----------------
                IDLE: begin
                    busy         <= 1'b0;
                    baud_counter <= 13'd0;
                    bit_count    <= 3'd0;

                    // Detect start bit
                    if (rx_sync2 == 1'b0) begin
                        state        <= START;
                        busy         <= 1'b1;
                        baud_counter <= 13'd0;
                    end
                end

                // ---------------- START ----------------
                START: begin

                    // Wait half a bit period
                    if (baud_counter == HALF_BAUD_COUNT - 1) begin
                        baud_counter <= 13'd0;

                        // Confirm start bit is still LOW
                        if (rx_sync2 == 1'b0) begin
                            state     <= DATA;
                            bit_count <= 3'd0;
                        end
                        else begin
                            state <= IDLE;
                            busy  <= 1'b0;
                        end
                    end

                    else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                // ---------------- DATA ----------------
                DATA: begin

                    // Wait one full bit period
                    if (baud_counter == BAUD_COUNT - 1) begin
                        baud_counter <= 13'd0;

                        // Receive LSB first
                        shift_reg[bit_count] <= rx_sync2;

                        if (bit_count == 3'd7) begin
                            state <= STOP;
                        end
                        else begin
                            bit_count <= bit_count + 1'b1;
                        end
                    end

                    else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                // ---------------- STOP ----------------
                STOP: begin

                    if (baud_counter == BAUD_COUNT - 1) begin
                        baud_counter <= 13'd0;

                        // Check stop bit
                        if (rx_sync2 == 1'b1) begin
                            data_out   <= shift_reg;
                            data_valid <= 1'b1;
                        end

                        state <= IDLE;
                        busy  <= 1'b0;
                    end

                    else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                default: begin
                    state <= IDLE;
                    busy  <= 1'b0;
                end

            endcase
        end
    end

endmodule