#### USING GGPLOT2 TO VISUALISE YOUR DATA ----

# Part 2: Advanced Customised Plots
# Authors: Jemma Collova & Angus Hughes
# Date: 8/5/2020

#### Splitting Your Plots ----

# It's often useful to split plots up by groups.
# For example, say we wanted to know whether the relationship between
# stress and negative affect was different for individuals in the
# control and treatment groups.

# We can do this by using `facet_wrap()`!
# You need to tell ggplot to split BY the group using the `~` symbol)
ggplot(data, aes(x = stress, 
                 y = negative_affect)) +
  geom_point(alpha = .5) +     
  geom_smooth(method = "lm", 
              color = "navyblue",
              fullrange = TRUE) +  # Make sure line fills the axes
  labs (x = "Stress", 
        y = "Negative Affect") +
  facet_wrap( ~ treatment) +       # This is new: Split by treatment
  theme_bw()

# NB: These regressions lines are fit *separately* - 
# Ideally you'd fit just one model instead, but it's good for quick checks.

# Now, quite often we expect a relationship of interest will vary based on
# clustering into groups. This is a key motivation for multilevel models (MLMs)!

# We want to know whether the stress-negative affect relationship
# varies by the treatment facility the person was in.

# One way to do this is by setting the `linetype =` argument
ggplot(data, aes(x = stress, 
                 y = negative_affect)) +
  geom_point(alpha = .5) +     
  geom_smooth(aes(linetype = group),  # Specify separate lines by group
              method = "lm", 
              color = "navyblue",
              fullrange = TRUE) + 
  labs (x = "Stress", 
        y = "Negative Affect") +
  theme_bw()
# But this is horribly ugly! Try setting `se = FALSE` in `geom_smooth()`

# Let's use facet_wrap again though to split the data up by treatment facility
# This time we'll look at the impact of rumination on negative affect
ggplot(data, aes(x = rumination, 
                 y = negative_affect)) +
  geom_point(alpha = .5) +     
  geom_smooth(method = "lm", 
              color = "navyblue",
              fullrange = TRUE) + 
  labs (x = "Rumination", 
        y = "Negative Affect") +
  facet_wrap( ~ group) +  
  theme_bw()

# This makes it much easier to spot how the relationship varies across specific 
# groups! Compare group 4 with group 12. We could use a multilevel model 
# (with packages `lme4` or `nlme`) to average across this variability

# ### EXERCISE ###
# Our 16 groups neatly fell into a 4 by 4 grid. But what if we wanted a custom 
# sized grid? Try modifying to facet_wrap to tell it the number of rows (nrows)
#
# - YOUR CODE HERE -
#
# ### ### ### ### 

# What if we wanted to split the plot up by *two* variables?
# Try `facet_grid(Var1 ~ Var2)`!

# First we drop 6 people who were NA for gender. These observations are important! 
# But splitting by gender *including* them will create an additional NA panel that 
# has a really tiny sample size not suited for regression (too much uncertainty).
data_filtered <- filter(data, !is.na(gender))

# Then we plot treatment and gender split up
ggplot(data_filtered, 
       aes(x = rumination, 
           y = negative_affect)) +
  geom_point(alpha = .5) +     
  geom_smooth(method = "lm", 
              color = "navyblue",
              fullrange = TRUE) + 
  labs (x = "Rumination", 
        y = "Negative Affect") +
  facet_grid(treatment ~ gender) +  
  theme_bw()

# Quick Quiz!
# NB: Not for the faint hearted!
# What happens if you try to split on a *continuous* variable?
ggplot(data,  aes(x = rumination, 
                  y = negative_affect)) +
  geom_point(alpha = .5) +     
  facet_wrap( ~ stress) +    # Stress doesn't fall into groups!
  theme_bw()                 # What ever will ggplot do??

#### Joining Your Plots ----

