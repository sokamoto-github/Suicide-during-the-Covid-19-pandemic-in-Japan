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
		
		ppmlhdfe sr c.post#c.first c.post#c.second [w=pop], absorb(city_id#month city_id#nyear) cluster(city_id) eform
		parmest , saving($figure/Ex3/did.dta, replace) idstr("real") idnum(2) eform
		
		ppmlhdfe sr `event' [w=pop], absorb(month#city_id nyear#city_id) cluster(city_id) eform
		parmest , saving($figure/Ex3/event.dta, replace) idstr("real") idnum(2) eform
				
********************************************************************************
	
	* create ranking 
	
	* Over time placebo		
		
		use "$data\working_data\working_data.dta", replace	
		keep city_id year month nyear period sr pop ym
								
		xtset city_id ym
				
	* create 1000 random variables
		
		forvalues i = 1(1)1000{
			quietly bys city_id: gen num`i' = runiform() if nyear <= 3 & period == 1
			quietly bys city_id: egen rank`i' = rank(num`i')
			
			quietly gen r_first`i' = 0
			quietly gen r_second`i' = 0
			quietly replace r_first`i' = 1 if rank`i' == 1
			
			quietly replace r_first`i' = l.r_first`i' if period == 2
			quietly replace r_first`i' = l2.r_first`i' if period == 3
			quietly replace r_first`i' = l3.r_first`i' if period == 4
			quietly replace r_first`i' = l4.r_first`i' if period == 5
			
			quietly replace r_second`i' = l5.r_first`i' if period == 6
			quietly replace r_second`i' = l6.r_first`i' if period == 7
			quietly replace r_second`i' = l7.r_first`i' if period == 8
			quietly replace r_second`i' = l7.r_first`i' if period == 9
						
			quietly for num 1/9: gen DX_`i' = 0
			quietly for num 1/9: replace DX_`i' = 1 if period == X & r_first`i' == 1
			quietly for num 1/9: replace DX_`i' = 1 if period == X & r_second`i' == 1
			
			quietly for num 1/2: gen FDX_`i' = 0
			quietly local k = `i' + 1
			quietly for num 1/2: replace FDX_`i' = 1 if (period + X) == 1 & FX.r_first`i' == 1
			}
		
			drop num* rank*
			
		save "$figure\Ex3\placebo_random.dta", replace 
		
********************************************************************************		
		
	* reg suicide on placebo treatment
	
		use "$figure\Ex3\placebo_random.dta", clear 
						
		drop if nyear == 4
		gen base = 0
				
		forvalues i = 1(1)1000{
			quietly ppmlhdfe sr r_first`i' r_second`i' [w=pop], absorb(city_id#month city_id#nyear) cluster(city_id) eform
			quietly lincom r_first`i', eform
			quietly generate placebo_first`i' = r(estimate) 
			quietly lincom r_second`i', eform
			quietly generate placebo_second`i' = r(estimate) 
			
			local event = "FD2_`i' FD1_`i' base D1_`i' D2_`i' D3_`i' D4_`i' D5_`i' D6_`i' D7_`i' D8_`i' D9_`i'"
			
			quietly ppmlhdfe sr `event' [w=pop], absorb(city_id#month city_id#nyear) cluster(city_id) eform
			quietly lincom FD2_`i', eform
			quietly generate coef_FD2_`i' = r(estimate) 
			quietly lincom FD1_`i', eform
			quietly generate coef_FD1_`i' = r(estimate) 
			quietly lincom base, eform
			quietly generate coef_base_`i' = r(estimate)
			quietly lincom D1_`i', eform
			quietly generate coef_D1_`i' = r(estimate) 
			quietly lincom D2_`i', eform
			quietly generate coef_D2_`i' = r(estimate) 
			quietly lincom D3_`i', eform
			quietly generate coef_D3_`i' = r(estimate) 
			quietly lincom D4_`i', eform
			quietly generate coef_D4_`i' = r(estimate) 
			quietly lincom D5_`i', eform
			quietly generate coef_D5_`i' = r(estimate) 
			quietly lincom D6_`i', eform
			quietly generate coef_D6_`i' = r(estimate) 
			quietly lincom D7_`i', eform
			quietly generate coef_D7_`i' = r(estimate) 
			quietly lincom D8_`i', eform
			quietly generate coef_D8_`i' = r(estimate) 
			quietly lincom D9_`i', eform
			quietly generate coef_D9_`i' = r(estimate) 
		}
		
			
	* keep estimate
		
		keep placebo* coef_FD* coef_D* coef_base*
		
		gen sample = _n
		keep if sample == 1
		
		reshape long placebo_first placebo_second coef_FD2_ coef_FD1_ coef_base_ coef_D1_ coef_D2_ coef_D3_ coef_D4_ coef_D5_ coef_D6_ coef_D7_ coef_D8_ coef_D9_, i(sample) j(x)
		drop sample 
		
		save "$figure\Ex3\placebo_month.dta", replace 		
		
