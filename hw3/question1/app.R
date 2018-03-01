library(ggplot2)
library(tidyr)
library(dplyr)
library(readr)
library(shiny)
library(DBI)
library(RSQLite)
library(rsconnect)

#1 For efficiency of the Shiny app, you should first pre-process, 
#pare down, tidy, and save the data, e.g., as a compressed RDS file, to be used in the app.'''

payroll <- read_csv('/home/m280-data/la_payroll/LA_City_Employee_Payroll.csv', col_names = TRUE)


payroll_p <- payroll %>% select(Year, `Row ID`,`Department Title`, `Job Class Title`, 
                                `Projected Annual Salary`, `Total Payments`, `Base Pay`, 
                                `Overtime Pay`, `Other Pay (Payroll Explorer)`)
names(payroll_p) <- c('Year', 'Row ID', 'Department_Title', 'Job_Class_Title' ,
                      'Proj_An_Sal', 'Total_Pay', 'Base_Pay', 
                      'Overtime_Pay', 'Other_Pay')

payroll_p <-payroll_p %>% mutate(Total_Pay = as.numeric(gsub('\\$|,', '', Total_Pay)),
                                 Base_Pay =  as.numeric(gsub('\\$|,', '', Base_Pay)),
                                 Overtime_Pay = as.numeric(gsub('\\$|,', '', Overtime_Pay)),
                                 Other_Pay = as.numeric(gsub('\\$|,', '', Other_Pay)))
saveRDS(payroll_p, '/home/mondals/biostat-m280-2018-winter/hw3/question1/payroll_p.rds', compress = TRUE)

payroll_p<-readRDS('payroll_p.rds')

payroll_p<-payroll_p[order(-payroll_p$Total_Pay),]

## Question 2-5 

## These are the datasets that are to be used in Question 4
payroll_des<-payroll_p %>% select(Department_Title, Year, Total_Pay, Base_Pay, Overtime_Pay, Other_Pay) %>% 
  group_by(Year, Department_Title) %>% summarize(Mean_Total = mean(Total_Pay),
                                                 Median_Total = median(Total_Pay),
                                                 Mean_Base = mean(Base_Pay), 
                                                 Median_Base = median(Base_Pay),
                                                 Mean_Overtime = mean(Overtime_Pay), 
                                                 Median_Overtime = median(Overtime_Pay), 
                                                 Mean_Other = mean(Other_Pay), 
                                                 Median_Other = median(Other_Pay)) %>% 
                                      gather(Descriptive, Value, -Year, -Department_Title) %>%
                                      arrange(Year, Department_Title)

payroll_dmean<-payroll_des %>% filter(Descriptive %in% c('Mean_Total','Mean_Base', 'Mean_Overtime', 
                                                         'Mean_Other')) %>%
                                arrange(Year, Department_Title)
payroll_ddes<-payroll_des %>% filter(Descriptive %in% c('Median_Total','Median_Base', 'Median_Overtime', 
                                                        'Median_Other')) %>%
                              bind_cols(payroll_dmean[,c('Descriptive', 'Value')]) 

#Dataset to be used in question 5
payroll_cost<-payroll_p %>% 
  select(Department_Title, Year, Total_Pay, Base_Pay, Overtime_Pay, Other_Pay) %>% 
  group_by(Year, Department_Title) %>% summarize(Tot_Cost = sum(Total_Pay, na.rm = TRUE), 
                                                 Base_Cost = sum(Base_Pay, na.rm = TRUE), 
                                                 Over_Cost = sum(Overtime_Pay, na.rm = TRUE), 
                                                 Other_Cost = sum(Other_Pay, na.rm = TRUE)) %>% 
                                        gather(Descriptive, Value, -Year, -Department_Title) %>% 
                                        arrange(Year, Department_Title) 

