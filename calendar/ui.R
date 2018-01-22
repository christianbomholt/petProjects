## ui.R ##,
pacman::p_load(rhandsontable,shinydashboard, shiny, dygraphs)#highcharter
workdir <- getwd()



body <- dashboardBody(
  tabItems(
    tabItem(tabName = "All",
            fluidRow(
              column(width = 6,
              h3("Calendar"),
              rHandsontableOutput("hot"),
              
              br(),
              actionButton("saveButton", "Save"),
              verbatimTextOutput("nText")
              ),
              
              column(width = 6,
              h3("Visuals"),
              
                
              
              valueBoxOutput("valueBox"),
              # valueBoxOutput("sumBox"),
              
              
              # highchartOutput('mainplot')
              dygraphOutput('mainplot')
              )

            )
    )
    
  )
)
dashboardPage(
  dashboardHeader(title = "Calendar"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("All", tabName = "All", icon = icon("table")      ),
      menuItem(dateInput("dateSel", "Date:",value = Sys.Date(),
                         weekstart = 1)),
      menuItem(              numericInput("nDays", "Number of days in calendar", 6, min = NA, max = NA, step =1,width = NULL)),
      menuItem(dateRangeInput('dateRange',
                                                               label = 'Date range input: yyyy-mm-dd',
                                                               start = Sys.Date() - 10, end = Sys.Date() + 10
      ))
    )
  ),
  body
)

