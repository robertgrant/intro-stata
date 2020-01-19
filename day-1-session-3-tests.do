/* 
   Day 1, session 3 Stata code
   Basic tests and regression
*/



/*
1.	Open the aid.dta file. Let's formally compare the first and second 
halves of the alphabet (we don't expect to find much!). These are two 
unpaired groups of data, and we know from the histogram that aid1960 
is skewed in distribution, so we should use the rank-sum test 
(Wilcoxon-Mann-Whitney).
*/
tabstat aid1960, by(half) stat(n mean sd min q max)
ranksum aid1960, by(half)



/*
2.	Draw a scatter plot comparing aid1960 and aid1970; include only values 
below 500 in both variables. Use twoway so that you can superimpose a line 
of equality on it with the function graph type. Does there appear to be a 
shift to one side of the line? Test this paired data with the sign-rank 
(Wilcoxon) test.
*/
twoway (scatter aid1970 aid1960 if aid1960<500 & aid1970<500) ///
       (function y=x, range(0 100)), ///
	   legend(off) xtitle("Aid in 1960") ytitle("Aid in 1970")
signrank aid1960=aid1970



/*
3.	Generate a new variable, log1960, which is the logarithm of aid1960. 
Draw a histogram to see if it is symmetrically distributed, with the 
normal option. Use a t-test to compare the two halves of the alphabet.
*/
generate log1960=log(aid1960)
histogram log1960, normal
ttest log1960, by(half)


/*
4.	Now, open the built-in auto dataset using sysuse. Fit a linear 
regression to predict price, using the continuous variable mpg and 
the factors foreign and rep78.
*/
sysuse auto, clear
twoway (scatter price mpg if foreign==0, mcolor(blue) msymbol(Oh)) ///
       (scatter price mpg if foreign==1, mcolor(dkorange) msymbol(Oh)) ///
	   , graphregion(color(white)) ///
	     legend(order(1 "USA built" 2 "Foreign built"))
regress price mpg i.foreign i.rep78



/*
5.	Use predict to make a new variable called pr, which contains the 
predicted prices from the regression. Sort the data by mpg and draw a 
scatter plot of the observed data with lines for the predicted; make 
each of the two levels of foreign a different colour for these.
*/
predict pr
sort mpg
twoway (scatter price mpg if foreign==0, mcolor(blue) msymbol(Oh)) ///
       (scatter price mpg if foreign==1, mcolor(dkorange) msymbol(Oh)) ///
	   (line pr mpg if foreign==0, lcolor(blue)) ///
	   (line pr mpg if foreign==1, lcolor(dkorange)) ///
	   , graphregion(color(white)) ///
	     legend(order(1 "USA built" 2 "Foreign built"))
		 
		 
/*
6.	Use test to see if the coefficient for level 2 of rep78 is 
significantly different to that of level 3. Use margins to compare 
adjusted mean prices between USA-built and foreign-built cars, and 
then again to do this at mpg values of 15, 25 and 35.
*/
test 2.rep78=3.rep78
margins i.foreign
margins i.foreign, at(mpg=(15 25 35))
marginsplot

