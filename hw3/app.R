library(readr)
library(dplyr)
library(shiny)
library(tidyverse)

''' #1 For efficiency of the Shiny app, you should first pre-process, 
pare down, tidy, and save the data, e.g., as a compressed RDS file, to be used in the app.'''

payroll<-read_csv('/home/m280-data/la_payroll/LA_City_Employee_Payroll.csv', col_names = TRUE)


payroll_p<-payroll %>% select(Year, `Row ID`,`Department Title`, `Job Class Title`, `Projected Annual Salary`, 
                              `Total Payments`, `Base Pay`, `Overtime Pay`, `Other Pay (Payroll Explorer)`)
names(payroll_p)<-c('Year', 'Row ID','Department_Title','Job_Class_Title' ,'Proj_An_Sal', 'Total_Pay', 'Base_Pay', 
                    'Overtime_Pay', 'Other_Pay')

payroll_p<-payroll_p %>% mutate(Total_Pay = as.numeric(gsub('\\$|,', '', Total_Pay)),
                                Base_Pay =  as.numeric(gsub('\\$|,', '', Base_Pay)),
                                Overtime_Pay = as.numeric(gsub('\\$|,', '', Overtime_Pay)),
                                Other_Pay = as.numeric(gsub('\\$|,', '', Other_Pay)))
saveRDS(payroll_p, 'payroll_p.rds', compress = TRUE)

payroll_p<-readRDS('payroll_p.rds')

''' #2 Total payroll by LA City. Visualize the total LA City payroll of each year, 
with breakdown into base pay, overtime pay, and other pay.'''

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

''' #3 Who earned most? Visualize the payroll information (total payment with breakdown into base pay, 
overtime pay, and other pay, Department, Job Title)  of the top n highest paid LA City employees 
in a specific year. User specifies n (default 10) and year (default 2017). '''

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
                        c(1:dim(payroll_p)[1]), 
                        value =  10)
    ))
  ,
  # Create a new row for the table.
  fluidRow(
    DT::dataTableOutput("table")
  )
)

shinyApp(server = server2, ui = ui2)

'''#4. Which departments earn most? Visualize the mean or median payroll, 
with breakdown into base pay, overtime pay, and other pay, of top n earning departments. 
User specifies n (default 5), year (default 2017), and method (mean or median, default median).'''

#Variables needed are: department title, base pay, overtime pay, and other pay

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

server3<-function(input, output) {
  
  data<-payroll_ddes
  # Filter data based on selections
  
  output$table_dept <- DT::renderDataTable(DT::datatable({
    
    if (input$Method == 'Value') {
      data <- payroll_ddes[payroll_ddes$Year == input$Year,
                           c('Department_Title', 'Descriptive', 'Value')]
      data <- data %>% group_by(Department_Title)%>% mutate(max_p = Value[1]) %>% 
        arrange(desc(max_p)) %>% select(Department_Title, Descriptive, Value)}
    data <- data[1:(4*input$n),]
    data
    
    if (input$Method == 'Value1') {
      data <- payroll_ddes[payroll_ddes$Year == input$Year,
                           c('Department_Title', 'Descriptive1', 'Value1')]
      data <- data %>% group_by(Department_Title) %>% mutate(max_p = Value1[1]) %>%
        arrange(desc(max_p))%>%select(Department_Title, Descriptive1, Value1)
    }
    data <- data[1:(4*input$n),]
    data
  }))
}

ui3<-fluidPage(
  titlePanel("Top Earning Departments"),
  
  # Create a new Row in the UI for inputs
  fluidRow(
    column(4,
           selectInput("Year",
                       "Year:",
                       c(unique(payroll_ddes$Year)),
                       selected = 2017))
    ,
    column(4,
           selectInput("Method",
                       "Method:",
                       list('Median' = 'Value', 
                            'Mean' = 'Value1'),
                       selected = 'Median'))
    ,
    column(4,
           numericInput("n",
                        "Number of Departments:",
                        c(length(unique(payroll_ddes$Department_Title))), 
                        value =  5)
    ))
  ,
  # Create a new row for the table.
  fluidRow(
    DT::dataTableOutput("table_dept")
  )
)

shinyApp(server = server3, ui = ui3)

'''#5 Which departments cost most? Visualize the total payroll, with breakdown into base pay, 
overtime pay, and other pay, of top n expensive departments. 
User specifies n (default 5) and year (default 2017).'''

payroll_cost<-payroll_p %>% select(Department_Title, Year, Total_Pay, Base_Pay, Overtime_Pay, Other_Pay) %>% 
  group_by(Year, Department_Title) %>% summarize(Tot_Cost = sum(Total_Pay, na.rm = TRUE), 
                                                 Base_Cost = sum(Base_Pay, na.rm = TRUE), 
                                                 Over_Cost = sum(Overtime_Pay, na.rm = TRUE), 
                                                 Other_Cost = sum(Other_Pay, na.rm = TRUE)) %>% 
  gather(Descriptive, Value, -Year, -Department_Title) %>% arrange(Year, Department_Title) 



server4<-function(input, output) {
  
  # Filter data based on selections
  output$table_cost <- DT::renderDataTable(DT::datatable({
    data<- payroll_cost
    data <- data[data$Year == input$year,
                 c('Department_Title', 'Descriptive', 'Value')]
    data <- data %>% group_by(Department_Title)%>% mutate(max_r = Value[1]) %>% 
      arrange(desc(max_r)) %>% select(Department_Title, Descriptive, Value)
    data <- data[1:(4*input$n),]
    data
  }))
  
  
}


ui4<-fluidPage(
  titlePanel('Total Cost Breakdown'),
  sidebarLayout(
    sidebarPanel(
      selectInput('year', 'Year:', 
                  choices = unique(payroll_cost$Year), 
                  selected = 2017),
      numericInput('n', 'Number of Top Earning Departments:', 
                   1:length(unique(payroll_cost$Department_Title)), 
                   value = 5)
    ),
    
    fluidRow(
      DT::dataTableOutput("table_cost")
    )
  )
)

shinyApp(server = server4, ui = ui4)