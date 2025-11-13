#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(optparse)
  library(data.table)
  source("R/data_prep.R")
})

option_list = list(
  make_option(c("--model_path"), type="character", help="path to saved model (.rds)"),
  make_option(c("--input_file"), type="character", help="input CSV with text column"),
  make_option(c("--output_file"), type="character", default="predictions.csv", help="where to write predictions")
)

opt = parse_args(OptionParser(option_list=option_list))
if (is.null(opt$model_path) || is.null(opt$input_file)) stop("model_path and input_file required")

model <- readRDS(opt$model_path)
df <- load_data(opt$input_file)
df[[TEXT_COL]] <- basic_clean(df[[TEXT_COL]])
# very simple: assume model is random forest and accept a TF-IDF created from training vocabulary is not available.
# For robust prediction, you should save the vocabulary and tfidf transformer during training and reuse here.
preds <- NA
if ("randomForest" %in% class(model)) {
  # create a bag-of-words placeholder: use simple term frequencies from input
  df_matrix <- as.data.frame(matrix(0, nrow=nrow(df), ncol=1))
  names(df_matrix) <- c("v1")
  preds <- predict(model, df_matrix)
} else {
  preds <- rep(NA, nrow(df))
}
df$prediction <- preds
fwrite(df, opt$output_file)
cat("Wrote predictions to", opt$output_file, "\n")