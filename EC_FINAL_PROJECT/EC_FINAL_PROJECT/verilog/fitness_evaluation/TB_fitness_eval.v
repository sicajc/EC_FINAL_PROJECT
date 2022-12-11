`timescale 1ns/1ps
`define  CYCLE 10


module TB_fitness_eval ();

parameter NUM_PARTICLE_TYPE        = 3  ;
parameter DATA_WIDTH               = 4  ;
parameter PARTICLE_LENGTH          = 2  ;
parameter LATTICE_LENGTH           = 11 ;
parameter SELF_FIT_LENGTH          = 10 ;
parameter SELF_ENERGY_VEC_LENGTH   = NUM_PARTICLE_TYPE*DATA_WIDTH;
parameter INTERATION_MATRIX_LENGTH = (NUM_PARTICLE_TYPE**2)*DATA_WIDTH;
parameter INDIVIDUAL_LENGTH        = LATTICE_LENGTH * PARTICLE_LENGTH;
parameter POP_SIZE                 = 50 ;

reg clk_i=0;
reg rst_n;
reg [SELF_ENERGY_VEC_LENGTH   -1 : 0 ]     self_energy_vec_i;
reg [INTERATION_MATRIX_LENGTH -1 : 0]      interact_matrix_i;
reg [INDIVIDUAL_LENGTH   -1 :0]            individual_vec_i;
reg  in_valid_i;
reg  Set_data_i;
reg  ind_idx_i;

wire out_valid_ff_o;
wire done_ff_o;
wire [SELF_FIT_LENGTH-1:0] total_energy_ff_o;
wire ind_wb_idx_ff_o;

//interger
//integer seed=87;
integer i,j;
integer f;

//reg 
reg [SELF_FIT_LENGTH-1:0] total_energy_check=0;
reg [SELF_FIT_LENGTH-1:0] total_energy_check_d1,total_energy_check_d2,total_energy_check_d3,total_energy_check_d4;
reg [PARTICLE_LENGTH-1:0] random_number = 0,random_number_delay = 0;
reg [DATA_WIDTH-1:0] self_energy_vec[0:NUM_PARTICLE_TYPE-1];
reg [DATA_WIDTH-1:0] interact_matrix[0:NUM_PARTICLE_TYPE-1][0:NUM_PARTICLE_TYPE-1];

//clk
always
begin
  #(`CYCLE/2) clk_i = ~clk_i;
end

//main
initial begin  
    f=$fopen("C:/Users/User/EC_FINAL_PROJECT/EC_FINAL_PROJECT/EC_FINAL_PROJECT/verilog/fitness_evaluation/test.txt","w");
    rst_n = 0;
    in_valid_i = 0;
    Set_data_i = 0;
    {self_energy_vec[0],self_energy_vec[1],self_energy_vec[2]} = 12'b000100100011;
    {interact_matrix[0][0],interact_matrix[0][1],interact_matrix[0][2]} = 12'b101001000001;
    {interact_matrix[1][0],interact_matrix[1][1],interact_matrix[1][2]} = 12'b010010100101;
    {interact_matrix[2][0],interact_matrix[2][1],interact_matrix[2][2]} = 12'b000101011010;
    #20
    rst_n = 1;
    Set_data_i = 1;
    @(negedge clk_i);
    input_task;
end

task input_task; begin
    Set_data_i = 0;
    self_energy_vec_i = 12'b000100100011;
    interact_matrix_i = 36'b101001000001010010100101000101011010;
    @(negedge clk_i);
    self_energy_vec_i = 'bx;
    interact_matrix_i = 'bx;
    for(i=0;i<POP_SIZE;i=i+1) begin
        in_valid_i = 1;
        total_energy_check = 0;
        for(j=0;j<LATTICE_LENGTH;j=j+1) begin
            random_number_delay = random_number;
            random_number = $urandom_range(0,2);
            individual_vec_i[PARTICLE_LENGTH*j +: PARTICLE_LENGTH] = random_number;
            //self energy
            total_energy_check = total_energy_check + self_energy_vec[random_number];
            //interact_energy
            if(j>0) begin
                total_energy_check = total_energy_check + 2*interact_matrix[random_number_delay][random_number];
            end
        end
        if(i>=4) begin
            if(total_energy_check_d3 != total_energy_ff_o) begin
                $display("something error,out is %3d,exp is %3d",total_energy_ff_o,total_energy_check_d3);
            end
        end
        write;
        @(negedge clk_i);
    end
    $fclose(f);
end 
endtask:input_task

task write; begin
    for(j=0;j<LATTICE_LENGTH;j=j+1) begin
        $fwrite(f,"%d ",individual_vec_i[PARTICLE_LENGTH*j +: PARTICLE_LENGTH]);
    end
    $fwrite(f,"\n");
end
endtask : write

//total_energy_check_delay
always @(posedge clk_i) begin
    if(in_valid_i) begin
        {total_energy_check_d1,total_energy_check_d2,total_energy_check_d3,total_energy_check_d4} <= 
        {total_energy_check,total_energy_check_d1,total_energy_check_d2,total_energy_check_d3};
    end 
end

//module
    fitness_eval #(
            .NUM_PARTICLE_TYPE(NUM_PARTICLE_TYPE),
            .DATA_WIDTH(DATA_WIDTH),
            .PARTICLE_LENGTH(PARTICLE_LENGTH),
            .LATTICE_LENGTH(LATTICE_LENGTH),
            .SELF_FIT_LENGTH(SELF_FIT_LENGTH),
            .SELF_ENERGY_VEC_LENGTH(SELF_ENERGY_VEC_LENGTH),
            .INTERATION_MATRIX_LENGTH(INTERATION_MATRIX_LENGTH),
            .INDIVIDUAL_LENGTH(INDIVIDUAL_LENGTH),
            .POP_SIZE(POP_SIZE)
        ) inst_fitness_eval (
            .clk_i             (clk_i),
            .rst_n             (rst_n),
            .self_energy_vec_i (self_energy_vec_i),
            .interact_matrix_i (interact_matrix_i),
            .individual_vec_i  (individual_vec_i),
            .in_valid_i        (in_valid_i),
            .Set_data_i        (Set_data_i),
            .ind_idx_i         (ind_idx_i),
            .out_valid_ff_o    (out_valid_ff_o),
            .done_ff_o         (done_ff_o),
            .total_energy_ff_o (total_energy_ff_o),
            .ind_wb_idx_ff_o   (ind_wb_idx_ff_o)
        );


endmodule : TB_fitness_eval