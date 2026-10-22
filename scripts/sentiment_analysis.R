library(tidyverse)

data_raw <- read.csv(
  "data/raw/BDFoodSent-334k.csv",
  stringsAsFactors = FALSE
)

cat("\n========== ORIGINAL DATA ==========\n")
cat("Rows:", nrow(data_raw), "\n")
cat("Columns:", ncol(data_raw), "\n")

data <- data_raw %>%
  select(text, labels) %>%
  filter(!is.na(text), !is.na(labels)) %>%
  mutate(text = trimws(text)) %>%
  filter(text != "")

data$sentiment <- factor(
  data$labels,
  levels = c(1, 2, 3),
  labels = c("negative", "neutral", "positive")
)

cat("\n========== AFTER BASIC FILTERING ==========\n")
cat("Rows:", nrow(data), "\n")
cat("Columns:", ncol(data), "\n")

cat("\n========== SENTIMENT DISTRIBUTION ==========\n")
print(table(data$sentiment))

cat("\nPercentage:\n")
print(round(prop.table(table(data$sentiment)) * 100, 2))

cat("\n========== EXACT DUPLICATES ==========\n")
exact_duplicates <- sum(duplicated(data$text))
cat("Exact duplicate texts:", exact_duplicates, "\n")

normalize_duplicate <- function(x) {
  x <- tolower(x)
  x <- gsub("http\\S+|www\\S+", " ", x)
  x <- gsub("[[:punct:]]", " ", x)
  x <- gsub("[0-9]+", " ", x)
  x <- gsub("\\s+", " ", x)
  x <- trimws(x)
  return(x)
}

data$dup_text <- normalize_duplicate(data$text)

normalized_duplicates <- sum(duplicated(data$dup_text))

cat("\n========== NORMALIZED DUPLICATES ==========\n")
cat("Normalized duplicate texts:", normalized_duplicates, "\n")

duplicate_label_check <- data %>%
  group_by(dup_text) %>%
  summarise(
    total_rows = n(),
    label_count = n_distinct(sentiment),
    .groups = "drop"
  )

conflicting_duplicates <- sum(
  duplicate_label_check$label_count > 1
)

cat("\n========== DUPLICATE LABEL CHECK ==========\n")
cat(
  "Normalized texts with conflicting sentiment labels:",
  conflicting_duplicates,
  "\n"
)

cat("\nLabel-count distribution:\n")
print(table(duplicate_label_check$label_count))

cat("\n========== SAMPLE REVIEWS ==========\n")

set.seed(42)

sample_reviews <- data %>%
  select(text, sentiment) %>%
  slice_sample(n = 10)

print(sample_reviews)

cat("\n========== AUDIT COMPLETE ==========\n")
banglish_words <- c(
  "ami","amar","amra","apni","apnar","tumi","tomar","ora","oder",
  "eta","eita","oita","ei","oi","ekta","onek","khub","beshi","kom",
  "bhalo","valo","kharap","moja","mojar","darun","shundor","sundor",
  "moja","joss","jos","faltu","baje","bekar",
  "khawa","khabar","foodta","khabarta","taste","tasty",
  "laglo","lagse","lage","lagbe","chilo","chilo na","ache","ase",
  "nai","nei","na","hoy","hoise","hoye","korlam","korsi","korse",
  "dise","dilo","diche","paisi","pelam","paichi","pai nai",
  "delivery","order","packaging","packet","restaurant",
  "dam","taka","poriman","quantity","service",
  "bhorta","vorta","bhat","vat","mangsho","mangso","chicken",
  "biriyani","biryani","kacchi","khichuri","dal","alu","dim",
  "mach","fish","beef","mutton",
  "gorom","thanda","jhal","mishti","tok","lobon","nun",
  "fresh","purano","kom chilo","beshi chilo"
)

banglish_pattern <- paste0(
  "\\b(",
  paste(unique(banglish_words), collapse = "|"),
  ")\\b"
)

data_clean <- data_clean %>%
  mutate(
    text_lower = tolower(text),
    banglish_hits = str_count(text_lower, banglish_pattern),
    english_word_hits = str_count(
      text_lower,
      "\\b(the|is|was|very|good|bad|food|order|delivery|taste|best|worst|not|too|really|with|and|but|this|that)\\b"
    )
  )

banglish_candidates <- data_clean %>%
  filter(
    banglish_hits >= 2
  )

cat("\n========== BANGLISH CANDIDATE SUBSET ==========\n")
cat("Candidate rows:", nrow(banglish_candidates), "\n")

cat("\nSentiment distribution:\n")
print(table(banglish_candidates$sentiment))

cat("\nPercentage:\n")
print(round(
  prop.table(table(banglish_candidates$sentiment)) * 100,
  2
))

cat("\n========== RANDOM CANDIDATE SAMPLES ==========\n")

set.seed(42)

candidate_samples <- banglish_candidates %>%
  select(text, sentiment, banglish_hits, english_word_hits) %>%
  slice_sample(n = min(30, nrow(banglish_candidates)))

print(candidate_samples)

cat("\n========== STEP COMPLETE ==========\n")

library(tidyverse)

cat("\n========== DUPLICATE CLEANING ==========\n")

duplicate_label_check <- data %>%
  group_by(dup_text) %>%
  summarise(
    total_rows = n(),
    label_count = n_distinct(sentiment),
    .groups = "drop"
  )

conflicting_texts <- duplicate_label_check %>%
  filter(label_count > 1) %>%
  pull(dup_text)

