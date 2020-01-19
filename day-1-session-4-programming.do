/* 
   Day 1, session 4 Stata code
   Progarmming techniques and dynamic outputs
*/



sysuse auto, clear

// accessing estimates after a command
summarize mpg
global mean_mpg = r(mean) 

// macros - global
display "The mean MPG was ${mean_mpg}, and the..."

// macros - local
local mean_mpg = r(mean)
display "`mean_mpg' miles per gallon"

// you can still access the global but not the local

// macros - format
local mean_mpg: display %8.1f r(mean)
display "`mean_mpg' miles per gallon"


// macro evaluation
global m1 r(mean)
global m2 = r(mean)
display $m1
display "$m1"
display $m2
display "$m2"


// #################  LOOPS ##################

sysuse nlsw88.dta, clear

forvalues i=1(0.5)10 {
	display "This is loop number `i'"
	local i_squared = `i'^2
	display "...which is the square root of `i_squared'"
	display ""
}

foreach v of varlist race married grade - c_city {
	tabulate `v' union, chi2
}

global dependent_vars "wage hours"
global predictor_vars "age ttl_exp tenure"
foreach depvar of global dependent_vars {
	foreach predvar of global predictor_vars {
		display "###### Regression of `depvar' on `predvar' ######"
		regress `depvar' `predvar'
	}
}

decode occupation, generate(occupation_s)

levelsof occupation_s, local(occupation_levels)
display `occupation_levels'

local loopcount = 1
foreach occu of local occupation_levels {
	histogram age if occupation_s=="`occu'", ///
		name("occu_hist_`loopcount'", replace)
	preserve
		keep if occupation_s=="`occu'"
		save "nlsw88_occupation_`loopcount'.dta", replace
	restore
	local loopcount = `loopcount'+1
}




decode occupation, generate(occupation_s)
levelsof occupation_s, local(occupation_levels)
local loopcount = 1
foreach occu of local occupation_levels {
	preserve
		keep if occupation_s=="`occu'"
		save "nlsw88_occupation_`loopcount'.dta", replace
	restore
	local loopcount = `loopcount'+1
}










// ##############  BRANCHING  ###############
global mean_mpg = 4
if $mean_mpg > 10 {
   display as error "what a large mean!"
}
else {
   display as error "what a small mean!"
   error 999
}

/*
Looping and branching exercise - multiple files
	Having saved the 13 occupation-specific files, read each one back in turn,
	use the sample command to select ten women at random from that occupation.
	Then use append to put the samples together into one big file.
	But if the occupation has fewer than ten, omit it entirely.
	Note! You should have a loop over the 13 files. The first file will 
	need to be saved, not appended!
*/
// loop over 1-13 (forvalues)
// open the file
// if n>9...
// sample 10, count
// 		save filename.dta
// 		BUT! append using filename.dta
// 		save...
// else...











// ################  PROGRAMS  #################

// ssc install myname


capture program drop mycommand
program define mycommand
	display "Hello, world!"
end

forvalues i=1/10 {
	mycommand
}

capture program drop myregression
program define myregression
	syntax varlist
	preserve
		regress wage `varlist'
		local rmse: display %8.3g e(rmse)
		predict pred
		sort pred
		generate index=_n
		twoway (scatter wage index, msymbol(oh) mcolor(%40)) (line pred index), ///
			ytitle("Wage") xtitle("Ascending order of predicted wage") ///
			legend(order(1 "Observed" 2 "Predicted")) ///
			caption(`"Predictors: `varlist'.  Root MSE = `rmse'"')
		// compound quotes
	restore
end

myregression grade ttl_exp
myregression south age union






// ################  RETRIEVING RESULTS  #################

sysuse nlsw88.dta, clear

global dependent_vars "wage hours"
global predictor_vars "age ttl_exp tenure"
foreach depvar of global dependent_vars {
	foreach predvar of global predictor_vars {
		quietly regress `depvar' `predvar'
		matrix BETA=e(b)
		local beta: display %8.3f BETA[1,1]
		display "Coefficient of `predvar', predicting `depvar': `beta'"
	}
}


// ###############  DYNAMIC DOCUMENT OUTPUTS  ################

// plain text output
dyntext "dyntext_output1.txt", saving("dyntext_output2.txt") replace

// HTML output
dyndoc "dyndoc_output1.md", saving("dyndoc_output2.html") replace

dyndoc "dyndoc_output3.md", saving("dyndoc_output4.html") replace

dyndoc "dyndoc_output5.md", saving("dyndoc_output6.html") replace

dyndoc "dyndoc_output7.md", saving("dyndoc_output8.html") replace

dyndoc "dyndoc_output9.md", saving("dyndoc_output10.html") replace

dyndoc "dyndoc_output11.md", saving("dyndoc_output12.html") replace


