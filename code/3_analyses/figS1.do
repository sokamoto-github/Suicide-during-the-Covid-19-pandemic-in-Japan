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
		
	* COVID-19
	
		use "$data\raw_data\figures\figS1\covid.dta", clear
		rename date day
		rename testedpositive case
		
		collapse (sum) case, by(year month day)
			
		merge 1:1 year month day using "$data\raw_data\figures\figS1\diamond.dta" 
		drop _merge	
		
		sort year month day
		gen mdy = mdy(month, day, year)
		tsset mdy
		
		gen new = case - l.case
		gen new_diamond = diamond - l.diamond
		
		replace new_diamond = . if new_diamond == 0 
		
		drop if mdy >= 22220 & mdy != .
		
		graph twoway (area new mdy, fcolor(blue*0.2) lcolor(blue*0.2)) /// 
					(line new_diamond mdy, lpattern(shortdash) lcolor(gs6) lwidth(thin)) ///
					, legend(order(1) label(1 "New confirmed cases") ring(0) pos(11) rowgap(0.6)) ///
					ylabel(2000 1500 1000 500 0 0.00000000000001 "          .", nogrid) ///
					xlabel(21865 " "  21897 "Dec" 21959 "Feb" 22018 "Apr" 22076 "Jun" 22141 "Aug" 22202 "Oct", nogrid) ///
					xscale(range(21835 22230)) ///
					title("a. Trend of COVID-19 cases", size(4) pos(11) ring(2)) ///
					text(200 21930 "Outbreak in the cruise" "Diamond Princess", size(2.2)) ///
					text(850 22018 "first" "outbreak", size(2.2)) ///
					text(1750 22130 "Second" "outbreak", size(2.2)) ///
					xtitle("") ///
					scheme(plotplain)				 
					 
		graph save "$figure/figS1/figS1_A", replace
				
********************************************************************************
		
	* Major Event
		
		import excel using "$data\raw_data\figures\figS1\event.xlsx", clear firstrow
		
		destring date start end, replace force
			
		graph twoway (scatter x date if x == 7, msymbol(X) msize(2) mcolor(gs6)) ///
					(scatter x date if x == 6, msymbol(X) msize(2) mcolor(gs6)) ///
					(scatter x date if x == 3, msymbol(X) msize(2) mcolor(gs6)) ///	
					(rspike start end x if x == 5 & end <= 21985, horizontal lcolor(gs6)) ///
					(rspike start end x if x == 5 & start >= 21986, horizontal lcolor(gs6) lpattern(shortdash) lwidth(thin)) ///
					(rspike start end x if x == 4 & end <= 21998, horizontal lcolor(gs6)) ///
					(rspike start end x if x == 4 & start >= 21998, horizontal lcolor(gs6) lpattern(shortdash) lwidth(thin)) ///
					(rspike start end x if x == 3, horizontal lcolor(gs6)) ///
					(rspike start end x if x == 2, horizontal lcolor(gs6)) ///
					(rspike start end x if x == 1, horizontal lcolor(gs6)) ///
					,xlabel(21865 " "  21897 "Dec" 21959 "Feb" 22018 "Apr" 22076 "Jun" 22141 "Aug" 22202 "Oct", nogrid) ///
					xscale(range(21835 22230)) ///
					ylabel(0 "         .", nogrid noticks) ///
					yscale(range(0 8)) ///
					legend(off) ///
					text(7 21836 "First case", place(e) size(2.2)) ///
					text(6 21836 "First death", place(e) size(2.2)) ///
					text(5 21836 "Request: no large gathering", place(e) size(2.2)) ///
					text(4 21836 "School closure", place(e) size(2.2)) ///
					text(3 21836 "State of emergency (7 prefectures)", place(e) size(2.2)) ///
					text(2 21836 "State of emergency (39 prefectuers)", place(e) size(2.2)) ///
					text(1 21836 "Request: shorten-time operation in bars/restaurants", place(e) size(2.2)) ///
					title("b. COVID-19 and anti-virus measures in Japan", size(4) pos(11) ring(2)) ///
					xtitle("") ytitle("") ///
					scheme(plotplain)
					
		graph save "$figure/figS1/figS1_B", replace					
				
