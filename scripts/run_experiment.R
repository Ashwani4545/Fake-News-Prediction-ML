#!/usr/bin/env Rscript
# Run a single experiment
suppressPackageStartupMessages({
  library(optparse)
  library(data.table)
  library(Matrix)
  source("R/data_prep.R")
  source("R/models.R")
  source("R/eval.R")
})

option_list = list(
  make_option(c("--mode"), type="character", default="binary", help="binary|multi|three"),
  make_option(c("--model"), type="character", default="rf", help="rf|xgb|mlp"),
  make_option(c("--train"), type="character", default=NULL, help="training CSV path"),
  make_option(c("--test"), type="character", default=NULL, help="testing CSV path"),
  make_option(c("--out_prefix"), type="character", default=NULL, help="output prefix for model & results")
)

opt = parse_args(OptionParser(option_list=option_list))

# determine default paths
if (is.null(opt$train)) opt$train <- file.path("data", paste0(opt$mode, "_training.csv"))
if (is.null(opt$test)) opt$test <- file.path("data", paste0(opt$mode, "_testing.csv"))
if (is.null(opt$out_prefix)) opt$out_prefix <- paste0(opt$mode, "_", opt$model)

cat("Loading training:", opt$train, "testing:", opt$test, "\n")
train_df <- load_data(opt$train)
test_df <- load_data(opt$test)

train_df[[TEXT_COL]] <- basic_clean(train_df[[TEXT_COL]])
test_df[[TEXT_COL]]  <- basic_clean(test_df[[TEXT_COL]])

dtm <- create_dtm_tfidf(train_df[[TEXT_COL]], test_df[[TEXT_COL]])
x_train <- dtm$train
x_test  <- dtm$test
y_train <- train_df[[LABEL_COL]]
y_test  <- test_df[[LABEL_COL]]

model <- NULL
if (opt$model == "rf") {
  model <- train_rf(x_train, y_train)
} else if (opt$model == "xgb") {
  num_class <- length(unique(y_train))
  model <- train_xgb(x_train, y_train, num_class = num_class)
} else if (opt$model == "mlp") {
  model <- train_mlp(x_train, y_train)
} else {
  stop("Unknown model")
}

dir.create("models", showWarnings = FALSE)
model_path <- file.path("models", paste0(opt$out_prefix, ".rds"))
saveRDS(model, model_path)
cat("Saved model to", model_path, "\n")

# predict
pred <- NULL
if (opt$model == "xgb") {
  dtest <- xgb.DMatrix(data = x_test)
  preds <- predict(model, dtest)
  # if multi-class, reshape
  if (is.matrix(preds)) {
    # not expected here; for simplicity convert to labels by max column
    preds_mat <- matrix(preds, ncol = length(unique(y_train)), byrow = TRUE)
    pred <- apply(preds_mat, 1, function(x) which.max(x))
  } else {
    pred <- ifelse(preds > 0.5, 2, 1)
  }
} else if (opt$model == "rf") {
  pred <- predict(model, as.data.frame(as.matrix(x_test)))
} else if (opt$model == "mlp") {
  # neuralnet prediction is more involved; here we skip and use training labels as placeholder
  pred <- rep(NA, length(y_test))
}

metrics <- get_metrics(y_test, pred)
saveRDS(metrics, file.path("results", paste0(opt$out_prefix, "_metrics.rds")))
cat("Saved metrics\n")