# Examples for the BayesCamp workshop
# Using Stata and R Together
# www.bayescamp.com

library(haven)
library(dplyr)
library(ggplot2)
library(glmnet)

auto <- read_dta('auto.dta')
nlsw88 <- read_dta('nlsw88.dta')

# To get a logistic regression and then store predicted probabilities as
# a new variable, and draw a histogram of them:
nlsw88 <- mutate(nlsw88, above_median = (wage > median(nlsw88$wage)))
myregression <- glm(above_median ~ married + age, data=nlsw88, family=binomial())
predicted_prob <- predict(myregression, type="response")
hist(predicted_prob)

# These can be combined into one line
hist(predict(glm(above_median ~ married + age, 
                 data=nlsw88, family=binomial()), type="response"))

# But if you prefer, you can pipe left to right:
glm(above_median ~ married + age, data=nlsw88, family=binomial()) %>% 
  predict(type="response") %>% 
  hist()

# Defining vectors, matrices (R)
my_vector <- c(1,4,8,3)
my_matrix <- matrix(my_vector,nrow=2)
BETA <- glm(above_median ~ married + age, data=nlsw88, family=binomial())$coefficients

# Write to a text file
con <- file('myfile.txt', 'w')
write('Hello, world.',con)
write(c(
  'This is a text file',
  'three lines long'),con)
close(con)

# You can use this to write a Stata do-file:
con <- file('script.do', 'w')
write(c(
  'log using stata_log.txt, text replace',
  'use "nlsw88.dta", clear',
  'regress wage age i.race i.married, vce(bootstrap)',
  'estat bootstrap, bc',
  'log close'
),con)
close(con)

# Or to send data that won't transfer in the .dta file:
con <- file('moredata.do', 'w')
write(c(
'global filename "my_analysis"',
'matrix define test_values = [1.2, 1.4, 2.5, 3.1]',
'matrix define covariance = [4, 2.4 \ 2.4, 4]'
),con)
close(con)

# Calling Stata from the command line
system('"C:\Program Files\Stata15\StataMP" /e do C:\data\script.do')
system('/Applications/Stata/StataMP -e do script.do')


# ##################  extended example  #######################

# We are fitting a regression to the NLSW88 dataset, and the outcome
# variable (wage) is not really normal. So, we will use Stata's easy
# bootstrapping to give us more robust confidence intervals.

# Send the data and a scalar:
write_dta(nlsw88, 'nlsw88.dta')
con <- file('moredata.do', 'w')
write(c(
'global n_reps = 100'
),con)
close(con)

# Write the script.do file:
con <- file('script.do', 'w')
write(c(
  "use 'nlsw88.dta', clear // get the data",
  "do moredata.do // get the scalar",
  "regress wage age i.race i.married, vce(bootstrap, reps(${n_reps}))",
  "matrix BC = e(ci_bc)'",
  "matrix list BC",
  "rdump, matrices('BC') rfile('results.R')"
),con)
close(con)

# Call Stata, and read the results back in:
system('/Applications/Stata/StataMP.app/Contents/MacOS/StataMP -e do script.do')
source('results.R')
print(BC)
