##############
# INTRO TO R #
##############

# This tutorial is intended to introduce you to some of the basic functions of R as used by data scientists.
# It is intended to show you the sorts of things that R can do as a tool.
# It will not teach you all that you need to know in order to do this kind of work.

# If you want to learn more, there is a fantastic online book called _R for Data Science_ at
# http://r4ds.had.co.nz/index.html



# We will start with some basic concepts that are common to all programming languages, including R.


# Some basic terminology and concepts
#-------------------------------------

# Libraries:

# Libraries are code written by other people that can be imported into your code and reused.
# R also uses the term 'package' to refer to the same idea.

# We will be using the 'dplyr' library and syntax, so we need to import it. This tells R that we
# are going to use it and it loads the functions of the library.

library(dplyr)

# You should have already installed dplyr, but if Rstudio complains that dplyr isn't installed then you need to run: install.packages('dplyr')


# Variables:

# Variables are like containers that store things so that you can reuse them again.

x = 1

# stores the number 1 in the variable x. We can then do operations on x which change the value.

x = x + 1

print(x)

# This adds 1 to x, so now x stores the number 2.


# Functions:

# Functions are little pieces of code that take variables as input and produce an output.

add_one = function(n) {
  return(n + 1)
}

x = add_one(x)

print(x) # Print is also a function!


##################
# Importing Data #
##################

# R has a number of tools for importing different data types.
# We'll focus on the most common - importing CSVs

# We won't use this data in this tutorial, but this is how you import a CSV
wikia_data = read.csv('wikia_data.csv')
# And this is how you look at the first few rows to make sure it imported OK
head(wikia_data)


# For this tutorial, we'll be using a prepared dataset of flights from NYC in 2013. This is how to load it:
# Again, run this if it isn't installed yet: install.packages("nycflights13")
library(nycflights13)

################
# Loading Data #
################

# The dataset includes four dataframes. Dataframes are sort of like R's version of spreadsheets.
head(flights)
head(airlines)
head(weather)
head(planes)

# We will be using functions from dplyr. These make R much easier to understand.
# There are 6 basic functions: filter, select, arrange, mutate, summarize, and group_by.

# For each function, they take in a dataframe as the first argument (together with other arguments)
# and provide a dataframe as output.


## filter: keep rows that match certain criteria

# get the records for United Airlines
filter(flights, carrier=="UA")

# Or we could store this result in a new variable
temp_df = filter(flights, carrier=="UA")
head(temp_df)

# You can use pipe for OR condition or & for AND
filter(flights, carrier=="AA" | carrier=="UA")
filter(flights, carrier=="AA" & month>5)


## select: keep columns that match certain criteria

# Commas between a list of columns to keep
select(flights, carrier, dep_delay, arr_delay)

# Colons to keep everything between two columns
select(flights, carrier:dep_delay, arr_delay)

# Or remove columns with '-'
select(flights, -(carrier:dep_delay))

# You can even rename columns
select(flights, carrier, minlate=arr_delay)



## arrange: Put dataframes in order 
# default is ascending (smallest first); this is the flights that left earliest
arrange(flights, dep_delay)

# We can also see those that left latest
arrange(flights, desc(dep_delay))

# Or order by multiple columns
arrange(weather, desc(wind_dir), temp)



## mutate: create new columns
# Add a column to indicate high wind
tmp = select(weather, year:hour, wind_speed)
tmp = mutate(tmp, high_wind = wind_speed > 30)
# And then filter to just those with high wind
filter(tmp, high_wind == TRUE)


## summarize: Create summary data from a dataframe (we'll come back to this with group_by)
# Get the mean arrival and departure delays
summarize(flights, 
          mean_dep=mean(dep_delay, na.rm=T), 
          mean_arr=mean(arr_delay, na.rm=T))

# Get the standard deviations of each
summarize(flights, 
          sd_dep=sd(dep_delay, na.rm=T), 
          sd_arr=sd(arr_delay, na.rm=T))


