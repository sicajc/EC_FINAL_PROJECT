module fitness_eval #(
           parameter NUM_PARTICLE_TYPE        = 3  ,
           parameter DATA_WIDTH               = 4  ,
           parameter LATTICE_LENGTH           = 11 ,
           parameter SELF_FIT_LENGTH          = 10 ,
           parameter SELF_ENERGY_VEC_LENGTH   = NUM_PARTICLE_TYPE*DATA_WIDTH,
           parameter INTERATION_MATRIX_LENGTH = (NUM_PARTICLE_TYPE**2)*DATA_WIDTH,
           parameter INDIVIDUAL_LENGTH        = LATTICE_LENGTH * DATA_WIDTH
       ) (
           input clk_i,
           input rst_n,
           input [SELF_ENERGY_VEC_LENGTH   -1 : 0 ]     self_energy_vec_i,
           input [INTERATION_MATRIX_LENGTH -1 : 0]      interact_matrix_i,
           input [INDIVIDUAL_LENGTH   -1 :0]            individual_vec_i,
           input  in_valid_i,
           output out_valid_o,
           output reg[SELF_FIT_LENGTH-1:0] self_fit_o
       );

reg[DATA_WIDTH - 1 :0] self_energy_vec_rf[0:NUM_PARTICLE_TYPE-1];
reg[DATA_WIDTH - 1 :0] interact_matrix_rf[0:NUM_PARTICLE_TYPE-1][0:NUM_PARTICLE_TYPE-1];

reg[DATA_WIDTH - 1 :0] individual_buffer[0:LATTICE_LENGTH-1];

always @(posedge clk_i or negedge rst_n)
begin: self_energy
    integer i;
    for(i=0;i<NUM_PARTICLE_TYPE;i=i+1)
    begin
        if(~rst_n)
        begin
            self_energy_vec_rf[i] <= 'd0;
        end
        else if(in_valid_i)
        begin
            self_energy_vec_rf[i] <= self_energy_vec_i[i*DATA_WIDTH +: DATA_WIDTH];
        end
        else
        begin
            self_energy_vec_rf[i] <= self_energy_vec_rf[i];
        end
    end
end

always @(posedge clk_i or negedge rst_n)
begin: interact_matrix
    integer i,j;
    for(i=0;i<NUM_PARTICLE_TYPE;i=i+1)
        for(j=0;j<NUM_PARTICLE_TYPE;j=j+1)
        begin
            if(~rst_n)
            begin
                interact_matrix_rf[i][j] <= 'd0;
            end
            else if(in_valid_i)
            begin
                interact_matrix_rf[i][j] <= interact_matrix_i[i*(NUM_PARTICLE_TYPE*DATA_WIDTH)+j*DATA_WIDTH +: DATA_WIDTH];
            end
            else
            begin
                interact_matrix_rf[i][j] <= interact_matrix_rf[i][j];
            end
        end
end

always @(posedge clk_i or negedge rst_n)
begin: ind_buffer
    integer i;
    for(i=0;i<LATTICE_LENGTH;i=i+1)
    begin
        if(~rst_n)
        begin
            individual_buffer[i] <= 'd0;
        end
        else if(in_valid_i)
        begin
            individual_buffer[i] <= individual_vec_i[i*DATA_WIDTH +: DATA_WIDTH];
        end
        else
        begin
            individual_buffer[i] <= individual_buffer[i];
        end
    end
end



endmodule
