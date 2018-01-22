# setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# shiny::runGitHub("rhandsontable", "jrowen", subdir = "inst/examples/rhandsontable_corr")
# n = 400
# dateV <- seq(from=as.Date("2017-09-01"),by=1,length.out = n)
# df <- data.frame(Date=dateV, day = weekdays(dateV),
#                  Hours = rep(0,n), comments = rep("",n), arrival = rep(8.01, n), leave = rep(16.01,n))#, status = rep(F,n))
# df$comments <- as.character(df$comments)
# save(df,file="data/statusdf.rdata")

JS = "function (instance, td, row, col, prop, value, cellProperties) {
      Handsontable.renderers.TextRenderer.apply(this, arguments);

      if (instance.params && instance.params.myindex == row) {
        td.style.background = 'lightblue';
      } else if (value == 'Saturday') {
        td.style.background = 'steelblue';
      } else if (value == 'Sunday') {
        td.style.background = 'steelblue';
      }
  }"

datapath <- 'data/statusdf.rdata'

load(datapath)
save(df,file='data/backup.rdata')

# dyBarChart <- function(dygraph) {
#   dyPlotter(dygraph = dygraph,
#             name = "BarChart",
#             path = system.file("plotters/barchart.js",
#                                package = "dygraphs"))
# }

pacman::p_load(rhandsontable,shiny,DT,data.table,dplyr) #highcharter
shinyServer(function(input, output,session) {

  dataInput <- reactive({
    load(datapath)

    if(is.numeric(input$nDays)){
      n=input$nDays

    } else {
      n=7
    }

    selectedDates <- seq(from=input$dateSel-3,by=1,length.out = n)
    dt<-df[df$Date %in% selectedDates, ]
    dt$comments <- as.character(dt$comments)
    dt
    })

  output$hot <- renderRHandsontable({
    calendar = dataInput()

    if (!is.null(calendar)) {
      myIndex <- which(calendar$Date %in% as.Date(input$dateSel))-1

      hot = rhandsontable(calendar, myindex = myIndex, rowHeaders = NULL,
                          width = 600, stretchH = "all",
                          selectCallback = TRUE) %>%
        hot_cols(renderer = JS)
      hot
    }
  })


  ntext <- eventReactive(input$saveButton, {

    if(!is.null(input$hot)){

      load(datapath)
      df$comments <- as.character(df$comments)
      dt = setDT(hot_to_r(input$hot))
      dt$comments <- as.character(dt$comments)
      df[df$Date %in% dt$Date, ] <- dt
      df$comments <- as.character(df$comments)

      save(df,file=datapath)
    }
  })
  output$nText <- renderText({
      ntext()
      print('Successfully saved!')
   })
  observeEvent(eventExpr = input$saveButton, {
  # output$mainplot <- renderHighchart({
  #   load(datapath)
  #   require(viridisLite)
  #   n <- 4
  #   stops <- data.frame(q = 0:n/n,
  #                       c = substring(viridis(n + 1), 0, 7),
  #                       stringsAsFactors = FALSE)
  #   stops <- list_parse2(stops)
  #   hchart(df %>%
  #            subset(Date>=input$dateRange[1]) %>%
  #            subset(Date<=input$dateRange[2]), "column", hcaes(x = Date, y = Hours, color=Hours),
  #          colorByPoint = TRUE, name = "Work") %>%
  #     # hc_colors(.,RColorBrewer::brewer.pal(11,"RdYlGn")) %>%
  #     hc_colorAxis(stops = stops, max = 10)
  #   })
  
    output$mainplot <- renderDygraph({
      
      df <-df %>%
        subset(Date>=input$dateRange[1]) %>%
        subset(Date<=input$dateRange[2]) %>% 
        select(Date,Hours) %>% `rownames<-`(.[,1]) %>% select(-Date)
      
      print(df)
      
      dygraph(df) %>%
        dyRangeSelector() #%>%
        # dyBarChart()
      
      })
    
  output$valueBox <- renderValueBox({
    load(datapath)
    valueBox(
      mean(df$Hours[df$Hours>0]) %>% round(.,3), "Avg. Hours", icon = icon("calendar"),
      color = "green"
    )
  })

  output$sumBox <- renderValueBox({
    load(datapath)
    df <-   df %>% dplyr::filter(month(Date)==month(Sys.Date())&year(Date)==year(Sys.Date()))

    valueBox(
      sum(df$Hours[df$Hours>0]) %>% round(.,3),
      paste("Total hours ", lubridate::month(Sys.Date(), label=TRUE,abbr =FALSE) %>% as.character()), icon = icon("area-chart"),
      color = "light-blue"
    )
  })


  })

})