data_clean <- data %>%
  filter(!dup_text %in% conflicting_texts) %>%
  distinct(dup_text, .keep_all = TRUE)

cat("Rows before cleaning:", nrow(data), "\n")
cat("Conflicting groups removed:", length(conflicting_texts), "\n")
cat("Rows after duplicate cleaning:", nrow(data_clean), "\n")

cat("\n========== CLEAN LABEL DISTRIBUTION ==========\n")
print(table(data_clean$sentiment))

cat("\nPercentage:\n")
print(round(prop.table(table(data_clean$sentiment)) * 100, 2))

cat("\nNormalized duplicates remaining:",
    sum(duplicated(data_clean$dup_text)), "\n")


banglish_words <- c(
  "ami","amar","amra","apni","apnar","tumi","tomar","ora","oder",
  "eta","eita","oita","ei","oi","ekta","onek","khub","beshi","kom",
  "bhalo","valo","kharap","moja","mojar","darun","shundor","sundor",
  "joss","jos","faltu","baje","bekar",
  "khawa","khabar","foodta","khabarta",
  "laglo","lagse","lage","lagbe",
  "chilo","ache","ase","nai","nei","na",
  "hoy","hoise","hoye",
  "korlam","korsi","korse",
  "dise","dilo","diche",
  "paisi","pelam","paichi",
  "dam","taka","poriman",
  "bhorta","vorta","bhat","vat",
  "mangsho","mangso",
  "biriyani","biryani","kacchi","khichuri",
  "dal","alu","dim","mach",
  "gorom","thanda","jhal","mishti",
  "tok","lobon","nun","purano"
)

banglish_pattern <- paste0(
  "\\b(",
  paste(unique(banglish_words), collapse = "|"),
  ")\\b"
)

data_clean <- data_clean %>%
  mutate(
    text_lower = tolower(text),
    banglish_hits = str_count(text_lower, banglish_pattern),
    english_word_hits = str_count(
      text_lower,
      "\\b(the|is|was|very|good|bad|food|order|delivery|taste|best|worst|not|too|really|with|and|but|this|that)\\b"
    )
  )

banglish_candidates <- data_clean %>%
  filter(banglish_hits >= 2)

cat("\n========== BANGLISH CANDIDATES ==========\n")
cat("Candidate rows:", nrow(banglish_candidates), "\n")

cat("\nSentiment distribution:\n")
print(table(banglish_candidates$sentiment))

cat("\nPercentage:\n")
print(round(
  prop.table(table(banglish_candidates$sentiment)) * 100,
  2
))

cat("\n========== RANDOM SAMPLE ==========\n")

set.seed(42)

candidate_samples <- banglish_candidates %>%
  select(text, sentiment, banglish_hits, english_word_hits) %>%
  slice_sample(n = min(30, nrow(banglish_candidates)))

print(candidate_samples)

cat("\n========== STEP COMPLETE ==========\n")













library(tidyverse)

cat("\n========== DUPLICATE CLEANING ==========\n")

duplicate_label_check <- data %>%
  group_by(dup_text) %>%
  summarise(
    total_rows = n(),
    label_count = n_distinct(sentiment),
    .groups = "drop"
  )

conflicting_texts <- duplicate_label_check %>%
  filter(label_count > 1) %>%
  pull(dup_text)

data_clean <- data %>%
  filter(!dup_text %in% conflicting_texts) %>%
  distinct(dup_text, .keep_all = TRUE)

cat("Rows before cleaning:", nrow(data), "\n")
cat("Conflicting groups removed:", length(conflicting_texts), "\n")
cat("Rows after duplicate cleaning:", nrow(data_clean), "\n")

cat("\n========== CLEAN LABEL DISTRIBUTION ==========\n")
print(table(data_clean$sentiment))

cat("\nPercentage:\n")
print(round(prop.table(table(data_clean$sentiment)) * 100, 2))

cat("\nNormalized duplicates remaining:",
    sum(duplicated(data_clean$dup_text)), "\n")


banglish_words <- c(
  "ami","amar","amra","apni","apnar","tumi","tomar","ora","oder",
  "eta","eita","oita","ei","oi","ekta","onek","khub","beshi","kom",
  "bhalo","valo","kharap","moja","mojar","darun","shundor","sundor",
  "joss","jos","faltu","baje","bekar",
  "khawa","khabar","foodta","khabarta",
  "laglo","lagse","lage","lagbe",
  "chilo","ache","ase","nai","nei","na",
  "hoy","hoise","hoye",
  "korlam","korsi","korse",
  "dise","dilo","diche",
  "paisi","pelam","paichi",
  "dam","taka","poriman",
  "bhorta","vorta","bhat","vat",
  "mangsho","mangso",
  "biriyani","biryani","kacchi","khichuri",
  "dal","alu","dim","mach",
  "gorom","thanda","jhal","mishti",
  "tok","lobon","nun","purano"
)

banglish_pattern <- paste0(
  "\\b(",
  paste(unique(banglish_words), collapse = "|"),
  ")\\b"
)

data_clean <- data_clean %>%
  mutate(
    text_lower = tolower(text),
    banglish_hits = str_count(text_lower, banglish_pattern),
    english_word_hits = str_count(
      text_lower,
      "\\b(the|is|was|very|good|bad|food|order|delivery|taste|best|worst|not|too|really|with|and|but|this|that)\\b"
    )
  )

