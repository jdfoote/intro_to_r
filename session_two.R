
###########################
###### Introduction #######
###########################

# For this session, we will be going through a simple exploratory analysis of a real
# dataset. We will import, clean, visualize, and analyze the data.

# First, let's import the tidyverse library and the dataset we'll be working with.

# install.packages('MASS')
library(MASS)
library(tidyverse)
library(lubridate)


wikia_data = read.csv('~/Desktop/wikia_data.csv', 
                      sep = ',',
                      quote = '"')

# Make sure it imported correctly
head(wikia_data)


#################
# Data and Goal #
#################

# I study online communities and how people work together to produce shared goods.
# For this class, we'll be looking at data about the structure of communication in 
# thousands of online wiki communities at Wikia.com 

# We are interested in how the network of who talks to whom relates to the group's performance,
# as measured by the total amount of content added in the first 500 edits.

# Networks were created by creating a directed edge between each editor of a talk page 
# and the five previous editors of that page.

# Brief variable descriptions:
# talk.edits - number of edits to talk pages
# words.added - number of total words (tokens) added to the main pages of the wiki in the first 500 edits
# editors - number of unique contributors
# talk.density - ratio of possible connections between editors which actually exist
# talk.diameter - maximum distance between two nodes in the network
# clustering.coef - How likely is it that adjacent nodes are connected?
# talk.kcore.gt.2 - Basically, what proportion of nodes are part of groups of at least 3 people
# days.from.start.to.end - How many days it took to go from 1 to 250 edits
# days.from.half.to.end - How many days it took to go from 250 to 500 edits
# founding.date - Day that the first edit was made

#################
# Data Cleaning #
#################

# Look at the summary stats
summary(wikia_data)

# It looks like there is some missing data (NA)

# It is important to understand why data is missing. Let's look at the rows that have missing data

wikia_data %>% # Take the data and pipe it
  filter(is.na(talk.clustering.coef)) %>% # Filter it to only the NA columns
  summary() # And provide a summary

# For these wikis there is very little activity on the talk pages but it appears that
# there is nothing wrong with the data. Because we're interested in talk networks
# it seems reasonable to remove these.
# Note: Be sure to note whatever data you don't include when reporting results

# Overwrite the current wikia_data variable with a version of the dataframe that only
# includes the non-NA items 
wikia_data = wikia_data %>%
  filter(!is.na(talk.clustering.coef))


# We can also look at the data types
str(wikia_data)

# Note that founding date is marked as a factor instead of a date. Let's change that.
# Dates are their own type, and having them recognized as dates lets us visualize and
# analyze temporal dimensions of the data correctly

wikia_data = wikia_data %>% # Remember, mutate creates a new column based on current columns
  mutate(founding.date = as.Date(founding.date, format = '%Y-%m-%d'))

# Check to make sure that looks OK.
summary(wikia_data)


##### Exercise ####
# Create a new column called last_edit_date which is the date of the 500th edit

# Your code here


#### Exercise #####

# Now create a new data frame called 'new_wikis' which only includes wikis whose last_edit_date is
# after January 1, 2009.


# Your code here

###################



#################
# Visualization #
#################

# After importing the data it's usually a good idea to plot some of the distributions.
# This is another way to check that the data is what you think it is and there aren't surprises


# To plot the distribution of non-date variables we can create histograms one at a time

wikia_data %>%
  ggplot() +
  geom_histogram(aes(x=talk.density)) # Histograms don't need a y variable, since the count is on the y-axis
  
# Or we can use facets to look at all of them at once

wikia_data %>%
  select(-founding.date) %>%
  gather() %>% # This puts the variables in a "long" format of key-value pairs
  ggplot() +
  facet_wrap(~ key, scales = 'free') + # This is that faceting that we looked at earlier
  geom_histogram(aes(value)) # And this is what kind of plot to use

# Sidenote: one nice thing about the pipe syntax is that if you get confused about what is going on
# you can break it apart and look at the output from just one part of the pipeline, e.g.:
wikia_data %>%
  select(-founding.date) %>%
  gather() %>%
  head()

# On the plot, notice that there is a big outlier in our DV, words added. Let's look at that one:
wikia_data %>%
  filter(words.added == max(words.added))

# This looks weird; it is a ton of content added by only 9 people.
# It is probably spam, so let's remove it.
# Note: For an actual analyses, you would do all you could to figure out where
# outliers come from before removing them
wikia_data = wikia_data %>%
  filter(words.added != max(words.added))


