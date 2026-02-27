Coral Colony 3D Fate Tracking

This repository contains the R-based workflow to bridge TagLab (2D) and CloudCompare (3D) for long-term coral colony monitoring. It allows for the classification of high-density LAS point clouds using 2D digitized shapefiles.
Project Overview

The goal of this script is to assign unique Colony IDs (TL_id) to 3D points. This enables the calculation of 3D metrics (volume, rugosity, M3C2 linear extension) that can be directly compared to 2D metrics (surface area, perimeter) exported from TagLab.
The Workflow
1. Spatial Buffering

We apply a 1.5cm buffer (dist = 0.015) to the 2D shapes.

    Reasoning: To account for slight alignment offsets between the orthomosaic used in TagLab and the raw LAS point cloud, and to ensure the vertical "sides" of the coral colonies are captured.

2. LAS Classification

Using the lidR::merge_spatial function, the script performs a point-in-polygon operation.

    Input: .las point cloud and .shp colony boundaries.

    Output: A classified LAS file where each point carries a TL_id attribute.

3. CloudCompare Compatibility

The script registers TL_id as an Extra Byte attribute and forces the file to LAS 1.4. This ensures that CloudCompare recognizes the IDs as a Scalar Field for immediate filtering and batch processing.
Requirements

    R Version: 4.0+

    Packages: lidR, sf

    Data Format: LAS 1.2 or 1.4; ESRI Shapefile

Usage

    Update the file paths in classify_coral_colonies.R to point to your local data.

    Run the script in RStudio.

    Import the resulting .las file into CloudCompare.

    Use the "Scalar Field" tool to filter or split the cloud by TL_id.
