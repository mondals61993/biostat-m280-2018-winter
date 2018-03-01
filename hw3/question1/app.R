library(ggplot2)
library(tidyr)
library(dplyr)
library(readr)
library(shiny)
library(DBI)
library(RSQLite)
library(rsconnect)

####################################################
# Question 1- LA City Employee Payroll             #
####################################################

##### Question 1: For efficiency of the Shiny app, you should first pre-process, 
##### pare down, tidy, and save the data, e.g., as a compressed RDS file, to be used in the app.

payroll_p <- readRDS('payroll_p.rds')

payroll_p <- payroll_p[order(-payroll_p$Total_Pay), ]

##### Question 2: Total payroll by LA City. Visualize the total LA City payroll of each year, 
#####with breakdown into base pay, overtime pay, and other pay.

#Refer to Shiny App- It is the tab called 'Total Pay by Year'. I have also referenced
#the question in the server and ui code in this R file. 

##### Question 3: Who earned most? Visualize the payroll information 
##### (total payment with breakdown into base pay, overtime pay, and other pay, Department, Job Title) 
##### of the top n highest paid LA City employees in a specific year. 
##### User specifies n (default 10) and year (default 2017).

#Refer to Shiny App- It is the tab called 'Top Earning Employees'. I have also reference 
#the question in the server and ui code in this R file. 

##### Question 4: Which departments earn most? Visualize the mean or median payroll, 
##### with breakdown into base pay, overtime pay, and other pay, of top n earning departments. 
##### User specifies n (default 5), year (default 2017), and method (mean or median, default median).

#Refer to Shiny App- It is the tab called 'Top Earning Departments'. I have also reference 
#the question in the server and ui code in this R file. 

#Below, I attach the datasets that I processed to utliize in my R Shiny code. 

#Datasets to be used in Question 4
payroll_des <- payroll_p %>% select(Department_Title, 
                                    Year, Total_Pay, 
                                    Base_Pay, Overtime_Pay, 
                                    Other_Pay) %>% 
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

payroll_dmean <- payroll_des %>% filter(Descriptive %in% c('Mean_Total','Mean_Base', 'Mean_Overtime', 
                                                           'Mean_Other')) %>%
  arrange(Year, Department_Title)
payroll_ddes <- payroll_des %>% filter(Descriptive %in% c('Median_Total','Median_Base', 'Median_Overtime', 
                                                          'Median_Other')) %>%
  bind_cols(payroll_dmean[,c('Descriptive', 'Value')]) %>%
  mutate(Descriptive = recode(Descriptive, 
                              Median_Total = 'Median Total Salary', 
                              Median_Base = 'Median Base Salary', 
                              Median_Overtime = 'Median Overtime Salary', 
                              Median_Other = 'Median Other Salary'), 
         Descriptive1 = recode(Descriptive1, 
                               Mean_Total = 'Mean Total Salary', 
                               Mean_Base = 'Mean Base Salary', 
                               Mean_Overtime = 'Mean Overtime Salary', 
                               Mean_Other = 'Mean Other Salary'))

##### Question 5: Which departments cost most? Visualize the total payroll, 
##### with breakdown into base pay, overtime pay, and other pay, of top n 
##### expensive departments. User specifies n (default 5) and year (default 2017).

#Refer to Shiny App- It is the tab called 'Total Cost Breakdown'. I have also reference 
#the question in the server and ui code in this R file. 

#Below, I attach the datasets that I processed to utliize in my R Shiny code. 

#Dataset to be used in question 5
payroll_cost <- payroll_p %>% 
  select(Department_Title, Year, Total_Pay, Base_Pay, Overtime_Pay, Other_Pay) %>% 
  group_by(Year, Department_Title) %>% summarize(Tot_Cost = sum(Total_Pay, na.rm = TRUE), 
                                                 Base_Cost = sum(Base_Pay, na.rm = TRUE), 
                                                 Over_Cost = sum(Overtime_Pay, na.rm = TRUE), 
                                                 Other_Cost = sum(Other_Pay, na.rm = TRUE)) %>% 
                                        gather(Descriptive, Value, -Year, -Department_Title) %>% 
                                        arrange(Year, Department_Title) %>%
                                        mutate(Descriptive = recode(Descriptive, 
                                                                    Tot_Cost = 'Total Cost', 
                                                                    Base_Cost = 'Base Cost', 
                                                                    Over_Cost = 'Overtime Cost', 
                                                                    Other_Cost = 'Other Cost'))
  

##### Question 6: Visualize any other information you are interested in.

#Visualization Question: How do mean total pay and mean base pay differ by department from 2012-2017?

#Below, I attach the datasets that I processed to utliize in my R Shiny code. 

#Datasets for Question 6
mean_yr <- payroll_p %>% 
  group_by(Department_Title, Year) %>%
  summarize(Mean_Total = mean(Total_Pay, na.rm = TRUE), 
            Mean_Base = mean(Base_Pay, na.rm = TRUE)) %>%
  gather(Descriptive, Value, -Year, -Department_Title) %>%
  arrange(Department_Title, Year) %>% 
  mutate(Descriptive = recode(Descriptive, 
                              Mean_Total = 'Mean Total Pay', 
                              Mean_Base = 'Mean Base Pay'))
  
  
#####R SHINY CODE#####

server <- function(input, output){
  #Question 2
  output$PayPlot <- renderPlot({
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
  data <- payroll_ddes

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
    data <- payroll_cost
    data <- data[data$Year == input$year3,
                 c('Department_Title', 'Descriptive', 'Value')]
    data <- data %>% group_by(Department_Title)%>% mutate(max_r = Value[1]) %>% 
      arrange(desc(max_r)) %>% select(Department_Title, Descriptive, Value)
    data <- data[1:(4*input$n3),]
    data
  }))
  
  #Question 6
  output$dept_b <- renderPlot({
    ggplot(data = mean_yr[mean_yr$Department_Title == input$Department, ])+
      geom_bar(mapping = aes(x = Year, y = Value, fill = Descriptive), stat = 'identity', 
               position = 'dodge')+
      scale_x_continuous(breaks = unique(mean_yr$Year))
  })
  
}

ui <- navbarPage(
  title = 'LA City Employee Payroll App',
  
  #Question 2
  tabPanel(
   'Total Pay by Year',
    sidebarLayout(
    sidebarPanel(
      selectInput('year', 'Year:', 
                  choices = sort(unique(payroll_p$Year))),
      selectInput('payment', 'Type of Payment:', 
                  choices = list(
                    'Total Pay' = c('Total_Pay'),
                    'Base Pay'= c('Base_Pay'), 
                    'Overtime Pay' = c('Overtime_Pay'),
                    'Other Pay' = c('Other_Pay')
                  ))
    ),
    
    mainPanel(
      plotOutput('PayPlot')
    )
  )
),
  
  #Question 3
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

  #Question 4
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

  #Question 5
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
      ),
  
  #Question 6
  tabPanel(
    'Average Salary Statistics by Department', 
    selectInput('Department', 'Department:', 
                choices = unique(mean_yr$Department_Title), 
                selected = 'Aging')
    ,
    mainPanel(
      plotOutput('dept_b')
    )
  )
)

shinyApp(ui = ui, server = server)


##### Please refer to hw3.R for the answers to Question 2
