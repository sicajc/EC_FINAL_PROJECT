//~ `New testbench
`timescale  1ns / 1ps

module tb_counter;

// counter Parameters
parameter PERIOD     = 10;
parameter CNT_WIDTH  = 4;

// counter Inputs
reg   clk                                = 0 ;
reg   rst_n                              = 0 ;
reg   en                                 = 0 ;
reg   clr                                = 0 ;

// counter Outputs
wire  reg[CNT_WIDTH-1:0] cnt_ff            ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;

    #10 rst_n = 0;
        en    = 1;


    #(PERIOD*30) clr = 1;
    #(PERIOD*5)  clr = 0;

end

counter #(
    .CNT_WIDTH ( CNT_WIDTH ))
 u_counter (
    .clk_i                      ( clk                       ),
    .rst_n_i                      ( rst_n                     ),
    .en_i                       ( en                        ),
    .clr_i                      ( clr                       ),

    .cnt_ff  ( cnt_ff   )
);

initial
begin

    $finish;
end

endmodule