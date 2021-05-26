#### USING GGPLOT2 TO VISUALISE YOUR DATA ----

# Part 1: Bare Bones - Getting familiar with ggplot syntax
# Authors: Angus Hughes
# Date: 27/5/2020

#### Importing the packages and data ----

# Install ggplot2 package and load it from your library
# install.packages("tidyverse")
library(tidyverse)

# Import the data
data <- readRDS("experimental_data.rds")

# Checking our variables in the dataset
names(data)

# Inspect the data (alternatively click on data in the Environment tab)
View(data)

#### Plotting the distribution of one variable ----

# The simplest plot possible is a histogram.
# This only requires one variable on the x-axis. If it's continuous, 
# ggplot will split it into 'bins' and count the frequency on the y-axis. 
# Let's try with our 'rumination' variable.
ggplot(data, aes(x = rumination)) +
  geom_histogram()

# A cleaner way of seeing the distribution is to 'smooth' this out using
# a density plot. Again, let's take a look at the 'rumination' variable
ggplot(data, aes(x = rumination)) +
  geom_density()

# ### EXERCISE ###
# Try plotting the density of the 'stress' variable...
#
# - YOUR CODE HERE -
#
# ### ### ### ### 

# Let's say our x-axis variable isn't continuous, but falls into categories. 
# We can use a bar graph of a single (discrete) variable:
# Days of sleep difficulty in the last fortnight ('sleep_diff') 
ggplot(data, aes(x = sleep_diff)) +
  geom_bar()

# We can also modify the 'aesthetics' of the bar graph to provide information
# about sleep difficulty separated by treatment (our experimental variable). 
# We want to `fill` the bars by treatment.
ggplot(data, aes(x = sleep_diff, 
                 fill = treatment)) +  # Adding `fill =` to `aes()`
  geom_bar()

# The default is stacked bars. Looks nice, but doesn't help much in comparing. 
# Instead, we might want to tell `geom_bar` to allow these separately filled 
# bars to "dodge" one another -- creating a clustered bar chart
ggplot(data, aes(x = sleep_diff, 
                 fill = treatment)) +
  geom_bar(position = "dodge")

# ### EXERCISE ###
# Try plotting the density of the 'stress' variable once again, 
# but this time grouped by treatment using `fill...
#
# - YOUR CODE HERE -
#
# ### ### ### ### 

## Return to slides ## 

#### Plotting the distribution of two variables ----

# Let's look at the relationship between two variables: 
# Treatment (categorical experimental variable) and Stress (continuous outcome).
# We can use two different methods here - geom_boxplot() or geom_violin()

# Notice we now need to tell ggplot what variable will go on the y-axis also.
# Starting with the traditional boxplot
ggplot(data, aes(x = treatment, 
                 y = stress)) +
  geom_boxplot() 

# There's evidently a slight difference here - controls had higher stress. 
# But a violin plot captures the 'density' in the continuous variable better
ggplot(data, aes(x = treatment, 
                 y = stress)) +
  geom_violin()

# Let's check the relationship between two continuous variables, rumination 
# and negative affect. We can make a scatter plot using geom_point.
ggplot(data, aes(x = rumination, 
                 y = negative_affect)) +
  geom_point()

#### Styling and Layering your Ggplot ----

# Why stop at one geom!
# Ggplot allows you to stack layers of plots one on top of another.
# Let's add a new layer on top that will run a regression (i.e. a "linear 
# model", or lm for short) and plot the regression line.
ggplot(data, aes(x = rumination, 
                 y = negative_affect)) +
  geom_point() +
  geom_smooth(method = "lm")

# ### EXERCISE ###
# Try plotting the distribition of stress (on the X-xis) 
# by self-esteem (Y-axis), with the regression line......
#
# - YOUR CODE HERE -
#
# ### ### ### ### 

# We can also stack 'layers' that change the look and feel of the plot.
# Themes allow quick stylised changes in template form. Check the standard
# ones included in ggplot out here:
# https://ggplot2.tidyverse.org/reference/ggtheme.html

# Let's check out theme_minimal()
ggplot(data, aes(x = rumination, 
                 y = negative_affect)) +
  geom_point() +
  geom_smooth(method = "lm") +
  theme_minimal()

# Have a try: Replace the theme_minimal() with one of these below
# theme_bw()  theme_classic()  theme_dark()  theme_linedraw()

# Next we start tweaking arguments *inside* our geom functions.
# Once again we set the transparency of dots using `alpha = ` (0 to 1). 
# We can use `size = ` and `colour = ` to style geoms as well.
ggplot(data, aes(x = rumination, 
                 y = negative_affect)) +
  geom_point(alpha = .5,      # Set points to be half-transparent
             colour = "red",  # Make our points red.
             size = 4) +      # Make out points big!
  geom_smooth(method = "lm", 
              color = "navyblue") + 
  theme_minimal()

# Have a go: Play around with altering alpha, size, and colour!
# A full list of colours can be found here:
# http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf 

# Finally, let's use titles and some cleaner labels for our axes.
# You can set a number of such annotations using `labs()`
ggplot(data, aes(x = rumination, 
                 y = negative_affect)) +
  geom_point(alpha = .5,  
             colour = "red", 
             size = 4) +    
  geom_smooth(method = "lm", 
              color = "navyblue") + 
  # Set the labels - `labs()`
  labs(x = "Rumination", 
       y = "Negative Affect",
       title = "My Pretty Plot", 
       subtitle = "It's beautiful!",
       caption = "Don't you agree?") +
  theme_minimal()

# ### EXERCISE ###
# Try and see if you can split the data so that different 
# colours represent different treatment groups ...
# HINT: Think about how `fill =` worked. How could we do something similar? 
#
# - YOUR CODE HERE -
#
# ### ### ### ### 

# Specialized themes - seperating points for both treatmeant groups (colour blind) 
# This is a cool website to check how your figures look for those with colour blindness: 
# https://www.color-blindness.com/coblis-color-blindness-simulator/
# install.packages("viridis") 

library(viridis)
ggplot(data, aes(x = rumination, 
                 y = negative_affect)) +
  geom_point(aes(colour = treatment),  # Tricky! The `aes()` can actually go directly
             alpha = .5,               # into a geom function! 
             size = 3) +
  geom_smooth(method = "lm", 
              color = "black") +
  theme_minimal() + 
  scale_colour_viridis_d() # will colour discrete variables

# Here's another trick that might help if you need to publish in black and white.
# You can set the `shape =` of the points in `aes()` to vary by group as well!
ggplot(data, aes(x = rumination, 
                 y = negative_affect)) +
  geom_point(aes(colour = treatment,
                 shape = treatment),  # Now shape depends on treatment variable
             alpha = .5,     
             size = 3) +
  geom_smooth(method = "lm", 
              color = "black") +
  theme_bw()

# Quick Quiz! What's wrong with this plot below??
ggplot(data, aes(x = rumination, 
                 y = negative_affect,
                 colour = "blue")) +
  geom_point() +
  theme_bw()

### ### ### ###
