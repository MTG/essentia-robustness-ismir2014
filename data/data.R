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


# This script creates sample data to test the main code.
# It reads JSON files from a folder called 'original', where we expect one
# subfolder per genre:
# - original/blues/trackname.flac.wav.MP3.CBR.64.22050.mp3.1024_512.json
# - original/rock/trackname.flac.wav.WAV.44100.wav.4096_2048.json
#
# Filenames are expected to be in the format used by Dmitry and Julián for the
# ISMIR 2014 paper on robustness (see two examples above).
# The output will be in the format expected by the main code:
# - descriptors/tool/track-length/srate/codec/brate/param1-...-paramN/genre/file


library(digest)

# Set path
tool.name <- "essentia"
track.length <- "60-90"
path.base <- file.path("./descriptors", tool.name, track.length)
# remove previous data, if any
unlink(path.base, recursive = T, force = T)

# traverse genres, and all files within
for(genre.path in list.dirs("./original", recursive = F, full.names = T)){
  cat(genre.path,"\n")
  genre <- basename(genre.path)
  for(file.path in list.files(genre.path,"*.json", recursive = F, full.names = T)){
    file <- basename(file.path)
    
    # split filename in factors
    parts <- unlist(strsplit(file, ".flac.wav.", fixed=T))
    name <- digest(parts[1], algo="md5")
    parts <- unlist(strsplit(parts[2], ".", fixed=T))  
    codec <- parts[1]
    if(codec == "WAV"){
      brate <- 1411
      srate <- parts[2]
      fsize <- parts[4]
    }else{
      codec <- paste0(parts[1],".",parts[2])
      brate <- parts[3]
      srate <- parts[4]
      fsize <- parts[6]      
    }
    
    # copy only a sample of brates and fsizes
    if(brate %in% c(1411, 0,2,4,6, 64,96,128,160) &
         fsize %in% c("1024_512","4096_2048","16384_8192")){
      
      # create destination directory if necessary
      dir <- file.path(path.base,
                       srate,
                       codec,
                       brate,
                       paste0(fsize,"-","p2"), # params
                       genre)
      dir.create(dir, recursive = T, showWarnings = F)
      
      # copy file
      file.copy(from = file.path, to=file.path(dir,paste0(name,".json")), overwrite = T)
    }
  }  
}