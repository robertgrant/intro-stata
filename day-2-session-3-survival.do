/* 
Day 2, session 3 Stata code
Survival analysis 
*/
   

/*
1. Open the built-in demo data file "cancer", and define it as survival data: 
the time variable is studytime, and the event (failure) variable is died.
*/
clear all
sysuse cancer
// the data are already stset but we could type:
stset studytime, failure(died)


/*
2. Use sts graph to get Kaplam-Meier survival curves for the different drugs,
with and without confidence intervals.
*/
// to get K-M survival curves for categories of drug:
sts graph, by(drug)
// and the 95% CIs overlap a lot
sts graph, by(drug) ci


/*
3. Use strate to get the mortality rates tabulated
*/
strate drug



/*
4. Run a log-rank test to compare survival between the drugs
*/
sts test drug




// but we think age differs slightly between drug arms:
tabstat age, by(drug) stat(n mean q)
// so we want to adjust for age using Mantel-Haenszel rate ratios for drug 2 versus 1:
stmh drug age, compare(2,1)
// and 3 versus 1:
stmh drug age, compare(3,1)

/* 
5. Do this adjustment, but in a more modern way, with Cox regression
*/
stcox i.drug age
predict res, csnell // get the Cox-Snell residuals
scatter res study time
scatter res age
list drug age died studytime if res>2
// although there are three patients with high residuals, there 
// doesn't seem to be anything very unusual about them

/* Conclusion: Drug 1 is significantly inferior to the others, adjusted for age. 
   Drug 3 appears to be the best but is not sig. different to drug 2, after adjusting for age.
   The benefit is clear in the first year of the trial but not certain after that, other 
   than that Drug 3 is still sig. better than Drug 1 in the second year.
   Longer term research with a larger sample size (to account for attrition) would be
   needed to clarify the duration of benefit. */
   
