
*==============================================================================*
* Project: COVID and suicide in Japan			    			          	   *
* Date:   2020 Nov                                                             *
* Author: Tanaka and Okamoto                           						   *  
*==============================================================================*

* set directories 
clear all
set maxvar  30000
set matsize 11000 
set more off
cap log close

local TNK 1
local OKMT 0

if `TNK'==1{
	global dir= "C:\Users\takan\Dropbox\macro_suicide\suicide\publication"
}

if `OKMT'==1{
	global dir= "/Users/shoheiokamoto/Dropbox/macro_suicide\suicide\publication"
}

global data "$dir/data"
global tables "$dir/tables"
global figure  "$dir/figures"

********************************************************************************

	* set data
	
		use "$data\working_data\working_data.dta", replace	
		sort city_id year month
		
		gen treat1 = treat_post * first
		gen treat2 = treat_post * secon
	
	* regression
	
		ppmlhdfe sr treat1 treat2 [w=pop], absorb(city_id#month city_id#nyear, savefe) cluster(city_id) eform
			predictnl yhat_ln = xb() + __hdfe1__  + __hdfe2__
			predictnl yhat_cf_ln = xb() - _b[treat1]*treat1 -_b[treat2]*treat2 + __hdfe1__  + __hdfe2__
			gen yhat = exp(yhat_ln)
			gen yhat_cf = exp(yhat_cf_ln)
		
		collapse (mean) sr yhat yhat_cf nyear period [w=pop], by(year month)
		
	* graph
	
		egen meany = mean(sr) if nyear >= 1 & nyear <= 3, by(period nyear)
		egen meanyhat = mean(yhat) if nyear >= 1 & nyear <= 3, by(period nyear)
		
		gen ym = ym(year, month)
		sort nyear period	
		
		graph twoway (line meanyhat period if nyear == 3, lcolor(gs9) mcolor(gs9) lpattern(shortdash_dot)) ///
				(line meanyhat period if nyear == 2, lcolor(gs9) mcolor(gs9) lpattern(shortdash_dot)) ///
				(line meanyhat period if nyear == 1, lcolor(gs9) mcolor(gs9) lpattern(shortdash_dot)) ///
				(scatter sr period if nyear <= 3, lcolor(gs12) mcolor(gs12) lpattern(shortdash_dot) msymbol(circle) msize(0.8)) ///
				(line yhat period if nyear == 4, lcolor(blue*0.8) mcolor(blue*0.8) msymbol(circle) lpattern(solid)) ///
				(line yhat_cf period if nyear == 4, lcolor(gs6) mcolor(gs6) msymbol(circle) lpattern(solid)) ///
				(scatter sr period if nyear == 4, color(blue*0.6) msymbol(circle)) ///
				,legend(order(1 4 5 6 7) col(1) label(1 "Predicted: 2016 Nov - 2019 Oct") label(4 "Observed: 2016 Nov - 2019 Oct") label(5 "Predicted with COVID-19") label(6 "Predicted without COVID-19")  label(7 "Observed 2019 Nov - 2020 Oct") ring(0) pos(4) rowgap(0.6)) ///
				xlab(-2 "Nov" 0 "Jan" 2 "Mar" 4 "May" 6 "Jul" 8 "Sep" 9 " ", labsize(*0.8) labcolor(black) axis(1) nogrid) ///
				xscale(range(-3 10)) ///
				ylabel(0 5 10 15 20 19.999999999"        .", nogrid) ///
				xtitle("") ytitle("") ///
				title("a. Predicted effects of COVID-19 on suicide rate", size(4) pos(11) ring(2)) ///
				xline(0, lp(dash) lcolor(gs10) lwidth(vthin)) ///
				scheme(plotplain)
					
		graph save "$figure/Ex4/Ex4_A", replace
		
********************************************************************************

	* cumulative number
				
	* estimate the averted suicide	
		use "$data\working_data\working_data.dta", replace
		sort city_id year month
		
		gen treat1 = treat_post * first
		gen treat2 = treat_post * second
				
		ppmlhdfe sr treat1 treat2 [w=pop], absorb(city_id#month city_id#nyear, savefe) cluster(city_id) eform
			predictnl dif_ln = _b[treat1]*treat1 + _b[treat2]*treat2, ci(dif_min dif_max)
			gen dif_irr = exp(dif_ln)			
			gen dif_sr = dif_irr - 1
		
		collapse (sum) suicide (mean) dif_sr dif_min dif_max nyear period, by(year month)
	
	* graph
	
		gen ym = ym(year, month)
		sort nyear period
				 
		egen mean_suicide_ = mean(suicide) if nyear == 4 & period <= 0
		egen mean_suicide = max(mean_suicide_)
		gen saved = mean_suicide * dif_sr
		gen saved_min = mean_suicide * dif_min
		gen saved_max = mean_suicide * dif_max
		
		gen cum = sum(saved)
		gen cum_min = sum(saved_min)
		gen cum_max = sum(saved_max)		
		
		gen x = 0
		
		keep if nyear == 4
		
		graph twoway (rarea cum_min cum_max period if period >= 0, fcolor(blue*0.2) lcolor(white)) ////
				(line x period, lp(dash) lcolor(gs10) lwidth(vthin)) ///
				(line cum period, lcolor(blue*0.8) lpattern(dash) lwidth(med)) ///
				, legend(order (3 1) label(3 "Estimated suicide change") label(1 "95% CI") ring(0) pos(7)) ///
				xlab(-2 "Nov" 0 "Jan" 2 "Mar" 4 "May" 6 "Jul" 8 "Sep" 9 " ", labsize(*0.8) labcolor(black) axis(1) nogrid) ///
				xscale(range(-3 10)) ///
				title("b. Estimated number of suicide change", size(4) pos(11) ring(2)) ///
				ylabel(-2000 -1500 -1000 -500 0 500 499.99999 "        .", nogrid) ///
				xtitle("") ///
				xline(0, lp(dash) lcolor(gs10) lwidth(vthin)) ///
				scheme(plotplain)
				
		graph save "$figure/Ex4/Ex4_B", replace
		
********************************************************************************
	
	* graph combine
	
		graph combine  "$figure/Ex4/Ex4_A" "$figure/Ex4/Ex4_B", row(1) xsize(15) ysize(5) graphregion(margin(vtiny) fcolor(white) lcolor(white)) iscale(1.2) 
				
		graph save "$figure/Ex4/Ex4", replace
		graph export "$figure/fig_png/Ex4.png", replace width(3000)
		graph export "$figure/fig_eps/Ex4.eps", replace as(eps)
		graph export "$figure/fig_pdf/Ex4.pdf", replace
						
		
				
		