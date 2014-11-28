# Copyright (C) 2014  Music Technology Group - Universitat Pompeu Fabra
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.

# CHECK ARGUMENTS (taken from main script) #########################################################

path.indicators <- file.path(path.base, "results", tool.name, track.length, srate, descriptor.name,
                             "indicators.txt")
if(!file.exists(path.indicators)){
  cat(sep="", "Error: indicators file '", path.indicators, "' does not exist.\n")
  q(status=1)
}

# RUN ##############################################################################################

# Prepare destination file =========================================================================

# Plot everything in a multi-page PDF file
path.boxplots <- file.path(path.base, "results", tool.name, track.length, srate, descriptor.name,
                           "boxplots.pdf")
dir.create(dirname(path.boxplots), recursive=T, showWarnings=F)
# Delete previous plot, if any
unlink(path.boxplots, force=T)
# Initialize plot
pdf(file=path.boxplots, onefile=T, paper="a4")
# Increase bottom margin, make labels perpendicular to axes and reduce font size+
par(mar=c(20,3,3,1), cex=.7, las=3)

# Read indicators data and boxplot distributions ===================================================

ind <- read.table(path.indicators, head=T, sep="\t", quote="\"", stringsAsFactors=F)
track.index <- which(names(ind) == "track") # to quickly index factor names and indicators
# Set all effect columns to R factors, so droplevels works in the boxplots
for(i in 1:track.index){
  ind[,i] <- as.factor(ind[,i])
}

# Compile list of effects to plot by ---------------------------------------------------------------

factors <- c("genre", "track", "codec", "codec:brate")
# If we have custom params, parse and add to list of factors
if(track.index != 4){
  params <- names(ind)[3:(track.index-2)]
  
  # Include params main effects
  factors <- append(factors, params)
  # their interaction with the codec effect
  factors <- append(factors, paste("codec", params, sep=":"))
  # and their interaction with the codec:brate effect
  factors <- append(factors, paste("codec:brate", params, sep=":"))
}

# Traverse indicators
for(i in (track.index+1):length(ind)){
  ind.name <- names(ind)[i]
  ind.cleanname <- gsub("ind.", "", ind.name, fixed=T)
  
  # Boxplots by factors ----------------------------------------------------------------------------
  
  for(f in factors){
    form <- as.formula(paste0(ind.name, " ~ droplevels(", f, ")"))
    boxplot(form, data=ind, notch=T, main=paste(ind.cleanname, "by", f))
    # Plot means too
    a <- aggregate(form, data=ind, FUN=mean)
    points(a[ind.name], col="blue", pch=4)
  }
}

# Close boxplots file
print(dev.off())
