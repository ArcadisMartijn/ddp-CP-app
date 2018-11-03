#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Loan calculator"),
  
  # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            helpText("Provide all the input for the calculation"),
            selectInput("type",
                        label = "Choose the loan type",
                        choices = c("Linear",
                                    "Annuities"),
                        selected = "Linear"),
            sliderInput("period",
                        label = "Enter the duration of the loan",
                        min = 5, max = 50, value = 30),
            numericInput("interest",
                         label = "Enter the interest rate [% / Year]",
                         min = 0.01, max = 10, value = 2.00),
            hr(),
            hr(),
            hr(),
            numericInput("loan",
                         label = "Enter the total loan",
                         min = 1000, max = 10000000, value = 200000, width = "50%"),
            numericInput("year",
                         label = "Override for the starting year",
                         min = 0, value = format(Sys.Date(), "%Y"), width = "50%"),
            width = 3
        ),
    
# Show a plot of the generated distribution
        mainPanel(tabsetPanel(
            tabPanel("Overview",
                     plotOutput("plotDebt"),
                     plotOutput("plotPay"),
                     textOutput("totalcost"),
                     textOutput("partition")
            ),
            tabPanel("Table",
                     tableOutput("table")
            )
        )
))))