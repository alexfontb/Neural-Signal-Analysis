# Advanced Neural Signal Analysis — Nonlinear EEG & Surrogate Testing

**Author:**  
- Àlex Font Bartumeus  

---

## Overview

This repository contains MATLAB scripts and functions developed for the **Advanced Neural Signal Analysis** university course. The project implements state-space reconstruction via delay-coordinate embedding, Theiler-corrected pairwise distance matrices, nearest-neighbor phase-space forecasting, hyperparameter sweeps, and Fourier phase-randomized surrogate testing to evaluate deterministic nonlinearity across different electrophysiological states (seizure onset, rhythmic activity, interictal/anti-seizure periods, and artifacts).

---

## Repository Structure

```text
Neural-Signal-Analysis/
├── eeg_viewer.m                  # Interactive multi-channel EEG browser with keyboard navigation & gain scaling
├── delay_coordinates.m           # Phase-space reconstruction via Takens' time-delay embedding (m, tau)
├── distance_matrix_fast.m        # Vectorized pairwise Euclidean distance matrix with Theiler window mask
├── nearest_neighbors.m           # Extraction of k-nearest neighbors in reconstructed phase space
├── nonlinear_pred_error.m        # Initial implementation of Nonlinear Prediction Error (NPE)
├── nonlinear_pred_error2.m       # Updated NPE computation using fixed embedding window and fast distances
├── lab2_adapted.m                # Exploratory script evaluating NPE across tau and visualizing distance matrices
├── parametersweep.m              # Multi-segment sensitivity analysis across m, k, Tw, h, and tau
├── phase_randomized_surrogate.m  # Generation of linear stochastic surrogates via FFT phase randomization
└── surrogatesvnonlinearff.m      # Hypothesis testing comparing original vs. surrogate NPE across channels/windows
```

---

## Key Components & Methodology

### 1. Signal Visualization & Preprocessing
- **Interactive EEG Browser (`eeg_viewer.m`):** Plots multi-channel EEG recordings in 20-second windows with interactive keyboard controls (`←`/`→` to scroll in time, `↑`/`↓` to adjust amplitude gain by 1.5×).
- **Preprocessing Pipeline (`parametersweep.m`, `surrogatesvnonlinearff.m`):** Loads `EEG4.mat` ($F_s = 512\text{ Hz}$), applies a zero-phase 4th-order Butterworth low-pass anti-aliasing filter ($f_c = 100\text{ Hz}$), downsamples by a factor of 2 to $256\text{ Hz}$, extracts 20-second epochs ($5,120$ samples), and z-score normalizes each segment.

### 2. Phase-Space Reconstruction & Nearest-Neighbor Forecasting
- **Delay-Coordinate Embedding (`delay_coordinates.m`):** Reconstructs an $(N - \eta) \times m$ trajectory matrix $X$ from a scalar time series using embedding dimension $m$, time delay $\tau$, and window $\eta = (m - 1)\tau$.
- **Theiler-Corrected Distance Matrix (`distance_matrix_fast.m`):** Computes pairwise Euclidean distances (`pdist2`) across valid states ($M_{\text{valid}} = M - h$) and sets temporally correlated neighbors within $|i - j| \le T_w$ to `inf` to prevent spurious temporal correlations.
- **Nonlinear Prediction Error (`nearest_neighbors.m`, `nonlinear_pred_error2.m`):** Identifies the $k$ nearest phase-space neighbors for each reference state, averages their trajectories $h$ steps ahead ($i_{\text{neighbor}} + \eta + h$), and computes the Root Mean Squared Error (RMSE) against the true future value.

### 3. Parameter Sweeps & Surrogate Data Testing
- **Hyperparameter Sweep (`parametersweep.m`):** Evaluates NPE sensitivity across 7 labeled clinical/behavioral 20-second segments (`PIR2`, `TPPL1`, `TPAL6`, `TBAL1`, `TPAR4`, `DER01`) while varying embedding dimension ($m \in [1, 10]$), neighbors ($k \in [1, 100]$), Theiler window ($T_w \in [1, 50]$), prediction horizon ($h \in [1, 50]$), and delay ($\tau \in [1, 49]$).
- **Phase-Randomized Surrogates (`phase_randomized_surrogate.m`, `surrogatesvnonlinearff.m`):** Preserves the linear power spectrum of each EEG segment while randomizing Fourier phases symmetrically. Compares the NPE curves of original recordings against the mean of 6 surrogates across channels `TPPR1`, `TPPR3`, and `TBAL1` at $t = 40\text{ s}, 280\text{ s}, 300\text{ s}$ ($m=6, k=3, T_w=30, h=2$).

---

## Requirements & Usage

### Prerequisites
- **MATLAB** (R2020b or later recommended)
- **Signal Processing Toolbox** (`designfilt`, `filtfilt`, `downsample`)
- **Statistics and Machine Learning Toolbox** (`pdist2`)
- **Dataset:** `EEG4.mat` (containing variables `EEG` and `channelNameArray`) placed in the repository root directory.

### Running the Scripts
1. Clone the repository:
   ```bash
   git clone [https://github.com/alexfontb/Neural-Signal-Analysis.git](https://github.com/alexfontb/Neural-Signal-Analysis.git)
   ```
2. Open MATLAB, navigate to the repository directory, and place `EEG4.mat` in the root folder.
3. Inspect the raw recording interactively:
   ```matlab
   eeg_viewer('EEG4.mat', 512);
   ```
4. Run the parameter sensitivity sweeps or surrogate nonlinearity tests:
   ```matlab
   parametersweep
   surrogatesvnonlinearff
   ```
