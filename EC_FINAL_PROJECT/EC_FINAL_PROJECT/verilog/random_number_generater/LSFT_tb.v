`timescale  1ns / 1ps
`define CYCLE_TIME 1000
`define CYCLE 10
module tb_LSFR;

// LSFR Parameters
parameter S_WIDTH    = 8;
parameter IND_WIDTH  = 2;
parameter RND_WIDTH  = 6;

reg clk=0;
reg flag=0;
reg [9:0] count=0;
reg rst_n,in_valid;
reg [S_WIDTH-1:0] random_seed_1;
reg [S_WIDTH-1:0] random_seed_2;
reg [S_WIDTH-1:0] random_seed_3;

// LSFR Outputs
wire[S_WIDTH-1:0] random_num_ff_1 ;
wire[S_WIDTH-1:0] random_num_ff_2 ;
wire[S_WIDTH-1:0] random_num_ff_3 ;

reg [IND_WIDTH-1:0] random_num_ff_2_o;
reg [RND_WIDTH-1:0] random_num_ff_3_o;

//clk
always
begin
  #(`CYCLE/2) clk = ~clk;
end

initial
begin
    rst_n = 0;
    random_seed_1 = 'bx;
    random_seed_2 = 'bx;
    random_seed_3 = 'bx;
    in_valid = 0;
    #12 rst_n = 1;
    @(negedge clk)
    in_valid = 1;
    random_seed_1 = 127;
    random_seed_2 = 87;
    random_seed_3 = 78;
    @(negedge clk)
    flag = 1;
    in_valid = 0;
    #`CYCLE_TIME;
    flag = 0;
    $finish;
end

always@(posedge clk)
begin
    if(flag) begin
        count = count + 1;
        random_num_ff_2_o = random_num_ff_2[IND_WIDTH-1:0];
        random_num_ff_3_o = random_num_ff_3[RND_WIDTH-1:0];
        $display("----------- display number %3d ------------",count);
        $display("8 bit random_number : %3d,random_seed_1 is %3d",random_num_ff_1,random_seed_1);
        $display("2 bit random_number : %3d,random_seed_2 is %3d",random_num_ff_2_o,random_seed_2);
        $display("6 bit random_number : %3d,random_seed_3 is %3d",random_num_ff_3_o,random_seed_3);
        $display("----------- ---------- ------------");
    end
end

//module
    LSFR #(
            .S_WIDTH(S_WIDTH)
        ) inst_LSFR_1 (
            .clk               (clk),
            .rst_n             (rst_n),
            .random_seed_i     (random_seed_1),
            .in_valid          (in_valid),
            .random_num_ff_o   (random_num_ff_1)
        );

    LSFR #(
            .S_WIDTH(S_WIDTH)
        ) inst_LSFR_2 (
            .clk               (clk),
            .rst_n             (rst_n),
            .random_seed_i     (random_seed_2),
            .in_valid          (in_valid),
            .random_num_ff_o   (random_num_ff_2)
        );

    LSFR #(
            .S_WIDTH(S_WIDTH)
        ) inst_LSFR_3 (
            .clk               (clk),
            .rst_n             (rst_n),
            .random_seed_i     (random_seed_3),
            .in_valid          (in_valid),
            .random_num_ff_o   (random_num_ff_3)
        );

endmodule