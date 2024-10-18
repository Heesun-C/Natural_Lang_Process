library(shiny)
library(data.table)
library(stringr)

# Load models
ngram_models <- readRDS("combined_backoff_3gram_min5_top5.rds")
word_vectors <- readRDS("word_vectors.rds")

# Hybrid prediction function
predict_hybrid <- function(input_text, ngram_models, word_vectors, top = 5, ngram_weight = 0.6) {
  # N-gram prediction
  ngram_pred <- predict_next_word_without_unigram(input_text, ngram_models)
  
  # FastText prediction
  context_words <- tail(unlist(strsplit(tolower(input_text), "\\W+")), 5)
  context_words <- context_words[context_words %in% word_vectors$words]
  
  if (length(context_words) > 0) {
    context_vectors <- word_vectors$vectors[word_vectors$words %in% context_words, ,drop=FALSE]
    context_vector <- if(nrow(context_vectors) > 1) colMeans(context_vectors) else as.vector(context_vectors)
    
    # Cosine similarity calculation
    cosine_similarity <- function(vec1, matrix) {
      numerator <- matrix %*% vec1
      denominator <- sqrt(rowSums(matrix^2)) * sqrt(sum(vec1^2))
      similarity <- numerator / denominator
      return(as.vector(similarity))
    }
    
    similarities <- cosine_similarity(context_vector, word_vectors$vectors)
    valid_indices <- which(!(word_vectors$words %in% context_words))
    similarities <- similarities[valid_indices]
    valid_words <- word_vectors$words[valid_indices]
    top_similar <- head(order(similarities, decreasing = TRUE), top)
    
    fasttext_pred <- data.table(
      next_word = valid_words[top_similar],
      prob = similarities[top_similar]
    )
  } else {
    fasttext_pred <- data.table(next_word = character(0), prob = numeric(0))
  }
  
  # Combine results
  if (nrow(ngram_pred) > 0) {
    ngram_pred[, source := "ngram"]
    if (nrow(fasttext_pred) > 0) {
      fasttext_pred[, source := "fasttext"]
      combined_pred <- rbindlist(list(ngram_pred, fasttext_pred), fill = TRUE)
    } else {
      combined_pred <- ngram_pred
    }
  } else if (nrow(fasttext_pred) > 0) {
    fasttext_pred[, source := "fasttext"]
    combined_pred <- fasttext_pred
  } else {
    combined_pred <- data.table(next_word = character(0), prob = numeric(0), source = character(0), weighted_prob = numeric(0))
  }
  
  # Apply weights
  if (nrow(combined_pred) > 0) {
    combined_pred[source == "ngram", weighted_prob := prob * ngram_weight]
    combined_pred[source == "fasttext", weighted_prob := prob * (1 - ngram_weight)]
    
    combined_pred <- combined_pred[order(-weighted_prob)]
    combined_pred <- combined_pred[!duplicated(next_word)]
    combined_pred <- head(combined_pred, top)
    
    return(combined_pred)
  } else {
    return(combined_pred)
  }
}

# N-gram prediction function
predict_next_word_without_unigram <- function(input_text, ngram_models) {
  words <- unlist(strsplit(tolower(input_text), "\\W+"))
  n_gram_sizes <- as.integer(names(ngram_models))
  
  for (n in rev(n_gram_sizes[-1])) {
    if (length(words) >= n-1) {
      input_prefix <- paste(tail(words, n-1), collapse = " ")
      predictions <- ngram_models[[as.character(n)]][prefix == input_prefix]
      
      if (nrow(predictions) > 0) {
        return(predictions[order(-final_prob)][, .(next_word, prob = final_prob)])
      }
    }
  }
  
  return(data.table(next_word = character(0), prob = numeric(0)))
}