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
		
	* all
					
		use "$data\working_data\working_data.dta", replace	
			
		collapse (sum) suicide pop, by(nyear period year month)
			
		gen sr = suicide/pop
		egen mean = mean(sr) if nyear >= 1 & nyear <= 3, by(period)
			
		gen ym = ym(year, month)
		
		sort nyear period
		
		graph twoway  (scatter sr period if nyear <= 3, color(gs12) msymbol(circle) msize(0.8)) ///
					(line mean period if nyear == 3, lpattern(solid) lpattern(shortdash_dot) lcolor(gs6)) ///
					(connected sr period if nyear == 4, lcolor(blue*0.8) mcolor(blue*0.6) msymbol(circle) msize(0.8) lpattern(solid)) ///
					, legend(order(2 3) label(2 "2016 Nov - 2019 Oct") label(3 "2019 Nov - 2020 Oct") ring(0) pos(4) rowgap(0.6)) ///
					xlab(-2 "Nov" 0 "Jan" 2 "Mar" 4 "May" 6 "Jul" 8 "Sep" 9 " ", labsize(*0.8) labcolor(black) axis(1) nogrid) ///
					xscale(range(-3 10)) ///
					ylabel(0 5 10 15 20 25, nogrid) ///
					xlabel(, nogrid) ///
					xtitle("") ytitle("") ///
					title("a. Total", size(4) pos(11) ring(2)) ///
					xline(0, lcolor(gs10) lpattern(shortdash) lwidth(vthin)) ///
					scheme(plotplain)
					
		graph save "$figure/Ex1/Ex1_A", replace				
							
*******************************************************************************	
	
	* male
				
		use "$data\working_data\working_data.dta", replace	
			
		collapse (sum) suicide_male pop_male, by(nyear period year month)
			
		gen sr_male = suicide_male/pop_male
		egen mean = mean(sr_male) if nyear >= 1 & nyear <= 3, by(period)
			
		gen ym = ym(year, month)
		
		sort nyear period
		
		graph twoway  (scatter sr_male period if nyear <= 3, color(gs10) msymbol(circle) msize(0.8)) ///
					(line mean period if nyear == 3, lpattern(solid) lpattern(shortdash_dot) lcolor(gs6)) ///
					(connected sr_male period if nyear == 4, lcolor(blue*0.8) mcolor(blue*0.6) msymbol(circle) msize(0.8) lpattern(solid)) ///
					, legend(off) ///
					xlab(-2 "Nov" 0 "Jan" 2 "Mar" 4 "May" 6 "Jul" 8 "Sep" 9 " ", labsize(*0.8) labcolor(black) axis(1) nogrid) ///
					xscale(range(-3 10)) ///
					ylabel(0 5 10 15 20 25, nogrid) ///
					xlabel(, nogrid) ///
					xtitle("") ytitle("") ///
					title("b. Male", size(4) pos(11) ring(2)) ///
					xline(0, lcolor(gs10) lpattern(shortdash) lwidth(vthin)) ///
					scheme(plotplain)
				
		graph save "$figure/Ex1/Ex1_B", replace				
						
********************************************************************************	

	* female
					
		use "$data\working_data\working_data.dta", replace	
			
		collapse (sum) suicide_female pop_female, by(nyear period year month)
			
		gen sr_female = suicide_female/pop_female
		egen mean = mean(sr_female) if nyear >= 1 & nyear <= 3, by(period)
			
		gen ym = ym(year, month)
		
		sort nyear period
		
		graph twoway  (scatter sr_female period if nyear <= 3, color(gs10) msymbol(circle) msize(0.8)) ///
					(line mean period if nyear == 3, lpattern(solid) lpattern(shortdash_dot) lcolor(gs6)) ///
					(connected sr_female period if nyear == 4, lcolor(blue*0.8) mcolor(blue*0.6) msymbol(circle) msize(0.8) lpattern(solid)) ///
					, legend(off) ///
					xlab(-2 "Nov" 0 "Jan" 2 "Mar" 4 "May" 6 "Jul" 8 "Sep" 9 " ", labsize(*0.8) labcolor(black) axis(1) nogrid) ///
					xscale(range(-3 10)) ///
					ylabel(0 5 10 15 20 25, nogrid) ///
					xlabel(, nogrid) ///
					xtitle("") ytitle("") ///
					title("c. Female", size(4) pos(11) ring(2)) ///
					xline(0, lcolor(gs10) lpattern(shortdash) lwidth(vthin)) ///
					scheme(plotplain)
					
		graph save "$figure/Ex1/Ex1_C", replace				
						
