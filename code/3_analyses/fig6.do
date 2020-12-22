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
	
	* employment by gender
	
		import excel using "$data/raw_data/figures/fig6/worker", firstrow clear
					
		gen ym = ym(year,month)
		sort ym
		
		keep if ym >= 718
		
		foreach i in reg noreg male female {
			gen `i'_base_ = `i' if year == 2020 & month == 1
			egen `i'_base = max(`i'_base_)
			replace `i' = `i'/`i'_base
			}
							
		graph twoway (connected male ym, lcolor(gs6) msize(0.9) mcolor(red*1.2) msymbol(circle) lpattern(shortdash_dot)) ///
				(connected female ym, lcolor(gs6) msize(0.9) mcolor(blue*1.2) msymbol(circle) lpattern(shortdash_dot)) ///
				, xlabel(719 "Dec" 721 "Feb" 723 "Apr" 725 "Jun" 727 "Aug" 729 "Oct", nogrid) ///
				xscale(range(717.5 729.5)) ///
				ylabel(.9 .95 1 1.05 1.1 1.049999999999999 "          .", nogrid axis(1)) ///
				xline(720 ,lp(shortdash) lcolor(gs10) lwidth(vthin) noextend) ///
				yline(1, lp(shortdash) lcolor(gs10) lwidth(vthin) noextend) ///
				xtitle("") ///
				title("a. Employment by gender", pos(11) size(5)) ///
				legend(order(1 2)  label(1 "Male (Jan = 1.00)") label(2 "Female (Jan = 1.00)") ring(0) pos(2) rowgap(0.4) colgap(0.4)) ///
				scheme(plotplain)
			
		graph save "$figure/fig6/fig6_A", replace		
		
********************************************************************************

	* employment by types
	
		import excel using "$data/raw_data/figures/fig6/worker", firstrow clear
					
		gen ym = ym(year,month)
		sort ym
		
		keep if ym >= 718
		
		foreach i in reg noreg male female {
			gen `i'_base_ = `i' if year == 2020 & month == 1
			egen `i'_base = max(`i'_base_)
			replace `i' = `i'/`i'_base
			}
							
		graph twoway (connected reg ym, lcolor(gs6) msize(0.9) mcolor(red*1.2) msymbol(circle) lpattern(shortdash_dot)) ///
				(connected noreg ym, lcolor(gs6) msize(0.9) mcolor(blue*1.2) msymbol(circle) lpattern(shortdash_dot)) ///
				, xlabel(719 "Dec" 721 "Feb" 723 "Apr" 725 "Jun" 727 "Aug" 729 "Oct", nogrid) ///
				xscale(range(717.5 729.5)) ///
				ylabel(.9 .95 1 1.05 1.1 1.049999999999999 "          .", nogrid axis(1)) ///
				xline(720 ,lp(shortdash) lcolor(gs10) lwidth(vthin) noextend) ///
				yline(1, lp(shortdash) lcolor(gs10) lwidth(vthin) noextend) ///
				xtitle("") ///
				title("b. Employment by type", pos(11) size(5)) ///
				legend(order(1 2)  label(1 "Regular (Jan = 1.00)") label(2 "Non-regular (Jan = 1.00)") ring(0) pos(2) rowgap(0.4) colgap(0.4)) ///
				scheme(plotplain)
			
		graph save "$figure/fig6/fig6_B", replace
		
********************************************************************************

	* dv
	
		import excel using "$data/raw_data/figures/fig6/dv.xlsx", firstrow clear
					
		sort month		
							
		graph twoway (connected dv2019 month, lcolor(gs6) msize(0.9) mcolor(red*1.2) msymbol(circle) lpattern(shortdash_dot)) ///
				(connected dv2020 month, lcolor(gs6) msize(0.9) mcolor(blue*1.2) msymbol(circle) lpattern(shortdash_dot)) ///
				, xlabel(4 "Apr" 5 "May" 6 "Jun" 7 "Jul" 8 "Aug" 9 "Sep", nogrid) ///
				xscale(range(3.5 9.5)) ///
				ylabel(0 5000 10000 15000 20000 19999.99999"          ." 25000, nogrid axis(1)) ///
				xtitle("") ///
				title("c. Domestic violence help call", pos(11) size(5)) ///
				legend(order(1 2)  label(1 "2019") label(2 "2020") ring(0) pos(2) rowgap(0.4) colgap(0.4)) ///
				scheme(plotplain)
			
		graph save "$figure/fig6/fig6_C", replace
	
