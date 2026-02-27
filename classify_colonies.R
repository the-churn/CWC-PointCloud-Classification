# ==============================================================================
# Script: Coral Colony Point Cloud Classification
# Purpose: Classify LAS points by Colony ID using TagLab shapefiles
# Author: the-churn
# ==============================================================================

# Load required libraries
library(lidR)
library(sf)

# 1. LOAD DATA -----------------------------------------------------------------
# Replace these paths with your local directory or relative paths
las_path <- "D:/PhD_Data(Large)/01_Raw/TestStuff/1fps_Runthrough/2015_Data.las"
shp_path <- "D:/PhD_Data(Large)/01_Raw/TestStuff/1fps_Runthrough/2015_regions.shp"

las <- readLAS(las_path)
shapes <- st_read(shp_path)

# 2. SPATIAL PRE-PROCESSING ----------------------------------------------------
# Apply a 1.5cm buffer to ensure the coral points are captured within 
# the 2D digitized boundary.
shapes_buffered <- st_buffer(shapes, dist = 0.015)

# Harmonize CRS: Force the LAS object to inherit the Coordinate Reference System
# of the shapefile to ensure they overlap correctly during the spatial merge.
st_crs(las) <- st_crs(shapes_buffered)

# 3. SPATIAL JOIN (CLASSIFICATION) ---------------------------------------------
# merge_spatial performs a point-in-polygon check. It adds a new column 
# to the LAS data table based on the "TL_id" attribute in the shapefile.
las <- merge_spatial(las, shapes_buffered, "TL_id")

# Clean up: Replace NA values (points outside any colony) with 0.
# We use 0L to ensure it remains an integer type.
las@data$TL_id[is.na(las@data$TL_id)] <- 0L

# 4. LAS ATTRIBUTE REGISTRATION ------------------------------------------------
# To ensure CloudCompare and other software recognize 'TL_id' as a Scalar Field:
# 1. Ensure the ID is a 32-bit integer.
las@data$TL_id <- as.integer(las@data$TL_id)

# 2. Register 'TL_id' as an official LAS attribute (Extra Byte) in the header.
las <- add_lasattribute(
  las, 
  x = las@data$TL_id, 
  name = "TL_id", 
  desc = "Colony ID from TagLab"
)

# 3. Set the version to LAS 1.4 (Standard for supporting extra attributes).
las@header@version <- "1.4"

# 5. EXPORT --------------------------------------------------------------------
# Save the full classified cloud
writeLAS(las, "D:/PhD_Data(Large)/02_Processed/2015_Classified_Full.las")

# OPTIONAL: Export a "Colonies Only" file for faster loading in CloudCompare
# las_colonies <- filter_poi(las, TL_id > 0)
# writeLAS(las_colonies, "D:/PhD_Data(Large)/02_Processed/2015_Colonies_Only.las")

# Verify the result in the console
summary(las@data$TL_id)
