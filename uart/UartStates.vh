// states of state machine
`define RESET       3'b001
`define IDLE        3'b010
`define START_BIT   3'b011 // transmitter only
`define DATA_BITS   3'b100
`define STOP_BIT    3'b101
