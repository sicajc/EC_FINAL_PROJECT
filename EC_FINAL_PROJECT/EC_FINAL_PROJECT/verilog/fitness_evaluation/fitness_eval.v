module fitness_eval #(
           parameter NUM_PARTICLE_TYPE        = 3  ,
           parameter DATA_WIDTH               = 4  ,
           parameter LATTICE_LENGTH           = 11 ,
           parameter SELF_FIT_LENGTH          = 10 ,
           parameter SELF_ENERGY_VEC_LENGTH   = NUM_PARTICLE_TYPE*DATA_WIDTH,
           parameter INTERATION_MATRIX_LENGTH = (NUM_PARTICLE_TYPE**2)*DATA_WIDTH,
           parameter INDIVIDUAL_LENGTH        = LATTICE_LENGTH * DATA_WIDTH,
           parameter POP_SIZE                 = 50
       ) (
           //Inputs
           input clk_i,
           input rst_n,
           input [SELF_ENERGY_VEC_LENGTH   -1 : 0 ]     self_energy_vec_i,
           input [INTERATION_MATRIX_LENGTH -1 : 0]      interact_matrix_i,
           input [INDIVIDUAL_LENGTH   -1 :0]            individual_vec_i,
           input  in_valid_i,
           input  Set_data_i,
           input  ind_idx_i,

           //Outputs
           output reg out_valid_ff_o,
           output reg done_ff_o,
           output reg[SELF_FIT_LENGTH-1:0] total_energy_ff_o,
           output reg ind_wb_idx_ff_o
       );
//================================================================
//  LOCAL PARAMETERS
//================================================================
//SelfEnergy = SE
//IneractEnergy = IE
localparam LV1_SE_ADDER_NUM = 5;
localparam LV1_IE_ADDER_NUM = 5;

localparam LV2_SE_ADDER_NUM = 3;
localparam LV2_IE_ADDER_NUM = 3;

localparam LV3_ADDER_NUM = 3;

localparam LV1_ADD_RESULT_WIDTH  = DATA_WIDTH + 2;
localparam LV2_ADD_RESULT_WIDTH  = DATA_WIDTH + 3;
localparam LV3_ADD_RESULT_WIDTH  = DATA_WIDTH + 4;
localparam LV4_ADD_RESULT_WIDTH  = DATA_WIDTH + 5;
localparam LV5_ADD_RESULT_WIDTH  = SELF_FIT_LENGTH;

localparam DF_ADD1_PIPE_WIDTH    = DATA_WIDTH + 1;
localparam PARTIAL_ENERGY_PIPE_WIDTH   = LV3_ADD_RESULT_WIDTH;

localparam CNT_WIDTH = 4;

//================================================================
//  INNER COMPONENTS
//================================================================
// Buffer stage
reg[DATA_WIDTH - 1 :0] individual_buffer[0:LATTICE_LENGTH-1];
reg in_valid_buf;
reg ind_idx_buf;

// DF stage
reg[DATA_WIDTH - 1 :0] self_energy_vec_rf[0:NUM_PARTICLE_TYPE-1];
reg[DATA_WIDTH - 1 :0] interact_matrix_rf[0:NUM_PARTICLE_TYPE-1][0:NUM_PARTICLE_TYPE-1];

reg[DF_ADD1_PIPE_WIDTH - 1: 0] self_energy_DF_ADD1_pipe;
reg[DF_ADD1_PIPE_WIDTH - 1: 0] interact_energy_DF_ADD1_pipe;
reg in_valid_DF_ADD1_pipe;
reg ind_idx_DF_ADD1_pipe;

// ADD1 stage
wire[0:LV1_ADD_RESULT_WIDTH-1]      self_energy_add_tree_lv1          [LV1_SE_ADDER_NUM - 1 :0];
wire[0:LV2_ADD_RESULT_WIDTH-1]      self_energy_add_tree_lv2          [LV2_SE_ADDER_NUM - 1 :0];
wire[0:LV3_ADD_RESULT_WIDTH-1]      self_energy_add_tree_lv3          [LV3_ADDER_NUM    - 1 :0];

wire[0:LV1_ADD_RESULT_WIDTH-1]      interact_energy_add_tree_lv1      [LV1_IE_ADDER_NUM - 1 :0];
wire[0:LV2_ADD_RESULT_WIDTH-1]      interact_energy_add_tree_lv2      [LV2_IE_ADDER_NUM - 1 :0];

wire[0:LV3_ADD_RESULT_WIDTH-1]      partial_energy_add_tree_lv3       [LV3_ADDER_NUM-1:0];

