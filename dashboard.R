library(shiny)
library(shinydashboard)
library(ggplot2)
library(reshape)
library(dplyr)
library(lubridate)
library(leaflet)
library(stringi)
library(htmltools)

# Loading Data
crime_2023 <- read.csv('Crimes_2023.csv', header = TRUE)
crime_df <- as.data.frame(crime_2023) %>% 
  select(Case.Number, Date, Primary.Type, Location.Description, Latitude, Longitude)

# Data Cleaning
crime_df$Month <- months(strptime(crime_df$Date, "%m/%d/%Y %I:%M:%S %p"))
crime_df$TimeOfDay <- hour(strptime(crime_df$Date, "%m/%d/%Y %I:%M:%S %p"))
crime_df$Date <- as.Date(crime_df$Date, format = "%m/%d/%Y")
crime_df <- distinct(crime_df, Case.Number, .keep_all = TRUE)
crime_df <- crime_df[complete.cases(crime_df), ]
crime_df$Primary.Type <- as.character(crime_df$Primary.Type)

# Category Mapping
crime_df$PrimaryTypeDCD <- crime_df$Primary.Type
crime_df$PrimaryTypeDCD <- ifelse(crime_df$Primary.Type %in% c('NARCOTICS', 'OTHER NARCOTIC VIOLATION'), "Narcotics", crime_df$PrimaryTypeDCD)
crime_df$PrimaryTypeDCD <- ifelse(crime_df$Primary.Type %in% c('ROBBERY', 'THEFT', 'BURGLARY', 'MOTOR VEHICLE THEFT'), "Theft", crime_df$PrimaryTypeDCD)
crime_df$PrimaryTypeDCD <- ifelse(crime_df$PrimaryTypeDCD %in% c('CRIM SEXUAL ASSAULT', 'SEX OFFENSE', 'PROSTITUTION'), "Sexual", crime_df$PrimaryTypeDCD)
crime_df$PrimaryTypeDCD <- stri_trans_totitle(crime_df$PrimaryTypeDCD)
crime_df$Location.Description <- stri_trans_totitle(crime_df$Location.Description)

# Summarize Data
FreqMonthCrimeType <- crime_df %>% group_by(PrimaryTypeDCD, Month) %>% summarise(Freq = n())
FreqCrimeByLocation <- crime_df %>% group_by(PrimaryTypeDCD, Location.Description) %>% summarise(Freq = n())
FreqCrimeTime <- crime_df %>% group_by(PrimaryTypeDCD, TimeOfDay) %>% summarise(Freq = n())
month <- rev(unique(crime_df$Month))
Loc <- rev(sort(table(crime_df$Location.Description)))[1:15]
location <- names(Loc)
typ <- rev(sort(table(crime_df$PrimaryTypeDCD)))[1:15]
type <- names(typ)

