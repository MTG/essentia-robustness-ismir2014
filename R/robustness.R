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

# options(echo=T)

DEFAULT_PATH_BASE <- file.path("..", "data")
COMMANDS <- c("extract", "indicators", "distributions", "boxplots", "variance",
              "all", "help")

# PARSE COMMAND LINE ARGUMENTS #####################################################################

args <- commandArgs(trailingOnly=T)
command.name <- args[1]
tool.name <- args[2]
track.length <- args[3]
srate <- args[4]
descriptor.name <- args[5]
path.base <- args[6]
path.base <- ifelse(is.na(path.base), DEFAULT_PATH_BASE, path.base)

# Check arguments
if(is.na(command.name) | !(command.name %in% COMMANDS) | command.name == "help" |
     is.na(tool.name) | is.na(track.length) |is.na(srate) | is.na(descriptor.name) | is.na(path.base)){
  cat(sep="",
      "usage: Rscript robustness.R <command> <tool> <track-length> <srate> <descriptor> [<path>]\n",
      "\n",
      "  command       command to run (see below).\n",
      "  tool          name of the tool used to compute descriptors, eg. 'essentia'.\n",
      "  track-length  length of the tracks used to compute descriptors, eg '30-60'.\n",
      "  srate         sampling rate of the tracks used to compute descriptors, eg. '44100'.\n",
      "  descriptor    name of the descriptor to analyze, eg. 'lowlevel.mfcc.mean'.\n",
      "  path          optional path to all data (see below), defaults to '", DEFAULT_PATH_BASE, "'.\n",
      "\n",
      "Available commands are (in expected order of execution):\n",
      "  extract        extract data specific of the descriptor.\n",
      "  indicators     compute robustness indicators.\n",
      "  distributions  describe the distributions of the indicators.\n",
      "  boxplots       boxplot the distributions of the indicators.\n",
      "  variance       decompose in variance components.\n",
      "  --\n",
      "  all            run all commands (extract, indicators, distributions, variance).\n",
      "  help           show this message.\n",
      "\n",
      "Expected file structure of descriptors:\n",
      "  path/descriptors/<tool>/<track-length>/<srate>/<codec>/<brate>/<param1>-...-<paramN>/<genre>/file\n",
      "Output file structure:\n",
      "  path/results/<tool>/<track-length>/<srate>/<descriptor>/<command>.txt\n")
  q(status=1)
}

# FUNCTIONS COMMON TO ALL COMMANDS #################################################################

# Given the vector of factor names 'fs', return their order.
# Sorted by degree (main effects, 2nd order interactions, 3rd order, etc.) and then by name.
# The last effects are always 'genre', 'track' and 'Residual' (if present).
order.factors <- function(fs){
  degree <- nchar(gsub("[^:]", "", fs))
  degree[fs=="genre"] <- .Machine$integer.max-2
  degree[fs=="track"] <- .Machine$integer.max-1
  degree[fs=="Residual"] <- .Machine$integer.max
  return(order(degree, fs))
}

# RUN COMMAND ######################################################################################

if(command.name == "all"){
  for(command in COMMANDS[1:(length(COMMANDS)-2)]){
    cat("**", command, "\n")
    source(file.path("commands",paste0(command, ".R")))
  }
}else{
  source(file.path("commands", paste0(command.name, ".R")))
}