********************************************************************************

	* income
	
		import excel using "$data/raw_data/figures/fig6/household_subsidy", firstrow clear
		save "$data/raw_data/figures/fig6/household_subsidy", replace
			
		import excel using "$data/raw_data/figures/fig6/kakei", firstrow sheet("kakei") clear
					
		gen ym = ym(year,month)
		sort ym
		
		keep if ym >= 718
		
		merge 1:1 ym using "$data/raw_data/figures/fig6/household_subsidy"
		drop _merge
		sort ym
		
		foreach i in income ordinary special bonus{
			replace `i' = `i'/1000
			}
			
		gen income_st = income - bonus			
		
		foreach i in income_st {
			gen `i'_base_ = `i' if year == 2020 & month == 1
			egen `i'_base = max(`i'_base_)
			replace `i' = `i'/`i'_base
			}
			
		gen subsidy_st = subsidy/2.455 * 1.6
				
		graph twoway (bar subsidy_st ym, fcolor(blue*0.15) lcolor(white) lwidth(vthin) barwidth(0.32)) ///
				(connected income_st ym, lcolor(gs6) msize(0.9) mcolor(blue*1.2) msymbol(circle) lpattern(shortdash_dot)) ///
				, xlabel(719 "Dec" 721 "Feb" 723 "Apr" 725 "Jun" 727 "Aug" 729 "Oct", nogrid) ///
				xscale(range(717.5 729.5)) ///
				ylabel(0 0.5 1 1.5 1.49999999999999 "          ." 2, nogrid axis(1)) ///
				xline(720 ,lp(shortdash) lcolor(gs10) lwidth(vthin) noextend) ///
				yline(1, lp(shortdash) lcolor(gs10) lwidth(vthin) noextend) ///
				xtitle("") ///
				title("d. Income and cash benefits", pos(11) size(5)) ///
				legend(order(2 1)  label(2 "Income (Jan = 1.00)") label(1 "% benefits distributed" "Max=15.1% in a week") ring(0) pos(7) rowgap(0.4) colgap(0.4)) ///
				text(1000 718 "bonus" "payment", size(2.5)) ///
				scheme(plotplain)
			
		graph save "$figure/fig6/fig6_D", replace	
			
********************************************************************************
	
	* bankrupt
	
		import excel using "$data/raw_data/figures/fig6/tosan", firstrow sheet("tosan") clear
			
		gen ym = ym(year,month)
		sort ym
				
		keep if ym >= 718
		
		foreach i in tosan {
			gen `i'_base_ = `i' if year == 2020 & month == 1
			egen `i'_base = max(`i'_base_)
			replace `i' = `i'/`i'_base
			}
		
		gen shikyu_st = shikyu / 131395 * 1.6
				
		graph twoway (bar shikyu_st ym, fcolor(blue*0.15) lcolor(white) lwidth(vthin) barwidth(0.25)) ///
				(connected tosan ym, lcolor(gs6) msize(0.9) mcolor(blue*1.2) msymbol(circle) lpattern(dash)) ///
				, xlabel(719 "Dec" 721 "Feb" 723 "Apr" 725 "Jun" 727 "Aug" 729 "Oct", nogrid) ///
				xscale(range(717.5 729.5)) ///
				ylabel(0 0.5 1 1.5 1.49999999999999 "          ." 2, nogrid axis(1)) ///
				xline(720 ,lp(shortdash) lcolor(gs10) lwidth(vthin) noextend) ///
				yline(1 ,lp(shortdash) lcolor(gs10) lwidth(vthin) noextend) ///
				xtitle("") ///
				title("e. Bankrupcy and business subsidy", pos(11) size(5)) ///
				legend(order(2 1)  label(2 "# of bankrupcy (Jan = 1.00)") label(1 "Weekly subsidy claims (max=131k in a week)") ring(0) pos(11) rowgap(0.4) colgap(0.4)) ///
				scheme(plotplain)	
		
		graph save "$figure/fig6/fig6_E", replace	

		
********************************************************************************
				
	* working hours
	
		import excel using "$data/raw_data/figures/fig6/work", firstrow sheet("work") clear
			
		gen ym = ym(year,month)
		sort ym
				
		keep if ym >= 718
		
		foreach i in work full temp{
			gen `i'_base_ = `i' if year == 2020 & month == 1
			egen `i'_base = max(`i'_base_)
			replace `i' = `i'/`i'_base
			}
			
		graph twoway (connected full ym, lcolor(gs6) msize(0.9) mcolor(orange*1.2) msymbol(square) lpattern(longdash)) ///
				(connected temp ym, lcolor(gs6) msize(0.9) mcolor(ebblue*1.2) msymbol(diamond) lpattern(shortdash)) ///
				(connected work ym, lcolor(gs6) msize(0.9) mcolor(blue*1.2) msymbol(circle) lpattern(shortdash_dot)) ///
				, xlabel(719 "Dec" 721 "Feb" 723 "Apr" 725 "Jun" 727 "Aug" 729 "Oct", nogrid) ///
				xscale(range(717.5 729.5)) ///
				ylabel(0 0.5 1 1.5 1.49999999999999 "          ." 2, nogrid) ///
				xline(720 ,lp(shortdash) lcolor(gs10) lwidth(vthin) noextend) ///
				yline(1 ,lp(shortdash) lcolor(gs10) lwidth(vthin) noextend) ///
				xtitle("") ///
				title("f. Working hours", pos(11) size(5)) ///
				legend(order(3 1 2)  label(3 "All workers (Jan = 1.00)") label(1 "Full time worker") label(2 "Part-time worker") ring(0) pos(4) rowgap(0.4) colgap(0.4)) ///
				scheme(plotplain)
			
		graph save "$figure/fig6/fig6_F", replace	
	
********************************************************************************
		
	* graph combine
	
		graph combine "$figure/fig6/fig6_A" "$figure/fig6/fig6_B" "$figure/fig6/fig6_C" "$figure/fig6/fig6_D" "$figure/fig6/fig6_E" "$figure/fig6/fig6_F", col(3) row(2) imargin(3 3 3 3 3 3) graphregion(margin(vtiny) fcolor(white) lcolor(white)) iscale(0.6) xsize(20) ysize(10)	
		
		graph save "$figure/fig6/fig6", replace
		graph export "$figure/fig_png/fig6.png", replace width(3000)
		graph export "$figure/fig_eps/fig6.eps", replace as(eps)
		graph export "$figure/fig_pdf/fig6.pdf", replace
	
	
	
	