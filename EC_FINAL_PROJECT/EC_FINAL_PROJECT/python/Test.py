from Evaluator import Particles1D
Particles1D.selfEnergy = [1, 2, 3]
Particles1D.interactionEnergy = [[10, 4, 1], [4, 10, 5], [1, 5, 10]]
state = [1, 2, 0, 2, 2, 2, 2, 2, 1, 0, 0]
print(Particles1D.fitnessFunc(state))
