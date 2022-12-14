# EC_FINAL_PROJECT

1. Change the self mutate rate into int8 instead of using fix or floating point values.
2. Change the normal distribution into Discrete Binomial distribution and implement it using LUT.
3. Dividing Evaluate Fitness Module into N-stage Pipelines, propagate out_valid and use it as in_valid for POP_rf write back signal.
4. In evaluate fitness module, WB to POP_rf in negedge clk.
5. Can Set different modules to different clk frequency to enable faster calculation, like let generate_ind produces child faster. However, we have to solve the problem of CDC.
6. Notice that the BottleNeck might appears at the Gen_ind block, calculate it using faster frequency is a good idea.
7. System block design has been completed.
8. We would discard self-adaptive parameter of each individual to simplify the algorithm.

```mermaid
    graph TD
    A[IDLE] -->D{start}
    B(Generate Individual) --> C[Evaluate Fitness]
    --> f[Write_Ind_to_POPrf]
    D --> |T|RD_DATA
    RD_DATA --> rd_done{rd_done}
    rd_done --> |T|B
    rd_done --> |F|RD_DATA
    D --> |F|A
    f --> E{generate_ind_done}
    E --> |T| F[POP_rf]
    E --> |F| B
    F --> a{Done}
    a --> |T| b[OUTPUT]
    a --> |F| F
    b --> c{outputDone} --> |T|A
    c --> |F|b
```
## POPrf
```mermaid
graph TD
    CopyPop;
    CrossOver[CrossOver];
    ConductTour[ConductTour];
    Mutate[Mutate];
    EvalFit;
    CopyPop-->CrossOver-->ConductTour-->Mutate-->EvalFit
    --> Combine&Truncate&FindBestFit --> WB_PopRF
```