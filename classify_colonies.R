# ==============================================================================
# Script: 3D Point Cloud Genet Classification
# Purpose: Assign Biological Genet IDs to LAS points using TagLab Shapefiles
# Author: the-churn
# ==============================================================================

library(lidR)
library(sf)
library(dplyr)

# 1. PATH CONFIGURATION --------------------------------------------------------
# Update these paths for 2015/2022 runs
las_in      <- "D:/PhD_Data(Large)/01_Raw/TestStuff/1fps_Runthrough/2022_Data_Las.las"
shp_in      <- "D:/PhD_Data(Large)/05_Code/Automating_3D_analysis/Shapes/2022_Shapes.shp"
output_path <- "D:/PhD_Data(Large)/05_Code/Automating_3D_analysis/Master_Genet_2022.las"

# 2. DATA IMPORT ---------------------------------------------------------------
las    <- readLAS(las_in)
shapes <- st_read(shp_in)

# 3. SPATIAL PRE-PROCESSING & BUFFERING ----------------------------------------
# We apply a 3cm buffer (0.03m) to capture leaning branches and peripheral 
# growth that may fall outside the 2D orthomosaic footprint. 
# We arrange by area so that smaller colonies aren't 'swallowed' by the 
# buffers of larger neighbors during the spatial join.

shapes_to_merge <- shapes %>%
  st_buffer(dist = 0.03) %>%
  mutate(TL_Genet = as.integer(as.character(TL_Genet))) %>% # Force integer conversion
  arrange(st_area(.)) %>% 
  select(TL_Genet) # Drop extraneous columns to prevent merge conflicts

# Ensure CRS synchronization
st_crs(las) <- st_crs(shapes_to_merge)

# 4. SPATIAL MERGE (POINT-IN-POLYGON) ------------------------------------------
# Map the 'TL_Genet' attribute to the 3D points
las <- merge_spatial(las, shapes_to_merge, "TL_Genet")

# Handle points outside of polygons (assign ID 0)
las@data$TL_Genet[is.na(las@data$TL_Genet)] <- 0L

# 5. HEADER REGISTRATION (EXTRA BYTES) -----------------------------------------
# Ensure the new attribute is registered in the LAS header so it is 
# visible as a Scalar Field in CloudCompare.

genet_values <- as.integer(las@data$TL_Genet)

las <- add_lasattribute(
  las, 
  x    = genet_values, 
  name = "TL_Genet", 
  desc = "Biological Genet ID"
)

# Use LAS 1.4 to ensure full support for extra attributes
las@header@version <- "1.4"

# 6. EXPORT & VERIFICATION -----------------------------------------------------
# Note: writeLAS may warn about missing EPSG codes if using local coordinates;
# this can be ignored as long as the relative alignment is preserved.

writeLAS(las, output_path)

# Print point distribution to console for QC
print("--- Point Count per Genet ID ---")
print(table(las@data$TL_Genet))

cat("\nProcessing Complete. File saved to:", output_path)
