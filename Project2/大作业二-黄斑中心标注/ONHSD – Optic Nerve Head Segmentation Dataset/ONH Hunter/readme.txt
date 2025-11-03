ONHMarkup Directory
-------------------

Contains the m-files for Optic Nerve Head Segmentation.

m-files are broadly divided into categories - Fitting routines,
Analysis routines, Graphing routines, CLinician Markup routines,
plus a few others.

The BatchExperiments.m file is a good place to start, to see
how the major routines to generate global and local models,
then to calculate disparity stats, run.

All the m-files needed are in this directory, even utilities that
may be available elsewhere.

The data set for analysis should be put into the directory with the
m-files (*.bmp files) - there should be no other bmps in this directory.
The standard 99 bmps are included.

Sub-directories are needed: "Clinicians" to hold the clinician mark-up data;
"ONHResults" to hold files giving results of experiments with various settings.

The ONHUsed.mat file can be loaded ("load ONHUsed") to yield an array which nominates
the 90 images used for evaluation of segmentation of the algorithm; this can be passed
to various analysis/graphing routines that expect a "range" parameter to specify which
images should be used.
