
module EV3a#(
           parameter INT8_LENGTH       = 8,
           parameter ENERGY_LENGTH     = 4,
           parameter PARTICLE_LENGTH   = 2,
           parameter LATTICE_LENGTH    = 11,
           parameter INDIVIDUAL_LENGTH = PARTICLE_LENGTH*LATTICE_LENGTH,
           parameter IND_FIT_LENGTH    = 10,
           parameter NUM_PARTICLE_TYPE = 3,
           parameter POP_SIZE          = 40,
           parameter NUM_GENERATIONS   = 50,
           parameter CROSSFRACTION     = {INT8_LENGTH{1'b0}}
       )
       (
           //global
           clk,    // Clock
           rst_n,  // Asynchronous reset active low
           //energy
           self_energy_in,
           interact_energy_in,
           //data
           Mutate_rate_in,
           ind_state_in,
           ind_fit_in,
           //valid
           in_valid_ind,
           in_valid_self,
           in_valid_interact,
           //output
           Min_fit_o,
           out_valid,
           Best_ind_state_o,
           Best_ind_mut_o
       );
//input
input  clk,rst_n,in_valid_ind,in_valid_self,in_valid_interact;
input  [ENERGY_LENGTH-1:0] self_energy_in;
input  [ENERGY_LENGTH-1:0] interact_energy_in;
input  [INT8_LENGTH-1:0] Mutate_rate_in;
input  [INDIVIDUAL_LENGTH-1:0] ind_state_in;
input  [IND_FIT_LENGTH-1:0] ind_fit_in;
//output
output reg [IND_FIT_LENGTH-1:0] Min_fit_o = 0;
output reg [INDIVIDUAL_LENGTH-1:0] Best_ind_state_o;
output reg [INT8_LENGTH-1:0] Best_ind_mut_o;
output reg out_valid;

// ====== integer ======
integer i ;
genvar idx; 
parameter INTERACT_LENGTH = NUM_PARTICLE_TYPE*NUM_PARTICLE_TYPE;
parameter IND_REG_LENGTH  = INT8_LENGTH+IND_FIT_LENGTH+INDIVIDUAL_LENGTH;

//local param
localparam IDLE                 = 3'b000;
localparam CONDUCT_TOUR         = 3'b001;
localparam CROSSOVER            = 3'b010;
localparam MUTATE2EVALUATE_FIT  = 3'b011;
localparam TRUNCATE_POP         = 3'b100;
localparam DONE                 = 3'b101;

// ====== reg ======
reg [5:0] global_counter;
reg pulse;

// ====== mem ======
//{Mutate_rate_in,ind_fit_in,ind_state_in}
reg [IND_REG_LENGTH-1:0] pop_rf [0:POP_SIZE-1];
reg [IND_REG_LENGTH-1:0] pop_offspring_rf [0:POP_SIZE-1];
//[1, 2, 3]
reg [ENERGY_LENGTH-1:0] self_energy_r [0:NUM_PARTICLE_TYPE-1] ;
//[[10,4,1],[4,10,5],[1,5,10]]
reg [ENERGY_LENGTH-1:0] interact_energy_r [0:INTERACT_LENGTH-1];


// ====== flag =======
wire random_start = in_valid_ind && global_counter[5];
wire rd_done = global_counter == (POP_SIZE-1) && in_valid_ind;
wire conduct_tour_done = 0;
wire crossover_done = 0;
wire mutate2evaluateFit_done = 0;
wire truncate_pop_done = 0;
wire done = 0;

//module inout
//random_number
wire [INT8_LENGTH-1:0] random_num_vec_o [0:LATTICE_LENGTH-1];
//evaluate_fitness
wire self_energy_vec_o;
wire interact_matrix_o;
wire individual_vec_o;
wire in_valid_o;
wire Set_data_o;
wire ind_idx_o;
wire done_ff_i;
wire total_energy_ff_i;
wire ind_wb_idx_ff_i;

// ==========================
// ------- FSM --------------
// ==========================
reg [2:0] current_state,next_state;

//current_state
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

//next_state
always @(*) begin 
    case (current_state)
        IDLE                : next_state = rd_done ? CONDUCT_TOUR : IDLE;
        CONDUCT_TOUR        : next_state = conduct_tour_done ? CROSSOVER : CONDUCT_TOUR;
        CROSSOVER           : next_state = crossover_done ? MUTATE2EVALUATE_FIT : CROSSOVER;
        MUTATE2EVALUATE_FIT : next_state = mutate2evaluateFit_done ? TRUNCATE_POP : MUTATE2EVALUATE_FIT;
        TRUNCATE_POP        : next_state = truncate_pop_done ? done ? DONE : CONDUCT_TOUR : TRUNCATE_POP;
        DONE                : next_state = IDLE;
        default : next_state = IDLE;
    endcase
end

// ==========================
// ------- Global -----------
// ==========================

//pulse
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        pulse <= 0;
    end else begin
        pulse <= ~pulse;
    end
end

//global_counter
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        global_counter <= 0;
    end 
    else if(rd_done) begin
        global_counter <= 0;
    end
    else if(in_valid_ind) begin
        global_counter <= global_counter + 'd1;
    end
end

// ==========================
// ------- RD_DATA ----------
// ==========================

//pop_rf
always @(posedge clk or negedge rst_n) begin 
    if(~rst_n) begin
        for(i=0;i<POP_SIZE;i=i+1) begin
            pop_rf[i] <= 0;
        end
    end 
    else if(in_valid_ind) begin
        pop_rf[global_counter] <= {Mutate_rate_in,ind_fit_in,ind_state_in};
    end
end

//pop_offspring_rf
always @(posedge clk or negedge rst_n) begin 
    if(~rst_n) begin
        for(i=0;i<POP_SIZE;i=i+1) begin
            pop_offspring_rf[i] <= 0;
        end
    end 
    else if(in_valid_ind) begin
        pop_offspring_rf[global_counter] <= {Mutate_rate_in,ind_fit_in,ind_state_in};
    end
end

//self_energy_r
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for(i=0;i<NUM_PARTICLE_TYPE;i=i+1) begin
            self_energy_r[i] <= 0;
        end
    end 
    else if(in_valid_self) begin
        self_energy_r[global_counter] <= self_energy_in;
    end
end

//interact_energy_r
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for(i=0;i<INTERACT_LENGTH;i=i+1) begin
            interact_energy_r[i] <= 0;
        end
    end 
    else if(in_valid_interact) begin
        interact_energy_r[global_counter] <= interact_energy_in;
    end
end

// ==========================
// ------- RF ---------------
// ==========================

// ==========================
// ------- OUT --------------
// ==========================

//output
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        out_valid <= 0;
    end
    else
    begin
        out_valid <= 0;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        Best_ind_mut_o <= 0;
    end
    else
    begin
        Best_ind_mut_o <= 0;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        Best_ind_state_o <= 0;
    end
    else
    begin
        Best_ind_state_o <= 0;
    end
end


// ==========================
// ------- Module -----------
// ==========================

generate
    for(idx=0;idx<LATTICE_LENGTH;idx=idx+1) begin
            LSFR #(
            .S_WIDTH(INT8_LENGTH),
            .RANDOM_SEED(87+idx)
        ) inst_LSFR (
            .clk             (clk),
            .rst_n           (rst_n),
            .in_valid        (random_start),
            .random_num_ff_o (random_num_vec_o[idx])
        );
    end
