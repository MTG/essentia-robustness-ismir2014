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

if(!file.exists(file.path("extractors", paste0(tool.name,".R")))){
  cat(sep="", "Error: tool '", tool.name, "' does not exist.\n")
  q(status=1)
}
path.descriptors <- file.path(path.base, "descriptors", tool.name, track.length, srate)
if(!file.exists(path.descriptors)){
  cat(sep="", "Error: path '", path.descriptors, "' does not exist.\n")
  q(status=1)
}

# Source the extractor code and check that extractor is defined
source(file.path("extractors", paste0(tool.name,".R")))
if(!exists("extract.data", mode="function")){
  cat(sep="", "Error: tool '", tool.name, "' does not define an 'extract.data' function.\n")
  q(status=1)
}

# RUN ##############################################################################################

library(tools)

# Prepare destination file =========================================================================

# For efficiency, we simply write tab-separated raw data instead of creating a temporary data.frame
# and then writing it to the file.
path.extracted <- file.path(path.base, "results", tool.name, track.length, srate, descriptor.name,
                            "extracted.txt")
dir.create(dirname(path.extracted), recursive=T, showWarnings=F)
# Delete previous data, if any
unlink(path.extracted, force=T)
# Initialize file
conn <- file(path.extracted, open="w")
# At this point we don't know anything about analysis parameters or size of the descriptor data,
# so we can't just write column names now. Keep this variable to tell us when to write the header
# for the first time.
conn.head <- F

# Traverse file structure and extract ==============================================================
for(codec.path in list.dirs(recursive=F, path.descriptors)){
  codec <- basename(codec.path)
  for(brate.path in list.dirs(recursive=F, codec.path)){
    brate <- basename(brate.path)
    for(params.path in list.dirs(recursive=F, brate.path)){
      # Parse params. If just '=', set to empty vector
      params <- basename(params.path)
      if(params=="-"){
        params <- NULL
      }else{
        params <- unlist(strsplit(params, split="-", fixed=T))
      }
      for(genre.path in list.dirs(recursive=F, params.path)){
        genre <- basename(genre.path)
        for(file.path in list.files(recursive=F, full.names=T, genre.path)){
          file <- basename(file_path_sans_ext(file.path))
          
          # Extract descriptor from file
          d <- extract.data(file.path, descriptor.name)
          if(is.null(d)){
            # Something wrong with extractor, probably wrong descriptor name
            cat(sep="", "Error: null descriptor data for file '", file.path, "'.\n")
            q(status=1)
          }
          
          # Write column names if first time here
          if(!conn.head){
            if(is.null(params)){
              newline <- paste(c("codec", "brate",
                                 "genre", "track",
                                 paste0("x", seq_along(d))), collapse="\t")
            }else{
              newline <- paste(c("codec", "brate",
                                 paste0("param", seq_along(params)),
                                 "genre", "track",
                                 paste0("x", seq_along(d))), collapse="\t")
            }
            writeLines(newline, con=conn)
            conn.head <- T
          }
          # Write actual descriptor data          
          if(is.null(params)){
            newline <- paste(c(codec, brate, genre, file, d), collapse="\t")
          }else{
            newline <- paste(c(codec, brate, params, genre, file, d), collapse="\t")
          }
          writeLines(newline, con=conn)
        }
      }
    }
  }
}

# Close destination file
close(conn)
