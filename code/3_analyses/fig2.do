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
		local event = "FD2 FD1 base D1 D2 D3 D4 D5 D6 D7 D8 D9"
		
	* regression
		
		ppmlhdfe sr `event'  [w=pop], absorb(month#city_id nyear#city_id) cluster(city_id) eform
			parmest, saving($figure/fig2/event_sr.dta, replace) idstr(sr) idnum(1) eform
			
		ppmlhdfe sr c.post#c.first c.post#c.second [w=pop], absorb(city_id#month city_id#nyear) cluster(city_id) eform
			parmest , saving($figure/fig2/did_sr.dta, replace) idstr(sr) idnum(1) eform
	
	* by gender
	
		foreach i in male female {
			if "`i'" == "male" local k = "2"
			if "`i'" == "female" local k = "3"
			ppmlhdfe sr_`i' `event' [w=pop_`i'], absorb(month#city_id nyear#city_id) cluster(city_id) eform
			parmest , saving($figure/fig2/event_`i'.dta, replace) idstr(`i') idnum(`k') eform
			
			ppmlhdfe sr_`i' c.post#c.first c.post#c.second [w=pop_`i'], absorb(city_id#month city_id#nyear) cluster(city_id) eform
			parmest , saving($figure/fig2/did_`i'.dta, replace) idstr(`i') idnum(`k') eform
			}
				*
	
	* by age
	
		foreach i in ad el {
			if "`i'" == "ad" local k = "5"
			if "`i'" == "el" local k = "6"
			ppmlhdfe sr_`i' `event'  [w=pop_`i'], absorb(month#city_id nyear#city_id) cluster(city_id) eform
			parmest , saving($figure/fig2/event_`i'.dta, replace) idstr(`i') idnum(`k') eform
			
			ppmlhdfe sr_`i' c.post#c.first c.post#c.second [w=pop_`i'], absorb(city_id#month city_id#nyear) cluster(city_id) eform
			parmest , saving($figure/fig2/did_`i'.dta, replace) idstr(`i') idnum(`k') eform
			}
				*
		