banglish_candidates <- data_clean %>%
  filter(banglish_hits >= 2)

cat("\n========== BANGLISH CANDIDATES ==========\n")
cat("Candidate rows:", nrow(banglish_candidates), "\n")

cat("\nSentiment distribution:\n")
print(table(banglish_candidates$sentiment))

cat("\nPercentage:\n")
print(round(
  prop.table(table(banglish_candidates$sentiment)) * 100,
  2
))

cat("\n========== RANDOM SAMPLE ==========\n")

set.seed(42)

candidate_samples <- banglish_candidates %>%
  select(text, sentiment, banglish_hits, english_word_hits) %>%
  slice_sample(n = min(30, nrow(banglish_candidates)))

print(candidate_samples)

cat("\n========== STEP COMPLETE ==========\n")









strong_banglish_words <- c(
  "ami","amar","amra","apni","apnar","tumi","tomar",
  "eta","eita","oita","jeita","jeta",
  "onek","onk","khub","khubi","beshi","kom",
  "bhalo","valo","bhaloi","kharap","baje","baze","faltu",
  "khawa","khabar","khabarta",
  "laglo","lagse","lage","lagbe","lageni",
  "chilo","cilo","chilona","ache","ase",
  "nai","nei","hoy","hoise","hoye",
  "korlam","korsi","korse","korle","kora",
  "dise","disi","disen","dilo","diyeche",
  "paisi","pelam","paichi",
  "dam","taka","tk","poriman",
  "gorom","thanda","thnda",
  "jhal","mishti","tok","lobon","nun",
  "ager","abar","ektu","ekdom","motamoti",
  "jaygay","theke","jonno","sathe",
  "kintu","r","ar","na"
)

english_words <- c(
  "the","is","was","were","very","good","bad",
  "food","order","ordered","delivery","taste","tasty",
  "best","worst","not","too","really","with",
  "and","but","this","that","so",
  "chicken","beef","burger","pizza","pasta",
  "rice","sauce","packaging","quantity",
  "service","average","spicy","fresh",
  "disappointing","delicious","waste"
)

strong_banglish_pattern <- paste0(
  "\\b(",
  paste(unique(strong_banglish_words), collapse = "|"),
  ")\\b"
)

english_pattern <- paste0(
  "\\b(",
  paste(unique(english_words), collapse = "|"),
  ")\\b"
)

data_clean <- data_clean %>%
  mutate(
    strong_banglish_hits = str_count(
      text_lower,
      strong_banglish_pattern
    ),
    english_hits_new = str_count(
      text_lower,
      english_pattern
    )
  )

code_mixed_data <- data_clean %>%
  filter(
    strong_banglish_hits >= 2,
    english_hits_new >= 1
  )

cat("\n========== STRICT CODE-MIXED DATA ==========\n")

cat("Rows:", nrow(code_mixed_data), "\n")

cat("\nSentiment distribution:\n")
print(table(code_mixed_data$sentiment))

cat("\nPercentage:\n")
print(
  round(
    prop.table(table(code_mixed_data$sentiment)) * 100,
    2
  )
)

set.seed(42)

strict_samples <- code_mixed_data %>%
  select(
    text,
    sentiment,
    strong_banglish_hits,
    english_hits_new
  ) %>%
  slice_sample(
    n = min(30, nrow(code_mixed_data))
  )

cat("\n========== 30 STRICT SAMPLES ==========\n")

print(strict_samples)

cat("Total strict code-mixed rows:", nrow(code_mixed_data), "\n")

print(table(code_mixed_data$sentiment))

print(
  round(
    prop.table(table(code_mixed_data$sentiment)) * 100,
    2
  )
)

final_dataset <- code_mixed_data %>%
  select(text, sentiment) %>%
  filter(
    !is.na(text),
    !is.na(sentiment),
    trimws(text) != ""
  )

final_dataset <- code_mixed_data %>%
  select(text, sentiment) %>%
  filter(
    !is.na(text),
    !is.na(sentiment),
    trimws(text) != ""
  )

library(tidyverse)

final_dataset <- code_mixed_data %>%
  select(text, sentiment) %>%
  filter(
    !is.na(text),
    !is.na(sentiment),
    trimws(text) != ""
  )

final_dataset$sentiment <- droplevels(final_dataset$sentiment)

cat("\n========== FINAL BANGLISH DATASET ==========\n")
cat("Total rows:", nrow(final_dataset), "\n")

cat("\nClass distribution:\n")
print(table(final_dataset$sentiment))

cat("\nPercentage:\n")
print(round(prop.table(table(final_dataset$sentiment)) * 100, 2))

cat("\nDuplicate texts:", sum(duplicated(final_dataset$text)), "\n")

write.csv(
  final_dataset,
  "data/processed/banglish_sentiment_final.csv",
  row.names = FALSE
)

cat("\nSaved: banglish_sentiment_final.csv\n")



library(tidyverse)
library(caret)

data_model <- read.csv(
  "data/processed/banglish_sentiment_final.csv",
  stringsAsFactors = FALSE
)

data_model$sentiment <- factor(
  data_model$sentiment,
  levels = c("negative", "neutral", "positive")
)

clean_text <- function(x) {
  x <- tolower(x)
  x <- gsub("http\\S+|www\\S+", " ", x)
  x <- gsub("[^a-zA-Z\\s]", " ", x)
  x <- gsub("\\s+", " ", x)
  x <- trimws(x)
  return(x)
}

data_model$text_clean <- clean_text(data_model$text)

