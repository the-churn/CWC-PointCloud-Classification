Coral Colony 3D Fate Tracking: 2D-to-3D Integration

This repository provides an R-based spatial pipeline to bridge TagLab (2D) and CloudCompare (3D) for long-term coral reef monitoring. It enables the precise classification of high-density LAS point clouds using 2D digitized shapefiles, facilitating automated 3D growth analysis (M3C2, volume, and rugosity).
Project Overview

The core of this workflow is the automated assignment of Biological Genet IDs to 3D points. By projecting 2D annotations into 3D space, researchers can link planar metrics (surface area, perimeter) directly to volumetric and linear extension data across multi-year surveys.
Key Technical Features
1. Adaptive Spatial Buffering

We implement a 3cm (0.03m) buffer to all 2D shapes before the spatial join.

    Reasoning: Captures leaning branches and vertical growth that often extend beyond the 2D orthomosaic footprint. This prevents "clipping" the edges of complex morphologies like Madrepora oculata.

2. Overlap Priority Logic (Small-to-Large)

To handle dense reef clusters where buffers may overlap, the script sorts colonies by area (smallest first) before the join.

    Reasoning: This ensures that small recruits or fragments aren't "swallowed" by the expanded buffers of larger neighboring colonies during the point-in-polygon operation.

3. High-Fidelity Attribute Registration

The script utilizes the lidR package to inject Genet IDs directly into the LAS header as an Extra Byte attribute.

    Compatibility: Forces the output to LAS 1.4, ensuring that CloudCompare recognizes the IDs as a native Scalar Field (TL_Genet) for seamless batch processing and automated M3C2 extraction.

Workflow

    Annotation: Digitize colonies in TagLab and export as an ESRI Shapefile.

    Classification: Run classify_coral_genets.R to perform the 3D spatial join.

    Extraction: Import the classified LAS into CloudCompare and use the TL_Genet scalar field to filter, segment, or batch-process individual colonies.

Requirements

    R Version: 4.2+

    Core Packages: lidR, sf, dplyr

    Data Formats: LAS 1.2/1.4 (Point Clouds); ESRI Shapefile (Polygons)

Usage

    Configure the input/output paths in classify_coral_genets.R.

    Execute the script; verify the point distribution via the console table() output.

    Load the resulting Master LAS into CloudCompare and set the Active Scalar Field to TL_Genet.
