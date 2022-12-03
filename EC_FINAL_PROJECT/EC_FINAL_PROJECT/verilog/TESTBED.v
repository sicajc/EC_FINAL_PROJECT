`timescale 1ns/1ps
`define CYCLE 10

module TESTBED ();

parameter INT8_LENGTH     = 8;
parameter ENERGY_LENGTH   = 4;
parameter PARTICLE_LENGTH = 2;
parameter LATTICE_LENGTH  = 11;
parameter IND_FIT_LENGTH  = 10;

reg clk=0;
reg rst_n;
reg in_valid;

reg [INT8_LENGTH-1:0] Num_generations;
reg [INT8_LENGTH-1:0] crossoverFraction;
reg [INT8_LENGTH-1:0] Pop_size;
reg [ENERGY_LENGTH-1:0] self_energy;
reg [ENERGY_LENGTH-1:0] interact_energy;
reg [PARTICLE_LENGTH-1:0] Num_particleType;
reg [INT8_LENGTH-1:0] Mutate_rate_in;
reg [PARTICLE_LENGTH*LATTICE_LENGTH-1:0] ind_state_in;

wire [IND_FIT_LENGTH-1:0] Min_fit_out;
wire [PARTICLE_LENGTH*LATTICE_LENGTH-1:0] Best_ind_state;
wire [INT8_LENGTH-1:0] Best_ind_mut;
wire done;

//integer 
integer populationSize=40;
integer pop;
integer particle_type=3;
integer input_file,self_energy_file,interact_energy_file;
integer gap;
integer k,l,m,n;

//module EV3a
EV3a #(
        .INT8_LENGTH(INT8_LENGTH),
        .ENERGY_LENGTH(ENERGY_LENGTH),
        .PARTICLE_LENGTH(PARTICLE_LENGTH),
        .LATTICE_LENGTH(LATTICE_LENGTH),
        .IND_FIT_LENGTH(IND_FIT_LENGTH)
    ) inst_EV3a (
        .clk               (clk),
        .rst_n             (rst_n),
        .Num_generations   (Num_generations),
        .self_energy       (self_energy),
        .crossoverFraction (crossoverFraction),
        .interact_energy   (interact_energy),
        .Num_particleType  (Num_particleType),
        .Pop_size          (Pop_size),
        .Mutate_rate_in    (Mutate_rate_in),
        .ind_state_in      (ind_state_in),
        .in_valid          (in_valid),
        .Min_fit_out       (Min_fit_out),
        .done              (done),
        .Best_ind_state    (Best_ind_state),
        .Best_ind_mut      (Best_ind_mut)
    );

//clk
always
begin
  #(`CYCLE/2) clk = ~clk;
end

//main
initial begin
    rst_n = 1;
    in_valid = 0;
    set_initail_task;
    reset_signal_task;
    input_file=$fopen("C:/Users/User/EC_FINAL_PROJECT/EC_FINAL_PROJECT/EC_FINAL_PROJECT/verilog/input.txt","r");
    self_energy_file=$fopen("C:/Users/User/EC_FINAL_PROJECT/EC_FINAL_PROJECT/EC_FINAL_PROJECT/verilog/self_energy.txt","r");
    interact_energy_file=$fopen("C:/Users/User/EC_FINAL_PROJECT/EC_FINAL_PROJECT/EC_FINAL_PROJECT/verilog/interact_energy.txt","r");
    input_task;
end

task set_initail_task();begin
    Num_generations = 'bx;
    crossoverFraction = 'bx;
    Pop_size = 'bx;
    self_energy = 'bx;
    interact_energy = 'bx;
    Num_particleType = 'bx;
    Mutate_rate_in ='bx;
    ind_state_in = 'bx;
end
endtask : set_initail_task

task reset_signal_task; begin 
    #(0.5);   rst_n=0;
    #(2.0);
    if((done !== 0)||(Min_fit_out !== 'b0)||(Best_ind_state !== 'b0)||(Best_ind_mut !=='b0)) begin
        $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
        $display ("                                                                     SPEC 3 FAIL!!                                                               ");
        $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
        // repeat(2) @(negedge clk_1);
        $finish;
    end
    #(10); rst_n=1;
end 
endtask:reset_signal_task

task input_task; begin
    gap = $urandom_range(1,5);
    repeat(gap)@(negedge clk);
    in_valid = 1;
    Num_generations   = 50;
    crossoverFraction = 204;
    Pop_size = populationSize;
    Num_particleType = 3;
    //energy
    for(pop=0;pop < populationSize;pop=pop+1) begin
       //data
       if (pop < particle_type) begin
            m=$fscanf(self_energy_file,"%b",self_energy); 
       end
       else begin
           self_energy = 'bx;
       end 
       if(pop < (particle_type*particle_type)) begin
           n=$fscanf(interact_energy_file,"%b",interact_energy); 
       end
       else begin
           interact_energy = 'bx;
       end
       k=$fscanf(input_file,"%b",Mutate_rate_in); 
       l=$fscanf(input_file,"%b",ind_state_in); 
       @(negedge clk)
       Num_generations = 'bx;
       crossoverFraction = 'bx;
       Pop_size = 'bx;
       Num_particleType = 'bx;
    end
    in_valid = 0;
    Mutate_rate_in = 'bx;
    ind_state_in = 'bx;
end 
endtask:input_task

task check_out; begin
  while(!done) begin
    if((Min_fit_out !== 'b0)||(Best_ind_state !== 'b0)||(Best_ind_mut !=='b0))begin
        $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
        $display ("                                    out should be zero while Outvalid is 0                                                           ");
        $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
        repeat(2)@(negedge clk);
        $finish;
    end
  end
end endtask:check_out

task in_valid_check_out_valid; begin
    while(in_valid==1) begin
        if(done==1)begin
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("                                            Outvalid should be zero while invalid is 1                                                                ");
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            repeat(2)@(negedge clk);
            $finish;
        end
    end
end endtask

endmodule : TESTBED