data_model <- data_model %>%
  filter(
    !is.na(text_clean),
    text_clean != ""
  )

set.seed(42)

train_index <- createDataPartition(
  data_model$sentiment,
  p = 0.80,
  list = FALSE
)

train_data <- data_model[train_index, ]
test_data <- data_model[-train_index, ]

cat("\n========== DATA SPLIT ==========\n")

cat("Total rows:", nrow(data_model), "\n")
cat("Train rows:", nrow(train_data), "\n")
cat("Test rows:", nrow(test_data), "\n")

cat("\nTrain distribution:\n")
print(table(train_data$sentiment))

cat("\nTrain percentage:\n")
print(round(
  prop.table(table(train_data$sentiment)) * 100,
  2
))

cat("\nTest distribution:\n")
print(table(test_data$sentiment))

cat("\nTest percentage:\n")
print(round(
  prop.table(table(test_data$sentiment)) * 100,
  2
))

write.csv(
  train_data,
  "data/processed/banglish_train.csv",
  row.names = FALSE
)

write.csv(
  test_data,
  "data/processed/banglish_test.csv",
  row.names = FALSE
)

cat("\nSaved: banglish_train.csv\n")
cat("Saved: banglish_test.csv\n")



library(tidyverse)
library(quanteda)
library(quanteda.textmodels)
library(caret)

train_data <- read.csv(
  "data/processed/banglish_train.csv",
  stringsAsFactors = FALSE
)

test_data <- read.csv(
  "data/processed/banglish_test.csv",
  stringsAsFactors = FALSE
)

train_data$sentiment <- factor(
  train_data$sentiment,
  levels = c("negative", "neutral", "positive")
)

test_data$sentiment <- factor(
  test_data$sentiment,
  levels = c("negative", "neutral", "positive")
)

train_tokens <- tokens(
  train_data$text_clean,
  remove_punct = TRUE,
  remove_numbers = TRUE
)

test_tokens <- tokens(
  test_data$text_clean,
  remove_punct = TRUE,
  remove_numbers = TRUE
)

train_dfm <- dfm(train_tokens)
test_dfm <- dfm(test_tokens)

train_dfm <- dfm_trim(
  train_dfm,
  min_docfreq = 5
)

test_dfm <- dfm_match(
  test_dfm,
  features = featnames(train_dfm)
)

cat("\n========== BoW FEATURES ==========\n")
cat("Train documents:", ndoc(train_dfm), "\n")
cat("Test documents:", ndoc(test_dfm), "\n")
cat("Features:", nfeat(train_dfm), "\n")

bow_lr_model <- textmodel_lr(
  train_dfm,
  y = train_data$sentiment
)

bow_lr_pred <- predict(
  bow_lr_model,
  newdata = test_dfm
)

bow_lr_pred <- factor(
  bow_lr_pred,
  levels = levels(test_data$sentiment)
)

cm_bow_lr <- confusionMatrix(
  bow_lr_pred,
  test_data$sentiment
)

cat("\n========== BoW + LOGISTIC REGRESSION ==========\n")

print(cm_bow_lr$table)

cat("\nAccuracy:\n")
print(cm_bow_lr$overall["Accuracy"])

precision <- diag(cm_bow_lr$table) / colSums(cm_bow_lr$table)
recall <- diag(cm_bow_lr$table) / rowSums(cm_bow_lr$table)
f1 <- 2 * precision * recall / (precision + recall)

precision[is.na(precision)] <- 0
recall[is.na(recall)] <- 0
f1[is.na(f1)] <- 0

cat("\nPrecision by class:\n")
print(precision)

cat("\nRecall by class:\n")
print(recall)

cat("\nF1 by class:\n")
print(f1)

cat("\nMacro Precision:", mean(precision), "\n")
cat("Macro Recall:", mean(recall), "\n")
cat("Macro F1:", mean(f1), "\n")


library(quanteda)
library(quanteda.textmodels)
library(caret)

train_tfidf <- dfm_tfidf(train_dfm)
test_tfidf <- dfm_tfidf(test_dfm)

cat("\n========== TF-IDF FEATURES ==========\n")
cat("Train documents:", ndoc(train_tfidf), "\n")
cat("Test documents:", ndoc(test_tfidf), "\n")
cat("Features:", nfeat(train_tfidf), "\n")

tfidf_lr_model <- textmodel_lr(
  train_tfidf,
  y = train_data$sentiment
)

tfidf_lr_pred <- predict(
  tfidf_lr_model,
  newdata = test_tfidf
)

tfidf_lr_pred <- factor(
  tfidf_lr_pred,
  levels = levels(test_data$sentiment)
)

cm_tfidf_lr <- confusionMatrix(
  tfidf_lr_pred,
  test_data$sentiment
)

cat("\n========== TF-IDF + LOGISTIC REGRESSION ==========\n")
print(cm_tfidf_lr$table)

accuracy_tfidf_lr <- unname(
  cm_tfidf_lr$overall["Accuracy"]
)

precision_tfidf_lr <- diag(cm_tfidf_lr$table) /
  rowSums(cm_tfidf_lr$table)

recall_tfidf_lr <- diag(cm_tfidf_lr$table) /
  colSums(cm_tfidf_lr$table)

f1_tfidf_lr <- 2 *
  precision_tfidf_lr *
  recall_tfidf_lr /
  (precision_tfidf_lr + recall_tfidf_lr)

