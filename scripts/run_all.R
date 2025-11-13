#!/usr/bin/env Rscript
modes <- c("binary", "multi", "three")
models <- c("rf", "xgb") # mlp is optional
for (m in modes) {
  for (mod in models) {
    cmd <- sprintf("Rscript scripts/run_experiment.R --mode %s --model %s", m, mod)
    cat("Running:", cmd, "\n")
    system(cmd)
  }
}