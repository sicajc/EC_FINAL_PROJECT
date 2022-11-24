# EC_FINAL_PROJECT

1. Change the self mutate rate into int8 instead of using fix or floating point values.
2. Change the normal distribution into Discrete Binomial distribution and implement it using LUT.
3.
```mermaid
    graph TD
    A[IDLE] -->D{start}
    B(Generate Individual) --> C[Evaluate Fitness]
    D --> |T|B
    D --> |F|A
    C --> E{generate_ind_done}
    E --> |T| F[RF]
    E --> |F| B
    F --> a{Done}
    a --> |T| b[OUTPUT]
    a --> |F| F
    b --> c{outputDone} --> |T|A
    c --> |F|b

```