precision_tfidf_lr[is.na(precision_tfidf_lr)] <- 0
recall_tfidf_lr[is.na(recall_tfidf_lr)] <- 0
f1_tfidf_lr[is.na(f1_tfidf_lr)] <- 0

cat("\nAccuracy:", accuracy_tfidf_lr, "\n")

cat("\nPrecision by class:\n")
print(precision_tfidf_lr)

cat("\nRecall by class:\n")
print(recall_tfidf_lr)

cat("\nF1 by class:\n")
print(f1_tfidf_lr)

cat("\nMacro Precision:",
    mean(precision_tfidf_lr), "\n")

cat("Macro Recall:",
    mean(recall_tfidf_lr), "\n")

cat("Macro F1:",
    mean(f1_tfidf_lr), "\n")



library(LiblineaR)
library(quanteda)
library(caret)

train_bow_matrix <- as(train_dfm, "dgCMatrix")
test_bow_matrix <- as(test_dfm, "dgCMatrix")

train_tfidf_matrix <- as(train_tfidf, "dgCMatrix")
test_tfidf_matrix <- as(test_tfidf, "dgCMatrix")

y_train <- as.integer(train_data$sentiment)

cat("\n========== BoW + SVM ==========\n")

bow_svm_model <- LiblineaR(
  data = train_bow_matrix,
  target = y_train,
  type = 2,
  cost = 1,
  bias = TRUE,
  verbose = FALSE
)

bow_svm_raw <- predict(
  bow_svm_model,
  test_bow_matrix
)$predictions

bow_svm_pred <- factor(
  bow_svm_raw,
  levels = c(1, 2, 3),
  labels = c("negative", "neutral", "positive")
)

cm_bow_svm <- confusionMatrix(
  bow_svm_pred,
  test_data$sentiment
)

print(cm_bow_svm$table)

bow_svm_accuracy <- unname(
  cm_bow_svm$overall["Accuracy"]
)

bow_svm_precision <- diag(cm_bow_svm$table) /
  rowSums(cm_bow_svm$table)

bow_svm_recall <- diag(cm_bow_svm$table) /
  colSums(cm_bow_svm$table)

bow_svm_f1 <- 2 *
  bow_svm_precision *
  bow_svm_recall /
  (bow_svm_precision + bow_svm_recall)

bow_svm_precision[is.na(bow_svm_precision)] <- 0
bow_svm_recall[is.na(bow_svm_recall)] <- 0
bow_svm_f1[is.na(bow_svm_f1)] <- 0

cat("\nAccuracy:", bow_svm_accuracy, "\n")
cat("Macro Precision:", mean(bow_svm_precision), "\n")
cat("Macro Recall:", mean(bow_svm_recall), "\n")
cat("Macro F1:", mean(bow_svm_f1), "\n")


cat("\n========== TF-IDF + SVM ==========\n")

tfidf_svm_model <- LiblineaR(
  data = train_tfidf_matrix,
  target = y_train,
  type = 2,
  cost = 1,
  bias = TRUE,
  verbose = FALSE
)

tfidf_svm_raw <- predict(
  tfidf_svm_model,
  test_tfidf_matrix
)$predictions

tfidf_svm_pred <- factor(
  tfidf_svm_raw,
  levels = c(1, 2, 3),
  labels = c("negative", "neutral", "positive")
)

cm_tfidf_svm <- confusionMatrix(
  tfidf_svm_pred,
  test_data$sentiment
)

print(cm_tfidf_svm$table)

tfidf_svm_accuracy <- unname(
  cm_tfidf_svm$overall["Accuracy"]
)

tfidf_svm_precision <- diag(cm_tfidf_svm$table) /
  rowSums(cm_tfidf_svm$table)

tfidf_svm_recall <- diag(cm_tfidf_svm$table) /
  colSums(cm_tfidf_svm$table)

tfidf_svm_f1 <- 2 *
  tfidf_svm_precision *
  tfidf_svm_recall /
  (tfidf_svm_precision + tfidf_svm_recall)

tfidf_svm_precision[is.na(tfidf_svm_precision)] <- 0
tfidf_svm_recall[is.na(tfidf_svm_recall)] <- 0
tfidf_svm_f1[is.na(tfidf_svm_f1)] <- 0

cat("\nAccuracy:", tfidf_svm_accuracy, "\n")
cat("Macro Precision:", mean(tfidf_svm_precision), "\n")
cat("Macro Recall:", mean(tfidf_svm_recall), "\n")
cat("Macro F1:", mean(tfidf_svm_f1), "\n")



bow_lr_precision <- diag(cm_bow_lr$table) /
  rowSums(cm_bow_lr$table)

bow_lr_recall <- diag(cm_bow_lr$table) /
  colSums(cm_bow_lr$table)

bow_lr_f1 <- 2 *
  bow_lr_precision *
  bow_lr_recall /
  (bow_lr_precision + bow_lr_recall)

bow_lr_precision[is.na(bow_lr_precision)] <- 0
bow_lr_recall[is.na(bow_lr_recall)] <- 0
bow_lr_f1[is.na(bow_lr_f1)] <- 0

cat("\n========== CORRECT BoW + LR METRICS ==========\n")

cat("Accuracy:",
    unname(cm_bow_lr$overall["Accuracy"]),
    "\n")

cat("Macro Precision:",
    mean(bow_lr_precision),
    "\n")

cat("Macro Recall:",
    mean(bow_lr_recall),
    "\n")

