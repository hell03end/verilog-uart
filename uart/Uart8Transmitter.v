`timescale 1 ns / 1 ps

/*
 * 8-bit UART Transmitter.
 * Able to transmit 8 bits of serial data, one start bit, one stop bit.
 * When transmit is complete {done} is driven high for one clock cycle.
 * When transmit is in progress {busy} is driven high.
 * Clock should be decreased to baud rate.
 */
module Uart8Transmitter  (
    input wire clk, // baud rate
    input wire en,
    input wire start, // start of transaction
    input wire [7:0] in, // data to transmit
    output reg out, // tx
    output reg done, // end on transaction
    output reg busy // transaction is in process
);
// states of state machine
reg [2:0] RESET = 3'b000;
reg [2:0] IDLE = 3'b001;
reg [2:0] START_BIT = 3'b010;
reg [2:0] DATA_BITS = 3'b011;
reg [2:0] STOP_BIT = 3'b100;

reg [2:0] state;
reg [7:0] data = 8'b0; // to store a copy of input data
reg [2:0] bitIdx = 3'b0; // for 8-bit data

initial begin
    out <= 1'b1;
    done <= 1'b0;
    busy <= 1'b0;
end

always @(posedge clk) begin
    if (!en) begin
        state = RESET;
    end

    case (state)
        RESET: begin
            out <= 1'b1;
            done <= 1'b0;
            busy <= 1'b0;
            bitIdx <= 3'b0;
            data <= 8'b0;
            if (en) begin
                state <= IDLE;
            end
        end

        IDLE: begin
            out <= 1'b1; // drive line high for idle
            done <= 1'b0;
            if (start) begin
                data <= in; // save a copy of input data
                state <= START_BIT;
            end
        end

        // Send out start bit (low)
        START_BIT: begin
            out <= 1'b0;
            busy <= 1'b1;
            state <= DATA_BITS;
        end

        // Wait 8 clock cycles for data bits to be sent
        DATA_BITS: begin
            out <= data[bitIdx];
            if (&bitIdx) begin
                state <= STOP_BIT;
                bitIdx <= 3'b0;
            end else begin
                bitIdx = bitIdx + 1'b1;
            end
        end

        // Send out Stop bit (high)
        STOP_BIT: begin
            out <= 1'b1;
            done <= 1'b1;
            busy <= 1'b0;
            data <= 8'b0;
            state <= IDLE;
        end

        default: state <= IDLE;
    endcase
end

endmodule
