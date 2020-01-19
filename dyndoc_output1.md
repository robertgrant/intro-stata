MPG facts from 1978
======

We will now analyse the **auto.dta** file.

<<dd_do>>
sysuse auto.dta, clear
quietly summarize mpg
dis _n r(mean)
<</dd_do>>