cat("Macro F1:",
    mean(bow_lr_f1),
    "\n")

cat("\nClass Precision:\n")
print(bow_lr_precision)

cat("\nClass Recall:\n")
print(bow_lr_recall)

cat("\nClass F1:\n")
print(bow_lr_f1)






library(quanteda)
library(quanteda.textmodels)
library(caret)

cat("\n========== BoW + NAIVE BAYES ==========\n")

bow_nb_model <- textmodel_nb(
  train_dfm,
  y = train_data$sentiment,
  distribution = "multinomial"
)

bow_nb_pred <- predict(
  bow_nb_model,
  newdata = test_dfm
)





library(ggplot2)
library(dplyr)

class_plot_data <- final_dataset %>%
  count(sentiment) %>%
  mutate(
    percentage = n / sum(n) * 100,
    label = paste0(n, "\n(", round(percentage, 1), "%)")
  )

print(class_plot_data)

fig1 <- ggplot(
  class_plot_data,
  aes(x = sentiment, y = n, fill = sentiment)
) +
  geom_col(width = 0.65, show.legend = FALSE) +
  geom_text(
    aes(label = label),
    vjust = -0.4,
    size = 4
  ) +
  labs(
    title = "Sentiment Class Distribution",
    x = "Sentiment Class",
    y = "Number of Reviews"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    )
  ) +
  expand_limits(
    y = max(class_plot_data$n) * 1.12
  )

print(fig1)

ggsave(
  "figures/Figure_1_Sentiment_Class_Distribution.png",
  plot = fig1,
  width = 7,
  height = 5,
  dpi = 300
)
bow_nb_pred <- factor(
  bow_nb_pred,
  levels = levels(test_data$sentiment)
)

cm_bow_nb <- confusionMatrix(
  bow_nb_pred,
  test_data$sentiment
)

print(cm_bow_nb$table)

bow_nb_accuracy <- unname(
  cm_bow_nb$overall["Accuracy"]
)

bow_nb_precision <- diag(cm_bow_nb$table) /
  rowSums(cm_bow_nb$table)

bow_nb_recall <- diag(cm_bow_nb$table) /
  colSums(cm_bow_nb$table)

bow_nb_f1 <- 2 *
  bow_nb_precision *
  bow_nb_recall /
  (bow_nb_precision + bow_nb_recall)

bow_nb_precision[is.na(bow_nb_precision)] <- 0
bow_nb_recall[is.na(bow_nb_recall)] <- 0
bow_nb_f1[is.na(bow_nb_f1)] <- 0

cat("\nAccuracy:", bow_nb_accuracy, "\n")
cat("Macro Precision:", mean(bow_nb_precision), "\n")
cat("Macro Recall:", mean(bow_nb_recall), "\n")
cat("Macro F1:", mean(bow_nb_f1), "\n")

cat("\nClass Precision:\n")
print(bow_nb_precision)

cat("\nClass Recall:\n")
print(bow_nb_recall)

cat("\nClass F1:\n")
print(bow_nb_f1)


cat("\n========== TF-IDF + NAIVE BAYES ==========\n")

tfidf_nb_model <- textmodel_nb(
  train_tfidf,
  y = train_data$sentiment,
  distribution = "multinomial"
)

tfidf_nb_pred <- predict(
  tfidf_nb_model,
  newdata = test_tfidf
)

tfidf_nb_pred <- factor(
  tfidf_nb_pred,
  levels = levels(test_data$sentiment)
)

cm_tfidf_nb <- confusionMatrix(
  tfidf_nb_pred,
  test_data$sentiment
)

print(cm_tfidf_nb$table)

tfidf_nb_accuracy <- unname(
  cm_tfidf_nb$overall["Accuracy"]
)

tfidf_nb_precision <- diag(cm_tfidf_nb$table) /
  rowSums(cm_tfidf_nb$table)

tfidf_nb_recall <- diag(cm_tfidf_nb$table) /
  colSums(cm_tfidf_nb$table)

tfidf_nb_f1 <- 2 *
  tfidf_nb_precision *
  tfidf_nb_recall /
  (tfidf_nb_precision + tfidf_nb_recall)

tfidf_nb_precision[is.na(tfidf_nb_precision)] <- 0
tfidf_nb_recall[is.na(tfidf_nb_recall)] <- 0
tfidf_nb_f1[is.na(tfidf_nb_f1)] <- 0

cat("\nAccuracy:", tfidf_nb_accuracy, "\n")
cat("Macro Precision:", mean(tfidf_nb_precision), "\n")
cat("Macro Recall:", mean(tfidf_nb_recall), "\n")
cat("Macro F1:", mean(tfidf_nb_f1), "\n")

cat("\nClass Precision:\n")
print(tfidf_nb_precision)

cat("\nClass Recall:\n")
print(tfidf_nb_recall)

cat("\nClass F1:\n")
print(tfidf_nb_f1)



# install.packages("DiagrammeR")


library(DiagrammeR)

