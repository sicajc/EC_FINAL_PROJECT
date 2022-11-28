//pseudo code
module evaluate_fit (
	input total_energy_in,    
	input index, // 
	input self_energy_in,
	input interact_energy_in_A,
	input interact_energy_in_B,
   output self_energy_out,        //next_state energy
   output interact_energy_out_A,  //next_state energy
   output interact_energy_out_B,  //next_state energy
   output total_energy_out
); //evaluate_fit 1~12

wire temp_1 = total_energy_in + self_energy_in;
wire temp_2 = interact_energy_in_A + interact_energy_in_B;

assign self_energy_out = self_energy[state[index+1]];
assign interact_energy_out_A = interact_energy[state[index]][state[index+1]];//state name not confirm 
assign interact_energy_out_B = interact_energy[state[index+1]][state[index]];
assign total_energy_out = interact_energy_out_A + interact_energy_out_B;

endmodule : evaluate_fit