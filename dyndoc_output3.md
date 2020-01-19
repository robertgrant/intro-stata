MPG facts from 1978
======

We will now analyse the **auto.dta** file.

<<dd_do: quietly>>
sysuse auto.dta, clear
summarize mpg
<</dd_do>>
The mean MPG was <<dd_display: %8.2f r(mean)>>
