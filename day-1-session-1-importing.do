/* 
Day 1, Session 1 exercises
Importing and manipulating data

Import the data file aid.csv from Gapminder.org, yearly figures for each country on international aid received per person (in US $)

For each step that follows, you should use Stata commands in the command line 
or do-file editor. Remember that, if you don't know the command you need, 
you can search for it using the hsearch command, or look through the 
drop-down menus
*/

/*
1.	Open the CSV data in Stata. 
*/
import delimited "aid.csv", delimiter(",") varnames(1) clear



/*
2.	Note that you might find some of the variables are not named properly 
(for example, v2 instead of 1960). Explain why this problem can happen 
when importing data, with reference to either the Stata help files or 
manual, or to the Statalist archive online.

   Stata takes variable names from the first row, but
   does not allow variable names to begin with a number,
   which is the case with these years. The year has been
   stored in the variable label instead. By default, such
   variables are given names v1, v2, v3, v4... Also, the cell
   in the CSV file that we would expect to contain the name of
   the country column actually contained the title of the whole 
   file. 
*/

   
   
/*
3.	Rename the variables that should be "country", "aid1960", "aid1970", 
"aid1980", "aid1990", "aid2000" and "aid2010". Then, delete all the others. 
You might like to correct the label that the country variable has.
*/
rename aidreceivedperpersoncurrentus country
// the decades we want are v2, v12, v22, v32, v42 and v52
// this is a slow way to do it:
rename v2 aid1960
rename v12 aid1970
rename v22 aid1980
rename v32 aid1990
rename v42 aid2000
rename v52 aid2010
// later, you'll learn about loops:
	forvalues i=2(10)52 {
		local yr=`i'+1958
		rename v`i' aid`yr'
	}
	// what if we imported from Excel and we have variables called B, C, D...
	global yr=1960
	foreach i of varlist B-Z {
		rename `i' aid${yr}
		global yr=${yr}+1
	}
keep country aid* 
/* The commands -drop- and -keep- are both useful here but -keep- is 
   more succinct, thanks to the wildcard *. This will drop all other 
   variables. Note that we can use an asterisk (aid*) to indicate any 
   variables starting with the letters "aid" */
label variable country "Country name"
   
   
   
/*
4.	Make a table of descriptive statistics comparing the aid received in 1960 
and 2010, including the number of countries with data, the mean, standard 
deviation, minimum, maximum and quartiles.
*/
tabstat aid1960 aid2010, stat(n mean sd min max q)



/*
5.	How many countries had negative aid values in 1960? Use a Stata command 
for this, don't just count them!
*/
count if aid1960<0 


   
   
/*
6.	What is the Pearson correlation between 1960 and 2010 aid per person? 
What is the Spearman correlation?
*/
correlate aid1960 aid2010
spearman aid1960 aid2010






/*
We are going to examine a strange hypothesis: that countries from the 
first half of the alphabet, like Afghanistan, Belize and Cambodia, are 
relatively poor and recipients of aid, while countries from the second 
half, like Norway, Oman and Portugal are relatively wealthy and do not 
receive aid.
*/

/*
7.	Our first task is to create a new variable that holds only the first 
letter of the country name. In Stata variables like country, which hold 
text, are called string variables, and you will find a selection of "string 
functions" to manipulate them in the help files.
*/
generate first_letter=substr(country,1,1)



/*
8.	Now, create a new variable called half, which distinguishes between 
two groups depending on whether the first letter is in A-M or N-Z. You 
could think of this as being less than "N" or greater than "M". Are there 
any countries with first letters not in this A-Z range? Does your do-file 
classify them the way you would expect?
*/
generate half=(first_letter>"M")
label define halflab 0 "A-M" 1 "N-Z"
label values half halflab
/* There is a country (or autonomous region) called the 
   Åland Islands, which appear after Z. We would probably 
   rather have them listed in the first half of the alphabet. 
   We can make a quick ad hoc correction, identifying them
   by their row number: */
replace half=0 in 259
replace country="Aland Islands" in 259
/* You can type any ASCII character in Windows by holding down Alt and 
   typing its code number on the numeric keypad (0197, in this case). 
   But you could also do this: */
sort first_letter
// Åland is now at the end. Now you can type:
replace half=0 if first_letter>"Z"
/* or you could just type -edit- (or click on the edit data icon)and 
   do it manually... but this is dangerous */

   
   
/*
9.	Now make a table of descriptive statistics for aid1960 and aid2010, 
broken down by half. Is there an obvious difference in the mean aid? 
What about the median?
*/
tabstat aid1960 aid2010, stat(n mean sd min max q) by(half)
// but two seperate tables would be clearer:
tabstat aid1960, by(half) stat(n mean sd min q max)
tabstat aid2010, by(half) stat(n mean sd min q max)

   
   
   
/*
10.	Sort the data according to aid, and get Stata to show you a list of the 
ten biggest aid recipients (per person) in 1960 and again in 2010. Do you 
think there are problematic countries distorting the analysis? Why do you 
think they have the values they do?
*/

/* -gsort- is a convenient command that lets you choose ascending
   or descending order with a plus or minus symbol */
gsort - aid1960
list country aid1960 in 1/10
gsort - aid2010
list country aid2010 in 1/10
/* The country receiving the most aid per person in 1960, and the top
   six in 2010, all have small populations. This makes them 
   potentially unrepresentative as a small increase in aid could look large
   in per capita terms. Next, we will merge population data into this dataset. */

   
   
/*
11.	Blank out the largest value in 1960 by replacing it with '.'
*/
gsort - aid1960
replace aid1960=. in 1



/*
12.	Save the data you have worked on so far as a Stata .dta file, perhaps 
called aid.dta. You will be revisiting it later.
*/
save aid.dta, replace



/*
13.	Now import the Excel file population.xls into Stata, rename the country 
name variable "country", and the the population variables pop1960, pop1970, 
pop1980, pop1990, pop2000, pop2010. Keep only the country name and the 
populations in 1990. Save this file as population.dta.
*/
import excel population.xls, firstrow clear // it's ok to clear because we saved aid.dta
rename Totalpopulation country
rename (B L V AF AP) ///
       (pop1970 pop1980 pop1990 pop2000 pop2010) // you can combine renames like this
keep country pop*
save population.dta, replace



/*
14.	Use -merge- to combine this file with the aid file, matching on the 
country name. Keep only those countries that are in both data files.
*/
merge 1:1 country using aid.dta
keep if _merge==3
// look at -help merge- to see the meaning of _merge values
drop _merge // forgetting to do this is a very common mistake



/*
15.	Create a new variable which is the total aid received (or given) 
in 2010: pop2010 times aid2010. What if aid2010 is missing? 
Then total aid should be 0.
*/
generate total_aid2010 = pop2010 * aid2010
replace total_aid2010 = 0 if aid2010==.



/*
16.	Save this file as aid.dta
*/
save aid.dta, replace

