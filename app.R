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

# Connect to Amazon Bedrock
bedrock_client <- paws::bedrockruntime(
  config = list(
    region = "us-east-1"
  )
)

# Define the call_llm function
call_llm <- function(prompt) {
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
  titlePanel("Basic Shiny App with call_llm"),

  sidebarLayout(
    sidebarPanel(
      textInput("user_input", "Enter your prompt:", ""),
      actionButton("submit", "Submit")
    ),

    mainPanel(
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