# UI
ui <- dashboardPage(
  dashboardHeader(title = "Chicago Crime Analysis"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Monthly Crime Frequency", tabName = "monthly_freq", icon = icon("calendar")),
      menuItem("Crime Frequency by Location", tabName = "location_freq", icon = icon("map-marker")),
      menuItem("Time-Based Crime Heatmap", tabName = "time_heatmap", icon = icon("clock")),
      menuItem("Crime type over the year", tabName="crime_overmonths", icon=icon("clock")),
      menuItem("Crime Map by Date", tabName = "crime_map", icon = icon("globe"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "monthly_freq",
              fluidRow(
                box(title = "Select Month", width = 4, status = "primary", solidHeader = TRUE,
                    selectInput("monthInput", "Select Month:", choices = factor(month.name, levels = month.name), selected = month['January']),
                    helpText("Choose a month to view crime types and frequencies for the selected period.")
                ),
                box(title = "Crime Frequency by Type and Month", width = 8, status = "primary", solidHeader = TRUE,
                    plotOutput("FreqofCrimeByMonthType")
                )
              )
      ),
      
      tabItem(tabName = "location_freq",
              fluidRow(
                box(title = "Select Location", width = 4, status = "primary", solidHeader = TRUE,
                    selectInput("locationInput", "Select Location:", choices = location, selected = location[1]),
                    helpText("Choose a location to view crime types and frequencies for the selected area.")
                ),
                box(title = "Crime Frequency by Location", width = 8, status = "primary", solidHeader = TRUE,
                    plotOutput("FreqofCrimeByLocationType")
                )
              )
      ),
      
      tabItem(tabName = "time_heatmap",
              fluidRow(
                box(title = "Heatmap of Crime Frequency by Time of Day", width = 12, status = "primary", solidHeader = TRUE,
                    plotOutput("FreqCrimeTime")
                )
              )
      ),
      tabItem(tabName = "crime_overmonths",
              fluidRow(
                box(title = "Select Type", width = 4, status = "primary", solidHeader = TRUE,
                    selectInput("locationInput", "Select Type:", choices = type, selected = type[1]),
                    helpText("Choose a type to view crimes over the year.")
                ),
                box(title = "Crime types over the months", width = 8, status = "primary", solidHeader = TRUE,
                    plotOutput("FreqofCrimeByLocationTypeLine")
                )
              ) 
      ),
      
      tabItem(tabName = "crime_map",
              fluidRow(
                box(title = "Select Date", width = 4, status = "primary", solidHeader = TRUE,
                    dateInput("dateInputforMap", "Select Date:", value = "2023-01-01", format = "yyyy-mm-dd", min = "2023-01-01", max = "2023-12-31"),
                    helpText("Choose a date to view crimes on the map for the selected date.")
                ),
                box(title = "Crime Map", width = 8, status = "primary", solidHeader = TRUE,textOutput("totalCrimesText"),br(),
                    leafletOutput("Map")
                )
              )
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  output$FreqofCrimeByMonthType <- renderPlot({
    req(input$monthInput)
    plot_data1 <- filter(FreqMonthCrimeType, Month == input$monthInput)
    ggplot(plot_data1, aes(x = PrimaryTypeDCD, y = Freq)) + 
      geom_bar(stat = "identity", fill = "#4B0082") +
      geom_text(aes(label = Freq), vjust = -0.5, color = "black", size = 3.5) +
      labs(x = 'Crime Type', y = 'Frequency', title = 'Crime Frequency by Type and Month') +
      theme_minimal() +
      theme(axis.text.x = element_text(angle=45,hjust=1))
  })
  
  output$FreqofCrimeByLocationType <- renderPlot({
    req(input$locationInput)
    plot_data2 <- filter(FreqCrimeByLocation, Location.Description == input$locationInput)
    ggplot(plot_data2, aes(x = PrimaryTypeDCD, y = Freq)) + 
      geom_bar(stat = "identity", fill = "#4B0082") +
      geom_text(aes(label = Freq), vjust = -0.5, color = "black", size = 3.5) +
      labs(x = 'Crime Type', y = 'Frequency', title = 'Crime Frequency by Location') +
      theme_minimal() +
      theme(axis.text.x = element_text(angle=45,hjust=1))
  })
  
  output$FreqCrimeTime <- renderPlot({
    ggplot(FreqCrimeTime, aes(x = PrimaryTypeDCD, y = TimeOfDay, fill = Freq)) + 
      geom_tile() + 
      scale_fill_gradient(low = "lightyellow", high = "orange") +
      labs(x = 'Crime Type', y = 'Hour of the Day', title = 'Crime Frequency Heatmap by Time of Day') +
      theme_minimal() +
      theme(axis.text.x = element_text(angle=45,hjust=1))
  })
  output$FreqofCrimeByLocationTypeLine <- renderPlot({
    plot_data4 <- crime_df %>%
      filter(PrimaryTypeDCD == input$locationInput) %>%  
      group_by(Month) %>%
      summarise(Freq = n(), .groups = "drop")
    plot_data4$Month <- factor(plot_data4$Month, 
                               levels = c("January", "February", "March", "April", 
                                          "May", "June", "July", "August", 
                                          "September", "October", "November", "December"))
    
    ggplot(plot_data4, aes(x = Month, y = Freq, group = 1)) +
      geom_line(color = "#4B0082", size = 1) +
      geom_point(color = "#4B0082", size = 2) +
      labs(x = "Month", y = "Frequency", title = paste("Frequency of", input$locationInput, "Over the year")) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  
  
  output$Map <- renderLeaflet({
    plot_data3 <- filter(crime_df, Date == input$dateInputforMap)
    leaflet(plot_data3) %>%
      addTiles() %>%
      addMarkers(
        lng = ~Longitude, lat = ~Latitude,
        label = lapply(seq(nrow(plot_data3)), function(i) {
          paste0('<p><b>Crime Type:</b> ', plot_data3$PrimaryTypeDCD[i], '<br><b>Location:</b> ', plot_data3$Location.Description[i],
                 '<br><b>Time:</b> ', plot_data3$TimeOfDay[i], '</p>')
        })
      )
  })
  output$totalCrimesText <- renderText({
    plot_data3 <- filter(crime_df, Date == input$dateInputforMap)
    paste("Total number of crimes:", nrow(plot_data3))
  })
}

shinyApp(ui, server)
