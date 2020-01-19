
/* 
Examples for the BayesCamp workshop
Using Stata and R Together
www.bayescamp.com
*/


// writing data to a new .dta file is just as usual
sysuse auto, clear
save "auto.dta", replace
sysuse nlsw88, clear
save "nlsw88.dta", replace

generate above_median = (wage > 6.27)
logistic above_median age married
predict predicted_risk
hist predicted_risk

// I wrote an rdump program:
do "rdump.ado"
// make some globals
global myglobal=4.1
global anotherglobal="abc123"
// make some matrices
matrix beta=e(b)
matrix sigma=e(V)
// write to the Rdump format
rdump, rfile("to_R.R") matrices("beta sigma") globals("myglobal anotherglobal")


// an example of calling R for one line of code
/* 
	you might need to know where Rscript is stored on your computer
	and to specify the path in full, or you'll get an error that Rscript 
	is not known
*/
! /usr/local/bin/Rscript -e "exp(1)"

// or a few lines with semicolons
! /usr/local/bin/Rscript -e "x <- 1:4; y <- c(10,13,12,15); summary(lm(y~x));"

// let's use R to get a specific graph (hexagonal bins)
sysuse nlsw88, clear
scatter wage hours

// writing an R script file can be done several ways... this is simplest and inside the do-file
// you have to install Sergio Correia's -block- command
net from "https://raw.githubusercontent.com/sergiocorreia/stata-misc/master/"
capture ado uninstall block
net install block
block, file("script.R") verbose
  library(ggplot2)
  library(haven)
  # read in the auto data
  auto <- read_dta("auto.dta")
  # make a hexagonal bin scatterplot
  png('hexbin.png')
  ggplot(auto, aes(hours, wage)) + geom_hex()
  dev.off()
endblock

// Charles Opondo's method uses only core Stata
tempname handle
file open `handle' using "script.R", write replace
#delimit ;
foreach line in
  "library(ggplot2)"
  "library(haven)"
  "# read in the auto data"
  "nlsw88 <- read_dta('nlsw88.dta')"
  "# make a hexagonal bin scatterplot"
  "png('hexbin.png')"
  "ggplot(nlsw88, aes(hours, wage)) + geom_hex()"
  "dev.off()"
{;
  #delimit cr
  file write `handle' "`line'" _n
}
file close `handle'
// (note how each line of R is in double quotes, so any quotes that you want to appear in R
// have to be single quotes, or you could use the dreaded Stata compound quotes) 

// for any approach to this, avoid dollar signs in your R script...

// once you have a script file saved, you can get Rscript to run it like this
! /usr/local/bin/Rscript -e "source('script.R')"

// compare the two graphs



// #############  a longer example: Stata to R and back  #############

// for what follows, let's read in the familiar auto dataset
sysuse auto, clear
keep mpg price headroom trunk weight length turn displacement gear_ratio foreign

// plain linear regression to predict mpg
// (this is not a very clever model because of multi-colinearity)
regress mpg price headroom trunk weight length turn displacement ///
  gear_ratio foreign
/* it would be nice to fit a lasso regression instead, which obtains a 
   simpler model by forcing uninformative predictors' coefficients down to zero
   - the R package glmnet is excellent for this */

// send the data to auto.dta
save auto.dta, replace

// send the alpha parameter (don't worry about what it does) to moredata.R
global glmnet_alpha = 1
tempname handle
file open `handle' using "moredata.R", write replace
file write `handle' "myalpha <- ${glmnet_alpha}" _n
file close `handle'

// send the R script to script.R (Opondo method)
tempname handle
file open `handle' using "script.R", write replace
#delimit ;
foreach line in
  "library(haven)"
  "library(glmnet)"
  "library(dplyr)"
  "source('moredata.R') # get scalar"
  "auto <- read_dta('auto.dta') # get data"
  "predictors <- as.matrix(select(auto, -one_of(c('mpg'))))"
  "mpg <- unlist(select(auto, mpg))"
  "lasso <- glmnet(x=predictors, y=mpg, family='gaussian', alpha=myalpha)"
  "crossval <- cv.glmnet(x=predictors, y=mpg, family='gaussian', alpha=myalpha)"
  "png('crossvalidation.png'); plot(crossval); dev.off();"
  "beta_lasso <- as.matrix(coef(crossval, s = 'lambda.min'))"
  "#statado(matrices='beta_lasso', dofile='results.do'"
  "print(as.matrix(beta_lasso))"
{;
  #delimit cr
  file write `handle' "`line'" _n
}
file close `handle'

shell /usr/local/bin/Rscript -e "source('script.R')"
do "results.do"
matrix list beta_lasso

// compare with plain regression again
regress mpg price headroom trunk weight length turn displacement ///
  gear_ratio foreign


  