server<-function(input, output){
  #Question 2
  output$PayPlot<-renderPlot({
    hist(as.numeric(unlist(payroll_p[payroll_p$Year == input$year, input$payment])),
         col = "#75AADB", border = 'white',
         main = input$year,
         xlab = "Year",
         ylab = "Pay")
  })
  
  #Question 3
  output$table <- DT::renderDataTable(DT::datatable({
    data <- payroll_p[payroll_p$Year == input$Year,
                      c('Department_Title', 'Job_Class_Title','Base_Pay', 
                        'Overtime_Pay', 'Other_Pay', 'Total_Pay','Year')][c(1:input$n),]
    data
  }))
  
  #Question 4
  data<-payroll_ddes

  output$table_dept <- DT::renderDataTable(DT::datatable({
    
    if (input$Method == 'Value') {
      data <- payroll_ddes[payroll_ddes$Year == input$Year2,
                           c('Department_Title', 'Descriptive', 'Value')]
      data <- data %>% group_by(Department_Title)%>% mutate(max_p = Value[1]) %>% 
        arrange(desc(max_p)) %>% select(Department_Title, Descriptive, Value)}
    data <- data[1:(4*input$n2),]
    data
    
    if (input$Method == 'Value1') {
      data <- payroll_ddes[payroll_ddes$Year == input$Year2,
                           c('Department_Title', 'Descriptive1', 'Value1')]
      data <- data %>% group_by(Department_Title) %>% mutate(max_p = Value1[1]) %>%
        arrange(desc(max_p))%>%select(Department_Title, Descriptive1, Value1)
    }
    data <- data[1:(4*input$n2),]
    data
  }))
  
  #Question 5
  output$table_cost <- DT::renderDataTable(DT::datatable({
    data<- payroll_cost
    data <- data[data$Year == input$year3,
                 c('Department_Title', 'Descriptive', 'Value')]
    data <- data %>% group_by(Department_Title)%>% mutate(max_r = Value[1]) %>% 
      arrange(desc(max_r)) %>% select(Department_Title, Descriptive, Value)
    data <- data[1:(4*input$n3),]
    data
  }))
  
  #Question 6
  
}

ui<-navbarPage(
  title = 'LA City Employee Payroll App',

  tabPanel(
   'Total Pay by Year',
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
),

  tabPanel(
    "Top Earning Employees",

    column(4,
           selectInput("Year",
                       "Year:",
                      c(unique(payroll_p$Year)),
                       selected = 2017))
    ,
    column(4,
           numericInput("n",
                        "Number of Employees:",
                        min = 1, 
                        max = c(dim(payroll_p)[1]), 
                        value =  10))
    ,
  # Create a new row for the table.
  fluidRow(
    DT::dataTableOutput("table")
  )
  ),

  tabPanel(
    "Top Earning Departments",
    
    # Create a new Row in the UI for inputs
      column(4,
             selectInput("Year2",
                         "Year:",
                         choices = unique(payroll_ddes$Year),
                         selected = 2017))
      ,
      column(4,
             selectInput("Method",
                         "Method:",
                         choices =  list('Median' = 'Value', 
                                         'Mean' = 'Value1'),
                         selected = 'Median'))
      ,
      column(4,
             numericInput("n2",
                          "Number of Departments:",
                          min = 1, 
                          max = length(unique(payroll_ddes$Department_Title)), 
                          value =  5)),
    # Create a new row for the table.
    fluidRow(
      DT::dataTableOutput("table_dept")
    )
    ),

  tabPanel(
      'Total Cost Breakdown',
        selectInput('year3', 'Year:', 
                choices = unique(payroll_cost$Year), 
                selected = 2017),
        numericInput('n3', 'Number of Top Earning Departments:', 
                 min = 1,
                 max = length(unique(payroll_cost$Department_Title)), 
                 value = 5)
                  ,
        fluidRow(
          DT::dataTableOutput("table_cost")
        )
      )
)

shinyApp(ui = ui, server = server)




