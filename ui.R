library(leaflet)
library(lubridate)
library(shinyBS)
library(shinydashboard)
# library(dashboardthemes)
library(shinyjs)

dashboardPage(
  dashboardHeader(),
  dashboardSidebar(
                column(width = 9, style='padding:0px;',
                          h4("About"),
                          "Here we are sharing our online database of strontium isotope ratios 
in California surface waters and biota (bivalve shells and otoliths from fish of known origin). 
Each point on the map represents a sample. You can filter by collection year(s) and sample type, 
and the map and table below will update. This is still a work in progress and will be updated periodically. 
A download button is coming soon. Any questions or data requests, please contact me at asturrock@ucdavis.edu.", offset = 1,
                   
                   sliderInput("year_slider",
                               "Choose year",
                               min=1998, max=2019, value=c(1998,2019),
                               sep="",width = 200),
                   
                   checkboxGroupInput("sample_type",
                                      "Sample type",
                                      choices = c("Water",
                                                  "Otolith",
                                                  "Clam"),
                                      selected = c("Water",
                                                   "Otolith",
                                                   "Clam")))),
  dashboardBody(useShinyjs(),
                
                fluidRow(
                  includeCSS("styles.css"),

                  box(leafletOutput(
                    "output_map", height = 550, width = "100%"
                  ),
                  height = 600, width = 12)
                                
),
                
                  box(DT::DTOutput('output_table'), width = 12)
                ))

