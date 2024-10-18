library(shiny)
library(plotly)

ui <- fluidPage(
  titlePanel("Next Word Prediction"),
  
  tabsetPanel(
    tabPanel("Predict", 
             sidebarLayout(
               sidebarPanel(
                 textInput("user_input", "Enter text:", ""),
                 actionButton("predict_button", "Predict Next Word"),
                 hr(),
                 h4("Real-time Predictions:"),
                 uiOutput("real_time_predictions"),
                 hr(),
                 helpText("Please refer to the 'How to Use' tab for usage instructions.")
               ),
               mainPanel(
                 h3("Predicted Next Words:"),
                 verbatimTextOutput("prediction_output"),
                 plotlyOutput("prediction_plot"),
                 helpText("The stacked bar chart shows the contribution of each model:"),
                 tags$ul(
                   tags$li("Blue: N-gram model contribution"),
                   tags$li("Green: FastText model contribution"),
                   tags$li("Total height: Overall prediction probability")
                 )
               )
             )
    ),
    tabPanel("How to Use", 
             fluidRow(
               column(12,
                      h3("How to Use This App"),
                      p("This app predicts the next word based on the text you input. Here's how to use it:"),
                      tags$ol(
                        tags$li("Enter some text in the input box on the 'Predict' tab."),
                        tags$li("Click the 'Predict Next Word' button or use real-time predictions."),
                        tags$li("View the predicted next words and their probabilities."),
                        tags$li("The bar chart visualizes the prediction probabilities.")
                      ),
                      h4("Features:"),
                      tags$ul(
                        tags$li("Real-time prediction: The app suggests words as you type."),
                        tags$li("Hybrid model: Combines n-gram and FastText models for better predictions."),
                        tags$li("Visualization: Bar chart shows relative probabilities of predicted words.")
                      ),
                      h4("Tips:"),
                      tags$ul(
                        tags$li("For better predictions, enter at least a few words."),
                        tags$li("The model works best with common phrases and expressions."),
                        tags$li("Explore different inputs to see how predictions change!")
                      ),
                      h4("For more information:"),
                      tags$ul(
                        tags$li(
                          "Please visit my ", 
                          tags$a(href="https://github.com/Heesun-C/Natural_Lang_Process", 
                                 "GitHub repository", 
                                 target="_blank")
                        )
                      )
               )
             )
    )
  )
)