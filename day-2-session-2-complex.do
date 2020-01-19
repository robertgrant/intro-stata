/*
Day 2, session 2 Stata code
More complex regression
*/


use "titanic.dta", clear
encode embarked, gen(home)

/*
1. Examine accommodation class, sex and home city as predictors of survival
*/
tab pclass surv, row chi2
tab sex surv, row chi2
tab home surv, row chi2
tabstat age, by(surv) stat(n q)

logistic survived age i.pclass i.sex i.home
margins pclass, at(age=(5 25 45 65))
marginsplot
// now try this with an interaction between age and pclass



/*
2. Examine age and race as predictors of wage. 
Add a random intercept and slope for age.
*/
use "nlsw.dta", clear
gen age21=age-21 // improves interpretation
regress ln_wage age21 i.race if year==88
mixed ln_wage age21 i.race || id:age,



/*
3. Use Non-parametric (local-linear) regression to find a curve linking
systolic blood pressure and CHD.
*/
use "SAheart.dta", clear

logistic chd sbp 
margins, at(sbp=(110(10)200))
marginsplot, name(logistic_margins, replace) title("Marginal means") ///
			 graphregion(color(white)) yscale(range(0 1)) ylabel(0(0.2)1)

npregress kernel chd sbp, bwidth(10 10, copy)
scatter _Mean sbp, graphregion(color(white)) name(predict, replace) ///
			       title("Predictions") /// 
				   yscale(range(0 1)) ylabel(0(0.2)1)
margins, at(sbp=(110(10)200)) reps(100) // this will take a few minutes to run!
marginsplot, name(npregress_margins, replace) title("Marginal means") ///
			 graphregion(color(white)) yscale(range(0 1)) ylabel(0(0.2)1)

// try this with the Titanic dataset
