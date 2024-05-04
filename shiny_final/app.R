# Load libraries
library(shiny)
library(tidyverse)

# Define UI for application that draws a histogram
ui <- fluidPage(
  # Title
  titlePanel("PSY 8721 Shiny App - Final"),
  # Make sidebar with select panel 
  sidebarLayout(
    sidebarPanel(
      selectInput("gender", "Choose gender",
                  selected = "Male",
                  choices = c("Male", "Female")),
      selectInput("marital", "Choose Marital Status",
                  selected = "Single",
                  choices = c("Single", "Married", "Divorced/Widowed")),
      selectInput("permanent", "Choose Job Status",
                  selected = "Permanent",
                  choices = c("Permanent", "Temporary")),
      selectInput("error_band", "Choose Error band",
                  selected = "Display Error Band",
                  choices = c("Display Error Band", "Suppress Error Band"))),
    # Display plot
    mainPanel(
      plotOutput("plot"))
  ) 
)

server = function(input, output){
  # Input: Load RDS file making rmd file
  shinyapp_data <- readRDS("final_data.rds")
  # Output: By using the if function, when users select gender, app shows results.
  output$plot <- renderPlot({
    if(input$gender == c("Male") | input$gender == c("Female")) { 
      shinyapp_data <- shinyapp_data %>% 
        filter(gender == input$gender)
    } 
    # By using the if function, when users select marital status, app shows results.
    if(input$marital == c("Single") | input$marital == c("Married") | input$marital == c("Divorced/Widowed")) { 
      shinyapp_data <- shinyapp_data %>% 
        filter(marital == input$marital)
    } 
    # By using the if function, when users select job status, app shows results.
    if(input$permanent == c("Permanent") | input$permanent == c("Temporary")) { 
      shinyapp_data <- shinyapp_data %>% 
        filter(permanent == input$permanent)
    } 
    # By using the if and else function, when users select Suppress Error Band, app doesn't show the shaded error band around the regression line.
    if(input$error_band == "Display Error Band") {
      shinyapp_data %>% 
        ggplot(aes(x = clan_culture, y = job_satis)) +
        geom_point() + 
        geom_smooth(method = "lm", color = "purple", se = TRUE) + 
        labs(title = "The Scatter Plot of Clan Culture & Job Satisfaction",
             x = "Average of Clan Culture", 
             y = "Average of Job Satisfaction")
    } else {
      shinyapp_data %>% 
        ggplot(aes(x = clan_culture, y = job_satis)) +
        geom_point() + 
        geom_smooth(method = "lm", color = "purple", se = FALSE) + 
        labs(title = "The Scatter Plot of Clan Culture & Job Satisfaction",
        x = "Average of Clan Culture", 
        y = "Average of Job Satisfaction")}})}

# Run the application 
shinyApp(ui = ui, server = server)
