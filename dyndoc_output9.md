<html>
<head>
<style>
body{ font-family:sans-serif; }
</style>
</head>

<body>

MPG facts from 1978
======

We will now analyse the **auto.dta** file.

<<dd_do: quietly>>
sysuse auto.dta, clear
scatter price mpg, name(scatter1, replace)
summarize mpg
<</dd_do>>
The mean MPG was <<dd_display: %8.2f r(mean)>>

This is based on cars like the:

* Buick Regal
* Renault Le Car
* Datsun 810

The top 5 for fuel efficiency were:

1.  VW Diesel
1.  Datsun 210
1.  Subaru
1.  Plym. Champ
1.  Toyota Corolla

<<dd_graph: graphname(scatter1)>>
</body>
</html>
