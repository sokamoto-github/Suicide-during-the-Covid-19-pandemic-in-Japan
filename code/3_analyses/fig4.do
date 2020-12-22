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
	
		use "$data\working_data\working_data_jobstatus.dta", replace	
		sort city_id year month
						
	* regression
	
		ppmlhdfe srall treat_post  [w=pop], absorb(city_id#month city_id#nyear) cluster(city_id) eform
		parmest , saving($figure/fig4/coef_lnall.dta, replace) idstr("lnall") idnum(1) eform			
						
		foreach i in srself sremp srunemp srhousewife srretire {
			if "`i'" == "srself" local k = "2"
			if "`i'" == "sremp" local k = "3"
			if "`i'" == "srunemp" local k = "4"
			if "`i'" == "srhousewife" local k = "5"
			if "`i'" == "srretire" local k = "6"
		
			ppmlhdfe `i' c.post#c.first c.post#c.second  [w=pop], absorb(city_id#month city_id#nyear) cluster(city_id) eform
			parmest , saving($figure/fig4/coef_`i'.dta, replace) idstr("`i'") idnum(`k') eform
			}
			
		ppmlhdfe srstudent c.post#c.before_close c.post#c.sch_close c.post#c.after_close  [w=pop], absorb(city_id#month city_id#nyear) cluster(city_id) eform
		parmest , saving($figure/fig4/coef_srstudent.dta, replace) idstr("srstudent") idnum(7) eform

********************************************************************************						
							
		cd "$figure/fig4"
		openall
		
		drop if parm == "_cons"  		
		sort parm	
		
		keep if idstr == "sremp"
		gen x = _n
		
		graph twoway (rspike min95 max95 x if x == 1, msymbol(circle) lcolor(gs6) lwidth(med)) ///
				(scatter estimate x if x == 1, msymbol(circle) mcolor(blue*1.2) mlcolor(blue*1.2) mlwidth(thin) ) ///
				(rspike min95 max95 x if x == 2, msymbol(circle) lcolor(gs6) lwidth(med)) ///
				(scatter estimate x if x == 2, msymbol(circle) mcolor(red*1.2) mlcolor(red*1.2) mlwidth(thin) ) ///
				, scheme(plotplain) ///
				title("a. Employed", pos(11) size(4)) ///
				xlabel(0.5 " " 1 "first" 2 "second" 2.5 " ", nogrid) ///
				ylabel(.4 (.2) 1.6, nogrid) ///
				xtitle("") ///
				yline(1, lp(shortdash) lcolor(gs10) lwidth(vthin)) ///		
				text(0.63 1 "0.8", size(2.0) linegap(1)) ///
				text(0.56 1 "(0.7 0.91)", size(2.0) linegap(1)) ///
				text(1.04 2 "1.24", size(2.0) linegap(1)) ///
				text(0.97 2 "(1.11 1.4)", size(2.0) linegap(1)) ///
				legend(order(2 4) label(2 "First outbreak (Feb-Jun)") label(4 "Second outbreak (Jul-Oct)") col(2) row(2) ring(0) pos(11) rowgap(0.4) colgap(0.4))
					
			graph save "$figure/fig4/fig4_A", replace
	
********************************************************************************		
					
		cd "$figure/fig4"
		openall
		
				
		drop if parm == "_cons" 		
		sort parm	
		
		keep if idstr == "srretire"
		gen x = _n
		
		graph twoway (rspike min95 max95 x if x == 1, msymbol(circle) lcolor(gs6) lwidth(med)) ///
				(scatter estimate x if x == 1, msymbol(circle) mcolor(blue*1.2) mlcolor(blue*1.2) mlwidth(thin) ) ///
				(rspike min95 max95 x if x == 2, msymbol(circle) lcolor(gs6) lwidth(med)) ///
				(scatter estimate x if x == 2, msymbol(circle) mcolor(red*1.2) mlcolor(red*1.2) mlwidth(thin) ) ///
				, scheme(plotplain) ///
				title("b. Retired", pos(11) size(4)) ///
				xlabel(0.5 " " 1 "first" 2 "second" 2.5 " ", nogrid) ///
				ylabel(.4 (.2) 1.6, nogrid) ///
				xtitle("") ///
				yline(1, lp(shortdash) lcolor(gs10) lwidth(vthin)) ///
				text(0.62 1 "0.8", size(2.0) linegap(1)) ///
				text(0.55 1 "(0.69 0.92)", size(2.0) linegap(1)) ///
				text(0.87 2 "1.08", size(2.0) linegap(1)) ///
				text(0.8 2 "(0.94 1.24)", size(2.0) linegap(1)) ///
				legend(off)
					
			graph save "$figure/fig4/fig4_B", replace
	
********************************************************************************		
		
		cd "$figure/fig4"
		openall
		
				
		drop if parm == "_cons" 		
		sort parm	
		
		keep if idstr == "srunemp"
		gen x = _n
		
		graph twoway (rspike min95 max95 x if x == 1, msymbol(circle) lcolor(gs6) lwidth(med)) ///
				(scatter estimate x if x == 1, msymbol(circle) mcolor(blue*1.2) mlcolor(blue*1.2) mlwidth(thin) ) ///
				(rspike min95 max95 x if x == 2, msymbol(circle) lcolor(gs6) lwidth(med)) ///
				(scatter estimate x if x == 2, msymbol(circle) mcolor(red*1.2) mlcolor(red*1.2) mlwidth(thin) ) ///
				, scheme(plotplain) ///
				title("c. Unemployed", pos(11) size(4)) ///
				xlabel(0.5 " " 1 "first" 2 "second" 2.5 " ", nogrid) ///
				ylabel(.4 (.2) 1.6, nogrid) ///
				xtitle("") ///
				yline(1, lp(shortdash) lcolor(gs10) lwidth(vthin)) ///
				text(0.66 1 "0.83", size(2.0) linegap(1)) ///
				text(0.59 1 "(0.73 0.95)", size(2.0) linegap(1)) ///
				text(0.88 2 "1.11", size(2.0) linegap(1)) ///
				text(0.81 2 "(0.95 1.29)", size(2.0) linegap(1)) ///
				legend(off)
					
			graph save "$figure/fig4/fig4_C", replace
			
********************************************************************************			

		cd "$figure/fig4"
		openall
		
		drop if parm == "_cons"  		
		sort parm	
		
		keep if idstr == "srself"
		gen x = _n
		
		graph twoway (rspike min95 max95 x if x == 1, msymbol(circle) lcolor(gs6) lwidth(med)) ///
				(scatter estimate x if x == 1, msymbol(circle) mcolor(blue*1.2) mlcolor(blue*1.2) mlwidth(thin) ) ///
				(rspike min95 max95 x if x == 2, msymbol(circle) lcolor(gs6) lwidth(med)) ///
				(scatter estimate x if x == 2, msymbol(circle) mcolor(red*1.2) mlcolor(red*1.2) mlwidth(thin) ) ///
				, scheme(plotplain) ///
				title("d. Self-employed", pos(11) size(4)) ///
				xlabel(0.5 " " 1 "first" 2 "second" 2.5 " ", nogrid) ///
				ylabel(.4 (.2) 1.6, nogrid) ///
				xtitle("") ///
				text(0.54 1 "0.81", size(2.0) linegap(1)) ///
				text(0.47 1 "(0.61 1.09)", size(2.0) linegap(1)) ///
				text(0.61 2 "0.95", size(2.0) linegap(1)) ///
				text(0.54 2 "(0.68 1.33)", size(2.0) linegap(1)) ///
				yline(1, lp(shortdash) lcolor(gs10) lwidth(vthin)) ///
				legend(off)
					
			graph save "$figure/fig4/fig4_D", replace	

********************************************************************************			
			
		cd "$figure/fig4"
		openall
						
		drop if parm == "_cons" 		
		sort parm	
		
		keep if idstr == "srhousewife"
		gen x = _n
		
		graph twoway (rspike min95 max95 x if x == 1, msymbol(circle) lcolor(gs6) lwidth(med)) ///
				(scatter estimate x if x == 1, msymbol(circle) mcolor(blue*1.2) mlcolor(blue*1.2) mlwidth(thin) ) ///
				(rspike min95 max95 x if x == 2, msymbol(circle) lcolor(gs6) lwidth(med)) ///
				(scatter estimate x if x == 2, msymbol(circle) mcolor(red*1.2) mlcolor(red*1.2) mlwidth(thin) ) ///
				, scheme(plotplain) ///
				title("e. Housewife", pos(11) size(4)) ///
				xlabel(0.5 " " 1 "first" 2 "second" 2.5 " ", nogrid) ///
				ylabel(0 (.5) 3.5, nogrid) ///
				xtitle("") ///
				yline(1, lp(shortdash) lcolor(gs10) lwidth(vthin)) ///
				text(0.62 1 "1.17", size(2.0) linegap(1)) ///
				text(0.44 1 "(0.81 1.7)", size(2.0) linegap(1)) ///
				text(1.46 2 "2.32", size(2.0) linegap(1)) ///
				text(1.28 2 "(1.65 3.26)", size(2.0) linegap(1)) ///
				legend(off)
					
			graph save "$figure/fig4/fig4_E", replace

********************************************************************************			
				
		cd "$figure/fig4"
		openall
						
		drop if parm == "_cons" 		
		sort parm	
		
		keep if idstr == "srstudent"
		gen x = _n
		replace x = 1 if parm == "c.post#c.before_close"
		replace x = 2 if parm == "c.post#c.sch_close"
		replace x = 3 if parm == "c.post#c.after_close"
		
		graph twoway (rspike min95 max95 x if x == 1, msymbol(circle) lcolor(gs6) lwidth(med)) ///
				(scatter estimate x if x == 1, msymbol(circle) mcolor(yellow) mlcolor(yellow) mlwidth(thin) ) ///
				(rspike min95 max95 x if x == 2, msymbol(circle) lcolor(gs6) lwidth(med)) ///
				(scatter estimate x if x == 2, msymbol(circle) mcolor(green*0.6) mlcolor(green*0.6) mlwidth(thin) ) ///
				(rspike min95 max95 x if x == 3, msymbol(circle) lcolor(gs6) lwidth(med)) ///
				(scatter estimate x if x == 3, msymbol(circle) mcolor(orange) mlcolor(orange) mlwidth(thin) ) ///
				, scheme(plotplain) ///
				title("f. Student", pos(11) size(4)) ///
				xlabel(0.5 " " 1 "Before" 2 "Close"  3 "After" 3.5 " ", nogrid) ///
				ylabel(0 (.5) 2.5, nogrid) ///
				xtitle("") ///
				yline(1, lp(shortdash) lcolor(gs10) lwidth(vthin)) ///
				text(0.48 1 "0.98", size(2.0) linegap(1)) ///
				text(0.34 1 "(0.61 1.57)", size(2.0) linegap(1)) ///
				text(1.04 2 "0.51", size(2.0) linegap(1)) ///
				text(0.90 2 "(0.34 0.77)", size(2.0) linegap(1)) ///
				text(0.64 3 "1.05", size(2.0) linegap(1)) ///
				text(0.50 3 "(0.77 1.43)", size(2.0) linegap(1)) ///
				legend(order(2 4 6) label(2 "Before closure (Feb)") label(4 "School closure (Mar&Apr)") label(6 "After closure (May-Oct)") ring(0) pos(11) rowgap(0.4) colgap(0.4))
					
			graph save "$figure/fig4/fig4_F", replace

********************************************************************************			
			
	* graph combine
	
		graph combine  "$figure/fig4/fig4_A" "$figure/fig4/fig4_B" "$figure/fig4/fig4_C" "$figure/fig4/fig4_D" "$figure/fig4/fig4_E" "$figure/fig4/fig4_F", col(3) row(2) imargin(4 4 4 4 4 4) xsize(20) ysize(10) graphregion(margin(vtiny) fcolor(white) lcolor(white)) iscale(.75)
								
		graph save "$figure/fig4/fig4", replace
		graph export "$figure/fig_png/fig4.png", replace width(3000)
		graph export "$figure/fig_eps/fig4.eps", replace as(eps)
		graph export "$figure/fig_pdf/fig4.pdf", replace
		
		