# Often we want to combine plots for publications. 
# Let's take two previous ones, modify them, assign them names to save
# them into the R environment separately, and then put them side by side.

# Reworking our clustered bar chart (using `position = "dodge"`)
sleep_bar_plot <- ggplot(data, aes(x = sleep_diff, 
                                   fill = treatment)) +
  geom_bar(position = "dodge", 
           alpha = .9) +
  labs(y = "Number of Individuals",
       x = "Days of Sleep Difficulty in Last 2 Weeks",
       title = "A.") +
  theme_minimal()

# Reworking our overlapped density plot
stress_plot <- ggplot(data, aes(x = stress, 
                                fill = treatment)) +
  geom_density(position = "dodge", 
               alpha = .5) +
  labs(y = "Density",
       x = "Distribution of Self-reported Stress",
       title = "B.") + 
  theme_minimal()

# Ok, we've got two good looking plots now
sleep_bar_plot
stress_plot

# The `patchwork` package makes joining them up incredibly easy!
# Let's use patchwork to merge them into a publication-worthy plot
library(patchwork)
sleep_bar_plot + stress_plot
# You could just keep adding more side-by-side like so.

# But what about if we want another a third plot (C.) below it?
negative_scatter_plot <- ggplot(data_filtered, aes(x = stress, 
                                                   y = negative_affect)) +
  geom_smooth(aes(linetype = treatment,
                  colour = treatment),
              method = "lm",
              fullrange = TRUE,
              se = FALSE) +
  labs(y = "Self-reported Negative Affect",
       x = "Self-reported Stress",
       title = "C.",
       caption = "Note: Error bars omitted") +
  theme_minimal()

# Let's join them all up and save it into the Environment as Figure 1!
# We simply put the first two on top (or over, like a numerator) the third
Fig_1 <- (sleep_bar_plot + stress_plot) / negative_scatter_plot
Fig_1

# More info is available on patchwork here
# https://patchwork.data-imaginist.com/index.html

#### Model-based Plots ----

# Often we work with regression models (e.g. ANOVA's, multiple regression)
# These models allow us to make predictions, which can be helpful interpreting
# combined effects of independent variables, interactions between them, etc.

# Let's say rumination (dependent variable) is predicted by the treatment, the
# individual's negative affect, and we think there's a interaction between the two.
# We would write this model like so in R
mod1 <- lm(rumination ~ treatment * negative_affect, data = data)
summary(mod1)

# Our interaction is non-significant, but both main effects are.
# That doesn't mean the interaction doesn't impact our predictions though!

# The `ggeffects` package allows you to quickly plot predictions from models!
# Let's use `ggpredict()` from the ggeffects package to interpret the impacts
# of both our model terms (treatment and negative affect).
library(ggeffects)
predictions <- ggpredict(mod1,
                         terms = c("negative_affect",         # We want predictions for
                                   "treatment"))  # both IV's (our 'terms')

# ggpredict will choose cut-points for our negative affect variable based on 
# the mean +/- 1 SD, but we can modify this if we want - see `?ggpredict()`
predictions

# This 'plays nice' with ggplot 
pred_plot <- plot(predictions)
pred_plot

# And we can adjust the legend using `scale_colour_discrete()`
Fig_2 <- pred_plot + 
  labs(x = "Self-reported Negative Affect",
       y = "Self-reported Rumination",
       title = "Model-Based Predictions for Rumination from Negative Affect",
       subtitle = "By Treatment Condition, N = 353, Adjusted R-squared = 0.159")
Fig_2

#### Saving and Quitting ----

# Finally, we can save our work using `ggsave()`
# Here I'll save as png, but pdf, jpg, and other formats are available
ggsave("Fig_1.png", plot = Fig_1)
ggsave("Fig_2.png", plot = Fig_2)

# Usually it's easier to manually adjust the size in the 'Plots' panel
# of RStudio though, and then click 'Export'. No code needed; Easy peasy! 

### ### ### ###
