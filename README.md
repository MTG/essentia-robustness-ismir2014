essentia-robustness
===================

This is a collection of R scripts to analyze the robustness of audio descriptors to different encodings and analysis parameters, as performed for instance in this paper:

- J. Urbano, D. Bogdanov, P. Herrera, E. Gómez and X. Serra, "[What is the Effect of Audio Quality on the Robustness of MFCCs and Chroma Features?](http://mtg.upf.edu/system/files/publications/025-what-effect-audio-quality-robustness-mfcc-chroma-features_0.pdf)", in 15th ISMIR Conference, 2014.

How to run
----------

Use `robustness.R` as the main entry point from `Rscript`:

	> cd R
	> Rscript robustness.R
	usage: Rscript robustness.R <command> <tool> <track-length> <srate> <descriptor> [<path>]

	  command       command to run (see below).
	  tool          name of the tool used to compute descriptors, eg. 'essentia'.
	  track-length  length of the tracks used to compute descriptors, eg '30-60'.
	  srate         sampling rate of the tracks used to compute descriptors, eg. '44100'.
	  descriptor    name of the descriptor to analyze, eg. 'lowlevel.mfcc.mean'.
	  path          optional path to all data (see below), defaults to '../data'.

	Available commands are (in expected order of execution):
	  extract        extract data specific of the descriptor.
	  indicators     compute robustness indicators.
	  distributions  describe the distributions of the indicators.
	  boxplots       boxplot the distributions of the indicators.
	  variance       decompose in variance components.
	  --
	  all            run all commands (extract, indicators, distributions, variance).
	  help           show this message.

	Expected file structure of descriptors:
	  path/descriptors/<tool>/<track-length>/<srate>/<descriptor>/<codec>/<brate>/<param1>-...-<paramN>/<genre>/file
	Output file structure:
	  path/results/<tool>/<track-length>/<srate>/<descriptor>/<command>.txt
	  
Dependencies
------------

The following R packages are required:
- `rjson`
- `tools`
- `doBy`
- `lme4`