
module EV3a#(
           parameter INT8_LENGTH     = 8,
           parameter ENERGY_LENGTH   = 4,
           parameter PARTICLE_LENGTH = 2,
           parameter LATTICE_LENGTH  = 11,
           parameter IND_FIT_LENGTH  = 10
       )
       (
           //global
           clk,    // Clock
           rst_n,  // Asynchronous reset active low
           //local
           Num_generations,
           self_energy,
           crossoverFraction,
           interact_energy,
           Num_particleType,
           Pop_size,
           //data
           Mutate_rate_in,
           ind_state_in,
           //valid
           in_valid,
           //output
           Min_fit_out,
           done,
           Best_ind_state,
           Best_ind_mut
       );
//input
input  clk,rst_n,in_valid;

input  [INT8_LENGTH-1:0] Num_generations;
input  [INT8_LENGTH-1:0] crossoverFraction;
input  [INT8_LENGTH-1:0] Pop_size;

input  [ENERGY_LENGTH-1:0] self_energy;
input  [ENERGY_LENGTH-1:0] interact_energy;

input  [PARTICLE_LENGTH-1:0] Num_particleType;

input  [INT8_LENGTH-1:0] Mutate_rate_in;
input  [PARTICLE_LENGTH*LATTICE_LENGTH-1:0] ind_state_in;
//output
output reg [IND_FIT_LENGTH-1:0] Min_fit_out;
output reg [PARTICLE_LENGTH*LATTICE_LENGTH-1:0] Best_ind_state;
output reg [INT8_LENGTH-1:0] Best_ind_mut;
output reg done;

//output
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        done <= 0;
    end
    else
    begin
        done <= 0;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        Min_fit_out <= 0;
    end
    else
    begin
        Min_fit_out <= 0;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        Best_ind_mut <= 0;
    end
    else
    begin
        Best_ind_mut <= 0;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        Best_ind_state <= 0;
    end
    else
    begin
        Best_ind_state <= 0;
    end
end

endmodule
