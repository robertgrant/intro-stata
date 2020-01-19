/* 
   Day 1, session 2 Stata code
   Graphics
*/

histogram aid1960
histogram aid1960, bin(30)

graph box aid1960, over(half) // box is unusual in using "over"
graph box aid1960 if aid1960<100, over(half) // remember that this changes the quartiles


/*
1.	Convert country into an id number, using the encode command. This will 
give integers in alphabetical order. Let's also make one in ascending order 
of the aid received in 1960 (those countries receiving none will be on the 
end, still in alphabetical order – make sure you understand why!)
*/
encode country, gen(id1)
label var id1 "Countries (alphabetical order)"

sort aid1960
generate id2 = _n // row number
label var id2 "Countries (ascending 1960 aid order)"



/*
2.	Make a scatter plot with country ID on the x-axis and aid1960 on 
the y-axis. Try both the ID versions. Then, make a scatter plot that 
also has a line linking the points, superimposing two graphs using the 
twoway command.
*/
scatter aid1960 id1
twoway (scatter aid1960 id2) (line aid1960 id2)


/*
3.	Make the same scatterplot, but remove the countries with no aid in 
1960 by an if statement. Use the following options to control how the 
graph looks: msymbol for hollow circles, ytitle and xtitle for the axis 
titles, graphregion or scheme to remove the grey background, note to 
acknowledge the source ("World Bank via Gapminder"), and name so that 
the graph does not get discarded next time you draw one.
*/
scatter aid1960 id2 if aid1960!=. , ///
        msymbol(Oh) ///
		ytitle("Aid per person in 2010 (US$)") ///
        xtitle("Countries (ascending order of aid)") ///
		graphregion(color(white)) ///
		note("World Bank data via Gapminder") ///
		name(aid_scatter, replace)
/* Including the -if- helps to get the scales right for 
   the two axes */

   

/*
4.	Use reshape long to make all the aid* variables one long one, with 
a new variable for year. Draw a line chart of aid on the y-axis and year 
on the x-axis, showing only the countries with the five highest aid values 
in 1960 (use in to select values of id2), and how they developed over time.
*/
preserve
	reshape long aid, i(id1) j(year)
	sort id1 year
	line aid year if id2>98 & id2<104, connect(ascending) name(epidemic_line, replace)
restore

graph export aid_scatter.png, name(aid_scatter) 



/*
5.	Experiment with the graph editor window, to change any formatting 
you like in the graph.
*/

