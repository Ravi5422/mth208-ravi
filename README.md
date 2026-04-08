# India Health Dashboard
A Shiny dashboard visualizing key health trends in India, including state-level mortality causes, cancer deaths, self-harm statistics, and long-term cancer forecasts.
#  Required packages

Install the required R packages:

```r
install.packages(c(
  "shiny",
  "ggplot2",
  "dplyr",
  "shinythemes",
  "readr",
  "shinyWidgets"
))
```
# Required csv files
Place the following CSV files in your app’s working directory: 

    Types of Cancer Deaths.csv
    heat map pf states.csv
    self harm.csv
    Cancer Prediction India rate.csv
# Setting working directory
```r
setwd('path to your directory containing the shiny app')
shiny::runApp('app.R')
```
# Package version used
```
| Package      | Version |
|--------------|---------|
| R            |4.5.1    |
| shiny        | 1.11.1  |
| ggplot2      | 3.5.2   |
| dplyr        | 1.1.4   |
| shinythemes  | 1.2.0   |
| readr        | 2.1.5   |
| shinyWidgets | 0.9.0   |
```
