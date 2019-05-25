# Data-Driven_Crime_Prevention
## Abstract
Having the ability to forecast crime statistics in a region can greatly benefit decision making of law enforcement leaders and policymakers. This paper presents the process of generating county-level forecasts for crime statistics by developing and evaluating machine learning models based on a combination of incident-based crime data for the state of Virginia, USA, and complementary demographic datasets. With the type of offense as the supervised variable, our models revealed that the types of crime that occur most frequently in a county are strongly influenced by the hour of incident, weekday, day of month, and month as well as county population and median housing price. In order to create a prototype, we exported the model into an interactive dashboard, through which users can extract actionable insights and forecasts of crime statistics.
## Data Source
### https://crime-data-explorer.fr.cloud.gov/downloads-and-docs
## Instruction to Run
### Python Notebook (CrimeData.ipynb)
Extract all contents of the project .zip file into any folder on your computer but do not change the directory structure within the extracted folder.
  
Ensure you install the following Python packages before running:
  
    o	glob
    o	string
    o	pandas
    o	numpy
    o	os

To install the h2o package, follow the instructions under the “Install in Python” tab in the following link: http://h2o-release.s3.amazonaws.com/h2o/rel-xu/4/index.html

### R Studio/R Shiny (CrimeViewer/app.R)
Ensure you install the following packages before running
  
    o	shiny
    o	shinythemes
    o	leaflet
    o	rgdal
    o	ggplot2

To install the h2o package, follow the instructions under the “Install in R” tab in the following link: http://h2o-release.s3.amazonaws.com/h2o/rel-xu/4/index.html

In line 34, ensure the variable model_path is assigned the string equivalent to the path of the “GBM_model” file of the extracted project folder

    o	Do NOT insert a slash (“/”) at the end of the path 
### Notes
It is important that you install h2o for both Python and R using the links in the instructions above for model file compatibility
