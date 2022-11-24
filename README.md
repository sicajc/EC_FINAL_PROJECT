# EC_FINAL_PROJECT

1. Change the self mutate rate into int8 instead of using fix or floating point values.
2. Change the normal distribution into Discrete Binomial distribution and implement it using LUT.

```mermaid
    graph TD
    A[IDLE] -->D{start}
    B(Generate Individual) --> C[Evaluate Fitness]
    --> f[Write_Ind_to_POPrf]
    D --> |T|B
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