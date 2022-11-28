//pseudo code
module evaluate_fit_0 (
	input self_energy_in,
	input interact_energy_in,
   output self_energy_out,       //next_state energy
   output interact_energy_out_A, //next_state energy
   output interact_energy_out_B, //next_state energy
   output total_energy_out       //next_state energy
);

assign self_energy_out = self_energy[state[1]];
assign interact_energy_out_A = interact_energy[state[index]][state[index+1]];//state name not confirm 
assign interact_energy_out_B = interact_energy[state[index+1]][state[index]];
assign total_energy_out = self_energy_in + interact_energy_in;

endmodule : evaluate_fit_0