#########################
### Combining functions #
#########################

# There are a few different ways to combine functions together.

# First, saving intermediate dataframes

tmp = filter(flights, arr_delay > 5)
tmp = select(tmp, year:arr_delay)
head(tmp)

# Next, enclosing them
select(filter(flights, arr_delay > 5), year:arr_delay)

# Finally, dplyr has a piping option

## With piping, the output from one function becomes the first argument passed
# to the next function
latearr = flights %>% 
            filter(arr_delay > 5) %>% 
            select(year:arr_delay)

# Compare am and pm flights for delays
am_stats = flights %>%
              filter(sched_arr_time < 1200) %>%
              summarize(mn_arr_delay = mean(arr_delay, na.rm=T),
                        mn_dep_delay = mean(dep_delay, na.rm=T),
                        p_delay = mean(as.integer(dep_delay > 5), na.rm=T))

pm_stats = flights %>%
  filter(sched_arr_time >= 1200) %>%
  summarize(mn_arr_delay = mean(arr_delay, na.rm=T),
            mn_dep_delay = mean(dep_delay, na.rm=T),
            p_delay = mean(as.integer(dep_delay > 5), na.rm=T))


am_stats
pm_stats
am_stats - pm_stats



## group_by: puts rows into groups so that they can be summarized

flights %>% 
  group_by(carrier) %>% 
  tally() %>% # tally counts how many are in each group and puts the count in a column called 'n'
  arrange(desc(n)) # and this sorts by the n column

# The summarize function becomes particularly useful with group_by
planes %>% 
  group_by(manufacturer) %>% 
  summarize(mn_age = mean(2017 - year, na.rm=T), mn_size=mean(seats, na.rm=T)) %>%
  arrange(desc(mn_age))

# Weather by airport
weather %>% 
  group_by(origin) %>%
  summarize(max_gust = max(wind_gust, na.rm=T),
            mn_wind = mean(wind_speed, na.rm=T),
            mn_tmp = mean(temp, na.rm=T),
            min_vis = min(visib, na.rm=T),
            max_vix = max(visib, na.rm=T),
            mn_vis = mean(visib, na.rm=T))


# Visualizations

# We can take the outputs and pass them to another library, ggplot2, which makes visualizations
library(ggplot2)

# ggplot works based on this template:
# ggplot(data = <DATA>) + 
#   <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>)) + 
#   <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>))

# Scatterplot
flights %>% 
  sample_n(3000) %>% # Random sample to make it faster
  ggplot() + 
  geom_point(aes(x=arr_delay, y=dep_delay))

# With colors by category
flights %>% 
  sample_n(3000) %>%
  ggplot() + 
  geom_point(aes(x=arr_delay, y=dep_delay, color=carrier))

# You can also layer additional plots, like the linear fit
flights %>% 
  sample_n(3000) %>% 
  ggplot() + 
  geom_point(aes(x=arr_delay, y=dep_delay, color=carrier)) +
  geom_smooth(mapping=aes(x=arr_delay, y=dep_delay), method = 'lm')

# Note: If you'll be reusing the same aesthetics over and over,
# you can put them in the ggplot() call, like so:
flights %>% 
  sample_n(3000) %>%
  ggplot(mapping = aes(x=arr_delay, y=dep_delay)) + 
  geom_point(mapping=aes(color=carrier)) + # The color only applies here, so it has to be here
  geom_smooth( method = 'lm')


# Histograms and density plots
flights %>%
  ggplot(mapping = aes(x=dep_time)) +
  geom_histogram(fill='blue', alpha=.7) +
  xlab('Departure time') + # Label for x-axis
  ggtitle('Histogram of departure times')


# And a density plot
flights %>%
  ggplot(mapping = aes(x=dep_time)) +
  geom_density(fill='blue', alpha=.7)


# When plotting skewed data you can log the axis
flights %>%
  ggplot(mapping = aes(x=dep_delay)) +
  geom_histogram(fill='blue', alpha=.7) +
  coord_trans(y='log1p')

