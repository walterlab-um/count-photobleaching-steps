# count-photobleaching-steps

## Description
Matlab script for automated counting of stepwise photobleaching in single-molecule intensity-versus-time traces.

## Requirements
If using the OpenFRET format, please clone/download the OpenFRET library from https://github.com/simol-lab/OpenFRET and place the library's folder + all subdirectories on your Matlab path.

## Installation and running
1. Clone repository
2. Add repository + subdirectories to Matlab path
3. Open main.m
4. Set desired options
5. Run main.m

Option `report_individual_results` indicates whether individual photobleaching step counting results are plotted and displayed for the user.  If set to `true`, results for each trace will be plotted and displayed until the user presses `ENTER`.  If set to `false`, individual traces will not be plotted; only a histogram of the final results will be.

## Input data types
- Single-channel `*traces.dat` or `*traces.mat` (Matlab .mat format)
- Two-channel `.traces` files (16-bit binary ieee-le format)
- Two-channel `.json` or `.json.zip` files in the OpenFRET format
