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
		gen ymsq = ym*ym
						
		local wth = "temp tempsq prec precsq"
	
	* DID
	* including control and prefectural trend
		
		ppmlhdfe sr c.post#c.first c.post#c.second `wth' [w=pop], absorb(city_id#month city_id#nyear pref_id#c.ym pref_id#c.ymsq) cluster(city_id) eform
		parmest , saving($figure/figS2/did_wth.dta, replace) idstr("Add weather") idnum(1) eform
			
	* using OLS
	
		reghdfe sr c.post#c.first c.post#c.second [w=pop], absorb(city_id#month city_id#nyear) cluster(city_id)
		parmest , saving($figure/figS2/did_ols.dta, replace) idstr("Add weather & city Trend") idnum(2)

********************************************************************************
				
	* set data
		
		use "$data\working_data\working_data.dta", replace	
					
		sort city_id year month		
		gen ymsq = ym*ym	
									
		local event = "FD2 FD1 base D1 D2 D3 D4 D5 D6 D7 D8 D9"
		local wth = "temp tempsq prec precsq"
	
	* event study		
	* including control and prefectural trend
		
		ppmlhdfe sr `event' `wth' [w=pop], absorb(city_id#month city_id#nyear pref_id#c.ym pref_id#c.ymsq) cluster(city_id) eform
		parmest , saving($figure/figS2/event_pref_wth.dta, replace) idstr("Add weather") idnum(1) eform
			
	* using OLS
		
		reghdfe sr `event' [w=pop], absorb(city_id#month) cluster(city_id)
		parmest , saving($figure/figS2/event_pref_ols.dta, replace) idstr("Add weather & city Trend") idnum(2)
			
********************************************************************************			
	
	* graph
	
		cd "$figure/figS2"
		openall
		
		keep if idstr == "Add weather"
		keep if parm == "c.post#c.first" | parm == "c.post#c.second" | parm == "FD2" | parm == "FD1" | parm == "o.base" | parm == "D1" | parm == "D2" | parm == "D3" | parm == "D4" | parm == "D5" | parm == "D6" | parm == "D7" | parm == "D8" | parm == "D9" 		
		gen x = _n - 4
		
		graph twoway (rarea max95 min95 x if x <= 8, fcolor(gs14) lcolor(gs14)) ///
			(line estimate x if x <= -1, lcolor(gs6) lpattern(solid)) ///
			(line estimate x if x >= -1 & x <= 4, lcolor(blue*1.2) lpattern(solid)) ///
			(line estimate x if x >= 4 & x <=5, lcolor(gs6) lpattern(shortdash)) ///
			(line estimate x if x >= 5 & x <= 8, lcolor(red*1.2) lpattern(solid)) ///
			(scatter estimate x if x <= -1, mcolor(gs6) mlcolor(gs6) msymbol(circle) msize(0.8)) ///
			(scatter estimate x if x >= 0 & x <= 4, mcolor(blue*1.2) mlcolor(blue*1.2) msymbol(circle) msize(0.8)) ///
			(scatter estimate x if x> 4 & x <= 8, mcolor(red*1.2) mlcolor(red*1.2) msymbol(circle) msize(0.8)) ///
			(scatter estimate x if x == 9, mcolor(blue*1.2) msymbol(x) msize(3)) ///
			(rspike max95 min95 x if x == 9, lcolor(blue*1.2) lpattern(solid)) ///
			(scatter estimate x if x == 10, mcolor(red*1.2) msymbol(x) msize(3)) ///
			(rspike max95 min95 x if x == 10, lcolor(red*1.2) lpattern(solid)) ///
			,scheme(plotplain) ///
			xlab(-3 "-3" -1 "-1" 1 "1" 3 "3" 5 "5" 7 "7" 9 "9", labsize(*0.8) labcolor(black) axis(1) nogrid) ///
			xscale(range(-3.5 10.5)) ///
			ylabel(.2 .6 1 1.4 1.8 1.7999999 "         ." 2.2, labsize(*0.8) nogrid) ///
			yline(1, lp(dash) lcolor(gs10) lwidth(vthin)) ///
			xline(-1, lp(dash) lcolor(gs10) lwidth(vthin)) ///
			title("a. Robustness: Additional control", pos(11) size(4)) ///
			text(.74 9 ".88", size(2) linegap(1)) ///
			text(.64 9 "(.84 .93)", size(2) linegap(1)) ///
			text(1.02 10 "1.20", size(2) linegap(1)) ///
			text(.92 10 "(1.12 1.29)", size(2) linegap(1)) ///
			ytitle("Estimated coefficients", size(2.5)) ///
			xtitle("") ///
			legend(order(6 9 1 11) label(6 "Point estimate; IRR") label(1 "95% CI") label(9 "First outbreak (Feb-Jun)") label(11 "Second outbreak (Jul-Oct)") size(2.2) col(2) row(2) ring(0) pos(11) rowgap(0.4) colgap(0.4) keygap(0.4)) 
		
			graph save "$figure/figS2/figS2_A", replace
		
********************************************************************************
					
	* OLS Model
		
		cd "$figure/figS2"
		openall
		
		keep if idstr == "Add weather & city Trend"
		keep if parm == "c.post#c.first" | parm == "c.post#c.second" | parm == "FD2" | parm == "FD1" | parm == "o.base" | parm == "D1" | parm == "D2" | parm == "D3" | parm == "D4" | parm == "D5" | parm == "D6" | parm == "D7" | parm == "D8" | parm == "D9" 		
		gen x = _n - 4
		
		graph twoway (rarea max95 min95 x if x <= 8, fcolor(gs14) lcolor(gs14)) ///
			(line estimate x if x <= -1, lcolor(gs6) lpattern(solid)) ///
			(line estimate x if x >= -1 & x <= 4, lcolor(blue*1.2) lpattern(solid)) ///
			(line estimate x if x >= 4 & x <=5, lcolor(gs6) lpattern(shortdash)) ///
			(line estimate x if x >= 5 & x <= 8, lcolor(red*1.2) lpattern(solid)) ///
			(scatter estimate x if x <= -1, mcolor(gs6) mlcolor(gs6) msymbol(circle) msize(0.8)) ///
			(scatter estimate x if x >= 0 & x <= 4, mcolor(blue*1.2) mlcolor(blue*1.2) msymbol(circle) msize(0.8)) ///
			(scatter estimate x if x> 4 & x <= 8, mcolor(red*1.2) mlcolor(red*1.2) msymbol(circle) msize(0.8)) ///
			(scatter estimate x if x == 9, mcolor(blue*1.2) msymbol(x) msize(3)) ///
			(rspike max95 min95 x if x == 9, lcolor(blue*1.2) lpattern(solid)) ///
			(scatter estimate x if x == 10, mcolor(red*1.2) msymbol(x) msize(3)) ///
			(rspike max95 min95 x if x == 10, lcolor(red*1.2) lpattern(solid)) ///
			,scheme(plotplain) ///
			xlab(-3 "-3" -1 "-1" 1 "1" 3 "3" 5 "5" 7 "7" 9 "9", labsize(*0.8) labcolor(black) axis(1) nogrid) ///
			xscale(range(-3.5 10.5)) ///
			ylabel(-8 -4 0 4 8 7.9999999 "         ." 12, labsize(*0.8) nogrid) ///
			yline(0, lp(dash) lcolor(gs10) lwidth(vthin)) ///
			xline(-1, lp(dash) lcolor(gs10) lwidth(vthin)) ///
			title("b. Robustness: OLS model", pos(11) size(4)) ///
			text(-3.33 9 "-1.83", size(2) linegap(1)) ///
			text(-4.33 9 "(-2.33 -1.33)", size(2) linegap(1)) ///
			text(0.5 10 "2.06", size(2) linegap(1)) ///
			text(-0.5 10 "(1.50 2.61)", size(2) linegap(1)) ///
			ytitle("Estimated coefficients", size(2.5)) ///
			xtitle("") ///
			legend(off)
			
		graph save "$figure/figS2/figS2_B", replace
	
********************************************************************************
	
	* graph combine
	
		graph combine  "$figure/figS2/figS2_A" "$figure/figS2/figS2_B", col(2) xsize(12) ysize(4) imargin(3 3) graphregion(margin(vtiny) fcolor(white) lcolor(white)) iscale(1.2)
		
		graph save "$figure/figS2/figS2", replace
		graph export "$figure/fig_png/figS2.png", replace width(3000)
		graph export "$figure/fig_eps/figS2.eps", replace as(eps)
		graph export "$figure/fig_pdf/figS2.pdf", replace
				
			