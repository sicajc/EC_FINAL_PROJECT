`timescale  1ns / 1ps
`define CYCLE_TIME 1000
module tb_LSFR;

// LSFR Parameters
parameter PERIOD     = 10;
parameter S_WIDTH    = 8;
parameter INT_WIDTH  = 2;


// LSFR Inputs
reg   clk                                = 0 ;
reg   rst_n                              = 0 ;
reg   random_seed_valid                  = 0 ;
reg   [1:0]  mode                        = 0 ;
reg   [S_WIDTH-1:0]  random_seed         = 8'b00100110 ;

// LSFR Outputs
wire[S_WIDTH-1:0]   mode_02_value ;
wire[INT_WIDTH-1:0] mode_1_value  ;

initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
    #10;
    rst_n   = 'd0;
    random_seed_valid = 1'b1;
    #50;
    random_seed_valid = 1'b0;
    mode    = 'd1;
    #200;
    mode    = 'd2;
    #100;
    mode    = 'd0;

end

LSFR #(
    .S_WIDTH   ( S_WIDTH   ),
    .INT_WIDTH ( INT_WIDTH ))
 u_LSFR (
    .clk_i                                 ( clk                             ),
    .rst_i                                 ( rst_n                           ),
    .random_seed_valid_i                   ( random_seed_valid               ),
    .mode_i                                ( mode                            ),
    .random_seed_i                         ( random_seed                     ),

    .random_num_ff_02_o  ( mode_02_value                ),
    .random_num_ff_1_o   ( mode_1_value                 )
);

initial
begin
    #`CYCLE_TIME;
    $finish;
end

endmodule