********************************************************************************

	* graph
	
		use "$figure\Ex3\placebo_month.dta", clear 
		
		sum placebo*, detail
			/*  5pctile: -0.213
				95pctile: .0211
			*/
		
		gen cat = 0
			
		foreach v in first second{
			preserve
		foreach i of numlist 1(1)1000{
			replace cat = `i' if placebo_`v' > (0.0025*`i'-0.0025) & placebo_`v' <= (0.0025*`i'-0.0) 
			}
			
			replace cat = cat - 400
				/*  1: 1 ~ 1.0025
					2: 1.0025 ~ 1.0050
					...
				*/
			
			collapse (count) placebo_`v', by(cat)			
			
		save "$figure\Ex3\placebo_`v'.dta", replace
		restore
		}
			
	* graph
		
		use "$figure\Ex3\placebo_first.dta", clear
		merge 1:1 cat using "$figure\Ex3\placebo_second.dta"
		drop _merge
		
		replace	placebo_first = placebo_first/1000
		replace	placebo_second = placebo_second/1000
			
		count
		local plus1 = r(N) + 3
		set obs `plus1'
		gen x = _n
		
		replace cat = -57 if x == 59
		replace cat = 65 if x == 60
		gen bottom = 0
		gen top = 0.05
		
		sort cat
		
		graph twoway (bar placebo_first cat, fcolor(blue*0.4) lcolor(blue*0.1) lwidth(vvthin)) ///
			(bar placebo_second cat, fcolor(orange*0.4) lcolor(orange*0.1) lwidth(vvthin)) ///
			(rspike bottom top cat if cat < -44, vertical yaxis(1) lcolor(blue*1.2) lpattern(shortdash)) ///
			(rspike bottom top cat if cat > 53, vertical yaxis(1) lcolor(orange*1.2) lpattern(shortdash)) ///
			,xlabel(-80 ".80"  -48 ".88"  -16 ".96"  16 "1.04" 48 "1.12"  80 "1.2", labsize(*0.8) nogrid) ///
			xscale(range(-88 120)) ///
			ylabel(0 .02 .04 .06 .08 0.0799999999999 "         .", labsize(*0.8) nogrid) ///
			yscale(range(0 0.08)) ///
			legend(ring(0) pos(11) order(1 2) label(1 "Randomized: first outbreak") label(2 "Randomized: second outbreak") size(2.2) rowgap(0.8)) ///
			xtitle("") ///
			ytitle("Share of estimates", size(2.5)) ///
			title("a. Placebo DID estimates", size(4) pos(11) ring(2)) ///
			text(.06 -57 "Real estimate:" "First outbreak" ".86 (.82 .90)", linegap(.8) place(c) size(2)) ///
			text(.06 65 "Real estimate:" "Second outbreak" "1.16 (1.11 1.21)", linegap(.8) place(c) size(2)) ///
			scheme(plotplain)
		
			graph save "$figure/Ex3/Ex3_A", replace
					
********************************************************************************
	
	* graph event
		
		use "$figure\Ex3\placebo_month.dta", clear 
	
		foreach i in 1 2{
			rename coef_FD`i'_ FD`i'
			}
				
		for num 1/9: rename coef_DX_ DX
		rename coef_base_ base
		
		foreach i in FD2 FD1 D1 D2 D3 D4 D5 D6 D7 D8 D9{
			egen estimate_`i' = mean(`i')
			egen min95_`i' = pctile(`i'), p(5)
			egen max95_`i' = pctile(`i'), p(95)
			}
		
		gen estimate_base = 1
		gen min95_base = 1
		gen max95_base = 1
				
		keep if x == 1
		reshape long estimate_ min95_ max95_, i(x) string
		drop placebo*	
		
		rename estimate_ estimate 
		rename min95_ min95
		rename max95_ max95
		rename _j parm
		drop x
		gen idstr = "placebo"
		gen idnum = 1
				
		append using "$figure\Ex3\event.dta"
		append using "$figure\Ex3\did.dta"
	
		drop stderr z p
		
		sort idnum parm
		drop if parm == "_cons"
		
		gen x = 0
		replace x = -1 if parm == "base" | parm == "o.base"
		
		foreach i in 1 2 3 4 5 6 7 8 9{
			local k = `i' + 1
			replace x = `i' if parm == "D`k'"
			}
		
		foreach i in 2 3{
			local k = `i' - 1
			replace x = -1 * `i' if parm == "FD`k'"
			}
			
		replace x = 9 if parm == "c.post#c.first"
		replace x = 10 if parm == "c.post#c.second"
		
		sort idnum x
		
		graph twoway (rarea max95 min95 x if idnum == 1, fcolor(orange*0.2) lcolor(orange*0.2)) ///
			(connected estimate x if idnum == 1, lcolor(orange*1.2) lpattern(solid) mcolor(orange*1.2) mlcolor(orange*1.2) msymbol(circle) msize(0.8)) ///
			(rarea max95 min95 x if x <= 8 & idnum == 2, fcolor(gs14) lcolor(gs14)) ///
			(line estimate x if x <= -1 & idnum == 2, lcolor(gs6) lpattern(solid)) ///
			(line estimate x if x >= -1 & x <= 4 & idnum == 2, lcolor(blue*1.2) lpattern(solid)) ///
			(line estimate x if x >= 4 & x <=5 & idnum == 2, lcolor(black*1.2) lpattern(shortdash)) ///
			(line estimate x if x >= 5 & x <= 8 & idnum == 2, lcolor(red*1.2) lpattern(solid)) ///
			(scatter estimate x if x <= -1 & idnum == 2, mcolor(gs6) mlcolor(gs6) msymbol(circle) msize(0.8)) ///
			(scatter estimate x if x >= 0 & x <= 4 & idnum == 2, mcolor(blue*1.2) mlcolor(blue*1.2) msymbol(circle) msize(0.8)) ///
			(scatter estimate x if x> 4 & x <= 8 & idnum == 2, mcolor(red*1.2) mlcolor(red*1.2) msymbol(circle) msize(0.8)) ///
			(scatter estimate x if x == 9, mcolor(blue*1.2) msymbol(x) msize(3)) ///
			(rspike max95 min95 x if x == 9, lcolor(blue*1.2) lpattern(solid)) ///
			(scatter estimate x if x == 10, mcolor(red*1.2) msymbol(x) msize(3)) ///
			(rspike max95 min95 x if x == 10, lcolor(red*1.2) lpattern(solid)) ///
			,scheme(plotplain) ///
			xlab(-3 "-2" -1 "-1" 1 "1" 3 "3" 5 "5" 7 "7" 9 "9", labsize(*0.8) labcolor(black) axis(1) nogrid) ///
			xscale(range(-3.5 10.5)) ///
			ylabel(.4 .6 .8 1 1.2 1.4 1.6 1.5999999 "         .", labsize(*0.8) nogrid) ///
			yline(1,lp(dash) lcolor(gs10) lwidth(vthin)) ///
			xline(-1, lp(dash) lcolor(gs10) lwidth(vthin)) ///
			title("b. Placebo event study estimates", pos(11) size(4)) ///
			ytitle("Estimated coefficients", size(2.5)) ///
			xtitle("") ///
			text(.760 9 ".86", size(2.0) linegap(1)) ///
			text(.700 9 "(.82 .90)", size(2.0) linegap(1)) ///
			text(1.05 10 "1.16", size(2.0) linegap(1)) ///
			text(0.99 10 "(1.11 1.21)", size(2.0) linegap(1)) ///
			legend(order(2 1 4 3) row(2) col(2) label(4 "Real estimate") label(3 "95% CI") label(2 "Placebo") label(1 "95% CI") ring(0) size(2.2) pos(11) rowgap(0.4) colgap(0.4)) 
		
		graph save "$figure/Ex3/Ex3_B", replace		
	
********************************************************************************
	
	* graph combine
	
		graph combine  "$figure/Ex3/Ex3_A" "$figure/Ex3/Ex3_B", col(2) xsize(12) ysize(4) imargin(3 3) graphregion(margin(vtiny) fcolor(white) lcolor(white)) iscale(1.2)
		
		graph save "$figure/Ex3/Ex3", replace
		graph export "$figure/fig_png/Ex3.png", replace width(3000)
		graph export "$figure/fig_eps/Ex3.eps", replace as(eps)
		graph export "$figure/fig_pdf/Ex3.pdf", replace
				
			