reg[PARTIAL_ENERGY_PIPE_WIDTH-1 : 0]     partial_energy_ADD1_ADD2_pipe[0:LV3_ADDER_NUM-1];

//ADD2 and output stage
reg in_valid_ADD1_ADD2_pipe;
reg ind_idx_add1_add2_pipe;

reg[CNT_WIDTH -1:0] individual_cnt;

wire[LV5_ADD_RESULT_WIDTH-1: 0] total_energy_wr;
wire done_flag;

//================================================================
//  GENERATE VARAIBLE
//================================================================
genvar adder_idx;

//================================================================
//  MAIN DESIGN
//================================================================
//===============================//
//  BUFFER STAGE                 //
//===============================//
always @(posedge clk_i or negedge rst_n )
begin : IN_VALID_BUF
    in_valid_buf <= ~rst_n ? 1'b1 : in_valid_i;
    ind_idx_buf  <= ~rst_n ? 1'b1 : ind_idx_i;
end


always @(posedge clk_i or negedge rst_n)
begin: IND_BUF
    integer i;
    for(i=0;i<LATTICE_LENGTH;i=i+1)
    begin
        if(~rst_n)
        begin
            individual_buffer[i] <= 'd0;
        end
        else
        begin
            individual_buffer[i] <= individual_vec_i[i*DATA_WIDTH +: DATA_WIDTH];
        end
    end
end

//==============================//
//  Data Fetch(DF) stage        //
//==============================//
always @(posedge clk_i or negedge rst_n)
begin: SELF_ENERGY_VEC_RF
    integer i;
    for(i=0;i<NUM_PARTICLE_TYPE;i=i+1)
    begin
        if(~rst_n)
        begin
            self_energy_vec_rf[i] <= 'd0;
        end
        else if(Set_data_i)
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
begin: INTERACT_MATRIX_RF
    integer i,j;
    for(i=0;i<NUM_PARTICLE_TYPE;i=i+1)
        for(j=0;j<NUM_PARTICLE_TYPE;j=j+1)
        begin
            if(~rst_n)
            begin
                interact_matrix_rf[i][j] <= 'd0;
            end
            else if(Set_data_i)
            begin
                interact_matrix_rf[i][j] <= interact_matrix_i[i*(NUM_PARTICLE_TYPE*DATA_WIDTH)+j*DATA_WIDTH +: DATA_WIDTH];
            end
            else
            begin
                interact_matrix_rf[i][j] <= interact_matrix_rf[i][j];
            end
        end
end

//=====================//
//  DF/ADD1            //
//=====================//

always @(posedge clk_i or negedge rst_n)
begin: SELF_ENERGY_DF_ADD1_PIPE
    integer i;
    for(i = 0; i < LATTICE_LENGTH ; i = i + 1)
        if(~rst_n)
        begin
            self_energy_DF_ADD1_pipe[i] <= 'd0;
        end
        else
        begin
            self_energy_DF_ADD1_pipe[i] <= self_energy_vec_rf[individual_buffer[i]];
        end
end

always @(posedge clk_i or negedge rst_n)
begin: INTERACT_ENERGY_DF_ADD1_PIPE
    integer i;
    for(i=0;i<LATTICE_LENGTH-1;i=i+1)
    begin
        //0~9 total 10 lines are being pulled out.
        if(~rst_n)
        begin
            interact_energy_DF_ADD1_pipe[i] <= 'd0;
        end
        else
        begin
            interact_energy_DF_ADD1_pipe[i] <= (interact_matrix_rf[individual_buffer[i]][individual_buffer[i+1]] << 1);
        end
    end
end

always @(posedge clk_i or negedge rst_n )
begin: IN_VALID_DF_ADD1_PIPE
    in_valid_DF_ADD1_pipe      <= ~rst_n ? 1'b0 : in_valid_buf;
    ind_idx_DF_ADD1_pipe       <= ~rst_n ? 1'b0 : ind_idx_buf;
end

//=======================//
//  ADD1 stage           //
//=======================//
//lv1.
generate
    for(adder_idx =0; adder_idx < LV1_SE_ADDER_NUM; adder_idx = adder_idx +1)
    begin: LV1_SE_adder_Tree1
        assign self_energy_add_tree_lv1[adder_idx] = (self_energy_DF_ADD1_pipe[adder_idx*2] + self_energy_DF_ADD1_pipe[adder_idx*2+ 1]);
    end

    for(adder_idx =0; adder_idx < LV1_IE_ADDER_NUM; adder_idx = adder_idx +1)
    begin: LV1_IE_adder_Tree1
        assign interact_energy_add_tree_lv1[adder_idx] = (interact_energy_DF_ADD1_pipe[adder_idx*2] + interact_energy_DF_ADD1_pipe[adder_idx*2 + 1]);
    end
