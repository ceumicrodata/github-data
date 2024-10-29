# Getting the .geojson files for the 50 biggest cities in our GitHub data.
library(arrow)
library(data.table)
library(dplyr)
library(osmdata)
library(sf)
library(geojsonio)
library(ggplot2)
library(stringr)

# Determine the cities from the user data. 
users <- data.table(read_parquet("data/github/users_2021.parquet"))
users[,country_code := tolower(country_code)]
pop_locations <- users[,.N,by=.(city_name,country_code)][order(-N)][1:100,]

# Remove all NA entries in the country_code or city_name column
pop_locations <- pop_locations[city_name != "\\N" & country_code != "\\N"]
# Note, that OSM API query has some documentation for country-specific adm level
# code which can be found here: https://wiki.openstreetmap.org/wiki/Tag:boundary%3Dadministrative#admin_level=*_Country_specific_values

# Merge this on the pop_location data
pop_locations <- merge(pop_locations , admin_levels  , by = "country_code" )
pop_locations[, country_name := countrycode::countrycode(country_code, origin = "iso2c", destination = "country.name")]




# Define the function
get_city_admin_levels <- function(city_name, country_name = NULL, admin_levels = 6:11) {
  # Initialize a list to store boundaries and plots
  boundaries_list <- list()
  plots_list <- list()
  
  # Combine city and country for the query if country_name is provided
  if (!is.null(country_name)) {
    city_query <- paste(city_name, country_name, sep = ", ")
  } else {
    city_query <- city_name
  }
  
  # Loop through the specified admin levels
  for (admin_level in admin_levels) {
    # Set up OSM query for the city and admin level
    query <- tryCatch({
      getbb(city_query) %>%
        opq() %>%
        add_osm_feature(key = "boundary", value = "administrative") %>%
        add_osm_feature(key = "admin_level", value = as.character(admin_level))
    }, error = function(e) NULL)
    
    # Check if the query was successful
    if (!is.null(query)) {
      # Retrieve data
      city_data <- tryCatch({
        osmdata_sf(query)
      }, error = function(e) NULL)
      
      # Check if data is available
      if (!is.null(city_data) && !is.null(city_data$osm_multipolygons)) {
        # Extract the boundary
        city_boundary <- city_data$osm_multipolygons
        
        # Add admin_level to the data
        city_boundary$admin_level <- admin_level
        
        # Append to the boundaries list
        boundaries_list[[as.character(admin_level)]] <- city_boundary
        
        # Create a plot for this admin level
        plot <- ggplot(data = city_boundary) +
          geom_sf(fill = "lightblue", color = "darkblue", size = 0.3) +
          labs(title = paste("Admin Level", admin_level),
               subtitle = paste("Boundary of", city_name),
               caption = paste("Admin Level:", admin_level)) +
          theme_minimal()
        
        # Add the plot to the plots list
        plots_list[[as.character(admin_level)]] <- plot
      } else {
        message(paste("No data found for admin level", admin_level))
      }
    } else {
      message(paste("Failed to set up query for admin level", admin_level))
    }
  }
  
  # Check if any boundaries were found
  if (length(boundaries_list) == 0) {
    message("No boundaries found for the specified admin levels.")
    return(NULL)
  }
  
  # Arrange the plots in a grid for comparison
  grid_arrange_shared_legend(plots_list, ncol = 2, nrow = ceiling(length(plots_list) / 2))
  
  # Return the list of boundaries for manual selection
  return(boundaries_list)
}

# Helper function to arrange plots with a shared legend (if needed)
grid_arrange_shared_legend <- function(plot_list, ncol, nrow) {
  library(gridExtra)
  do.call(grid.arrange, c(plot_list, ncol = ncol, nrow = nrow))
}

