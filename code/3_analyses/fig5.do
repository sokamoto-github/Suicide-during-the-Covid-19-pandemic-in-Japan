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
	
	* COVID, variable create	
		
		use "$data\raw_data\figures\Fig5\covid.dta", clear
		rename prefecturenamej pref_jp
		rename testedpositive case
		merge m:1 pref_jp using "$data\raw_data\figures\fig1\pref_id.dta"
		
		drop if month >= 11
		collapse (max) case, by(pref_id)
		save "$data\raw_data\figures\Fig5\covid_month.dta", replace
		
		use "$data\working_data\working_data.dta", clear 
		collapse (sum) pop, by(year month pref_id)
		keep if year == 2020 & month == 1
		save "$data\raw_data\figures\Fig5\pop_month.dta", replace
		
		use "$data\raw_data\figures\Fig5\covid_month.dta", clear
		merge 1:1 pref_id using "$data\raw_data\figures\Fig5\pop_month.dta"
			
		gen casepp = case/pop
		egen casepp_p50 = median(casepp)
		gen gp_covid = 0
		replace gp_covid = 1 if casepp > casepp_p50
		
		collapse gp_covid case, by(pref_id)
	
		save "$data\raw_data\figures\Fig5\hetero_covid.dta", replace	
		
********************************************************************************

	* regression
	
		use "$data\working_data\working_data.dta", replace	
					
		merge m:1 city_id using "$data\raw_data\figures\fig5\mun_ses"
		drop _merge
		
		merge m:1 pref_id using "$data\raw_data\figures\Fig5\hetero_covid.dta"	
		drop _merge
		
		sort city_id year month		
		
		replace incomepc = incomepc[_n-1] if incomepc == .
				
	* create base suicide rate
			
		egen basesr_ = mean(sr) if year == 2019, by(city_id)
		egen basesr = max(basesr_), by(city_id)
		
	* create group
				
		foreach v in incomepc basesr {
			egen `v'_p50 = median(`v')
			gen gp_`v' = 0
			replace gp_`v' = 1 if `v' > `v'_p50
			}
				
	* regression
		
		foreach i in 1 0 {
		foreach v in basesr covid incomepc {
			
			if "`v'" == "basesr" local k = "1"
			if "`v'" == "covid" local k = "2"
			if "`v'" == "incomepc" local k = "3"
									
			ppmlhdfe sr c.post#c.first c.post#c.second  [w=pop] if gp_`v' == `i', absorb(month#city_id nyear#city_id) cluster(city_id) eform
			parmest, saving($figure/fig5/hetero_`v'`i'.dta, replace) idstr(`v') idnum(`k'`i') eform
		}
		}
		
********************************************************************************

	* base suicide rate
	
		cd $figure/fig5
		openall
		
		keep if idstr == "basesr"
		drop if parm == "_cons" 
		
		sort parm idnum
		gen x = _n
		replace x = x+1 if x >= 3
		
		graph twoway (rspike max95 min95 x if x <= 2, lcolor(blue*1.2) lpattern(solid)) ///
			(scatter estimate x if x <= 2, mcolor(blue*1.2) msymbol(circle)) ///
			(rspike max95 min95 x if x >= 4, lcolor(red*1.2) lpattern(solid)) ///
			(scatter estimate x if x >= 4, mcolor(red*1.2) msymbol(circle)) ///
			,scheme(plotplainblind) ///
			xlab(0 " " 1 "low" 2 "high" 4 "low" 5 "high" 6 " ",labcolor(black) axis(1) nogrid labsize(3)) ///
			xscale(range(0 6)) ///
			ylabel(.4 (.2) 1.6, nogrid) ///
			yline(1, lp(dash) lcolor(gs10) lwidth(vthin)) ///
			title("a. Suicide rate before the pandemic", pos(11) size(4)) ///
			xtitle("") ///
			ytitle("") ///
			text(0.63 2 "0.74", size(2.0) linegap(1)) ///
			text(0.56 2 "(0.70 0.79)", size(2.0) linegap(1)) ///
			text(0.83 5 "0.96", size(2.0) linegap(1)) ///
			text(0.76 5 "(0.90 1.03)", size(2.0) linegap(1)) ///
			text(0.85 1 "0.98", size(2.0) linegap(1)) ///
			text(0.78 1 "(0.92 1.04)", size(2.0) linegap(1)) ///
			text(1.22 4 "1.37", size(2.0) linegap(1)) ///
			text(1.15 4 "(1.29 1.45)", size(2.0) linegap(1)) ///
			legend(order(1 3) label(1 "First outbreak (Feb-Jun)") label(3 "Second outbreak (Jul-Oct)") ring(0) pos(11) rowgap(0.4) colgap(0.4) keygap(0.8)) 
		
		graph save "$figure/fig5/fig5_A", replace
		
