# eval.R - evaluation helpers
library(caret)
library(ROCR)

get_metrics <- function(true_labels, pred_labels) {
  cm <- confusionMatrix(as.factor(pred_labels), as.factor(true_labels))
  res <- list(accuracy = cm$overall['Accuracy'], byClass = cm$byClass, table = cm$table)
  return(res)
}