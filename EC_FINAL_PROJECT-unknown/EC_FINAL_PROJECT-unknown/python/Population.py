#
# Population.py
#
#

import copy
import math
from operator import attrgetter
from Individual import *


class Population:
    """
    Population
    """
    uniprng = None
    crossoverFraction = None
    individualType = None

    def __init__(self, populationSize):
        """
        Population constructor
        """
        self.population = []
        for i in range(populationSize):
            self.population.append(self.__class__.individualType())

    def __len__(self):
        return len(self.population)

    def __getitem__(self, key):
        return self.population[key]

    def __setitem__(self, key, newValue):
        self.population[key] = newValue

    def copy(self):
        return copy.deepcopy(self)

    def evaluateFitness(self):
        for individual in self.population:
            individual.evaluateFitness()

    def mutate(self):
        for individual in self.population:
            individual.mutate()

    def crossover(self):
        index1 = self.uniprng.randint(0, len(self.population))
        index2 = self.uniprng.randint(0, len(self.population))

        if index1 == index2:
            index2 += 1

        for _ in range(len(self.population)):
            if index1 >= len(self.population):
                index1 = 0
            if index2 >= len(self.population):
                index2 = 0
            rn = self.uniprng.randint(1, 255)/255
            if rn < self.crossoverFraction:
                self[index1].crossover(self[index2])
            index1 += 1
            index2 += 1

        '''
        self.uniprng.shuffle(indexList1)
        self.uniprng.shuffle(indexList2)

        if self.crossoverFraction == 1.0:
            for index1, index2 in zip(indexList1, indexList2):
                self[index1].crossover(self[index2])
        else:
            for index1, index2 in zip(indexList1, indexList2):
                rn = self.uniprng.randint(1, 255)/255
                if rn < self.crossoverFraction:
                    self[index1].crossover(self[index2])
        '''

    def conductTournament(self):
        # binary tournament
        index1 = self.uniprng.randint(0, len(self.population))
        index2 = self.uniprng.randint(0, len(self.population))

        if index1 == index2:
            index2 += 1

        # compete
        newPop = []
        for _ in range(len(self.population)):
            if index1 >= len(self.population):
                index1 = 0
            if index2 >= len(self.population):
                index2 = 0
            if self[index1].fit > self[index2].fit:
                newPop.append(copy.deepcopy(self[index1]))
            elif self[index1].fit < self[index2].fit:
                newPop.append(copy.deepcopy(self[index2]))
            else:
                rn = self.uniprng.random()
                if rn > 0.5:
                    newPop.append(copy.deepcopy(self[index1]))
                else:
                    newPop.append(copy.deepcopy(self[index2]))
            index1 += 1
            index2 += 1

        # overwrite old pop with newPop
        self.population = newPop

    def combinePops(self, otherPop):
        self.population.extend(otherPop.population)

    def truncateSelect(self, newPopSize):
        # sort by fitness
        self.population.sort(key=attrgetter('fit'), reverse=True)

        # then truncate the bottom
        self.population = self.population[:newPopSize]

    def __str__(self):
        s = ''
        for ind in self:
            s += str(ind) + '\n'
        return s
