# Learning the Basics of R

This tutorial is intended to give non-programmers an introduction to three main tasks in R:

1. Importing and cleaning data
2. Summarizing and visualizing data
3. Applying inferential models to data

## Prep work

**Install R**

R is an [open-source](https://en.wikipedia.org/wiki/Open-source_software) statistical programming language. We will be working with it through RStudio but before installing RStudio you need to [install R](http://cran.us.r-project.org/).

**Install RStudio**
You need to set up an R programming environment. The easiest way to do this is to download and install [RStudio](https://www.rstudio.com/products/rstudio/download/#download) (download the free, open-source version).

**Install packages**

One of the most powerful concepts in programming languages is packages (also called libraries). Packages are code that other people have written which make common tasks much simpler. You can "import" them and then reuse this code.

We will be using the dplyr, ggplot2, hflights packages. You will need to install them by:
1. Opening RStudio
2. Copying the following into the console (at the bottom left):
```
    install.packages(c('dlpyr','hflights'))
```
3. Push enter

It should download and install these two packages. To make sure that it worked run the following in the console (again, copy and paste):

```
library(hflights)
library(dplyr)
library(ggplot2)

hflights %>%
  sample_n(500) %>%
  select(ArrDelay, DepDelay) %>%
  ggplot(aes(x=ArrDelay, y=DepDelay)) + 
    geom_point()
```

Don't worry if this code looks super confusing and doesn't make sense yet - after the workshop you'll know what all of this does!

If everything installed correctly, then you should see a scatterplot appear at the bottom right of RStudio. If it didn't work then look over all of the steps and see if you missed something.

**Download materials**

Download the Rmd files from this page (intro.Rmd, community_analysis.Rmd) by right-clicking on them and saving them to somewhere you can find them.

Check to make sure they worked by trying to open them in RStudio.



# Thanks

I've reused a lot of code for this tutorial from https://github.com/justmarkham/dplyr-tutorial and https://github.com/j3schaue/dplyr_workshop

In that same spirit, please feel free to reuse this work.
