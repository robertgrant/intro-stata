cd "~/Dropbox/BayesCamp/clients/Timberlake"

// let's start with a really simple putdocx example
local date_time = c(current_date) + ", " + c(current_time)
putdocx begin
putdocx paragraph
putdocx text ("Hello, world! It's currently `date_time'.")
putdocx save sample.docx, replace


// now let's add more tweaks!
// putdocx can include tables and figures
clear all
sysuse auto
putdocx begin, pagesize(A4) // pagesize option
putdocx paragraph // create a new paragraph
// this is how you can build up text with different formatting:
putdocx text ("Let's look at whether price predicted miles per gallon in the 1978 ")
putdocx text ("auto.dta"), font("Courier","10","blue")
putdocx text (" dataset.")
// this is how you add estimation outputs
regress mpg price
putdocx table t1 = etable // insert the current estimation table
	// note that the -regress- has to be in the output window: it can't be done -quietly-
// let's alter some of the text: change _cons to Intercept
putdocx table t1(3,1) = ("Intercept"), halign("right")
// this is how you add graphs
putdocx paragraph
twoway (scatter mpg price, msymbol(Oh) mcolor(%60) ytitle("MPG")) (lfit mpg price), legend(off)
graph export "sample.png", replace
putdocx image "sample.png"
// let's add a caption
putdocx text ("Figure 1: relationship between price and MPG in 1978 automobile data"), ///
	font("",10) italic 
putdocx save sample.docx, replace


/* 	We can use putdocx or putpdf inside a loop to automate the creation of multiple Word or PDF files.
	We'll use Stata's highschool.dta dataset, which has samples of high school pupils from each
	of the 50 states of the USA. Suppose we have people collecting the data in each state, and need to 
	periodically send a report to each of them on their progress and how their own data compares
	to everyone else's in terms of sex and race.
*/

webuse highschool, clear
			// we'll make some indicator variables to make life easier later
			tab sex, generate(sex_)
			tab race, generate(race_)
			// and some variables with values 0 or 100 to give us easy percentages
			foreach v of varlist sex_* race_* {
				gen `v'_100=100*`v'
			}
// the states have consecutive numbers from 1 to 50 in the data, so we'll use a forvalues loop
gen yourstate=(state==1)
forvalues i=1/50 {
	display "Now working on state `i'"
	putdocx begin
/*	write the heading, including the state number (we don't have states' names in the data, but 
	they could be added instead if we wanted to) 
*/
	putdocx paragraph, style(Heading1)
	putdocx text ("Report of data collected for state number `i'")
// now, we'll get counts for all data and for the state in question, and insert them into text as local macros
	putdocx paragraph
	qui count
	local n_all = r(N)
	qui count if state==`i'
	local n_state = r(N)
	putdocx text ("So far, data have been collected on `n_all' high school pupils nationwide. ")
	putdocx text ("This includes `n_state' from your state. ")
	putdocx text ("The tables and figures below look at the mix by sex and race to identify ")
	putdocx text ("if there is a difference between your state and the other 49.")
/*	Now we can use -tabstat- to give us stats in the state in question and the other 49.
	In this case, we'll just report numbers in categories of sex and race, using the sum and count of 
	the indicator variables for numerator and denominator respectively, and the sum of the 0-or-100 
	variables to give us the percentages. 
*/
	replace yourstate=(state==`i') // identify the state in question
	quietly tabstat sex_*, stat(sum n mean) by(yourstate) save
// get the stats as matrices
	matrix sexm0=r(Stat1)
	matrix sexm1=r(Stat2)
// assemble the table we would like to see as a matrix
	matrix sexm=(sexm1[1,1], sexm1[3,3], sexm1[1,2], sexm1[3,4], sexm1[2,1] \ ///
				sexm0[1,1], sexm0[3,3], sexm0[1,2], sexm0[3,4], sexm0[2,1])
// add it to the .docx file
	putdocx table t1 = matrix(sexm), rownames colnames nformat(%12.2g)
// let's tidy up the headings in the table
	putdocx table t1(1,2) = ("N male")
	putdocx table t1(1,3) = ("% male")
	putdocx table t1(1,4) = ("N female")
	putdocx table t1(1,5) = ("% female")
	putdocx table t1(1,6) = ("N all")	
	putdocx table t1(2,1) = ("Your state")
	putdocx table t1(3,1) = ("All other states")
// now we'll do the same by race
	quietly tabstat race_*, stat(sum n mean) by(yourstate) save
	matrix racem0=r(Stat1)
	matrix racem1=r(Stat2)
	matrix racem=(racem1[1,1], racem1[3,4], racem1[1,2], racem1[3,5], racem1[1,3], racem1[3,6], racem1[2,1] \ ///
				  racem0[1,1], racem0[3,4], racem0[1,2], racem0[3,5], racem0[1,3], racem0[3,6], racem0[2,1])
	putdocx table t2 = matrix(racem), rownames colnames nformat(%12.2g)
// let's tidy up the headings in the table
	putdocx table t2(1,2) = ("N white")
	putdocx table t2(1,3) = ("% white")
	putdocx table t2(1,4) = ("N black")
	putdocx table t2(1,5) = ("% black")
	putdocx table t2(1,6) = ("N other")
	putdocx table t2(1,7) = ("% other")
	putdocx table t2(1,8) = ("N all")	
	putdocx table t2(2,1) = ("Your state")
	putdocx table t2(3,1) = ("All other states")
// and finally, save the file before repeating the loop
	putdocx save state_report_`i'.docx, replace
}
