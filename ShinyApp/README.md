# Next Word Prediction Shiny App

This Shiny app predicts the next word based on user input using a hybrid model combining N-gram and FastText approaches.

## Features

- Real-time word prediction
- Hybrid model using N-gram and FastText
- Visualization of prediction probabilities

## Setup

1. Clone this repository
2. Install required R packages:
   ```R
   install.packages(c("shiny", "data.table", "stringr", "plotly"))
   ```
3. Run the Shiny app:
   ```R
   shiny::runApp()
   ```

## Files

- ui.R: User interface for the Shiny app
- server.R: Server logic for the Shiny app
- global.R: Global variables and functions
- combined_backoff_3gram_min5_top5.rds: N-gram model
- word_vectors.rds: FastText model (preprocessed word vector model by using <https://dl.fbaipublicfiles.com/fasttext/vectors-english/wiki-news-300d-1M.vec.zip>)

## Usage

This app predicts the next word based on the text you input. Here's how to use it:

1. Enter some text in the input box on the 'Predict' tab.
2. Click the 'Predict Next Word' button or use real-time predictions.
3. View the predicted next words and their probabilities.
4. The bar chart visualizes the prediction probabilities.