fig2 <- grViz("
digraph workflow {

  graph [
    layout = dot,
    rankdir = TB,
    nodesep = 0.45,
    ranksep = 0.55
  ]

  node [
    shape = rectangle,
    style = rounded,
    fontname = Helvetica,
    fontsize = 11,
    width = 3.2,
    height = 0.6
  ]

  edge [
    fontname = Helvetica,
    fontsize = 10
  ]

  A [label = 'Original BDFoodSent Dataset\\n334,119 Reviews']
  B [label = 'Text Cleaning and Normalization']
  C [label = 'Duplicate and Conflicting-Label Removal']
  D [label = 'Bangla-English Code-Mixed Filtering']
  E [label = 'Final Dataset\\n18,957 Reviews']
  F [label = 'Stratified Train-Test Split\\n80% Train / 20% Test']
  G [label = 'Feature Representation\\nBoW and TF-IDF']
  H [label = 'Classification\\nLogistic Regression / SVM / Naive Bayes']
  I [label = 'Evaluation\\nAccuracy / Precision / Recall / F1-score']
  J [label = 'Confusion Matrix and Model Comparison']

  A -> B
  B -> C
  C -> D
  D -> E
  E -> F
  F -> G
  G -> H
  H -> I
  I -> J
}
")

fig2


library(DiagrammeR)
library(DiagrammeRsvg)
library(rsvg)

svg_code <- export_svg(fig2)

writeLines(
  svg_code,
  "figures/Figure_2_Project_Workflow.svg"
)

rsvg_png(
  charToRaw(svg_code),
  file = "figures/Figure_2_Project_Workflow.png",
  width = 1800
)

cat("Saved: Figure_2_Project_Workflow.png\n")



library(ggplot2)

accuracy_data <- data.frame(
  Model = c(
    "BoW + LR",
    "TF-IDF + LR",
    "BoW + SVM",
    "TF-IDF + SVM",
    "BoW + NB",
    "TF-IDF + NB"
  ),
  Accuracy = c(
    78.77,
    78.42,
    75.68,
    73.67,
    70.75,
    69.19
  )
)

accuracy_data$Model <- factor(
  accuracy_data$Model,
  levels = accuracy_data$Model
)

fig3 <- ggplot(
  accuracy_data,
  aes(x = Model, y = Accuracy, fill = Model)
) +
  geom_col(
    width = 0.65,
    show.legend = FALSE
  ) +
  geom_text(
    aes(label = paste0(Accuracy, "%")),
    vjust = -0.4,
    size = 4
  ) +
  labs(
    title = "Accuracy Comparison of Classification Models",
    x = "Feature Representation and Classifier",
    y = "Accuracy (%)"
  ) +
  ylim(0, 90) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    ),
    axis.text.x = element_text(
      angle = 30,
      hjust = 1
    )
  )

print(fig3)

ggsave(
  "figures/Figure_3_Accuracy_Comparison.png",
  plot = fig3,
  width = 8,
  height = 5,
  dpi = 300
)

cat("Saved: Figure_3_Accuracy_Comparison.png\n")




library(ggplot2)

f1_data <- data.frame(
  Model = c(
    "BoW + LR",
    "TF-IDF + LR",
    "BoW + SVM",
    "TF-IDF + SVM",
    "BoW + NB",
    "TF-IDF + NB"
  ),
  Macro_F1 = c(
    54.86,
    53.78,
    57.92,
    57.77,
    60.54,
    59.11
  )
)

f1_data$Model <- factor(
  f1_data$Model,
  levels = f1_data$Model
)

fig4 <- ggplot(
  f1_data,
  aes(x = Model, y = Macro_F1, fill = Model)
) +
  geom_col(
    width = 0.65,
    show.legend = FALSE
  ) +
  geom_text(
    aes(label = paste0(Macro_F1, "%")),
    vjust = -0.4,
    size = 4
  ) +
  labs(
    title = "Macro F1-Score Comparison of Classification Models",
    x = "Feature Representation and Classifier",
    y = "Macro F1-Score (%)"
  ) +
  ylim(0, 70) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    ),
    axis.text.x = element_text(
      angle = 30,
      hjust = 1
    )
  )

print(fig4)

ggsave(
  "figures/Figure_4_Macro_F1_Comparison.png",
  plot = fig4,
  width = 8,
  height = 5,
  dpi = 300
)

cat("Saved: Figure_4_Macro_F1_Comparison.png\n")


library(ggplot2)

comparison_data <- data.frame(
  Classifier = rep(
    c("Logistic Regression", "SVM", "Naive Bayes"),
    each = 2
  ),
  
  Representation = rep(
    c("BoW", "TF-IDF"),
    3
  ),
  
  Macro_F1 = c(
    54.86, 53.78,
    57.92, 57.77,
    60.54, 59.11
  )
)

fig5 <- ggplot(
  comparison_data,
  aes(
    x = Classifier,
    y = Macro_F1,
    fill = Representation
  )
) +
  geom_col(
    position = position_dodge(width = 0.8),
    width = 0.7
  ) +
  geom_text(
    aes(label = paste0(Macro_F1, "%")),
    position = position_dodge(width = 0.8),
    vjust = -0.4,
    size = 4
  ) +
  labs(
    title = "BoW vs TF-IDF Performance Comparison",
    x = "Classifier",
    y = "Macro F1-Score (%)",
    fill = "Representation"
  ) +
  ylim(0, 70) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    ),
    legend.position = "top"
  )

print(fig5)

ggsave(
  "figures/Figure_5_BoW_vs_TFIDF.png",
  plot = fig5,
  width = 8,
  height = 5,
  dpi = 300
)

cat("Saved: Figure_5_BoW_vs_TFIDF.png\n")







library(ggplot2)

cm_data <- as.data.frame(cm_bow_nb$table)

colnames(cm_data) <- c(
  "Prediction",
  "Actual",
  "Count"
)

