#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(shinythemes)
library(h2o)
library(rgdal)
library(ggplot2)

#import processed crime dataset
nibrs <- read.csv("nibrs.csv", header=TRUE)

#import county json
vacounties <- readOGR("vacounties.json")
vacounties$NAME <- as.character(vacounties$NAME)
vacounties$NAME[vacounties$LSAD == 'city'] <- paste(vacounties$NAME[vacounties$LSAD == 'city'], 'City')

#obtain list of counties
county <- vacounties$NAME

#obtain list of offense types
offenses <- unique(nibrs$offense_category_name)
offenses <- sort(offenses)

h2o.init()
#Change the line below to the path of your project directory containing the "GBM_model" file
model_path <- "D:/Practicum"
model_path <- paste0(model_path, "/GBM_model")
saved_model <- h2o.loadModel(model_path)
saved_model

# Define UI for project
ui <- fluidPage(
    
    # Change theme to lumen for aesthetic purposes
    theme = shinytheme("lumen"),
    
    # Application title
    titlePanel("Crime Viewer"),
    
    tabsetPanel(type="tabs",
                
                tabPanel("Predictions Map", fluid = TRUE,
                         sidebarLayout(
                             sidebarPanel(
                                 # Input clarifying text
                                 helpText("Input model parameters:"),
                                 
                                 # Create a drop down to set the month
                                 selectInput("month", label = "Month:",
                                             choices = list("January"=1, "February"=2, "March"=3, "April"=4, "May"=5, "June"=6,
                                                            "July"=7, "August"=8, "September"=9, "October"=10, "November"=11, "December"=12), 
                                             selected = "January"),
                                 
                                 # Create a drop down to set the day
                                 selectInput("day", label = "Day:", choices = as.list(1:31), selected = 1),
                                 
                                 # Create a drop down to set the weekday
                                 selectInput("weekday", label = "Weekday:", 
                                             choices = list("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"), 
                                             selected = "Sunday"),
                                 
                                 # Create a drop down to set the hour
                                 selectInput("incident_hour", label = "Hour:", choices = as.list(0:23), selected = 6),
                                 
                                 # Create a numeric input to set the number of officers
                                 numericInput("total_officers", label = "Number of officers:", value = 30),
                                 
                                 # Create a numeric input to set the population
                                 numericInput("population", label = "Population:", value = 100000),
                                 
                                 # Create a numeric input to set the median home value
                                 numericInput("median_house_price", label = "Median Home Value ($):", value = 200000),
                                 
                                 # Create a numeric input to set the employment percentage
                                 numericInput("employment", label = "Employment (%):", value = 55),
                                 
                                 actionButton("pred_update", "Update")
                                 
                             ), position = "right", fluid = TRUE,
                             mainPanel(leafletOutput("pred_tab", height=630))
                         )
                ),
                
                tabPanel("County Details", fluid = TRUE,
                         sidebarLayout(
                             sidebarPanel(
                                 # Input clarifying text
                                 helpText("Input model parameters:"),
                                 
                                 # Create a drop down to set the hour
                                 selectInput("det_county", label = "County:", choices = as.list(sort(county)), selected = sort(county)[1]),
                                 
                                 # Create a drop down to set the month
                                 selectInput("det_month", label = "Month:",
                                             choices = list("January"=1, "February"=2, "March"=3, "April"=4, "May"=5, "June"=6,
                                                            "July"=7, "August"=8, "September"=9, "October"=10, "November"=11, "December"=12), 
                                             selected = "January"),
                                 
                                 # Create a drop down to set the day
                                 selectInput("det_day", label = "Day:", choices = as.list(1:31), selected = 1),
                                 
                                 # Create a drop down to set the weekday
                                 selectInput("det_weekday", label = "Weekday:", 
                                             choices = list("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"), 
                                             selected = "Sunday"),
                                 
                                 # Create a drop down to set the hour
                                 selectInput("det_incident_hour", label = "Hour:", choices = as.list(0:23), selected = 6),
                                 
                                 # Create a numeric input to set the number of officers
                                 numericInput("det_total_officers", label = "Number of officers:", value = 30),
                                 
                                 # Create a numeric input to set the population
                                 numericInput("det_population", label = "Population:", value = 100000),
                                 
                                 # Create a numeric input to set the median home value
                                 numericInput("det_median_house_price", label = "Median Home Value ($):", value = 200000),
                                 
                                 # Create a numeric input to set the employment percentage
                                 numericInput("det_employment", label = "Employment (%):", value = 55),
                                 
                                 actionButton("det_update", "Update")
                             ), position = "right", fluid = TRUE,
                             mainPanel(plotOutput("desc_tab"))
                         )
                )
    )
)

# Define server logic required to output required text and visuals
server <- function(input, output) {
    
    
    # Output map to view all of California if appropriate California ZIP code isn't provided
    output$pred_tab <- renderLeaflet({
        input$pred_update
        
        isolate({
            input_frame <- data.frame("incident_hour" = as.numeric(input$incident_hour),
                                      "total_officers" = as.numeric(input$total_officers),
                                      "month" = input$month,
                                      "day" = input$day,
                                      "weekday" = input$weekday,
                                      "median_house_price" = as.numeric(input$median_house_price),
                                      "population" = as.numeric(input$population),
                                      "employment" = as.numeric(input$employment))
            pred_input <- cbind(input_frame, county)
            pred_input_h2o <- as.h2o(pred_input)
            
            prediction <- h2o.predict(saved_model, pred_input_h2o)[1]
            prediction_frame <- as.data.frame(prediction)
            pred_output <- as.character(prediction_frame$predict)
            
            vacounties$pred_output <- pred_output
    
            pal <- colorFactor(palette = palette(), levels = offenses)
            
            leaflet(vacounties)%>%addProviderTiles("CartoDB.Positron",options = providerTileOptions(noWrap = TRUE)) %>%
                addPolygons(stroke = TRUE, weight=1, smoothFactor = 0.3, fillColor = ~pal(pred_output), opacity = 1,
                            fillOpacity = 1, label = ~paste0(NAME, ": ", pred_output), color = "black") %>%
                addLegend("topright", pal = pal, values = ~pred_output, title = "Offense")
        })
    })
    
    output$desc_tab <- renderPlot({
        input$det_update
        
        isolate({
            det_input <- data.frame("incident_hour" = as.numeric(input$det_incident_hour),
                                      "total_officers" = as.numeric(input$det_total_officers),
                                      "month" = input$det_month,
                                      "day" = input$det_day,
                                      "weekday" = input$det_weekday,
                                      "median_house_price" = as.numeric(input$det_median_house_price),
                                      "population" = as.numeric(input$det_population),
                                      "employment" = as.numeric(input$det_employment),
                                      "county" = input$det_county)
            det_input_h2o <- as.h2o(det_input)
            prediction <- h2o.predict(saved_model, det_input_h2o)[2:22]
            prediction_frame <- as.data.frame(prediction)
            
            names <- colnames(prediction_frame)
            transposed_frame <- t(prediction_frame)
            det_output <- data.frame("offense" = names, "prob" = as.vector(transposed_frame))
            
            g <- ggplot(det_output, aes(x=reorder(offense, prob), y=prob))
            g + geom_bar(stat = "identity") + coord_flip() +
                ylab("Probability of Offense") + xlab("") + ggtitle(paste("Crime Probabilities for", input$det_county))
        })
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

