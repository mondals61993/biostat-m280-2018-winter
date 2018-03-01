library(ggplot2)
library(dplyr)
library(readr)
library(shiny)
library(DBI)
library(RSQLite)
library(rsconnect)

##Question 1##

payroll_p<-readRDS('payroll_p.rds')

#2 Total payroll by LA City. Visualize the total LA City payroll of each year, 
#with breakdown into base pay, overtime pay, and other pay.

server<-function(input, output){
  output$PayPlot<-renderPlot({
    hist(as.numeric(unlist(payroll_p[payroll_p$Year == input$year, input$payment])),
         col = "#75AADB", border = 'white',
         main = input$year,
         xlab = "Year",
         ylab = "Pay")
  })
}

ui<-fluidPage(
  titlePanel('Total Pay by Year'),
  sidebarLayout(
    sidebarPanel(
      selectInput('year', 'Year:', 
                  choices = unique(payroll_p$Year)),
      selectInput('payment', 'Type of Payment:', 
                  choices = names(payroll_p)[c(6,7,8,9)])
    ),
    
    mainPanel(
      plotOutput('PayPlot')
    )
  )
)

shinyApp(ui = ui, server = server)


###3 Who earned most? Visualize the payroll information (total payment with breakdown into base pay, 
##overtime pay, and other pay, Department, Job Title)  of the top n highest paid LA City employees 
##in a specific year. User specifies n (default 10) and year (default 2017). 

payroll_p<-payroll_p[order(-payroll_p$Total_Pay),]

server2<-function(input, output) {
  
  # Filter data based on selections
  output$table <- DT::renderDataTable(DT::datatable({
    data <- payroll_p[payroll_p$Year == input$Year,
                      c('Department_Title', 'Job_Class_Title','Base_Pay', 
                        'Overtime_Pay', 'Other_Pay', 'Total_Pay','Year')][c(1:input$n),]
    data
  }))
  
  
}

ui2<-fluidPage(
  titlePanel("Top Earning Employees"),
  
  # Create a new Row in the UI for inputs
  fluidRow(
    column(4,
           selectInput("Year",
                       "Year:",
                       c(unique(payroll_p$Year)),
                       selected = 2017))
    ,
    column(4,
           numericInput("n",
                        "Number of Employees:",
                        c(dim(payroll_p)[1]), 
                        value =  10)
    ))
  ,
  # Create a new row for the table.
  fluidRow(
    DT::dataTableOutput("table")
  )
)

shinyApp(server = server2, ui = ui2)
