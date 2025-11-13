# Fake News Prediction — Refined & Reproducible

**Overview**
This repository contains R scripts to perform fake news detection experiments (binary, multi-class, three-class).
I refactored the project to provide a reproducible workflow, modular code, and easy commands to run training and prediction.

## What's included
- `R/` — modular R functions:
  - `data_prep.R` — data loading & text preprocessing helpers.
  - `models.R` — training helpers for RandomForest, XGBoost, and a simple neural net.
  - `eval.R` — evaluation helpers (confusion matrix, metrics).
- `scripts/` — runnable scripts:
  - `run_experiment.R` — run one experiment (specify dataset and model).
  - `run_all.R` — run all experiments and save results.
  - `predict.R` — load a saved model and run prediction on new CSV.
- `data/` — (contains your CSVs: `binary_*.csv`, `multi_*.csv`, `three_*.csv`)
- `models/` — saved R models (created after training).
- `results/` — output metrics, plots, and confusion matrices.
- `requirements.R` — installs required R packages.
- `LICENSE` — MIT license.

## Quick start

1. Install R packages:
```r
source("requirements.R")
```

2. Run a single experiment (example — Binary Random Forest):
```bash
Rscript scripts/run_experiment.R --mode binary --model rf
```

3. Run all experiments:
```bash
Rscript scripts/run_all.R
```

4. Predict using saved model:
```bash
Rscript scripts/predict.R --model_path models/binary_rf.rds --input_file new_data.csv --output_file predictions.csv
```

## Notes & Recommendations
- Models and results are saved under `models/` and `results/`.
- The scripts assume each CSV contains a `text` column and a `label` column. If your column names differ, open the `R/data_prep.R` and adjust `TEXT_COL` / `LABEL_COL`.
- For production use, consider containerizing with Docker and managing R package versions with `renv`.

---

(Refined from the original README. For details on improvements and code structure, see the `R/` and `scripts/` folders.)