endgenerate

    fitness_eval #(
            .NUM_PARTICLE_TYPE(NUM_PARTICLE_TYPE),
            .DATA_WIDTH(ENERGY_LENGTH),
            .PARTICLE_LENGTH(PARTICLE_LENGTH),
            .LATTICE_LENGTH(LATTICE_LENGTH),
            .SELF_FIT_LENGTH(SELF_FIT_LENGTH),
            .SELF_ENERGY_VEC_LENGTH(PARTICLE_LENGTH*ENERGY_LENGTH),
            .INTERATION_MATRIX_LENGTH(INTERACT_LENGTH*ENERGY_LENGTH),
            .INDIVIDUAL_LENGTH(INDIVIDUAL_LENGTH),
            .POP_SIZE(POP_SIZE)
        ) inst_fitness_eval (
            .clk_i             (clk),
            .rst_n             (rst_n),
            .self_energy_vec_i (self_energy_vec_o),
            .interact_matrix_i (interact_matrix_o),
            .individual_vec_i  (individual_vec_o),
            .in_valid_i        (in_valid_o),
            .Set_data_i        (Set_data_o),
            .ind_idx_i         (ind_idx_o),
            .out_valid_ff_o    (out_valid_ff_i),
            .done_ff_o         (done_ff_i),
            .total_energy_ff_o (total_energy_ff_i),
            .ind_wb_idx_ff_o   (ind_wb_idx_ff_i)
        );



endmodule