********************************************************************************	

	* children
	
		use "$data\working_data\working_data.dta", replace	
			
		collapse (sum) child pop_ch, by(nyear period year month)
			
		gen sr_ch = child/pop_ch
		egen mean = mean(sr_ch) if nyear >= 1 & nyear <= 3, by(period)
			
		gen ym = ym(year, month)
		
		sort nyear period
		
		graph twoway  (scatter sr_ch period if nyear <= 3, color(gs10) msymbol(circle) msize(0.8)) ///
					(line mean period if nyear == 3, lpattern(solid) lpattern(shortdash_dot) lcolor(gs6)) ///
					(connected sr_ch period if nyear == 4, lcolor(blue*0.8) mcolor(blue*0.6) msymbol(circle) msize(0.8) lpattern(solid)) ///
					, legend(off) ///
					xlab(-2 "Nov" 0 "Jan" 2 "Mar" 4 "May" 6 "Jul" 8 "Sep" 9 " ", labsize(*0.8) labcolor(black) axis(1) nogrid) ///
					xscale(range(-3 10)) ///
					ylabel(0 5 10 15 20 25, nogrid) ///
					xlabel(, nogrid) ///
					xtitle("") ytitle("") ///
					title("d. Age below 20", size(4) pos(11) ring(2)) ///
					xline(0, lcolor(gs10) lpattern(shortdash) lwidth(vthin)) ///
					scheme(plotplain)
									
		graph save "$figure/Ex1/Ex1_D", replace
				
********************************************************************************
	
	* adult
	
		use "$data\working_data\working_data.dta", replace	
			
		collapse (sum) adult pop_ad, by(nyear period year month)
			
		gen sr_ad = adult/pop_ad
		egen mean = mean(sr_ad) if nyear >= 1 & nyear <= 3, by(period)
			
		gen ym = ym(year, month)
		
		sort nyear period
		
		graph twoway  (scatter sr_ad period if nyear <= 3, color(gs10) msymbol(circle) msize(0.8)) ///
					(line mean period if nyear == 3, lpattern(solid) lpattern(shortdash_dot) lcolor(gs6)) ///
					(connected sr_ad period if nyear == 4, lcolor(blue*0.8) mcolor(blue*0.6) msymbol(circle) msize(0.8) lpattern(solid)) ///
					, legend(off) ///
					xlab(-2 "Nov" 0 "Jan" 2 "Mar" 4 "May" 6 "Jul" 8 "Sep" 9 " ", labsize(*0.8) labcolor(black) axis(1) nogrid) ///
					xscale(range(-3 10)) ///
					ylabel(0 5 10 15 20 25, nogrid) ///
					xlabel(, nogrid) ///
					xtitle("") ytitle("") ///
					title("e. Age 20~69", size(4) pos(11) ring(2)) ///
					xline(0, lcolor(gs10) lpattern(shortdash) lwidth(vthin)) ///
					scheme(plotplain)
								
		graph save "$figure/Ex1/Ex1_E", replace	
				
********************************************************************************
	
	* elderly
		
		use "$data\working_data\working_data.dta", replace	
			
		collapse (sum) elderly pop_el, by(nyear period year month)
			
		gen sr_el = el/pop_el
		egen mean = mean(sr_el) if nyear >= 1 & nyear <= 3, by(period)
			
		gen ym = ym(year, month)
		
		sort nyear period
		
		graph twoway  (scatter sr_el period if nyear <= 3, color(gs10) msymbol(circle) msize(0.8)) ///
					(line mean period if nyear == 3, lpattern(solid) lpattern(shortdash_dot) lcolor(gs6)) ///
					(connected sr_el period if nyear == 4, lcolor(blue*0.8) mcolor(blue*0.6) msymbol(circle) msize(0.8) lpattern(solid)) ///
					, legend(off) ///
					xlab(-2 "Nov" 0 "Jan" 2 "Mar" 4 "May" 6 "Jul" 8 "Sep" 9 " ", labsize(*0.8) labcolor(black) axis(1) nogrid) ///
					xscale(range(-3 10)) ///
					ylabel(0 5 10 15 20 25, nogrid) ///
					xlabel(, nogrid) ///
					xtitle("") ytitle("") ///
					title("f. Age over 70", size(4) pos(11) ring(2)) ///
					xline(0, lcolor(gs10) lpattern(shortdash) lwidth(vthin)) ///
					scheme(plotplain)
									
		graph save "$figure/Ex1/Ex1_F", replace				
				
********************************************************************************
	
	* graph combine
	
		graph combine "$figure/Ex1/Ex1_A" "$figure/Ex1/Ex1_B" "$figure/Ex1/Ex1_C" "$figure/Ex1/Ex1_D" "$figure/Ex1/Ex1_E" "$figure/Ex1/Ex1_F", col(3) row(2) imargin(3 3 3 3 3 3) xsize(20) ysize(9) graphregion(margin(vtiny) fcolor(white) lcolor(white)) iscale(0.8) 
		
		graph save "$figure/Ex1/Ex1", replace
		graph export "$figure/fig_png/Ex1.png", replace width(3000)
		graph export "$figure/fig_eps/Ex1.eps", replace as(eps)
		graph export "$figure/fig_pdf/Ex1.pdf", replace
				
		
		