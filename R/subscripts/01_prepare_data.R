# -----------------------------------------------------------------------
# Project: SST-GPM
# File name: 01_prepare_data.R
# Last updated: 2023-02-21
# Author: Lewis A. Jones
# Email: LewisA.Jones@outlook.com
# Repository: https://github.com/LewisAJones/SST-GPM
# Load libraries --------------------------------------------------------
library(palaeoverse)
source("./R/options.R")
# Read data -------------------------------------------------------------
df <- readRDS("./data/raw/PhanSST_v001.RDS")
# Process data ----------------------------------------------------------
# Replace "age x" interval name with "stage x" interval name
df$Stage <- gsub(pattern = "Age 2", replacement = "Stage 2", x = df$Stage)
df$Stage <- gsub(pattern = "Age 10", replacement = "Stage 10", x = df$Stage)
# Look up and assign stage ages
df <- look_up(occdf = df,
              early_interval = "Stage",
              late_interval = "Stage",
              assign_with_GTS = "GTS2020")
# Reduce to unique coordinates for palaeorotation
coords <- unique(df[, c(lat, lng, age)])
# Palaeorotate coordinates
coords <- palaeorotate(occdf = coords,
                       lng = lng,
                       lat = lat,
                       age = age,
                       model = models,
                       method = "point",
                       uncertainty = TRUE,
                       round = NULL)
# Match coordinates 
coords$match <- paste0(coords[, lng], coords[, lat], coords[, age])
df$match <- paste0(df[, lng], df[, lat], df[, age])
m <- match(x = df$match, table = coords$match)
# Replicate coord rows according to match
coords <- coords[m, ]
# Drop match columns before binding
df <- df[, -which(colnames(df) == "match")]
coords <- coords[, -which(colnames(coords) == "match")]
df <- cbind.data.frame(df, coords)
