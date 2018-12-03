# Computer Vision Currency Conversion
## Authors: Katrina Steinman and Clayton Kramp
## Description of files:
### fasterCNN.m
Our faster R-CNN model that given an input image, proposes the region of interest.  This ROI can be used to crop the image and pass it down through our pipeline.  Opens the `localization\_labelled.mat` file for data input.
### convert.m
Conversion file that given an image with ROI, classifies each symbol within it, and projects the converted currency.
### helper/loadMNIST
helper to load the MNIST data
### helper/resizeLocalizationImages.m
Helper to resize our localization image to be 200 x 300 and to be in grayscale
### helper/symbolDataCreation.m
Helper to construct our symbol dataset given an image with a bunch of symbols
### helper/processSymbol.m
Helper to construct the input data and labels for our symbol data

## What to do to run
First train the Faster R-CNN model with `fasterCNN.m`.  Then, pass it an image you are interested in, and have use the proposed bounding box to crop.  Type `addpath('helper')` to include helper functions to your working directory, and then pass this image into `convert.m` to have it project the currency exchange.

## Data
Contains data on the symbols and MNIST
## Images
Contains images that were used to train the localization network and for testing purposes
## Presentation
Contains pretty pictures used for our presentation
