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

DEFAULT_BASE_PATH <- "../data"

# PARSE COMMAND LINE ARGUMENTS #################################################

args <- commandArgs(trailingOnly=T)
tool.name <- args[1]
descriptor.name <- args[2]
base.path <- args[3]
base.path <- ifelse(is.na(base.path), DEFAULT_BASE_PATH, base.path)

if(is.na(tool.name) | is.na(descriptor.name)){
  cat("usage: Rscript extract.R <tool> <descriptor> [<path>]\n",
       "\n",
       "tool        name of the tool used to compute descriptors\n",
       "descriptor  name of the descriptor to extract\n",
       "path        optional path to all data")
  q(status=1)
}
if(!file.exists(paste0("extractors/", tool.name, ".R"))){
  cat(paste0("Error: tool '", tool.name, "' does not exist."))
  q(status=1)
}
if(!file.exists(base.path)){
  cat(paste0("Error: path '", base.path, "' does not exist."))
  q(status=1)
}

# TRAVERSE BASE PATH ###########################################################

for(track.length in list.dirs(paste0(base.path,"/descriptors"))){
  
}

