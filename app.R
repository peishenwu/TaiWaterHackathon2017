#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(tidyverse)
library(shiny)
library(rCharts)

read_csv("shiny_data.csv") %>% filter(yyyymm_key == "201610") -> target  #initialize
begin = 2
end = 8
target %>% arrange(desc(actual_predicted_ratio)) %>% mutate(rank = 1:nrow(target)) -> target
use_target <- target[begin:end,] 
use_list <- paste("'",paste(use_target$COUNTY,
                            use_target$TOWN,
                            use_target$VILLAGE,"-",
                            use_target$CODE1),"' = '",
                  use_target$CODE1,"'",sep="") %>% 
  paste(collapse=",") %>% paste("list(",.,")",sep="") %>% 
  parse(text=.) %>% eval


# Define UI for application that draws a histogram
ui <- fluidPage(
   
  titlePanel("用水異常地區"),
  #hr(),
  fluidRow(column(3,
                  # sliderInput("index",
                  #             "異常程度排名:",
                  #             min = 1,
                  #             max = nrow(target),
                  #             value = 1)
                  # numericInput("index", label = h3("異常程度排名"), value = 1,
                  #              min = 1,
                  #              max = nrow(target))
                  actionButton("taiwan", "全台View"),
                  sliderInput("index", label = h3("異常程度排名"), min = 1, 
                              max =  nrow(target), value = c(2, 8)),
                  selectInput("select", label = h3("異常一級發佈區"), 
                              choices = use_list, 
                              selected = 1),
                  sliderInput("cluster", label = h3("kmeans分群"), min = 1, 
                              max =  5, value = c(1, 5))
                  ),
           column(6,
                  chartOutput('map', 'leaflet'))),
  fluidRow(
    column(9,
           dataTableOutput('viewing'))
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
   
  #initialize
  values <- reactiveValues(map_lat = 23.973875, 
                           map_lon = 120.982024,
                           zoom = 7)
  
  observe({
    use_target <- target %>% 
      arrange(desc(actual_predicted_ratio)) %>% mutate(rank = 1:nrow(target)) %>% 
      filter(cluster >= input$cluster[1], cluster <= input$cluster[2],
                                    rank <= input$index[2], rank >= input$index[1])
    
    use_list <- paste("'",paste(use_target$COUNTY,
                                use_target$TOWN,
                                use_target$VILLAGE,"-",
                                use_target$CODE1),"' = '",
                      use_target$CODE1,"'",sep="") %>% 
      paste(collapse=",") %>% paste("list(",.,")",sep="") %>% 
      parse(text=.) %>% eval
    ##
    updateSelectInput(session, "select", choices = use_list)
    values$df <- use_target
  })
  
  # observeEvent(input$index,{
  #   values$from_update <- F
  # })
  # 
  # observeEvent(input$cluster,{
  #   values$from_update <- F
  # })
  
  ##
  observeEvent(input$select,{
    values$map_lat <- target$lat[target$CODE1 == input$select]
    values$map_lon <- target$lon[target$CODE1 == input$select]
    values$zoom <- 14
  })
  
  observeEvent(input$taiwan,{
    values$map_lat <- 23.973875
    values$map_lon <- 120.982024
    values$zoom <- 7
  })
  
  ##
  output$map <- renderMap({
    
    map3 <- Leaflet$new()
    #map3$tileLayer(provide='Esri.WorldTopoMap')
    # use_target <- target[input$index[1]:input$index[2],] %>% filter(cluster >= input$cluster[1], 
    #                                                                 cluster <= input$cluster[2])
    # 
    #23.973875°N 120.982024°E
    map3$setView(c(values$map_lat,
                   values$map_lon),
                 zoom = values$zoom)
    # map3$setView(c(target$lat[target$CODE1 == input$select],
    #                target$lon[target$CODE1 == input$select]),
    #              zoom = 14)
    
    ##
    for(i in 1:nrow(values$df)){
      map3$marker(c(values$df$lat[i], values$df$lon[i]),
                  bindPopup = paste0(values$df$TOWN[i]," ",values$df$VILLAGE[i]," ",values$df$CODE1[i],
                                     "<br> 實際用水(度): ",round(values$df$monthly_water_usage[i], digits = 3),
                                     "<br> 預期用水(度): ",round(values$df$predicted_water_usage[i], digits = 3),
                                     "<br> 落差倍數: ",round(values$df$actual_predicted_ratio[i], digits = 3),
                                     "<br> 異常排名: ",values$df$rank[i],
                                     "<br> kmeans分群: ",values$df$cluster[i],
                                     "<hr>",
                                     " 總人口數:",values$df$people_total[i],
                                     " 戶籍數:",values$df$household_no[i],
                                     "<br> 工廠數:",values$df$factory_count[i],
                                     "<br> 便利超商:",values$df$store_count[i],
                                     "<br> 大專院校:",values$df$school_count[i],
                                     " 醫院數:",values$df$hospital_count[i]))  
      
      ##
      
    }#end for
    
    #map3$fullScreen(TRUE)
    return(map3)
  })
  
  output$viewing <- renderDataTable(values$df %>% 
                                      mutate(ratio = monthly_water_usage/predicted_water_usage) %>% 
                                      select(rank, ratio, cluster, COUNTY, TOWN, VILLAGE, 
                                             monthly_water_usage,
                                             predicted_water_usage,
                                             CODE1, 
                                             lon, 
                                             lat,
                                             people_total,
                                             household_no,
                                             factory_count,
                                             store_count,
                                             school_count,
                                             hospital_count))
  
}

# Run the application 
shinyApp(ui = ui, server = server)

