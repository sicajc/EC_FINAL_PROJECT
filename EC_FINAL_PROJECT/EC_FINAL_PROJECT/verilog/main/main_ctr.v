module main_ctr(
           input clk,
           input rst,
           input start,
           input rd_done,
           input rf_done,
           output reg[2:0] current_state
       );

localparam IDLE = 'd0 ;
localparam RD_DATA = 'd1;
localparam GENERATE_IND = 'd2;
localparam POP_RF = 'd3;
localparam OUTPUT = 'd4;

reg[2:0] next_state;

always @(posedge clk )
begin
    current_state <= rst ? IDLE : next_state;
end

always @(*)
begin
    case(current_state)
        IDLE:
            next_state =  start ? RD_DATA : IDLE;
        RD_DATA:
            next_state = rd_done ? GENERATE_IND : RD_DATA;
        POP_RF :
            next_state = rf_done ? OUTPUT : POP_RF;
        default :
            next_state = current_state;
    endcase
end





endmodule
