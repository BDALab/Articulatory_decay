# Articulatory decay

This software is designed to assess articulatory decay in patients with Parkinson's disease by analyzing vocal tract resonances from speech or voice recordings.

## Features

- Extracts features from speech using **Linear Predictive Coding (LPC)** analysis.
- Computes the following acoustic metrics:
  - **RFA1**: Distance between the second formant resonance and the local minimum *preceding* it in the LPC spectrum.
  - **RFA2**: Distance between the second formant resonance and the local minimum *following* it.
  - **#locMAX**: Number of local maxima in the vocal tract’s frequency response, representing resonances.

<p align="center">
  <img src="https://user-images.githubusercontent.com/85240065/210371801-a1d2a273-9480-4b5b-87dc-f9619dc795a4.png" alt="AR" />
</p>

- The main function is located in the file: **articulatory_decay.m**

---
Article: 
[Quantitative Analysis of Vocal Tract Resonances in Patients with Parkinson’s Disease](https://doi.org/10.13164/eeict.2024.146)

---

<sub>This work was supported by the EU – Next Generation EU (project no. LX22NPO5107 (MEYS)), and by the Quality Internal Grants of BUT (project KInG, reg. no. CZ.02.2.69/0.0/0.0/19_073/0016948; financed from OP VVV).</sub>
