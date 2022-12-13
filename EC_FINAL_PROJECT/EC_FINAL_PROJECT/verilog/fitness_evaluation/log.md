# Log of fitness evaluation
12/11
1. Error in the placement of MSB and LSB of self_energy_vec, interact_matrix and individual_buffer.
2. The order of data representation must be specified between teamates. Whether you use Big Endian or Little Endian matters a lot.
3. There should be no ambuiguity in combinational circuit and sequential circuit. Seperate them out No matter what.(Debug consideration)
4. Unless you are pretty sure what you are doing.












# 12/13 2:57pm
1. Add individual vector pipes
2. Fix the read in mode of interactionMatrix and self_energy_vec, it now reads sequentially according to their unique inValid signal
3. Fix individual cnt, it now serves as ptr of wr_interactionMatrix and wr_self_energy_vec