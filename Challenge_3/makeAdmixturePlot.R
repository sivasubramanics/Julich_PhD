#! /usr/bin/env Rscript
# title           :makeAdmixturePlot.R
# description     :This script will generate Plot for Admixture Qmatrix.
# author          :c.s.sivasubramani@gmail.com
# date            :11042021
# version         :0.1
# usage           :Rscript makeAdmixturePlot.R
# notes           : This script expects additional Utility source code for processing.
# ==============================================================================

# Load the POPS utilities
source("POPSutilities.r")

# Reading Admixture Q matrix
Qmatrix = read.table("maize.3.Q")

# Reading geo coord file (2 columns separated with comma)
coord = read.table("Maize.coord") 

# Output PNG File
png("AdmixtureClusters.png")

# Initial geo ploting
plot(coord, pch = 19,  xlab="Longitude", ylab = "Latitude")
map(add = T, interior = F, col = "grey80")
asc.raster = "RasterMaps/North_America.asc" 

# Defining grid for ancestory
grid=createGridFromAsciiRaster(asc.raster)
constraints=getConstraintsFromAsciiRaster(asc.raster,cell_value_min=0)
show.key = function(cluster=1,colorGradientsList=lColorGradients){
  ncolors=length(colorGradientsList[[cluster]])
  barplot(matrix(rep(1/10,10)),col=colorGradientsList[[cluster]][(ncolors-9):ncolors],main=paste("Cluster",cluster))}
layout(matrix(c(rep(1,6),2,3,4), 3, 3, byrow = FALSE), widths=c(3,1), respect = F)
par(ps = 22)
maps(matrix = Qmatrix, coord, grid, constraints, method = "max", main = "Ancestry coefficients", xlab = "Longitude", ylab = "Latitude")
par(ps = 16)

# Adding Cluster legends
for(k in 1:3){show.key(k)}
dev.off()
