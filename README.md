# Learning the Basics of R

This material is designed for a two session workshop, intended to give non-programmers an introduction to three main tasks in R:

1. Importing and cleaning data
2. Summarizing and visualizing data
3. Applying inferential models to data

Each of these topics could be its own entire course and so this is intended more as an example of what R can do with some resources to help you to learn more. The first workshop will show the basic features of R on flight data. The second workshop will be more hands-on, with demonstrations of how to apply these principles to a real-world online community dataset.

## Prep work

To make the workshop successful, it is vital that you come with the required software installed and working. Follow the instructions below carefully and test to make sure everything is working.

**Install R**

R is an [open-source](https://en.wikipedia.org/wiki/Open-source_software) statistical programming language. We will be working with it through RStudio but before installing RStudio you need to [install R](http://cran.us.r-project.org/).


**Install RStudio**

RStudio is an interface that makes working with R much easier. You can download and install it [here](https://www.rstudio.com/products/rstudio/download/#download) (download the free, open-source version).

**Install packages**

One of the most powerful concepts in programming languages is packages (also called libraries). Packages are code that other people have written which make common tasks much simpler. You can "import" them and then reuse this code.

We will be using the tidyverse, MASS, and nycflights13 packages. You will need to install them by:
1. Opening RStudio
2. Copying the following into the console (at the bottom left):
```
install.packages(c('tidyverse','MASS','nycflights13'))
```
3. Push enter

It should download and install these packages. To make sure that it worked run the following in the RStudio console (again, copy and paste):

```
library(nycflights13)
library(dplyr)
library(ggplot2)

flights %>%
  sample_n(500) %>%
  select(arr_delay, dep_delay) %>%
  ggplot(aes(x=arr_delay, y=dep_delay)) + 
  geom_point()
```

Don't worry if this code looks super confusing and doesn't make sense yet - after the workshop you'll know what all of this does!

If everything installed correctly, then you should see a scatterplot appear at the bottom right of RStudio. If it didn't work then look over all of the steps and see if you missed something.

**Download materials**

Download the R files (session_one.R, session_two.R) and CSV file (wikia_data.csv) files from this page by right-clicking on them and saving them to somewhere you can find them during the workshop.


# Thanks

I've reused a lot of code for this tutorial from https://github.com/justmarkham/dplyr-tutorial and https://github.com/j3schaue/dplyr_workshop

In that same spirit, please feel free to reuse this work.
