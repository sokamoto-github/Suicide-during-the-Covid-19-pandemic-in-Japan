
*==============================================================================*
* Project: COVID and suicide in Japan			    			          	   *
* Date:   2020 Nov                                                             *
* Author: Tanaka and Okamoto                           						   *  
*==============================================================================*

* set directories 
clear all
set matsize 800
set more off
cap log close

local TNK 1
local OKMT 0

if `TNK'==1{
	global dir= "C:\Users\takan\Dropbox\macro_suicide\suicide\publication"
}

if `OKMT'==1{
	global dir= "/Users/shoheiokamoto/Desktop/Macro_health_resources/suicide/publication"
}

global data "$dir/data"
global tables "$dir/tables"
global figure  "$dir/figures"

********************************************************************************

	* set data
	
		use "$data\working_data\working_data.dta", replace	
	
		sort city_id year month
				
	* baseline
		
		ppmlhdfe sr treat_post  [w=pop], absorb(city_id#month city_id#nyear) cluster(city_id) eform
		parmest , saving($figure/fig3/coef_baseline.dta, replace) idstr("baseline") idnum(1) eform
									
	* first and second wave
		
		ppmlhdfe srad_male c.post#c.soe c.post#c.nosoe c.post#c.second [w=pop_ad_male], absorb(city_id#month city_id#nyear) cluster(city_id) eform
		parmest , saving($figure/fig3/coef_admale_period.dta, replace) idstr(ad_male_period) idnum(3) eform
			
		ppmlhdfe srad_female c.post#c.soe c.post#c.nosoe c.post#c.second [w=pop_ad_female], absorb(city_id#month city_id#nyear) cluster(city_id) eform
		parmest , saving($figure/fig3/coef_adfemale_period.dta, replace) idstr(ad_female_period) idnum(4) eform
			
		ppmlhdfe srel_male c.post#c.soe c.post#c.nosoe c.post#c.second [w=pop_el_male], absorb(city_id#month city_id#nyear) cluster(city_id) eform
		parmest , saving($figure/fig3/coef_elmale_period.dta, replace) idstr(el_male_period) idnum(5) eform
			
		ppmlhdfe srel_female c.post#c.soe c.post#c.nosoe c.post#c.second [w=pop_el_female], absorb(city_id#month city_id#nyear) cluster(city_id) eform
		parmest , saving($figure/fig3/coef_elfemale_period.dta, replace) idstr(el_female_period) idnum(6) eform
		
********************************************************************************	
	
	* child
		
		use "$data/working_data/working_data_child.dta", replace	
					
	* regression
	
		ppmlhdfe sr_ch c.post#c.pre c.post#c.close c.post#c.after [w=pop_ch], absorb(pref_id#month pref_id#nyear) cluster(pref_id) eform
		parmest , saving($figure/fig3/coef_ch_period.dta, replace) idstr(child) idnum(7) eform
			
********************************************************************************	
				
	* graph
	
		cd "$figure/fig3"
		openall
		
		drop if parm == "_cons" 
		
		gen group = 0
		replace group = 1 if idstr == "baseline"
		replace group = 2 if parm == "c.post#c.soe"
		replace group = 3 if parm == "c.post#c.nosoe"
		replace group = 4 if parm == "c.post#c.second"
		replace group = 5 if parm == "c.post#c.pre"
		replace group = 6 if parm == "c.post#c.close"
		replace group = 7 if parm == "c.post#c.after"
		
		sort group idnum
		
		gen y = 17 - _n	
				
		label define ylabel   ///	
				16 "{it:Baseline}" ///
				15 "{it:State of Emergency (Apr&May)}, Male adult " ///
				14 "Female adult " ///
				13 "Male elderly " ///
				12 "Female elderly " ///
				11 "{it:First outbreak, others (Feb, Mar, Jun)}, Male adult" ///
				10 "Female adult " ///
				9 "Male elderly " ///
				8 "Female elderly " ///
				7 "{it:Second outbreak (Jul-Oct)}, Male adult " ///
				6 "Female adult " ///
				5 "Male elderly " ///
				4 "Female elderly " ///
				3 "{it:Before school closure (Feb)}, Children " ///
				2 "{it:School closure (Mar&April)}, Children " ///
				1 "{it:After school closure(Jun-Oct)}, Children " ///
				
			label values y ylabel
		
		graph twoway (rspike min95 max95 y if y <= 3, msymbol(circle) lcolor(gs6) horizontal lwidth(med)) ///
				(scatter y estimate if y <= 3, msymbol(circle) mcolor(yellow*1.2) mlcolor(yellow*1.2) mlwidth(thin) msize(0.8)) ///
				(rspike min95 max95 y if y >= 4 & y<= 7, msymbol(circle) lcolor(gs6) horizontal lwidth(med)) ///
				(scatter y estimate if y >= 4 & y<= 7, msymbol(circle) mcolor(red*1.2) mlcolor(red*1.2) mlwidth(thin) msize(0.8)) ///
				(rspike min95 max95 y if y >= 8 & y<= 11, msymbol(circle) lcolor(gs6) horizontal lwidth(med)) ///
				(scatter y estimate if y >= 8 & y<= 11, msymbol(circle) mcolor(green*0.75) mlcolor(green*0.75) mlwidth(thin) msize(0.8)) ///
				(rspike min95 max95 y if y >= 12 & y<= 15, msymbol(circle) lcolor(gs6) horizontal lwidth(med)) ///
				(scatter y estimate if y >= 12 & y<= 15, msymbol(circle) mcolor(blue*1.2) mlcolor(blue*1.2) mlwidth(thin) msize(0.8)) ///
				(rspike min95 max95 y if y == 16, msymbol(circle) lcolor(gs6) horizontal lwidth(med)) ///
				(scatter y estimate if y == 16, msymbol(circle) mcolor(orange) mlcolor(orange) mlwidth(thin) msize(0.8)) ///
				, xline(1) ///
				legend(off) ///
				xtitle("") ytitle("") ///
				xlabel(.5 (.25) 1.75, nogrid labsize(2)) ///
				xscale(range(.5 2.5)) ///
				ylabel(0.5 " " 1/16, valuelabel nogrid labsize(2)) ///
				yscale(range(0.5 16.5)) ///
				text(16.75 2.2 "IRR (95% CI)", place(c) size(2)) ///	
				text(16 2.2 "0.99 (0.95 1.03)", place(c) size(2)) ///
				text(15 2.2 "0.79 (0.73 0.85)", place(c) size(2)) ///
				text(14 2.2 "0.73 (0.65 0.83)", place(c) size(2)) ///
				text(13 2.2 "0.85 (0.73 1.00)", place(c) size(2)) ///
				text(12 2.2 "0.80 (0.64 1.00)", place(c) size(2)) ///
				text(11 2.2 "0.90 (0.83 0.96)", place(c) size(2)) ///
				text(10 2.2 "0.85 (0.76 0.95)", place(c) size(2)) ///
				text(9 2.2 "0.87 (0.75 1.00)", place(c) size(2)) ///
				text(8 2.2 "0.82 (0.67 1.00)", place(c) size(2)) ///
				text(7 2.2 "1.07 (1.00 1.14)", place(c) size(2)) ///
				text(6 2.2 "1.44 (1.30 1.60)", place(c) size(2)) ///
				text(5 2.2 "1.03 (0.90 1.18)", place(c) size(2)) ///
				text(4 2.2 "1.27 (1.08 1.51)", place(c) size(2)) ///
				text(3 2.2 "0.90 (0.60 1.36)", place(c) size(2)) ///
				text(2 2.2 "0.91 (0.66 1.26)", place(c) size(2)) ///
				text(1 2.2 "1.35 (1.04 1.75)", place(c) size(2)) ///
				text(15.2 .5 "a", place(c) size(2)) ///
				text(11.2 .5 "b", place(c) size(2)) ///
				text(7.2 .5 "c", place(c) size(2)) ///
				text(3.2 .5 "d", place(c) size(2)) ///							
				yline(3.5, lwidth(vthin) lcol(gs10) lpattern(shortdash)) ///
				yline(7.5, lwidth(vthin) lcol(gs10) lpattern(shortdash)) ///
				yline(11.5, lwidth(vthin) lcol(gs10) lpattern(shortdash)) ///
				yline(15.5, lwidth(vthin) lcol(gs10) lpattern(shortdash)) ///		
				xsize(12) ysize(11) ///
 				scheme(plotplain) 						
	
				graph save "$figure/fig3/fig3", replace
	
	* graph export
		
		graph export "$figure/fig_png/fig3.png", replace width(3000)
		graph export "$figure/fig_eps/fig3.eps", replace as(eps)
		graph export "$figure/fig_pdf/fig3.pdf", replace
	