boundaries <- get_city_admin_levels(city_name = "Minneapolis", country_name = "United States")
unique(pop_locations$city_name)
chosen_boundaries <- list()
chosen_boundaries[["Buenos Aires, Argentina"]] <- "8"
chosen_boundaries[["Sydney, Australia"]] <- "6"
chosen_boundaries[["Melbourne, Australia"]] <- "6"
chosen_boundaries[["Dhaka, Bangladesh"]] <- "7"
chosen_boundaries[["São Paulo, Brazil"]] <- "8"
chosen_boundaries[["Rio de Janeiro, Brazil"]] <- "8"
chosen_boundaries[["Minsk, Belarus"]] <- "9"
chosen_boundaries[["Toronto, Canada"]] <- "8"
chosen_boundaries[["Montreal, Canada"]] <- "8"
chosen_boundaries[["Vancouver, Canada"]] <- "8"
chosen_boundaries[["Ottawa, Canada"]] <- "9"
chosen_boundaries[["Beijing, China"]] <- "6"
chosen_boundaries[["Shanghai, China"]] <- "8"
chosen_boundaries[["Hangzhou, China"]] <- "8"
chosen_boundaries[["Guangzhou, China"]] <- "8"
chosen_boundaries[["Nanjing, China"]] <- "8"
chosen_boundaries[["Chengdu, China"]] <- "6"
chosen_boundaries[["Prague, Czechia"]] <- "7"
chosen_boundaries[["Berlin, Germany"]] <- "10"
chosen_boundaries[["Munich, Germany"]] <- "10"
chosen_boundaries[["Hamburg, Germany"]] <- "8"
chosen_boundaries[["Madrid, Spain"]] <- "8"
chosen_boundaries[["Barcelona, Spain"]] <- "8"
chosen_boundaries[["Paris, France"]] <- "9"
chosen_boundaries[["London, United Kingdom"]] <- "8"
chosen_boundaries[["Jakarta, Indonesia"]] <- "6"
chosen_boundaries[["Dublin, Ireland"]] <- "9"
chosen_boundaries[["Bengaluru, India"]] <- "6"
chosen_boundaries[["Pune, India"]] <- "6"
chosen_boundaries[["Hyderabad, India"]] <- "6"
chosen_boundaries[["New Delhi, India"]] <- "6"
chosen_boundaries[["Chennai, India"]] <- "9"
chosen_boundaries[["Mumbai, India"]] <- "10"
chosen_boundaries[["Kolkata, India"]] <- "6"
chosen_boundaries[["Noida, India"]] <- "6"
chosen_boundaries[["Tokyo, Japan"]] <- "7"
chosen_boundaries[["Seoul, South Korea"]] <- "6"
chosen_boundaries[["Amsterdam, Netherlands"]] <- "10"
chosen_boundaries[["Oslo, Norway"]] <- "9"
chosen_boundaries[["Islamabad, Pakistan"]] <- "7"
chosen_boundaries[["Warsaw, Poland"]] <- "9"
chosen_boundaries[["Moscow, Russia"]] <- "8"
chosen_boundaries[["Saint Petersburg, Russia"]] <- "8"
chosen_boundaries[["Stockholm, Sweden"]] <- "10"
chosen_boundaries[["Istanbul, Turkey"]] <- "6"
chosen_boundaries[["Kyiv, Ukraine"]] <- "10"
chosen_boundaries[["New York, United States"]] <- "7"
chosen_boundaries[["San Francisco, United States"]] <- "8"
chosen_boundaries[["Seattle, United States"]] <- "8"
chosen_boundaries[["Chicago, United States"]] <- "7"
chosen_boundaries[["Los Angeles, United States"]] <- "8"
chosen_boundaries[["Austin, United States"]] <- "8"
chosen_boundaries[["Boston, United States"]] <- "8"
chosen_boundaries[["Atlanta, United States"]] <- "8"
chosen_boundaries[["Portland, United States"]] <- "10"
chosen_boundaries[["Washington, United States"]] <- "10"
chosen_boundaries[["San Diego, United States"]] <- "8"
chosen_boundaries[["Denver, United States"]] <- "8"
chosen_boundaries[["San Jose, United States"]] <- "8"
chosen_boundaries[["Dallas, United States"]] <- "8"
chosen_boundaries[["Houston, United States"]] <- "8"
chosen_boundaries[["Philadelphia, United States"]] <- "8"
chosen_boundaries[["New York, United States"]] <- "8"
chosen_boundaries[["New York, United States"]] <- "8"
chosen_boundaries[["New York, United States"]] <- "10"

unlist(chosen_boundaries)
chosen_boundaries_df <- data.table(
  "City_Country" = names(chosen_boundaries),
  "Boundary" = unlist(chosen_boundaries) 
  
)

all_city_boundaries <- list()

# Loop through each row in chosen_boundaries_df
for (i in 1:nrow(chosen_boundaries_df)) {
  # Get the city-country name and boundary level from the current row
  city_country <- chosen_boundaries_df[i, "City_Country"]
  admin_level <- chosen_boundaries_df[i, "Boundary"]
  
  # Set up OSM query for the city and admin level
  query <- getbb(city_country$City_Country) %>%
    opq() %>%
    add_osm_feature(key = "boundary", value = "administrative") %>%
    add_osm_feature(key = "admin_level", value = admin_level)
  
  # Retrieve data and check if results are found
  city_data <- tryCatch({
    osmdata_sf(query)
  }, error = function(e) NULL)
  
  # Check if valid data is retrieved
  if (!is.null(city_data) && !is.null(city_data$osm_multipolygons)) {
    # Extract polygons for boroughs or neighborhoods
    city_boundaries <- city_data$osm_multipolygons
    
    # Add city_country to the properties
    city_boundaries$City_Country <- city_country$City_Country
    
    # Append to the list of all city boundaries
    all_city_boundaries[[length(all_city_boundaries) + 1]] <- city_boundaries
    
    # Print a message to track progress
    print(paste("Processed:", city_country))
  } else {
    print(paste("No data found for:", city_country))
  }
}

# Combine all city boundaries into one 'sf' object using 'bind_rows'
combined_boundaries <- bind_rows(all_city_boundaries)
class(combined_boundaries) <- c("sf", class(combined_boundaries))
output_file <- "data/geojson_files/all_cities_boundaries.geojson"
st_write(combined_boundaries, output_file, driver = "GeoJSON", delete_dsn = TRUE)

gzipped_file <- str_glue("{output_file}.gz")
gz_con <- gzfile(gzipped_file, "wb")
writeBin(readBin(output_file, "raw", file.info(output_file)$size), gz_con)
close(gz_con)


# Testing the file
combined_boundaries <- st_read("data/geojson_files/all_cities_boundaries.geojson", quiet = FALSE)
unique_cities <- unique(combined_boundaries$city_name)


