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

path.extracted <- file.path(path.base, "results", tool.name, track.length, srate, descriptor.name,
                            "extracted.txt")
if(!file.exists(path.extracted)){
  cat(sep="", "Error: extracted file '", path.extracted, "' does not exist.\n")
  q(status=1)
}

# RUN ##############################################################################################

# Prepare destination file =========================================================================

# For efficiency, we simply write tab-separated raw data instead of creating a temporary data.frame
# and then writing it to the file.
path.indicators <- file.path(path.base, "results", tool.name, track.length, srate, descriptor.name,
                            "indicators.txt")
dir.create(dirname(path.indicators), recursive=T, showWarnings=F)
# Delete previous data, if any
unlink(path.indicators, force=T)
# Initialize file
conn <- file(path.indicators, open="w")
# At this point we don't know anything about analysis parameters, so we can't just write column
# names now. Keep this variable to tell us when to write the header for the first time.
conn.head <- F

# Read extracted descriptor data and compute indicators ============================================

ex <- read.table(path.extracted, head=T, sep="\t", quote="\"", stringsAsFactors=F)
# Add a column 'id' to identify factors that must be equal between lossy and its lossless
track.index <- which(names(ex) == "track") # to quickly index factor names and data
ex$id <- apply(ex[3:track.index], 1, paste, collapse="\t")
# Split in lossless and lossy
ex.lossless <- ex[ex$codec == "WAV",]
ex.lossy <- ex[ex$codec != "WAV",]

# Traverse lossy descriptors
for(i in 1:nrow(ex.lossy)){
  # Select lossy and lossless
  lossy <- ex.lossy[i,]
  lossless <- ex.lossless[ex.lossless$id == lossy$id,]
  # and get actual data
  lossy <- unlist(lossy[,(track.index+1):(length(lossy)-1)])
  lossless <- unlist(lossless[,(track.index+1):(length(lossless)-1)])
  
  # Compute indicators
  indicators <- numeric(0)
  indicators["relative"] <- mean(abs(lossy - lossless) / apply(data.frame(abs(lossy), abs(lossless)), 1, max))
  indicators["epsilon"] <- sqrt(sum((lossy - lossless)^2))
  indicators["pearson"] <- cor(lossy, lossless, method="p")
  indicators["spearman"] <- cor(lossy, lossless, method="s")
  indicators["cosine"] <- sum(lossy * lossless) / sqrt(sum(lossy^2)) / sqrt(sum(lossless^2))
  
  # Write column names if first time here
  if(!conn.head){
    newline <- paste(c(names(ex)[1:track.index], paste0("ind.", names(indicators))), collapse="\t")
    writeLines(newline, con=conn)
    conn.head <- T
  }
  
  # Write actual descriptor data          
  newline <- paste(c(unlist(ex.lossy[i, 1:track.index]), indicators), collapse="\t")
  writeLines(newline, con=conn)
}

# Close destination file
close(conn)
