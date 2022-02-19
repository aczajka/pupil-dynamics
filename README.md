# Pupil Dynamics Research

Selected source codes for pupil dynamics-related publications.

### Dataset

`Warsaw-BioBase-Pupil-Dynamics v2.1` data was used in this research. Requests for a copy of this dataset should be made directly to the [Biometrics and Machine Learning Group](http://zbum.ia.pw.edu.pl/EN/node/46) at the Warsaw University of Technology.

### Handbook of Biometric Anti-Spoofing -- Presentation Attack Detection (Edition 3) (2022)

(comming soon -- upon acceptance of the revised chapter)

### Handbook of Biometric Anti-Spoofing -- Presentation Attack Detection (Edition 2) (2018)

#### `hodpad3/scores`: Presentation Attack Detection scores

`scores_tab1_parametricSection.csv` and `scores_tab1_dataDrivenSection.csv` files contain the scores obtained by parametric-model-based and data-driven solutions, respectively. They were used to generate results shown in Table 1.

Meaning of the CSV columns (corresponds to Tab. 1):

- `Stimulus`: both, positive, negative
- `Variant`: SVM (linear, polynomial, radial), Logistic regression, Bagged trees, kNN (1,10)
- `Node0, Node1`: softmax raw scores as presented by two output nodes (only for data-driven solutions)
- `Score`: classification decision (only for parametric-model-based solutions)
- `Label`: 1 for authentic eye, 0 for odd reaction (spoof)

#### `hodpad3/models/data-driven`: Presentation Attack Detection models

The models found in this directory were trained with all data except the data from subject ID #16 (randomly selected).

The models can be evaluated on the data from subject 16 (also included) using the the command:

```python data_driven_model.py (light|dark|both)```

The `light` argument corresponds to the positive stimulus data, the `dark` argument corresponds to the negative stimulus data, and the `both` argument corresponds to both stimuli.

The scrict `data_driven_model.py` also contains the code to train new models on other subsections of the data.

The code was written for Python 2.7, and uses the libraries `numpy` and `TensorFlow`.


### Clynes and Kohn parametric model (Matlab)

### Recurrent Neural Network-based model (Python)

### Plots

### Citation

```
@InCollection{Czajka_PAD_Handbook_2018,
  author    = {Adam Czajka and Benedict Becker},
  title     = {{ Application of Dynamic Features of the Pupil for Iris Presentation Attack Detection}},
  booktitle = {Handbook of Biometric Anti-Spoofing (2nd Edition)},
  publisher = {Springer International Publishing AG},
  year      = {2018},
  editor    = {S\'{e}bastien Marcel and Mark Nixon and Julian Fierrez and Nicholas Evans},
  pages     = {1--17},
  chapter   = 7,
  abstract  = {This chapter presents a comprehensive study on application of stimulated pupillary light reflex to presentation attack detection (PAD) that can be used in iris recognition systems. A pupil, when stimulated by visible light in a predefined manner, may offer sophisticated dynamic liveness features that cannot be acquired from dead eyes or other static objects such as printed contact lenses, paper printouts or prosthetic eyes. Modeling of pupil dynamics requires a few seconds of observation under varying light conditions that can be supplied by a visible light source in addition to the existing near-infrared illuminants used in iris image acquisition. The central element of the presented approach is an accurate modeling and classification of pupil dynamics that makes mimicking an actual eye reaction difficult. This chapter discusses new data-driven models of pupil dynamics based on recurrent neural networks and compares their PAD performance to solutions based on parametric Clynes-Kohn model and various classification techniques. Experiments with 166 distinct eyes of 84 subjects show that the best data-driven solution, one based on long-short term memory, was able to correctly recognize 99.97\% of attack presentations and 98.62\% of normal pupil reactions. In the approach using the Clynes-Kohn parametric model of pupil dynamics, we were able to perfectly recognize abnormalities and correctly recognize 99.97\% of normal pupil reactions on the same dataset with the same evaluation protocol as the data-driven approach. This means that the data-driven solutions favorably compare to the parametric approaches, which require model identification in exchange for a slightly better performance. We also show that observation times may be as short as 3 seconds when using the parametric model, and as short as 2 seconds when applying the recurrent neural network without substantial loss in accuracy. Along with this chapter we also offer: a) all time series representing pupil dynamics for 166 distinct eyes used in this study, b) weights of the trained recurrent neural network offering the best performance, c) source codes of the reference PAD implementation based on Clynes-Kohn parametric model, and d) all PAD scores that allow the reproduction of the plots presented in this chapter. To our best knowledge, this chapter proposes the first database of pupil measurements dedicated to presentation attack detection and the first evaluation of recurrent neural network-based modeling of pupil dynamics and PAD.},
}
```
https://www.springer.com/us/book/9783319926261 
