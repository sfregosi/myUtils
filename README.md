# myUtils
Miscellaneous functions/utilities for MATLAB

Last Updated: 30 April 2025

##### Table of Contents
Maybe I'll put some section headers here!



## Functions

*some key/most useful ones, in no particular order*

`decimateDir` - (in dataProcessing/downsampling folder) decimate a directory of `.wav` or `.flac` filess within a single directory (see [CRPTools/dasbr_utils/decimate](https://github.com/sfregosi-noaa/CRPTools/tree/main/dasbr_utils/decimate) for alternatives to process several subdirectories e.g., multiple DASBRs from a single cruise)

`dist_km` - calculates approx distance in km between two lat/lon points (requires Mapping Toolbox)

`newFun` - creates a function m-file with a template of proper help documentation
`newScript` - creates a script m-file with a template of help documentation at the top

`flac2wav` - command line wrapper to decode a directory of `.flac` files to `.wav`
`wav2flac` - command line wrapper to encode a directory of `.wav` files to `.flac`

`stripEmpties` - remove the '.' and '..' folders after running a `dir` command

`unix2matlab` - convert from Unix time (in seconds) to MATLAB datenum
`matlab2unix` - convert from MATLAB datenum to Unix time in seconds

`decdeg2degmin` - switch between decimal degrees and degrees decimal minutes format for lat/lon data
`decdeg2degminsec` - switch between decimal degrees and degrees minutes seconds format for lat/lon data
`degmin2decdeg` -  switch between degrees decimal minutes and decimal degrees format for lat/lon data
`degminsec2decdeg` -  switch between ddegrees minutes seconds and decimal degrees format for lat/lon data


