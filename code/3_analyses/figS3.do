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
	
		use "$data/raw_data/figures/figS3/covid.dta", clear

		rename countryterritorycode country_code
		keep if country_code == "JPN" | country_code == "USA" | country_code == "CAN" | country_code == "GBR" | country_code == "ITA" | country_code == "DEU" | country_code == "SWE" | country_code == "CHN" | country_code == "KOR"  
		
		gen mdy = mdy(month, day, year)
		
		sort country_code year month day
		bys country_code: gen cumcase = sum(case)
		
		gen casepp = cumcase / pop * 1000000
		gen lncasepp = ln(casepp)
		
		drop if mdy >= 22220 
		drop if mdy <= 21913
		
		graph twoway (line casepp mdy if country_code == "USA", lpattern(solid) lcolor(gs10) lwidth(vthin)) ///
				(line casepp mdy if country_code == "SWE", lpattern(solid) lcolor(gs10) lwidth(vthin)) ///
				(line casepp mdy if country_code == "GBR", lpattern(solid) lcolor(gs10) lwidth(vthin)) ///
				(line casepp mdy if country_code == "ITA", lpattern(solid) lcolor(gs10) lwidth(vthin)) ///
				(line casepp mdy if country_code == "CAN", lpattern(solid) lcolor(gs10) lwidth(vthin)) ///
				(line casepp mdy if country_code == "DEU", lpattern(solid) lcolor(gs10) lwidth(vthin)) ///
				(line casepp mdy if country_code == "KOR", lpattern(solid) lcolor(gs10) lwidth(vthin)) ///
				(line casepp mdy if country_code == "JPN", lcolor(blue) lpattern(solid)) ///
				(line casepp mdy if country_code == "CHN", lpattern(solid) lcolor(gs10) lwidth(vthin)) ///
				, xlabel(21884 "Dec1" 21946 "Feb 1" 22006 "Apr 1" 22067 "Jun 1" 22128 "Aug 1" 22189 "Oct 1" 22219 " ", nogrid) ///
				xscale(range(21870 22270)) ///
				ylabel(0 5000 9999.999 "          ." 10000 15000 20000 25000 30000,nogrid) ///
				yscale(range(-200 9000)) ///
				legend(off) ///
				xtitle("") ///
				title("a. COVID-19 cases per million", pos(11) size(4)) ///
				ytitle("") ///
				text(27494 22255 "USA", size(2.2)) ///
				text(12217 22255 "Sweden", size(2.2)) ///
				text(14851 22255 "UK", size(2.2)) ///
				text(10730 22255 "Italy", size(2.2)) ///
				text(6001 22255 "Canada", size(2.2)) ///
				text(7000 22255 "Germany", size(2.2)) ///
				text(200 22255 "Korea", size(2.2)) ///
				text(1500 22255 "Japan", color(blue) size(2.2)) ///
				text(-1000 22255 "China", size(2.2)) ///
				scheme(plotplain)

		graph save "$figure/figS3/figS3_A", replace

