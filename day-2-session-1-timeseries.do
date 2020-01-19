/*
Day 2, session 1 Stata code
Time series
*/

import delimited "trains.csv", varnames(1) delimiter(",") clear

/* 
The time variable here is caltime, which is in years and fractions thereof.
Each observation is a four-week reporting period but extra days at the 
end of the year are included in the last (of the financial year!)
Let's ignore the date and pretend each report is exactly 28 days later.
*/

gen reportweek=1936+((_n-1)*4) // 1936 is week 13 of 1997 in Stata coding
tsset reportweek, weekly delta(4)


// Moving-average and median smoothers
tssmooth ma ma5=london_se, window(5 0 0)
tssmooth nl nl5=london_se, smoother(5)
tsline london ma5, name(ma5, replace)
tsline london nl5, name(nl5, replace)

// Holt-Winters (exponential weighted moving average without and with seasonal effects)
tssmooth hwinters hw=london, samp0(26)
tsline london hw, name(hw, replace)
tssmooth shwinters shw=london, samp0(4) period(13)
tsline london shw, name(shw, replace)
gen shw_resid = london_se - shw


// autocorrelation plots
ac london_se, name(ac_london_se, replace)
ac shw_resid, name(ac_shw_resid, replace)


// ARIMA model, prediction and residuals, and Portmanteau white noise test
arima london_se, arima(1,0,4)
predict pred_arima104
predict resid_arima104, residual
tsline resid_arima104
wntestq resid_arima104

// unit root tests (stationarity)
dfuller london_se, trend lags(13)
dfgls london_se, maxlag(13)

// interrupted time-series
	// ssc install itsa
// 2300 = 1 Jan 2004
itsa london_se i.calperiod, trperiod(2300) single lag(4) figure replace