# Faceting lets you look at the same plot, with data broken up by group
flights %>%
  ggplot(mapping = aes(x=dep_time)) +
  geom_histogram(fill='blue', alpha=.7) +
  xlab('Departure time') + # Label for x-axis
  ggtitle('Histogram of departure times') +
  facet_wrap(~ carrier)

# Joyplots / ridge plots are another approach
# (to try this one run install.packages('ggridges') and library(ggridges))
# library(ggridges)
flights %>%
  ggplot(mapping = aes(x=dep_time)) +
  geom_density_ridges(mapping=aes(y=carrier,fill=carrier), alpha=.7) +
  xlab('Departure time') + # Label for x-axis
  ggtitle('Density plot of departure times by carrier') + 
  theme(legend.position = '') # Get rid of the legend

# Boxplots

# Let's look at delays by month
flights %>%
  ggplot(mapping=aes(y=dep_delay, 
                     x=as.factor(hour))) + 
  geom_boxplot()

# We can clean this up by breaking the day into chunks

flights %>%
  mutate(time_of_day=cut(hour, 
                         breaks=c(-1,6,12,18,24), 
                         labels=c('early morning',
                                  'morning',
                                  'afternoon',
                                  'night'))) %>%
  ggplot(mapping=aes(y=dep_delay, 
                     x=time_of_day))+ 
  geom_boxplot()

# We can also compare carriers
flights %>%
  filter(carrier == 'UA' | carrier == 'AA') %>%
  mutate(time_of_day=cut(hour, 
                         breaks=c(-1,6,12,18,24), 
                         labels=c('early morning',
                                  'morning',
                                  'afternoon',
                                  'night'))) %>%
  ggplot(mapping=aes(y=dep_delay, 
                     x=time_of_day,
                     color=as.factor(carrier))) + 
  geom_boxplot()


## Note about NA's and missing values ##

# For a bunch of plots we got an error message about rows being removed. What's that about?

# This shows us summary information about the dep_time column
flights %>%
  select(dep_time) %>%
  summary()

# It looks like the original data has a bunch of NA's - this is missing data.
# It's often important to understand why data is missing and how that could
# influence conlclusions.

# For example, we might check if they were all from the same carrier
flights %>%
  ggplot(aes(x=carrier, fill=is.na(dep_time))) + # The color is whether it's missing or not
  geom_bar(position = position_dodge()) # position_dodge() makes them show up next to each other

# By default, R will remove NAs from graphs and many other functions.
# In this case, NA's (I believe) represent canceled flights so that's probably OK,
# depending on the question we are trying to ask



# Regression

# Again, there are entire courses on this topic so this is a very simple introduction

# Let's try to predict whether a flight will be delayed by at least 1 hour

# First, let's make a variable

tmp = flights %>%
  mutate(long_delay = dep_delay > 60)

# Let's make sure there are enough instances for prediction to be useful
summary(tmp$long_delay)


# For the lm package we have to pass in a formula that is used to fit a regression model.
# They are in the format 'y ~ x1 + x2 + x3'
# There is also a shorthand 'y ~ .' will try to predict y using all other variables

# Note that glm isn't part of dplyr and so we can't pipe to it directly
tmp2 = tmp %>%
  select(-time_hour, -dep_delay, -tailnum, -dest,-arr_delay)

# Let's start with a really simple model. Summary gives a nice output
# but you can save these fitted objects and do all sorts of things with them
summary(glm(long_delay ~ distance, data=tmp, family=binomial))

# Longer flights are much less likely to be delayed

# What if we add in the month
summary(glm(long_delay ~ distance + as.factor(month), data=tmp, family=binomial))

# We can see that this is a better fit as well, since the AIC is lower (although there are lots of other tests)

# Finally, let's add in carriers
summary(glm(long_delay ~ distance + as.factor(month) + carrier, data=tmp, family=binomial))


