# data_prep.R - helper functions for loading and preprocessing text data
library(tm)
library(SnowballC)
library(text2vec)
library(data.table)

TEXT_COL <- "text"
LABEL_COL <- "label"

load_data <- function(path) {
  df <- fread(path, encoding = "UTF-8", data.table = FALSE)
  if (!(TEXT_COL %in% names(df))) stop(paste("Expected text column named", TEXT_COL))
  if (!(LABEL_COL %in% names(df))) stop(paste("Expected label column named", LABEL_COL))
  return(df)
}

basic_clean <- function(texts) {
  # simple text cleaning: lower, remove URLs, punctuation, numbers, stopwords, stemming
  texts <- tolower(texts)
  texts <- gsub("http[s]?://\\S+", " ", texts)
  texts <- gsub("[^a-z\\s]", " ", texts)
  texts <- gsub("\\s+", " ", texts)
  return(texts)
}

create_dtm_tfidf <- function(train_texts, test_texts = NULL, max_features = 20000) {
  it_train <- itoken(train_texts, progressbar = FALSE)
  vocab <- create_vocabulary(it_train, stopwords = stopwords("en"))
  vocab <- prune_vocabulary(vocab, term_count_min = 2, vocab_term_max = max_features)
  vectorizer <- vocab_vectorizer(vocab)
  dtm_train <- create_dtm(it_train, vectorizer)
  tfidf <- TfIdf$new()
  dtm_train_tfidf <- tfidf$fit_transform(dtm_train)
  if (!is.null(test_texts)) {
    it_test <- itoken(test_texts, progressbar = FALSE)
    dtm_test <- create_dtm(it_test, vectorizer)
    dtm_test_tfidf <- tfidf$transform(dtm_test)
    return(list(train = dtm_train_tfidf, test = dtm_test_tfidf, vocab=vocab))
  }
  return(list(train = dtm_train_tfidf, vocab=vocab))
}