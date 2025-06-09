# Articulatory decay

This software was developed for the assessment of articulatory decay in patients with Parkinson's disease, based on resonances in the vocal tract. Features extracted from voice or speech recordings quantify the distance in the linear predictive coding (LPC) spectrum between the resonance of the second formant and the local minimum before this formant (RFA1), the distance between the second formant and the local minimum after this formant (RFA2), and the number of local maxima in the frequency response of the vocal tract representing the resonances (#locMAX).
> Conditions for features extraction from a segment:
>
> 1. The fundamental speech frequency is between 75 Hz and 400 Hz. The software used to calculate this frequency is PRAAT.
> 2. The frequency of the second formant is within 3 kHz.
> 3. There is at least one local minimum.
> 4. The modulus of the first formant is higher than that of the third.
> 5. The lowest modulus of the first three formants is higher than the highest modulus of the remaining formants.

![AR](https://user-images.githubusercontent.com/85240065/210371801-a1d2a273-9480-4b5b-87dc-f9619dc795a4.png)

* the main function is the file: **articulatory_decay.m**

---
Article: 
[Quantitative Analysis of Vocal Tract Resonances in Patients with Parkinson’s Disease](https://doi.org/10.13164/eeict.2024.146)

---

<sub>This work was supported by the EU – Next Generation EU (project no. LX22NPO5107 (MEYS)), and by the Quality Internal Grants of BUT (project KInG, reg. no. CZ.02.2.69/0.0/0.0/19_073/0016948; financed from OP VVV).</sub>
