library(shiny)
library(paws)
library(jsonlite)
library(dotenv)

# Try to load .env if it exists (local dev), otherwise use environment vars (Docker)
if (file.exists(".env")) {
  load_dot_env()
} else {
  # Docker will already have env vars set
  message("No .env file found, using environment variables")
}

# Specify the application port
options(shiny.host = "0.0.0.0")
options(shiny.port = 80)

# Download Data from Kaggle if needed
if (file.exists("honeywell_reviews") == FALSE) {
  system2("curl", args = c(
    "-L", "-o", 'honeywell_reviews.zip',
    "https://www.kaggle.com/api/v1/datasets/download/dhirajnimbalkar/topicmodellinghoneywellglassdoorreviews"
  ))

  # Unzip and remove the .zip file
  unzip('honeywell_reviews.zip', exdir = "honeywell_reviews")
  file.remove('honeywell_reviews.zip')
}

# Load 500 rows of data, remove first column
reviews_df <- head(read.csv("honeywell_reviews/glassdoortest1.csv"), 500)[-1]

# Clean the text to prepare for LLM in JSON format
reviews_df[c("title", "pros", "cons")] <- lapply(
  reviews_df[c("title", "pros", "cons")],
  function(x) iconv(x, "ASCII", "UTF-8", sub = "")
)

reviews_json <- toJSON(reviews_df, pretty = TRUE)

# Connect to Amazon Bedrock
bedrock_client <- paws::bedrockruntime(
  config = list(
    region = "us-east-1"
  )
)

# Define the call_llm function
call_llm <- function(prompt) {
  # Add relevant deatils to the prompt
  prompt <- paste0(
    "You are a helpful assistant that analyzes reviews from the Glassdoor website. ",
    "Use the reviews included here in JSON format to answer the users questions: \n\n",
    reviews_json,
    "\n\n",
    prompt
  )


  request_body <- list(
    anthropic_version = "bedrock-2023-05-31",
    max_tokens = 1000,
    messages = list(
      list(
        role = "user",
        content = prompt
      )
    ),
    temperature = 0.7
  )

  response <- bedrock_client$invoke_model(
    body = toJSON(request_body, auto_unbox = TRUE),
    modelId = "anthropic.claude-3-sonnet-20240229-v1:0",
  )

  # Return the text response
  response_text <- fromJSON(rawToChar(response$body))
  return(response_text$content$text)
}

# Define UI for the app
ui <- fluidPage(
  titlePanel("Basic Shiny App with Bedrock"),

  # Input section at top
  fluidRow(
    column(12,
      textInput("user_input", "Enter your prompt:", ""),
      actionButton("submit", "Submit")
    )
  ),
  hr(),
  # Output section below
  fluidRow(
    column(12,
      h4("LLM Output:"),
      verbatimTextOutput("llm_output")
    )
  )
)

# Define server logic
server <- function(input, output) {

  observeEvent(input$submit, {
    # Call the call_llm function with user input
    output_text <- call_llm(input$user_input)

    # Display the output
    output$llm_output <- renderText({
      output_text
    })
  })
}

# Run the application
shinyApp(ui = ui, server = server)