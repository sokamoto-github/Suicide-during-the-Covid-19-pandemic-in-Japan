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
	
	* google mobility, variable create
		
		import delimited "$data\raw_data\figures\Ex5\2020_JP_Region_Mobility_Report.csv", clear	
					
		split iso_3166_2_code, p("-") 
		split date, p("-")
			
		rename iso_3166_2_code2 pref_id
		rename sub_region_1 pref_JP
		rename date1 year
		rename date2 month
		rename date3 day
			
		drop date iso_3166_2_code iso_3166_2_code1 country_region country_region_code sub_region_2 metro_area census_fips_code retail_and_recreation_percent_ch grocery_and_pharmacy_percent_cha parks_percent_change_from_baseli transit_stations_percent_change_ residential_percent_change_from_
		drop if pref_JP == ""
			
		destring pref_id year month day, replace
				
		rename workplaces_percent_change_from_b mob_work
		order pref_id pref_JP year month day mob_work
		
		replace mob = mob * (-1)
				
		egen mob_ = mean(mob_work) if month <= 10, by(pref_id)
		egen mob = max(mob_), by(pref_id)
				
		egen mob_p50 = median(mob)
		gen gp_mob = 0
		replace gp_mob = 1 if mob > mob_p50
		
		collapse gp_mob mob, by(pref_id)
				
		save "$data\raw_data\figures\Ex5\hetero_mob.dta", replace	

	
*******************************************************************************
	
	* unemp, variable create		
		
		import excel "$data\raw_data\figures\Ex5\unemp.xlsx", clear firstrow
		
		gen dif = (apr_jun+jul_sep)/2 - oct_dec 
		
		egen maxunemp_p50 = median(dif)
		gen gp_unemp = 0
		replace gp_unemp = 1 if dif > maxunemp_p50
		
		save "$data\raw_data\figures\Ex5\hetero_unemp.dta", replace	
			
*******************************************************************************
	
	* estimate
		
		use "$data\working_data\working_data.dta", clear 
			
		merge m:1 city_id using "$data\raw_data\figures\Ex5\mun_ses"
		drop _merge
		
		merge m:1 pref_id using "$data\raw_data\figures\Ex5\hetero_mob.dta"
		drop _merge
				
		merge m:1 pref_id using "$data\raw_data\figures\Ex5\hetero_unemp.dta"	
		drop _merge
		
	* create group
	
		sort city_id year month		
						
		gen gp_urband = 0
		replace gp_urband = 1 if urban > 0		
		
	* regression
		
		foreach i in 1 0 {
		foreach v in mob unemp urban {
			
			if "`v'" == "mob" local k = "1"
			if "`v'" == "unemp" local k = "2"
			if "`v'" == "urban" local k = "3"
									
			ppmlhdfe sr c.post#c.first c.post#c.second  [w=pop] if gp_`v' == `i', absorb(month#city_id nyear#city_id) cluster(city_id) eform
			parmest, saving($figure/Ex5/hetero_`v'`i'.dta, replace) idstr(`v') idnum(`k'`i') eform
		}
		}
	
*******************************************************************************
	
	* heatlh intervention
	
		cd $figure/Ex5
		openall
		
		keep if idstr == "mob"
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
			title("a. Intensity of health interventions", pos(11) size(4)) ///
			xtitle("") ///
			ytitle("") ///
			text(0.74 2 "0.85", size(2.0) linegap(1)) ///
			text(0.67 2 "(0.81 0.90)", size(2.0) linegap(1)) ///
			text(1.02 5 "1.15", size(2.0) linegap(1)) ///
			text(0.95 5 "(1.09 1.21)", size(2.0) linegap(1)) ///
			text(0.74 1 "0.88", size(2.0) linegap(1)) ///
			text(0.67 1 "(0.81 0.95)", size(2.0) linegap(1)) ///
			text(1.03 4 "1.20", size(2.0) linegap(1)) ///
			text(.96 4 "(1.10 1.31)", size(2.0) linegap(1)) ///
			legend(order(1 3) label(1 "First outbreak (Feb-Jun)") label(3 "Second outbreak (Jul-Oct)") ring(0) pos(11) rowgap(0.4) colgap(0.4) keygap(0.8)) 
					
		graph save "$figure/Ex5/Ex5_A", replace
		
********************************************************************************

	* economic shock
	
		cd $figure/Ex5
		openall
		
		keep if idstr == "unemp"
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
			title("b. Economic shock", pos(11) size(4)) ///
			xtitle("") ///
			ytitle("") ///
			text(0.74 2 "0.85", size(2.0) linegap(1)) ///
			text(0.67 2 "(0.81 0.93)", size(2.0) linegap(1)) ///
			text(1.03 5 "1.17", size(2.0) linegap(1)) ///
			text(.96 5 "(1.10 1.24)", size(2.0) linegap(1)) ///
			text(0.74 1 "0.87", size(2.0) linegap(1)) ///
			text(0.68 1 "(0.81 0.93)", size(2.0) linegap(1)) ///
			text(1.00 4 "1.13", size(2.0) linegap(1)) ///
			text(0.93 4 "(1.06 1.23)", size(2.0) linegap(1)) ///
			legend(off) 
		
		graph save "$figure/Ex5/Ex5_B", replace	
		
********************************************************************************

	* base urban rate
	
		cd $figure/Ex5
		openall
		
		keep if idstr == "urban"
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
			title("c. Urban population (%)", pos(11) size(4)) ///
			xtitle("") ///
			ytitle("") ///
			text(0.74 2 "0.84", size(2.0) linegap(1)) ///
			text(0.67 2 "(0.81 0.88)", size(2.0) linegap(1)) ///
			text(1.03 5 "1.15", size(2.0) linegap(1)) ///
			text(0.96 5 "(1.10 1.21)", size(2.0) linegap(1)) ///
			text(0.78 1 "0.97", size(2.0) linegap(1)) ///
			text(0.71 1 "(0.85 1.10)", size(2.0) linegap(1)) ///
			text(.98 4 "1.21", size(2.0) linegap(1)) ///
			text(0.91 4 "(1.05 1.40)", size(2.0) linegap(1)) ///
			legend(off)
					
		graph save "$figure/Ex5/Ex5_C", replace
	
********************************************************************************
	
	* graph combine
	
		graph combine  "$figure/Ex5/Ex5_A" "$figure/Ex5/Ex5_B" "$figure/Ex5/Ex5_C", row(1) xsize(15) ysize(4) imargin(3 3 3) graphregion(margin(vtiny) fcolor(white) lcolor(white)) iscale(1.4)  
		
		graph save "$figure/Ex5/Ex5", replace
		graph export "$figure/fig_png/Ex5.png", replace width(3000)
		graph export "$figure/fig_eps/Ex5.eps", replace as(eps)
		graph export "$figure/fig_pdf/Ex5.pdf", replace
				
			
			