********************************************************************************
	
	* COVID-19 prevalence
	
		cd $figure/fig5
		openall
		
		keep if idstr == "covid"
		drop if parm == "_cons" 
		
		sort parm idnum
		gen x = _n
		replace x = x+1 if x >= 3
		
		graph twoway (rspike max95 min95 x if x <= 2, lcolor(blue*1.2) lpattern(solid)) ///
			(scatter estimate x if x <= 2, mcolor(blue*1.2) msymbol(circle)) ///
			(rspike max95 min95 x if x >= 4, lcolor(red*1.2) lpattern(solid)) ///
			(scatter estimate x if x >= 4, mcolor(red*1.2) msymbol(circle)) ///
			,scheme(plotplainblind) ///
			xlab(0 " " 1 "low" 2 "high" 4 "low" 5 "high" 6 " ",labcolor(black) axis(1) nogrid labsize(3)) ///
			xscale(range(0 6)) ///
			ylabel(.4 (.2) 1.6, nogrid) ///
			yline(1, lp(dash) lcolor(gs10) lwidth(vthin)) ///
			title("b. COVID-19 cases per population", pos(11) size(4)) ///
			xtitle("") ///
			ytitle("") ///
			text(0.75 2 "0.86", size(2.0) linegap(1)) ///
			text(0.68 2 "(0.82 0.91)", size(2.0) linegap(1)) ///
			text(1.04 5 "1.17", size(2.0) linegap(1)) ///
			text(.97 5 "(1.11 1.24)", size(2.0) linegap(1)) ///
			text(0.71 1 "0.84", size(2.0) linegap(1)) ///
			text(0.64 1 "(0.78 0.91)", size(2.0) linegap(1)) ///
			text(0.96 4 "1.13", size(2.0) linegap(1)) ///
			text(0.89 4 "(1.04 1.22)", size(2.0) linegap(1)) ///
			legend(off)
			
		graph save "$figure/fig5/fig5_B", replace
		
********************************************************************************
	
	* base income
	
		cd $figure/fig5
		openall
		
		keep if idstr == "incomepc"
		drop if parm == "_cons" 
		
		sort parm idnum
		gen x = _n
		replace x = x+1 if x >= 3
		
		graph twoway (rspike max95 min95 x if x <= 2, lcolor(blue*1.2) lpattern(solid)) ///
			(scatter estimate x if x <= 2, mcolor(blue*1.2) msymbol(circle)) ///
			(rspike max95 min95 x if x >= 4, lcolor(red*1.2) lpattern(solid)) ///
			(scatter estimate x if x >= 4, mcolor(red*1.2) msymbol(circle)) ///
			,scheme(plotplainblind) ///
			xlab(0 " " 1 "low" 2 "high" 4 "low" 5 "high" 6 " ",labcolor(black) axis(1) nogrid labsize(3)) ///
			xscale(range(0 6)) ///
			ylabel(.4 (.2) 1.6, nogrid) ///
			yline(1, lp(dash) lcolor(gs10) lwidth(vthin)) ///
			title("c. Base income per capita", pos(11) size(4)) ///
			xtitle("") ///
			ytitle("") ///
			text(0.74 2 "0.86", size(2.0) linegap(1)) ///
			text(0.67 2 "(0.81 0.90)", size(2.0) linegap(1)) ///
			text(1.05 5 "1.18", size(2.0) linegap(1)) ///
			text(.98 5 "(1.12 1.24)", size(2.0) linegap(1)) ///
			text(0.72 1 "0.86", size(2.0) linegap(1)) ///
			text(0.65 1 "(0.79 0.95)", size(2.0) linegap(1)) ///
			text(0.93 4 "1.11", size(2.0) linegap(1)) ///
			text(0.86 4 "(1.00 1.22)", size(2.0) linegap(1)) ///
			legend(off)
			
		graph save "$figure/fig5/fig5_C", replace
		
********************************************************************************
	
	* graph combine
	
		graph combine  "$figure/fig5/fig5_A" "$figure/fig5/fig5_B" "$figure/fig5/fig5_C", row(1) xsize(15) ysize(4) imargin(3 3 3) graphregion(margin(vtiny) fcolor(white) lcolor(white)) iscale(1.4)  
		
		graph save "$figure/fig5/fig5", replace
		graph export "$figure/fig_png/fig5.png", replace width(3000)
		graph export "$figure/fig_eps/fig5.eps", replace as(eps)
		graph export "$figure/fig_pdf/fig5.pdf", replace
				
			