********************************************************************************	

	* regulation
	
		use "$data/raw_data/figures/figS3/reg.dta", clear
		
		rename countrycode country_code
		keep if country_code == "JPN" | country_code == "USA" | country_code == "CAN" | country_code == "GBR" | country_code == "ITA" | country_code == "DEU" | country_code == "SWE" | country_code == "CHN" | country_code == "KOR"  
		replace regioncode = "0" if regioncode == ""
		drop if regioncode != "0"
		
		rename stringencyindex index
		rename economicsupportindex economic
		
		tostring date, replace 
		gen year = substr(date,1,4)
		gen month = substr(date,5,2)
		gen day = substr(date,7,2)
		destring year month day date, replace	
		
		gen mdy = mdy(month, day, year)
		
		drop if mdy >= 22220 
		drop if mdy <= 21913
		
		sort country_code year month day
		
		graph twoway (line index mdy if country_code == "USA", lpattern(solid) lcolor(gs10) lwidth(vthin)) ///
				(line index mdy if country_code == "SWE", lpattern(solid) lcolor(gs10) lwidth(vthin)) ///
				(line index mdy if country_code == "GBR", lpattern(solid) lcolor(gs10) lwidth(vthin)) ///
				(line index mdy if country_code == "ITA", lpattern(solid) lcolor(gs10) lwidth(vthin)) ///
				(line index mdy if country_code == "CAN", lpattern(solid) lcolor(gs10) lwidth(vthin)) ///
				(line index mdy if country_code == "DEU", lpattern(solid) lcolor(gs10) lwidth(vthin)) ///
				(line index mdy if country_code == "KOR", lpattern(solid) lcolor(gs10) lwidth(vthin)) ///
				(line index mdy if country_code == "JPN", lcolor(blue) lpattern(solid)) ///
				(line index mdy if country_code == "CHN", lpattern(solid) lcolor(gs10) lwidth(vthin)) ///
				, xlabel(21884 "Dec1" 21946 "Feb 1" 22006 "Apr 1" 22067 "Jun 1" 22128 "Aug 1" 22189 "Oct 1" 22219 " ", nogrid) ///
				xscale(range(21870 22270)) ///
				ylabel(0 19.99999 "          ." 20 40 60 80 100,nogrid) ///
				yscale(range(-3 100)) ///
				legend(off) ///
				xtitle("") ///
				ytitle("") ///
				title("b. Policy stringency index", pos(11) size(4)) ///
				text(63 22255 "USA, China", size(2.2)) ///
				text(44 22255 "Korea", size(2.2)) ///
				text(75 22255 "UK", size(2.2)) ///
				text(59 22255 "CAN, GER", size(2.2)) ///
				text(67 22255 "Italy", size(2.2)) ///
				text(53 22255 "Sweden", size(2.2)) ///
				text(39 22255 "Japan",color(blue) size(2.2)) ///
				scheme(plotplain)
		
		graph save "$figure/figS3/figS3_B", replace
			
********************************************************************************	

	* fiscal expenditure
	
		use "$data/raw_data/figures/figS3/fiscal.dta", clear
			
		egen rank = rank(budget) if cat == 1
		egen maxrank = max(rank), by(country)
		
		sort maxrank cat
		
		drop x
		gen x = _n	
		
		graph twoway (bar budget x if cat == 1 & country != "Japan" , barwidth(.8) fcolor(gs8) lcolor(white) lwidth(vthin)) ///
				(bar budget x if cat == 2 & country != "Japan" , barwidth(.8) fcolor(gs14) lcolor(white) lwidth(vthin)) ///
				(bar budget x if cat == 1 & country == "Japan" , barwidth(.8) fcolor(blue) lcolor(white) lwidth(vthin)) ///
				(bar budget x if cat == 2 & country == "Japan" , barwidth(.8) fcolor(blue*0.3) lcolor(white) lwidth(vthin)) ///
				, legend(order(1 2) label(1 "Additioal spending") label(2 "Liquidity support") ring(0) pos(11) rowgap(0.6)) ///
				xlabel(1.5 "KOR" 3.5 "CHN" 5.5 "ITA" 7.5 "SWE" 9.5 "GER" 11.5 "UK" 13.5 "Japan" 15.5 "US" 17.5 "CAN", nogrid) ///
				xscale(range(0 19)) ///
				ylabel(0 10 20 30 39.99999 "          ." 40 ,nogrid) ///
				xtitle("") ///
				ytitle("") ///
				title("c. Fiscal support (% GDP)", pos(11) size(4)) ///
				   scheme(plotplain)
		
		graph save "$figure/figS3/figS3_C", replace
		
********************************************************************************
	
	* graph combine
	
		graph combine  "$figure/figS3/figS3_A" "$figure/figS3/figS3_B" "$figure/figS3/figS3_C", row(1) xsize(15) ysize(4) imargin(3 3 3) graphregion(margin(vtiny) fcolor(white) lcolor(white)) iscale(1.2)
		
		graph save "$figure/figS3/figS3", replace
		graph export "$figure/fig_png/figS3.png", replace width(3000)
		graph export "$figure/fig_eps/figS3.eps", replace as(eps)
		graph export "$figure/fig_pdf/figS3.pdf", replace
				
				