endgenerate

//lv2
generate
    for(adder_idx =0; adder_idx < LV2_SE_ADDER_NUM; adder_idx = adder_idx +1)
    begin: LV2_SE_adder_Tree2
        if(adder_idx == LV2_SE_ADDER_NUM-1)
        begin
            assign self_energy_add_tree_lv2[adder_idx] = (self_energy_add_tree_lv1[adder_idx*2] + {1'b0,self_energy_DF_ADD1_pipe[LATTICE_LENGTH-1]} );
        end
        else
        begin
            assign self_energy_add_tree_lv2[adder_idx] = (self_energy_add_tree_lv1[adder_idx*2] + self_energy_add_tree_lv1[adder_idx*2+1]);
        end
    end

    for(adder_idx =0; adder_idx < LV2_IE_ADDER_NUM; adder_idx = adder_idx +1)
    begin: LV2_IE_adder_Tree2
        if(adder_idx == 0)
        begin
            assign interact_energy_add_tree_lv2[0] = {1'b0,interact_energy_add_tree_lv1[0]} ;
        end
        else
        begin
            assign interact_energy_add_tree_lv2[adder_idx] = interact_energy_add_tree_lv1[adder_idx*2-1] + interact_energy_add_tree_lv1[adder_idx*2];
        end
    end
endgenerate

//lv3
assign partial_energy_add_tree_lv3[0] = self_energy_add_tree_lv2[0] + self_energy_add_tree_lv2[1];
assign partial_energy_add_tree_lv3[1] = self_energy_add_tree_lv2[2] + interact_energy_add_tree_lv2[0];
assign partial_energy_add_tree_lv3[2] = interact_energy_add_tree_lv2[1] + interact_energy_add_tree_lv2[2];

//=====================//
//  ADD1/ADD2          //
//=====================//

always @(posedge clk_i or negedge rst_n)
begin: ADD1_ADD2_PIPE
    integer pipe_idx;
    for(pipe_idx = 0 ; pipe_idx < LV3_ADDER_NUM - 1 ; pipe_idx = pipe_idx + 1)
        if(~rst_n)
        begin
            partial_energy_ADD1_ADD2_pipe[pipe_idx] <= 'd0;
        end
        else
        begin
            partial_energy_ADD1_ADD2_pipe[pipe_idx]  <= partial_energy_add_tree_lv3[pipe_idx];
        end
end

always @(posedge clk_i or negedge rst_n)
begin: IN_VALID_ADD1_ADD2_PIPE
    in_valid_ADD1_ADD2_pipe <= ~rst_n ? 1'd0 : in_valid_DF_ADD1_pipe;
    ind_idx_add1_add2_pipe  <= ~rst_n ? 1'd0 : ind_idx_DF_ADD1_pipe;
end


//=====================//
//  ADD2 stage         //
//=====================//

//2 lv Adder tree
assign total_energy_wr = (partial_energy_ADD1_ADD2_pipe[0] + partial_energy_ADD1_ADD2_pipe[1]) + {1'b0,partial_energy_ADD1_ADD2_pipe[2]};

always @(posedge clk_i or negedge rst_n)
begin: INDIVIDUAL_CNT
    if(~rst_n)
    begin
        individual_cnt <= 'd0;
    end
    else if(done_ff_o)
    begin
        individual_cnt <= 'd0;
    end
    else if(in_valid_ADD1_ADD2_pipe == 1'b1)
    begin
        individual_cnt <= individual_cnt + 'd1;
    end
    else
    begin
        individual_cnt <= individual_cnt;
    end
end

assign done_flag = (individual_cnt == POP_SIZE-1);

//====================//
//  OUTPUT stage      //
//====================//
always @(posedge clk_i or negedge rst_n)
begin: TOTAL_ENERGY_FF
    total_energy_ff_o <= ~rst_n ? 'd0 : total_energy_wr;
end

always @(posedge clk_i or negedge rst_n)
begin: OUTPUT_INDICATOR_SIGNAL
    done_ff_o           <= ~rst_n ? 1'b0 : done_flag;
    out_valid_ff_o      <= ~rst_n ? 1'b0 : in_valid_ADD1_ADD2_pipe;
    ind_wb_idx_ff_o     <= ~rst_n ? 1'b0 : ind_idx_add1_add2_pipe;
end


endmodule
