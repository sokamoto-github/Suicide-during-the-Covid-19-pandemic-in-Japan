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
		
	* predict counterfactual 
		
		ppmlhdfe sr [w=pop], absorb(city_id#month city_id#c.ym, savefe) cluster(city_id)
		egen fe1 = max(__hdfe1__), by(city_id month)
		egen fe2 = max(__hdfe2__), by(city_id)
		predictnl cons = xb()
		gen yhat_ln = cons + fe1 + fe2*ym
		gen yhat = exp(yhat_ln)
		gen resid = sr - yhat
		
		gen running = ym - 720
		gen pre_running = running
		replace pre_running = 0 if running > 0
		gen post_running = running
		replace post_running = 0 if running < 0
		gen jump = 0
		replace jump = 1 if running > 0
		
	* graph counterfactual
		
		collapse (mean) sr yhat [w=pop], by(ym)
		
		graph twoway (line sr ym, lcolor(gs6)) (line yhat ym, lcolor(gs6)) /// 
			, xlabel(684 "17-Jan" 696 "18-Jan" 708 "19-Jan" 720 "20-Jan" 729 " ",nogrid) ///
			xscale(range(678 734)) /// 
			ylabel(0 (5) 25, nogrid) ///
			xtitle("") ytitle("Suicide rate") ///			
			title("a. Real and counterfactual suicide rate", pos(11) size(4)) ///
			legend(order(1 2) label(1 "Suicide rate") label(2 "Counterfactual") ring(0) pos(11) rowgap(0.4) size(2.5) keygap(0.8)) ///
			xline(720, lp(dash) lcolor(gs10) lwidth(vthin)) ///
			scheme(plotplain) 
					
		graph save "$figure/figS4/figS4_A", replace
	
		use "$data\working_data\working_data.dta", replace	
					
		sort city_id year month		

********************************************************************************
		
		use "$data\working_data\working_data.dta", replace	
		sort city_id year month		
		
	* predict counterfactual 
		
		ppmlhdfe sr [w=pop], absorb(city_id#month city_id#c.ym, savefe) cluster(city_id)
		egen fe1 = max(__hdfe1__), by(city_id month)
		egen fe2 = max(__hdfe2__), by(city_id)
		predictnl cons = xb()
		gen yhat_ln = cons + fe1 + fe2*ym
		gen yhat = exp(yhat_ln)
		gen resid = sr - yhat
				
		gen running = ym - 720
		gen pre_running = running
		replace pre_running = 0 if running > 0
		gen post_running = running
		replace post_running = 0 if running < 0
		gen jump = 0
		replace jump = 1 if running > 0
	
	* interrupted analysis
	
		keep if ym >= 712
	
		reghdfe resid jump pre_running post_running [w=pop], noabsorb
		predict fitted		
	
	* local regression
						
		local each = "base c.post#c.period1 c.post#c.period2 c.post#c.period3 c.post#c.period4 c.post#c.period5 c.post#c.period6 c.post#c.period7 c.post#c.period8 c.post#c.period9"
		local combined = "c.post#c.first c.post#c.second"
		
		reghdfe resid `each' [w=pop], noabsorb cluster(city_id)
		parmest, saving($figure/figS4/each, replace) idstr(each) idnum(1)
		reghdfe resid `combined' [w=pop], noabsorb cluster(city_id)
		parmest, saving($figure/figS4/sum.dta, replace) idstr(combined) idnum(2)
				
		collapse (mean) fitted resid running pre_running post_running [w=pop], by(ym)
		
	* graph local regression
							
		graph twoway (line fitted running if running <= 0, lpattern(dash) lcolor(gs6)) ///
			(line fitted running if running >= 1, lpattern(dash) lcolor(gs6)) /// 
			(scatter resid running if running <= 0, mstyle(circle) mcolor(gs6)) ///
			(scatter resid running if running >= 1 & running <= 5, mstyle(circle) mcolor(blue*1.2)) ///
			(scatter resid running if running >= 6, mstyle(circle) mcolor(red*1.2)) ///
			, scheme(plotplain) ylabel(-8 (2) 6, nogrid) ///
			xlabel(-7 "-8" -5 "-6" -3 "-4" -1 "-2" 1 "0" 3 "2" 5 "4" 7 "6" 9 "8",nogrid) ///
			xscale(range(-8.5 9.5)) /// 
			xtitle("") ///
			ytitle("Coefficients") /// 
			legend(order(1 3 4 5) label(1 "Fitted line") label(3 "Residual: pre-pandemic") label(4 "Residual: first outbreak")  label(5 "Residual: second outbreak") ring(0) pos(4) rowgap(0.4) size(2.5) keygap(0.8)) ///
			title("b. Augmented interrupted analysis", pos(11) size(4)) ///
			text(2.5 -5 "slope = -.002", size(2.5) linegap(1)) ///
			text(1.75 -5 "(-.09 .09)", size(2.5) linegap(1)) ///
			text(-2.5 -1.75 "{&beta} = -2.52", size(2.5) linegap(1)) ///
			text(-3.25 -1.75 "(-3.21 -1.84)", size(2.5) linegap(1)) ///
			text(-2 7 "slope = .58", size(2.5) linegap(1)) ///
			text(-2.75 7 "(.49 .67)", size(2.5) linegap(1)) ///
			xline(0, lp(dash) lcolor(gs10) lwidth(vthin)) 
					
			graph save "$figure/figS4/figS4_B", replace
	
********************************************************************************

	* graph interrupted analysis
	
		cd "$figure/figS4"
		openall
			
		drop if parm == "_cons"
		sort idnum parm
		
		gen x = 0
		for num 1/9: replace x = X if parm == "c.post#c.periodX"
		replace x = 10 if parm == "c.post#c.first"
		replace x = 11 if parm == "c.post#c.second"
		replace x = x+1
		sort x
		
		graph twoway (rarea max95 min95 x if x <= 10, fcolor(gs14) lcolor(gs14)) ///
			(line estimate x if x >= 1 & x <= 2, lcolor(gs6) lpattern(shortdash)) ///
			(line estimate x if x >= 2 & x <= 6, lcolor(blue*1.2) lpattern(solid)) ///
			(line estimate x if x >= 6 & x <= 7, lcolor(gs6) lpattern(shortdash)) ///
			(line estimate x if x >= 7 & x <= 10, lcolor(red*1.2) lpattern(solid)) ///
			(scatter estimate x if x ==1, mcolor(gs6) mlcolor(gs6) msymbol(circle) msize(0.8)) ///
			(scatter estimate x if x >= 2 & x <= 6, mcolor(blue*1.2) mlcolor(blue*1.2) msymbol(circle) msize(0.8)) ///
			(scatter estimate x if x >= 7 & x <= 10, mcolor(red*1.2) mlcolor(red*1.2) msymbol(circle) msize(0.8)) ///
			(scatter estimate x if x == 11, mcolor(blue*1.2) msymbol(x) msize(3)) ///
			(rspike max95 min95 x if x == 11, lcolor(blue*1.2) lpattern(solid)) ///
			(scatter estimate x if x == 12, mcolor(red*1.2) msymbol(x) msize(3)) ///
			(rspike max95 min95 x if x == 12, lcolor(red*1.2) lpattern(solid)) ///
			,scheme(plotplain) ///
			xlab(1 "-1" 3 "1" 5 "3" 7 "5" 9 "7" 10 " ", labsize(*0.8) labcolor(black) axis(1) nogrid) ///
			xscale(range(0.5 12.5)) ///
			ylabel(-8 -6 -4 -2 0 2 4 6, labsize(*0.8) nogrid) ///
			yline(0, lp(dash) lcolor(gs10) lwidth(vthin)) ///
			title("c.  Augmented local regression", pos(11) size(4)) ///
			text(-2 11 "-.96", size(2.5) linegap(1)) ///
			text(-2.7 11 "(-1.29 -.64)", size(2.5) linegap(1)) ///
			text(1.0 12 "2.09", size(2.5) linegap(1)) ///
			text(.3 12 "(1.69 2.49)", size(2.5) linegap(1)) ///
			xtitle("") ///
			xline(1, lp(dash) lcolor(gs10) lwidth(vthin)) ///
			ytitle("Coefficients") ///
			legend(order(1 7 8) label(1 "95% CI") label(7 "First outbreak (Feb-Jun)") label(8 "Second outbreak (Jul-Oct)") size(2.2) col(1) ring(0) pos(4) rowgap(0.4) colgap(0.4) keygap(0.4)) 
			
		graph save "$figure/figS4/figS4_C", replace

********************************************************************************
	
	* graph combine
	
		graph combine  "$figure/figS4/figS4_A" "$figure/figS4/figS4_B" "$figure/figS4/figS4_C", row(1) xsize(15) ysize(4) imargin(3 3 3) graphregion(margin(vtiny) fcolor(white) lcolor(white)) iscale(1.2)  
		
		graph save "$figure/figS4/figS4", replace
		graph export "$figure/fig_png/figS4.png", replace width(3000)
		graph export "$figure/fig_eps/figS4.eps", replace as(eps)
		graph export "$figure/fig_pdf/figS4.pdf", replace
			
					
					
		
		
	