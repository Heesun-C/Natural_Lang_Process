library(shiny)
library(plotly)

server <- function(input, output, session) {
  
  predictions <- reactiveVal(NULL)
  real_time_predictions <- reactiveVal(NULL)
  
  observeEvent(input$predict_button, {
    user_input <- input$user_input
    
    if (nchar(trimws(user_input)) > 0) {
      pred_result <- predict_hybrid(user_input, ngram_models, word_vectors, top = 5, ngram_weight = 0.6)
      predictions(pred_result)
    } else {
      showNotification("Please enter some text before predicting.", type = "warning")
    }
  })
  
  output$prediction_output <- renderText({
    pred <- predictions()
    if (!is.null(pred) && nrow(pred) > 0) {
      result_str <- paste("Predicted next words (with probabilities):\n",
                          paste(paste(pred$next_word, sprintf("(%.2f)", pred$weighted_prob), sep = ": "), 
                                collapse = "\n"))
      return(result_str)
    } else {
      return("No predictions available. Try entering more text.")
    }
  })
  
  output$prediction_plot <- renderPlotly({
    pred <- predictions()
    if (!is.null(pred) && nrow(pred) > 0) {
      ngram_weight <- 0.6
      pred$ngram_contrib <- ifelse(pred$source == "ngram", pred$weighted_prob, 0)
      pred$fasttext_contrib <- ifelse(pred$source == "fasttext", pred$weighted_prob, 
                                      pred$weighted_prob * (1 - ngram_weight) / ngram_weight)
      
      plot_ly(pred, x = ~next_word, y = ~ngram_contrib, type = "bar", name = "N-gram",
              marker = list(color = "skyblue")) %>%
        add_trace(y = ~fasttext_contrib, name = "FastText", 
                  marker = list(color = "lightgreen")) %>%
        layout(title = "Prediction Probabilities with Model Contributions",
               xaxis = list(title = "Predicted Words"),
               yaxis = list(title = "Probability"),
               barmode = "stack") %>%
        add_annotations(x = ~next_word, y = ~weighted_prob, 
                        text = ~sprintf("%.3f", weighted_prob), 
                        showarrow = FALSE, textposition = "outside")
    }
  })
  
  # Real-time prediction
  observe({
    user_input <- input$user_input
    if (nchar(trimws(user_input)) > 0) {
      if (grepl("\\s$", user_input) || nchar(user_input) > 20) {
        pred_result <- predict_hybrid(user_input, ngram_models, word_vectors, top = 5, ngram_weight = 0.6)
        if (nrow(pred_result) > 0) {
          real_time_predictions(pred_result)
        }
      }
    } else {
      real_time_predictions(NULL)
    }
  })
  
  # New code snippet for rendering real-time predictions
  output$real_time_predictions <- renderUI({
    pred <- real_time_predictions()
    if (!is.null(pred) && nrow(pred) > 0) {
      tagList(
        lapply(1:nrow(pred), function(i) {
          actionButton(inputId = paste0("pred_", i),
                       label = pred$next_word[i],
                       onclick = sprintf("Shiny.setInputValue('select_prediction', '%s');", pred$next_word[i]))
        })
      )
    }
  })
  
  # Update input when a real-time prediction is selected
  observeEvent(input$select_prediction, {
    selected_word <- input$select_prediction
    if (!is.null(selected_word) && selected_word != "") {
      current_input <- input$user_input
      updateTextInput(session, "user_input", value = paste(current_input, selected_word))
    }
  })
}