********************************************************************************
	
	* Economy, consumption and employment
	
		import excel using "$data\raw_data\figures\figS1\data_figS1.xlsx", clear firstrow
			
		rename ciindex cindex
		rename consumption cons
		
		collapse (mean) unemp cindex cons, by(year month)
		
		foreach v of varlist unemp cindex cons {
			gen `v'_base_ = `v' if year == 2020 & month == 1
			egen `v'_base = max(`v'_base_)
			gen std_`v' = `v' / `v'_base
			}
			*
		
		drop unemp_base_ unemp_base cindex_base_ cindex_base cons_base_ cons_base
		
		gen ym = ym(year, month)
		drop if ym < 718	
				
		
		graph twoway  (connected std_unemp ym, lcolor(gs6) msize(0.9) mcolor(blue*1.2) msymbol(circle) lpattern(shortdash_dot)) ///
					(connected std_cons ym, lcolor(gs6) msize(0.9) mcolor(orange*.8) msymbol(square) lpattern(longdash)) ///
					(connected std_cindex ym, lcolor(gs6) msize(0.9) mcolor(ebblue*.8) msymbol(diamond) lpattern(shortdash)) ///
					, xlabel(719 "Dec" 721 "Feb" 723 "Apr" 725 "Jun" 727 "Aug" 729 "Oct", nogrid) ///
					xscale(range(717.5 729.5)) ///
					legend(order(1 2 3) label(1 "Unemployment rate") label(2 "Consumption index") label(3 "Composite index") ring(0) pos(7) rowgap(0.6)) ///
					ylabel(0 0.5 1 1.5 1.49999999999999 "          ." 1.5 2, nogrid axis(1)) ///
					xtitle("") ///
					title("c. Trend of economy, consumption, and employment", size(4) pos(11) ring(2)) ///
					yline(1, lcolor(gs10) lpattern(shortdash) lwidth(vthin)) ///
					scheme(plotplain)
					
		graph save "$figure/figS1/figS1_C", replace		

********************************************************************************

	* google mobility, variable create
		
		import delimited "$data\raw_data\figures\figS1\2020_JP_Region_Mobility_Report.csv", clear	
					
		split iso_3166_2_code, p("-") 
		split date, p("-")
			
		rename iso_3166_2_code2 pref_id
		rename sub_region_1 pref_JP
		rename date1 year
		rename date2 month
		rename date3 day		
		rename retail_and_recreation_percent_ch retail
		rename grocery_and_pharmacy_percent_cha grocery
		rename parks_percent_change_from_baseli parks
		rename transit_stations_percent_change_ transit
		rename workplaces_percent_change_from_b workplaces
		rename residential_percent_change_from_ residential
				
		destring pref_id year month day, replace
		drop if pref_id < .
		
		gen mdy = mdy(month, day, year)
		drop if mdy >= 22220 & mdy != .
				
		graph twoway (line workplaces mdy, lcolor(ebblue*0.8)) ///
					(line residential mdy, lcolor(red*1.2)) ///
					(line retail mdy, lcolor(orange*0.8)) ///
					(line transit mdy, lcolor(blue*1.2) lpattern(shortdash) lwidth(vthin)) ///
					, legend(order(1 2 3 4) label(1 "workplaces") label(2 "residential") label(3 "retail") label(4 "transit") ring(0) pos(11) rowgap(0.6)) ///
					ylabel(100 50 0 -50 -100 -99.999999999 "          .", nogrid) ///
					xlabel(21865 " "  21897 "Dec" 21959 "Feb" 22018 "Apr" 22076 "Jun" 22141 "Aug" 22202 "Oct", nogrid) ///
					xscale(range(21835 22230)) ///
					title("d. Google mobility Index", size(4) pos(11) ring(2)) ///
					xtitle("") ///
					yline(0, lcolor(gs10) lpattern(shortdash) lwidth(vthin)) ///
					scheme(plotplain)
					
		graph save "$figure/figS1/figS1_D", replace		

********************************************************************************
		
	* graph combine
	
		graph combine  "$figure/figS1/figS1_A" "$figure/figS1/figS1_B" "$figure/figS1/figS1_C" "$figure/figS1/figS1_D", col(2) row(2) xsize(15) ysize(10) imargin(3 3 3 3) graphregion(margin(vtiny) fcolor(white) lcolor(white)) iscale(0.6) 
				
		graph save "$figure/figS1/figS1", replace
		graph export "$figure/fig_png/figS1.png", replace width(3000)
		graph export "$figure/fig_eps/figS1.eps", replace as(eps)
		graph export "$figure/fig_pdf/figS1.pdf", replace
		
		

			
			