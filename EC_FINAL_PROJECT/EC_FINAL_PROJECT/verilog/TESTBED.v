`timescale 1ns/1ps
`define CYCLE 10

module TESTBED ();

parameter INT8_LENGTH     = 8;
parameter ENERGY_LENGTH   = 4;
parameter PARTICLE_LENGTH = 2;
parameter LATTICE_LENGTH  = 11;
parameter IND_FIT_LENGTH  = 10;
parameter INDIVIDUAL_LENGTH = PARTICLE_LENGTH*LATTICE_LENGTH;
parameter NUM_PARTICLE_TYPE = 3;
parameter POP_SIZE          = 40;
parameter NUM_GENERATIONS   = 50;
parameter CROSSFRACTION     = 8'd204;

reg clk=0;
reg rst_n;
reg in_valid_ind = 0;
reg in_valid_interact = 0;
reg in_valid_self = 0;

//output
reg [INT8_LENGTH-1:0]       Num_generations;
reg [INT8_LENGTH-1:0]       Pop_size;
reg [ENERGY_LENGTH-1:0]     self_energy_in;
reg [ENERGY_LENGTH-1:0]     interact_energy_in;
reg [PARTICLE_LENGTH-1:0]   Num_particleType;
reg [INT8_LENGTH-1:0]       Mutate_rate_in;
reg [INDIVIDUAL_LENGTH-1:0] ind_state_in;
reg [IND_FIT_LENGTH-1:0]    ind_fit_in;
//input
wire [IND_FIT_LENGTH-1:0]    Min_fit_o;
wire [INDIVIDUAL_LENGTH-1:0] Best_ind_state_o;
wire [INT8_LENGTH-1:0]       Best_ind_mut_o;
wire out_valid;

//integer 
integer pop;
integer input_file,self_energy_file,interact_energy_file;
integer gap;
integer k,l,m,n;

//module EV3a
EV3a #(
        .INT8_LENGTH       (INT8_LENGTH),
        .ENERGY_LENGTH     (ENERGY_LENGTH),
        .PARTICLE_LENGTH   (PARTICLE_LENGTH),
        .LATTICE_LENGTH    (LATTICE_LENGTH),
        .IND_FIT_LENGTH    (IND_FIT_LENGTH),
        .CROSSFRACTION     (CROSSFRACTION),
        .INDIVIDUAL_LENGTH (INDIVIDUAL_LENGTH),
        .NUM_PARTICLE_TYPE (NUM_PARTICLE_TYPE),
        .NUM_GENERATIONS   (NUM_GENERATIONS),
        .POP_SIZE          (POP_SIZE)
    ) inst_EV3a (
        .clk               (clk),
        .rst_n             (rst_n),
        .self_energy_in    (self_energy_in),
        .interact_energy_in(interact_energy_in),
        .Mutate_rate_in    (Mutate_rate_in),
        .ind_state_in      (ind_state_in),
        .ind_fit_in        (ind_fit_in),
        .in_valid_self     (in_valid_self),
        .in_valid_ind      (in_valid_ind),
        .in_valid_interact (in_valid_interact),
        .Min_fit_o         (Min_fit_o),
        .out_valid         (out_valid),
        .Best_ind_state_o  (Best_ind_state_o),
        .Best_ind_mut_o    (Best_ind_mut_o)
    );

//clk
always
begin
  #(`CYCLE/2) clk = ~clk;
end

//main
initial begin
    rst_n = 1;
    set_initail_task;
    reset_signal_task;
    input_file=$fopen("C:/Users/User/EC_FINAL_PROJECT/EC_FINAL_PROJECT/EC_FINAL_PROJECT/verilog/input.txt","r");
    self_energy_file=$fopen("C:/Users/User/EC_FINAL_PROJECT/EC_FINAL_PROJECT/EC_FINAL_PROJECT/verilog/self_energy.txt","r");
    interact_energy_file=$fopen("C:/Users/User/EC_FINAL_PROJECT/EC_FINAL_PROJECT/EC_FINAL_PROJECT/verilog/interact_energy.txt","r");
    input_task;
end

task set_initail_task();begin
    self_energy_in = 'bx;
    interact_energy_in = 'bx;
    Mutate_rate_in = 'bx;
    ind_state_in = 'bx;
    ind_fit_in = 'bx;
end
endtask : set_initail_task

task reset_signal_task; begin 
    #(0.5);   rst_n=0;
    #(2.0);
    if((out_valid !== 0)||(Min_fit_o !== 'b0)||(Best_ind_state_o !== 'b0)||(Best_ind_mut_o !=='b0)) begin
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
    in_valid_ind = 1;
    in_valid_interact = 1;
    in_valid_self     = 1;
    //energy
    for(pop=0;pop < POP_SIZE;pop=pop+1) begin
       //data
       if (pop < NUM_PARTICLE_TYPE) begin
            m=$fscanf(self_energy_file,"%b",self_energy_in); 
       end
       else begin
           in_valid_self = 0;
           self_energy_in = 'bx;
       end 
       if(pop < (NUM_PARTICLE_TYPE*NUM_PARTICLE_TYPE)) begin
           n=$fscanf(interact_energy_file,"%b",interact_energy_in); 
       end
       else begin
           in_valid_interact = 0;
           interact_energy_in = 'bx;
       end
       k=$fscanf(input_file,"%b",Mutate_rate_in); 
       l=$fscanf(input_file,"%b",ind_state_in); 
       m=$fscanf(input_file,"%b",ind_fit_in); 
       @(negedge clk);
    end
    in_valid_ind = 0;
    Mutate_rate_in = 'bx;
    ind_state_in = 'bx;
    ind_fit_in = 'bx;
end 
endtask:input_task

task check_out; begin
  while(!out_valid) begin
    if((Min_fit_o !== 'b0)||(Best_ind_state_o !== 'b0)||(Best_ind_mut_o !=='b0))begin
        $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
        $display ("                                    out should be zero while Outvalid is 0                                                           ");
        $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
        repeat(2)@(negedge clk);
        $finish;
    end
  end
end endtask:check_out

task in_valid_ind_check_out_valid; begin
    while(in_valid_ind==1) begin
        if(out_valid==1)begin
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("                                            Outvalid should be zero while invalid is 1                                                                ");
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            repeat(2)@(negedge clk);
            $finish;
        end
    end
end endtask

endmodule : TESTBED