fig6 <- ggplot(
  cm_data,
  aes(
    x = Actual,
    y = Prediction,
    fill = Count
  )
) +
  geom_tile(
    color = "white",
    linewidth = 1
  ) +
  geom_text(
    aes(label = Count),
    size = 5,
    fontface = "bold"
  ) +
  labs(
    title = "Confusion Matrix: BoW + Naive Bayes",
    x = "Actual Sentiment",
    y = "Predicted Sentiment"
  ) +
  scale_fill_gradient(
    low = "white",
    high = "steelblue"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    ),
    panel.grid = element_blank(),
    legend.title = element_text(face = "bold")
  )

print(fig6)

ggsave(
  "figures/Figure_6_Confusion_Matrix_BoW_NB.png",
  plot = fig6,
  width = 7,
  height = 5.5,
  dpi = 300
)

cat("Saved: Figure_6_Confusion_Matrix_BoW_NB.png\n")



library(ggplot2)
library(tidyr)

class_metric_data <- data.frame(
  Sentiment = c("Negative", "Neutral", "Positive"),
  Precision = c(
    0.9222924,
    0.2430472,
    0.6430939
  ) * 100,
  Recall = c(
    0.7541700,
    0.4620690,
    0.6945107
  ) * 100,
  F1 = c(
    0.8298012,
    0.3185420,
    0.6678141
  ) * 100
)

class_metric_long <- class_metric_data %>%
  pivot_longer(
    cols = c(Precision, Recall, F1),
    names_to = "Metric",
    values_to = "Score"
  )

fig7 <- ggplot(
  class_metric_long,
  aes(
    x = Sentiment,
    y = Score,
    fill = Metric
  )
) +
  geom_col(
    position = position_dodge(width = 0.8),
    width = 0.7
  ) +
  geom_text(
    aes(label = paste0(round(Score, 1), "%")),
    position = position_dodge(width = 0.8),
    vjust = -0.35,
    size = 3.8
  ) +
  labs(
    title = "Class-Wise Performance of BoW + Naive Bayes",
    x = "Sentiment Class",
    y = "Score (%)",
    fill = "Metric"
  ) +
  ylim(0, 100) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    ),
    legend.position = "top"
  )

print(fig7)

ggsave(
  "figures/Figure_7_Class_Wise_Performance_BoW_NB.png",
  plot = fig7,
  width = 8,
  height = 5,
  dpi = 300
)

cat("Saved: Figure_7_Class_Wise_Performance_BoW_NB.png\n")


library(ggplot2)
library(tidyr)

# ==============================
# Figure 6: Confusion Matrix
# BoW + Logistic Regression
# ==============================

cm_lr_data <- as.data.frame(cm_bow_lr$table)

colnames(cm_lr_data) <- c(
  "Prediction",
  "Actual",
  "Count"
)

fig6_lr <- ggplot(
  cm_lr_data,
  aes(
    x = Actual,
    y = Prediction,
    fill = Count
  )
) +
  geom_tile(
    color = "white",
    linewidth = 1
  ) +
  geom_text(
    aes(label = Count),
    size = 5,
    fontface = "bold"
  ) +
  labs(
    title = "Confusion Matrix: BoW + Logistic Regression",
    x = "Actual Sentiment",
    y = "Predicted Sentiment"
  ) +
  scale_fill_gradient(
    low = "white",
    high = "steelblue"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    ),
    panel.grid = element_blank(),
    legend.title = element_text(face = "bold")
  )

print(fig6_lr)

ggsave(
  "figures/Figure_6_Confusion_Matrix_BoW_LR.png",
  plot = fig6_lr,
  width = 7,
  height = 5.5,
  dpi = 300
)


# ==============================
# Figure 7: Class-Wise Metrics
# BoW + Logistic Regression
# ==============================

lr_class_metric_data <- data.frame(
  Sentiment = c(
    "Negative",
    "Neutral",
    "Positive"
  ),
  
  Precision = c(
    0.8227979,
    0.2909091,
    0.6991677
  ) * 100,
  
  Recall = c(
    0.94598888,
    0.03678161,
    0.70167064
  ) * 100,
  
  F1 = c(
    0.88010345,
    0.06530612,
    0.70041691
  ) * 100
)

lr_class_metric_long <- lr_class_metric_data %>%
  pivot_longer(
    cols = c(Precision, Recall, F1),
    names_to = "Metric",
    values_to = "Score"
  )

fig7_lr <- ggplot(
  lr_class_metric_long,
  aes(
    x = Sentiment,
    y = Score,
    fill = Metric
  )
) +
  geom_col(
    position = position_dodge(width = 0.8),
    width = 0.7
  ) +
  geom_text(
    aes(
      label = paste0(
        round(Score, 1),
        "%"
      )
    ),
    position = position_dodge(width = 0.8),
    vjust = -0.35,
    size = 3.8
  ) +
  labs(
    title = "Class-Wise Performance of BoW + Logistic Regression",
    x = "Sentiment Class",
    y = "Score (%)",
    fill = "Metric"
  ) +
  ylim(0, 100) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    ),
    legend.position = "top"
  )

print(fig7_lr)

ggsave(
  "figures/Figure_7_Class_Wise_Performance_BoW_LR.png",
  plot = fig7_lr,
  width = 8,
  height = 5,
  dpi = 300
)

cat(
  "Saved:\n",
  "figures/Figure_6_Confusion_Matrix_BoW_LR.png\n",
  "figures/Figure_7_Class_Wise_Performance_BoW_LR.png\n"
)
