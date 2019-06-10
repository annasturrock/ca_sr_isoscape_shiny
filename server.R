library(raster)
library(sp)
library(leaflet)
library(rjson)
library(readr)
library(DT)
library(sf)
library(RColorBrewer)
library(geojsonio)

sr_data <- read.csv("ALL_Sr8786_FOR_SHINY.csv")
sr_data_sp <- SpatialPointsDataFrame(SpatialPoints(sr_data[,c("Long_dd", "Lat_dd")]),
                                     sr_data)
sr_data_sf <- st_as_sf(sr_data_sp)
# sjr_watersheds <- st_read("watershed_geo_data/SanJoaquin_River_Watershed.shp")
# sac_watersheds <- st_read("watershed_geo_data/Sac_River_Watershed.shp")
# watersheds <- rbind(sjr_watersheds, sac_watersheds)
# watersheds$row <- 1:nrow(watersheds)


# Calc means or each watershed
# st_crs(sr_data_sf) <- st_crs(watersheds)
# hatcheries <- c("CNH", "FEH", "THE", "NIH", "MOH", "MEH")
# sr_data_no_hatcheries <- sr_data_sf[!(sr_data_sf$NAT_LOC %in% hatcheries),]
# watershed_row_logical <- st_within(sr_data_no_hatcheries, watersheds) %>% lengths > 0 
# watershed_row <- st_within(sr_data_no_hatcheries, watersheds) 
# 
# watershed_means <- aggregate(sr_data_no_hatcheries$Sr8786[watershed_row_logical], by=list(unlist(watershed_row)), FUN=mean)
# names(watershed_means) <- c("row", "mean_sr")
# 
# # Merge
# watersheds <- merge(watersheds, watershed_means, by = "row")
# watersheds$mean_sr <- round(watersheds$mean_sr, 6)

# Define map
sr_pal <- colorNumeric(brewer.pal(11,"Spectral"), sr_data_sf$Sr8786, na.color = NA)

map <- leaflet() %>%
  addTiles(
    "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}{r}.png",
    group = "Base map"
  ) %>%
  addProviderTiles("Esri.OceanBasemap", group = "Terrain") %>%
  addProviderTiles("Esri.WorldImagery", group = "Satellite") %>%
  addCircleMarkers(data=sr_data_sf) %>%
  addLegend(pal = sr_pal, values = sr_data_sf$Sr8786,
            title = "Sr87/Sr86") 


server <- function(input, output) {
  
  
  output$output_table <-
    
    DT::renderDT({
      
      as.data.frame(filtered_data())[,c("Sample_ID", "Sample_type", "WaterYear",
                                        "Site_name", "Sr8786", "SD", "Source")]

      })
      
  
  filtered_data <- reactive({
    
    water_years <- input$year_slider
    
    sr_data_sf[sr_data_sf$Sample_type %in% input$sample_type & 
                                   sr_data_sf$WaterYear >= input$year_slider[1] &
                                   sr_data_sf$WaterYear <= input$year_slider[2],]
   
  })
  
  
  output$output_map <- renderLeaflet({
    map
    })

    
    observeEvent(filtered_data(), {
      leafletProxy("output_map") %>%
         clearMarkers() %>%
        addCircleMarkers(data =  filtered_data(),
                         col = sr_pal(filtered_data()$Sr8786),
                         radius = 3,
                         popup =paste0("<p><strong>Site name: </strong>",
                                       filtered_data()$Site_name,
                                       "<br><strong>Sr87/Sr86: </strong>",
                                       filtered_data()$Sr8786)) %>%
        

        # 
        addLayersControl(baseGroups = c("Base map",
                                        "Terrain",
                                        "Satellite"),
                         # overlayGroups = c("Watershed mean (all yrs)"),
                         options = layersControlOptions(collapsed = FALSE))
 
    })

    
  }
  
  
  # output$output_table <-
  #   
  #   DT::renderDT({
  # 
  #       map_data_no_geom <- map_data()
  #       st_geometry(map_data_no_geom) <- NULL
  #       output_table <- as.data.frame(map_data_no_geom)
  #       DT::datatable(output_table,
  #                     options = list(pageLength = 15),
  #                     rownames = F)
  # 
  #   })
  

