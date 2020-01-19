/* 
########################################
#####       Day 2, session 4      ######
#####      multivariate stats     ######
#####   and linking R and Stata   ######
#####   prepared by Robert Grant  ######
#####   (robertgrantstats.co.uk)  ######
#####       for Timberlake        ######
#####     (timberlake.co.uk)      ######
########################################
*/


// ############ Multivariate stats: dimension reduction ############

// a 2-D example to get started
clear
set seed 3531
set obs 100
gen x=rnormal(0,1)
gen y=x+rnormal(0,1)
scatter y x, xscale(range(-6 6)) yscale(range(-6 6)) aspectratio(1) ///
             xlabel(-6(2)6, nogrid) ylabel(-6(2)6, nogrid) name(xy, replace)
pca x y
predict pc1 pc2
scatter pc1 pc2, xscale(range(-5 5)) yscale(range(-5 5)) aspectratio(1) ///
                 xlabel(-4(2)4, nogrid) ylabel(-4(2)4, nogrid) name(pc, replace)

// a multivariate example
sysuse census, clear
gen index=_n
foreach v of varlist poplt5-popurban death-divorce {
	gen `v'_pc = `v'/pop
}
graph box poplt5_pc-divorce_pc 
/* These all have different scales; medage is very different again.
   If we use their correlations for PCA, it's equivalent to standardising them 
   all to mean 0 and SD1. You might not be comfortable with that. The alternative,
   using the covariance matrix, retains the units of measurement, so the % of the
   population who got divorced has almost no influence compared to the much
   larger % who are over 18.
   We'll try out both and compare them.
*/
pca poplt5_pc-divorce_pc medage
pca poplt5_pc-divorce_pc medage, cov

// How many components do we retain?
pca poplt5_pc-divorce_pc medage
screeplot

// rotation
pca poplt5_pc-divorce_pc medage, comp(3)
loadingplot
rotate, varimax

// critique the reduced variables
loadingplot, comp(3)
predict rotpc1 rotpc2 rotpc3
scatter rotpc1 rotpc2, mlabel(state2)
scatter rotpc1 rotpc3, mlabel(state2)
/* Is it better to reduce the dataset to medage and popurban_pc, or to use the
   1st and 3rd component? What will be accepted by the audience?
*/





// ############ Multivariate stats: clustering ############

webuse iris, clear
twoway (scatter sepwid seplen if iris==1, mcolor(navy)) ///
       (scatter sepwid seplen if iris==2, mcolor(dkorange)) ///
	   (scatter sepwid seplen if iris==3, mcolor(forest_green)), ///
	   legend(order(1 "I. Setosa" 2 "I. Versicolor" 3 "I. Virginica"))

// k-means
cluster kmeans seplen sepwid petlen petwid, k(3) gen(kmeans)
tab iris kmeans
recode kmeans (1=2) (2=1) (3=3), gen(kmeans_iris)
gen kmeans_wrong=(kmeans_iris!=iris)
twoway (scatter sepwid seplen if iris==1 & kmeans_wrong==0, mcolor(purple) msymbol(Oh)) ///
       (scatter sepwid seplen if iris==2 & kmeans_wrong==0, mcolor(dkorange) msymbol(Oh)) ///
	   (scatter sepwid seplen if iris==3 & kmeans_wrong==0, mcolor(forest_green) msymbol(Oh)) ///
	   (scatter sepwid seplen if iris==1 & kmeans_wrong==1, mcolor(purple) msymbol(X)) ///
       (scatter sepwid seplen if iris==2 & kmeans_wrong==1, mcolor(dkorange) msymbol(X)) ///
	   (scatter sepwid seplen if iris==3 & kmeans_wrong==1, mcolor(forest_green) msymbol(X)), ///
	   legend(order(1 "I. Setosa" 2 "I. Versicolor" 3 "I. Virginica"))

// linkage (hierarchical clustering)
cluster averagelinkage seplen sepwid petlen petwid, gen(link) name(avlink)
cluster generate link_iris = group(3)
gen link_wrong=(link_iris!=iris)
twoway (scatter sepwid seplen if iris==1 & link_wrong==0, mcolor(purple) msymbol(Oh)) ///
       (scatter sepwid seplen if iris==2 & link_wrong==0, mcolor(dkorange) msymbol(Oh)) ///
	   (scatter sepwid seplen if iris==3 & link_wrong==0, mcolor(forest_green) msymbol(Oh)) ///
	   (scatter sepwid seplen if iris==1 & link_wrong==1, mcolor(purple) msymbol(X)) ///
       (scatter sepwid seplen if iris==2 & link_wrong==1, mcolor(dkorange) msymbol(X)) ///
	   (scatter sepwid seplen if iris==3 & link_wrong==1, mcolor(forest_green) msymbol(X)), ///
	   legend(order(1 "I. Setosa" 2 "I. Versicolor" 3 "I. Virginica"))
cluster dendrogram avlink, cutnumber(10) showcount



// ############ Linking R and Stata ############

// I wrote an rdump program (provided with this tutorial):
do "rdump.ado"

// you'll need to send data to R: writing to a .dta file is just as usual
sysuse nlsw88, clear
gen logwage = log(wage)
save "~/nlsw88.dta", replace // choose the path for your computer

// you can also send globals and matrices using rdump:
global myglobal=4.1
global anotherglobal="abc123"
quietly regress logwage age i.race
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
! /usr/local/bin/Rscript -e "exp(1)" // path changes, obviously, for your computer

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
file open `handle' using "~/script.R", write replace
#delimit ;
foreach line in
  "library(ggplot2)"
  "library(haven)"
  "library(hexbin)"
  "# read in the auto data"
  "nlsw88 <- read_dta('~/nlsw88.dta')"
  "# make a hexagonal bin scatterplot"
  "png('~/hexbin.png')"
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
! /usr/local/bin/Rscript -e "source('~/script.R')"

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


  

