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

#options(echo=T)

DEFAULT_BASE_PATH <- file.path("..","data")

# PARSE COMMAND LINE ARGUMENTS #####################################################################

args <- commandArgs(trailingOnly=T)
tool.name <- args[1]
track.length <- args[2]
srate <- args[3]
descriptor.name <- args[4]
base.path <- args[5]
base.path <- ifelse(is.na(base.path), DEFAULT_BASE_PATH, base.path)

# Check arguments
if(is.na(tool.name) | is.na(track.length) | is.na(srate) | is.na(descriptor.name) | is.na(base.path)){
  cat(sep="",
      "usage: Rscript extract.R <tool> <track-length> <srate> <descriptor> [<path>]\n",
      "\n",
      "tool          name of the tool used to compute descriptors, eg. 'essentia'.\n",
      "track-length  length of the track used to compute descriptors, eg '30-60'.\n",
      "srate         sampling rate of the track used to compute descriptors, eg. '44100'.\n",
      "descriptor    name of the descriptor to extract, eg. 'lowlevel.mfcc.mean'.\n",
      "path          optional path to all data, defaults to '", DEFAULT_BASE_PATH, "'.\n",
      "\n",
      "Expected file structure:\n",
      "  path/descriptors/<tool>/<track-length>/<srate>/<descriptor>/<codec>/<brate>/<param1>-...-<paramN>/<genre>/file\n")
  q(status=1)
}
if(!file.exists(file.path("extractors", paste0(tool.name,".R")))){
  cat(sep="", "Error: tool '", tool.name, "' does not exist.\n")
  q(status=1)
}
base.path <- file.path(base.path, "descriptors", tool.name, track.length, srate)
if(!file.exists(base.path)){
  cat(sep="", "Error: path '", base.path, "' does not exist.\n")
  q(status=1)
}

# Source the extractor code and check that extractor is defined
source(file.path("extractors", paste0(tool.name,".R")))
if(!exists("extract.data", mode="function")){
  cat(sep="", "Error: tool '", tool.name, "' does not define an 'extract.data' function.\n")
  q(status=1)
}

# RUN ##############################################################################################

# Traverse file structure
for(codec.path in list.dirs(recursive=F, base.path)){
  codec <- basename(codec.path)
  for(brate.path in list.dirs(recursive=F, codec.path)){
    brate <- basename(brate.path)
    for(params.path in list.dirs(recursive=F, brate.path)){
      # Parse params. If just '=', set to empty vector
      params <- basename(params.path)
      if(params=="-"){
        params <- character(0)
      }else{
        params <- unlist(strsplit(params, split="-", fixed=T))
      }
      for(genre.path in list.dirs(recursive=F, params.path)){
        genre <- basename(genre.path)
        for(file.path in list.files(recursive=F, full.names=T, genre.path)){
          file <- basename(file.path)
          
          # Extract descriptor from file
          d <- extract.data(file.path, descriptor.name)
          
          # TODO
        }
      }
    }
  }
}
