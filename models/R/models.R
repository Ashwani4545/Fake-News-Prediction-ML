# models.R - training wrappers for RF, XGBoost, and a simple neural net
library(randomForest)
library(xgboost)
library(neuralnet)
library(Matrix)

train_rf <- function(x_train, y_train) {
  df <- as.data.frame(as.matrix(x_train))
  df$label <- as.factor(y_train)
  model <- randomForest(label ~ ., data = df, ntree = 100)
  return(model)
}

train_xgb <- function(x_train, y_train, num_class = NULL) {
  if (!is.null(num_class) && num_class > 2) {
    params <- list(objective = "multi:softprob", eval_metric = "mlogloss", num_class = num_class)
  } else {
    params <- list(objective = "binary:logistic", eval_metric = "logloss")
  }
  dtrain <- xgb.DMatrix(data = x_train, label = as.numeric(y_train) - 1)
  model <- xgb.train(params = params, data = dtrain, nrounds = 100, verbose = 0)
  return(model)
}

train_mlp <- function(x_train, y_train, hidden = c(10)) {
  df <- as.data.frame(as.matrix(x_train))
  df$label <- as.numeric(as.factor(y_train))
  formula <- as.formula(paste("label ~", paste(names(df)[names(df) != "label"], collapse = " + ")))
  model <- neuralnet(formula, data = df, hidden = hidden, linear.output = FALSE)
  return(model)
}