********************************************************************************
		
	* child
		
		use "$data\working_data\working_data_child.dta", replace	
			
		local event = "FD2 FD1 base D1 D2 D3 D4 D5 D6 D7 D8 D9"
		
	* regression
		
		ppmlhdfe sr_ch `event' [w=pop_ch], absorb(month#pref_id nyear#pref_id) cluster(pref_id) eform
		parmest, saving($figure/fig2/event_ch.dta, replace) idstr(ch) idnum(4) eform
			
		ppmlhdfe sr_ch c.post#c.first c.post#c.second [w=pop_ch], absorb(pref_id#month pref_id#nyear) cluster(pref_id) eform
		parmest, saving($figure/fig2/did_ch.dta, replace) idstr(ch) idnum(4) eform
			
********************************************************************************
		
	* create graph
	* all
	
		cd $figure/fig2
		openall
		
		keep if idnum == 1
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
			ylabel(.0 .5 1 1.5 2 2.5, labsize(*0.8) nogrid) ///
			yline(1,lp(shortdash) lcolor(gs8) lwidth(vthin)) ///
			xline(-1, lp(shortdash) lcolor(gs10) lwidth(vthin)) ///
			title("a. All age", pos(11) size(4)) ///
			text(0.64 9 ".86", size(2.0) linegap(1)) ///
			text(0.51 9 "(.82 ", size(2.0) linegap(1)) ///
			text(0.38 9 " .90)", size(2.0) linegap(1)) ///
			text(0.93 10 "1.16", size(2.0) linegap(1)) ///
			text(0.80 10 "(1.11 ", size(2.0) linegap(1)) ///
			text(0.67 10 " 1.21)", size(2.0) linegap(1)) ///
			xtitle("") ///
			ytitle("") ///
			legend(order(6 9 1 11) label(6 "Point estimate; IRR") label(1 "95% CI") label(9 "First outbreak (Feb-Jun)") label(11 "Second outbreak (Jul-Oct)") size(2.2) col(2) row(2) ring(0) pos(11) rowgap(0.4) colgap(0.4) keygap(0.4)) 
						
		graph save "$figure/fig2/fig2_A", replace			
	
********************************************************************************			

	* Male
		
		cd $figure/fig2
		openall
		
		keep if idnum == 2
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
			ylabel(.0 .5 1 1.5 2 2.5, labsize(*0.8) nogrid) ///
			yline(1,lp(shortdash) lcolor(gs8) lwidth(vthin)) ///
			xline(-1, lp(shortdash) lcolor(gs10) lwidth(vthin)) ///
			title("b. Male", pos(11) size(4)) ///
			text(0.64 9 ".86", size(2.0) linegap(1)) ///
			text(0.51 9 "(.82", size(2.0) linegap(1)) ///
			text(0.38 9 " .91)", size(2.0) linegap(1)) ///
			text(0.83 10 "1.07", size(2.0) linegap(1)) ///
			text(0.70 10 "(1.01", size(2.0) linegap(1)) ///
			text(0.57 10 " 1.13)", size(2.0) linegap(1)) ///
			xtitle("") ///
			ytitle("") ///
			legend(off) 
					
			graph save "$figure/fig2/fig2_B", replace			
	
********************************************************************************
		
	* Female
		
		cd $figure/fig2
		openall
		
		keep if idnum == 3
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
			ylabel(.0 .5 1 1.5 2 2.5, labsize(*0.8) nogrid) ///
			yline(1,lp(shortdash) lcolor(gs8) lwidth(vthin)) ///
			xline(-1, lp(shortdash) lcolor(gs10) lwidth(vthin)) ///
			title("c. Female", pos(11) size(4)) ///
			text(0.58 9 ".82", size(2.0) linegap(1)) ///
			text(0.45 9 "(.76 ", size(2.0) linegap(1)) ///
			text(0.32 9 " .89)", size(2.0) linegap(1)) ///
			text(1.08 10 "1.37", size(2.0) linegap(1)) ///
			text(.95 10 "(1.26 ", size(2.0) linegap(1)) ///
			text(.82 10 " 1.49)", size(2.0) linegap(1)) ///
			xtitle("") ///
			ytitle("") ///
			legend(off) 
					
			graph save "$figure/fig2/fig2_C", replace
						
********************************************************************************
		
	* Children
	
		cd $figure/fig2
		openall
		
		keep if idnum == 4
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
			ylabel(.0 .5 1 1.5 2 2.5, labsize(*0.8) nogrid) ///
			yline(1,lp(shortdash) lcolor(gs8) lwidth(vthin)) ///
			xline(-1, lp(shortdash) lcolor(gs10) lwidth(vthin)) ///
			title("d. Age below 20", pos(11) size(4)) ///
			text(0.57 9 ".98", size(2.0) linegap(1)) ///
			text(0.44 9 "(.75 ", size(2.0) linegap(1)) ///
			text(0.31 9 " 1.27)", size(2.0) linegap(1)) ///
			text(0.94 10 "1.49", size(2.0) linegap(1)) ///
			text(0.81 10 "(1.12", size(2.0) linegap(1)) ///
			text(0.68 10 "( 1.98)", size(2.0) linegap(1)) ///
			xtitle("") ///
			ytitle("") ///
			legend(off) 
				
			graph save "$figure/fig2/fig2_D", replace

********************************************************************************
		
	* Adult		
		
		cd $figure/fig2
		openall
		
		keep if idnum == 5
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
			ylabel(.0 .5 1 1.5 2 2.5, labsize(*0.8) nogrid) ///
			yline(1,lp(shortdash) lcolor(gs8) lwidth(vthin)) ///
			xline(-1, lp(shortdash) lcolor(gs10) lwidth(vthin)) ///
			title("e. Age 20-69", pos(11) size(4)) ///
			text(0.62 9 ".85", size(2.0) linegap(1)) ///
			text(0.49 9 "(.80 ", size(2.0) linegap(1)) ///
			text(0.36 9 "( .89)", size(2.0) linegap(1)) ///
			text(0.93 10 "1.17", size(2.0) linegap(1)) ///
			text(0.80 10 "(1.11", size(2.0) linegap(1)) ///
			text(0.67 10 " 1.24)", size(2.0) linegap(1)) ///
			xtitle("") ///
			ytitle("") ///
			legend(off) 
					
			graph save "$figure/fig2/fig2_E", replace

********************************************************************************
		
	* Elderly
		
		cd $figure/fig2
		openall
		
		keep if idnum == 6
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
			ylabel(.0 .5 1 1.5 2 2.5, labsize(*0.8) nogrid) ///
			yline(1,lp(shortdash) lcolor(gs8) lwidth(vthin)) ///
			xline(-1, lp(shortdash) lcolor(gs10) lwidth(vthin)) ///
			title("f. Age over 70", pos(11) size(4)) ///
			text(0.61 9 ".87", size(2.0) linegap(1)) ///
			text(0.48 9 "(.79 ", size(2.0) linegap(1)) ///
			text(0.33 9 " .95)", size(2.0) linegap(1)) ///
			text(0.83 10 "1.11", size(2.0) linegap(1)) ///
			text(0.70 10 "(1.01", size(2.0) linegap(1)) ///
			text(0.57 10 "( 1.22)", size(2.0) linegap(1)) ///
			xtitle("") ///
			ytitle("") ///
			legend(off) 
				
			graph save "$figure/fig2/fig2_F", replace
			
********************************************************************************			
	
	* graph combine
	
		graph combine  "$figure/fig2/fig2_A" "$figure/fig2/fig2_B" "$figure/fig2/fig2_C" "$figure/fig2/fig2_D" "$figure/fig2/fig2_E" "$figure/fig2/fig2_F", col(3) row(2) imargin(4 4 4 4 4 4) xsize(20) ysize(9.5) graphregion(margin(vtiny) fcolor(white) lcolor(white)) iscale(0.8) 
				
		graph save "$figure/fig2/fig2", replace
		graph export "$figure/fig_png/fig2.png", replace width(3000)
		graph export "$figure/fig_eps/fig2.eps", replace as(eps)
		graph export "$figure/fig_pdf/fig2.pdf", replace
				
			