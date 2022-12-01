1. we can merge evaluate fitness and self adaptive mutate into evaulate fitness module
2. generate_ind module can remove, we can use TESBED passing first ind_state and ind_mutate_rate
3. RF module can accelerate if we combine conduct_tournment and crossover
4. RF module can accelerate if we combine combinePops and truncateSelect
5. we need to think how can we do evaluateFitness before combinePops and truncateSelect and only use one evaluateFitness.