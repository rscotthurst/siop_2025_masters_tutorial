library(shiny)
library(shinycssloaders)
library(paws)
library(jsonlite)
library(dotenv)

# Specify the application port
options(shiny.host = "0.0.0.0")
options(shiny.port = 80)

# Load data
reviews_df  <- read.csv('sample-data.csv')

# Clean the text to prepare for LLM in JSON format
reviews_df[c("JobTitle", "Pros", "Cons")] <- lapply(
  reviews_df[c("JobTitle", "Pros", "Cons")],
  function(x) iconv(x, "ASCII", "UTF-8", sub = "")
)

reviews_json <- toJSON(reviews_df, pretty = TRUE)

# Try to load .env if it exists (local dev), otherwise use environment vars (Docker)
if (file.exists(".env")) {
  message("Loading environment variables from .env")
  load_dot_env()
} else {
  # Docker will already have env vars set
  message("No .env file found, using environment variables")
}

# Connect to Amazon Bedrock
bedrock_client <- paws::bedrockruntime(
  config = list(
    region = "us-east-1"
  )
)

# Define the call_llm function
call_llm <- function(prompt) {
  # Add relevant details to the prompt
  prompt <- paste0(
    "You are a helpful assistant that analyzes reviews from the Glassdoor website. ",
    "Use the reviews included here in JSON format to answer the users questions: \n\n",
    reviews_json,
    "\n\n",
    prompt
  )

  request_body <- list(
    inferenceConfig = list(
      max_new_tokens = 1000
    ),
    messages = list(
      list(
        role = "user",
        content = list(
          list(
            text = prompt
          )
        )
      )
    )
  )

  response <- bedrock_client$invoke_model(
    body = toJSON(request_body, auto_unbox = TRUE),
    modelId = "amazon.nova-micro-v1:0",
    accept = "application/json",
    contentType = "application/json"
  )

  # Return the text response
  response_text <- fromJSON(rawToChar(response$body))
  print(response_text$output$message$content[1]$text)

  return(response_text$output$message$content[1]$text)
}

# Define UI for the app
ui <- fluidPage(
  # Set style
  tags$head(
    # Enable word wrap in llm output box
    tags$style("
      #llm_output {
        white-space: pre-wrap;
        word-wrap: break-word;
        word-break: normal;
        overflow-wrap: break-word;
        max-width: 100%;
        padding: 10px;
      }
    "
    ),
    # Make the "submit" button respond to Enter key
    tags$script(
      '$(document).ready(function() {
        $("#user_input").keypress(function(e) {
          if(e.which == 13) {
            $("#submit").click();
          }
        });
      });'
    )
  ),
  titlePanel("Basic Shiny App with Bedrock"),
  # Add introductory text
  fluidRow(
    column(12,
      HTML("
        <p>
          This is a basic Shiny app that uses Amazon Bedrock to generate responses to user input.
          The app has been provided with 500 reviews submitted to Glassdoor about working for Honeywell and will use
          those to answer questions (<a href='https://tinyurl.com/ms8fk7we' target='_blank'>data source</a>).

          Enter your instructions in the text box below and click 'Submit' to get the LLM response.
        </p>
      ")
    )
  ),


  # Input section at top
  fluidRow(
    column(12,
      textInput("user_input", "Enter Instructions:", "", width = '500px'),
      actionButton("submit", "Submit")
    )
  ),
  hr(),
  # Output section below
  fluidRow(
    column(12,
      h4("LLM Output:"),
      withSpinner(verbatimTextOutput("llm_output"))
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  llm_response <- eventReactive(input$submit, {
    # Call the call_llm function with user input
    call_llm(input$user_input)
  })

  output$llm_output <- renderText({
    llm_response()
  })
}

# Run the application
shinyApp(ui = ui, server = server)