# Let's take a look at it again
wikia_data %>%
  ggplot() +
  geom_histogram(aes(x=words.added)) # Histograms don't need a y variable, since the count is on the y-axis


# That's a little better, but still highly skewed. Why might that be?

# We'll talk more about this when we talk about our regression analysis



#### Exercise #####

# Instead of a histogram, display density plots for all of the variables

# Your code here


####################




# We can also look at temporal changes to variables. First, let's see how many communities are created over time

wikia_data %>%
  group_by(founding.date) %>%
  tally() %>% # Count how many rows are in each group
  ggplot() + # And visualize it
  geom_line(aes(x=founding.date, y = n))

# That's odd. Let's look at those outliers.

# Here we compare summary information for the outliers and everyone else
wikia_data %>%
  group_by(founding.date) %>%
  filter(n() > 29) %>% # The n() function is the count of members of each group
  summary()

summary(wikia_data)

# It's not totally clear what is going on here. The summary stats look similar, with 
# the exception of the days from start to end and days from half to end.
# It looks like there may be an error in the founding date. 
# Let's create a new dataset that removes the outlier communities.

wikia_data2 = wikia_data %>%
  group_by(founding.date) %>%
  filter(n() < 29) %>% # Filter the outliers
  ungroup() # And change it so it isn't grouped anymore


# Let's also look at how the median number of words added changes over time. Theoretically,
# there's no good reason to assume that it will change

wikia_data2 %>%
  group_by(month=floor_date(founding.date, 'month')) %>% # This just groups by month instead of by day
  summarize(med_words = median(words.added)) %>%
  ggplot() + 
  geom_line(aes(x=month, y=med_words))


# Do you have any theories about why this might be decreasing over time?



#### Exercise #####

# Plot the median clustering coefficient over time

# Your code here

####################




# It's also useful to look at how some of these variables relate to each other, since 
# linear regression can suffer from multicollinearity.

# It seems like the number of contributors could be correlated with the number of people
# in groups. It's easier to be in groups if there are a lot of people.

# Let's make a scatterplot of that relationship
wikia_data2 %>%
  ggplot() +
  geom_point(mapping = aes(x=editors,
                           y=talk.kcore.gt.2)) + 
  scale_x_log10() # We log editors since it's so skewed

# Is there a pattern in this relationship?



#### Exercise ####

# Density and diameter seem like they might also be closely related. Make a scatterplot of these two variables


# Your code here


# Now add the best fit line to the plot (see our last lesson for hints)


####################



# Our goal is to predict the number of words added to the wiki so let's plot that relationship, too

wikia_data2 %>%
  mutate(density_levels = cut(talk.density, breaks = c(0,.25,.5,.75,1), # This breaks a continuous variable up into a categorical one
                              labels = c('lowest','low','high','highest'))) %>%
  ggplot() + 
  geom_boxplot(mapping = aes(x = density_levels, y = words.added)) + 
  scale_y_log10()




#### Exercise ####

# Make a boxplot comparing the talk diameter and the words added.

# Your code here


### Advanced exercise ###
# Make a faceted plot with scatterplots for all of the variables by the words added.


# Your code here

##################




##############
# Regression #
##############

# Our goal is to predict the number of words added.
# Remember that this is highly skewed count data so we use a negative binomial function


fit = glm.nb(words.added ~ talk.edits + talk.diameter + talk.density, data = wikia_data2)

# Let's check the residual fit. This helps us know how well our model fits the data
plot(density(resid(fit)))
qqnorm(resid(fit))

# It looks like there are some outliers that might be skewing our data. It is often
# acceptable to remove them
# See https://stats.stackexchange.com/questions/175/how-should-outliers-be-dealt-with-in-linear-regression-analysis
# for a discussion about other approaches

cutoff =  3 * sd(resid(fit))

wikia_data3 = wikia_data2[abs(resid(fit)) < cutoff,] # This is the base R version of filtering

fit1 <- glm.nb(words.added ~ talk.edits + talk.diameter + talk.density, data = wikia_data3)

summary(glm.nb(words.added ~ ., data = wikia_data3))

qqnorm(resid(fit1))

# This looks a lot better.

summary(fit1)

plot(wikia_data3$talk.density, resid(fit1))




###### Exercise ######

# Add some additional variables to predict words added.
# Think about what you think might influence the words added and whether you think
# that the variable would be positively or negatively associated with the words added



# Remember to plot the residuals to look at the fit; remove outliers if necessary



##### Exercise #####

# Another option when dealing with skewed data is to dichotimize it.
# Run a logistic regression predicting whether a wiki will have more or
# less than the median number of words added.


######################