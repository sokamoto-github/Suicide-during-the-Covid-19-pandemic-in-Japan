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
		
	* trend: all
		
		use "$data\working_data\working_data.dta", replace	
		sort city_id year month		
		
		collapse (mean) sr [w=pop], by(ym year month) 
		
		graph twoway (line sr ym,  lcolor(blue*0.8) mlcolor(white)) ///
			, ylabel(0 (5) 25, nogrid) /// 
			xlabel(684 "17-Jan" 696 "18-Jan" 708 "19-Jan" 720 "20-Jan" 728 " ",nogrid) ///
			xscale(range(678 734)) ///
			xline(720, lcolor(gs10) lpattern(shortdash) lwidth(vthin)) ///
			ytitle("Suicide Rate") ///
			xtitle("") ///
			title("a1. Suicide trend: all", pos(11) size(3.5)) ///
			legend(off) ///
			scheme(plotplainblind)
			
		graph save "$figure/Ex2/Ex2_a1", replace
	
********************************************************************************	
		
	* seasonality: all
		
		use "$data\working_data\working_data.dta", replace	
		sort city_id year month		
		
		collapse (mean) sr [w=pop], by(ym year month)
		
		egen monthsr_ = mean(sr) if ym >= 685 & ym <= 720, by(month)
		egen monthsr = max(monthsr_), by(month)
		
		graph twoway (scatter monthsr month, mcolor(blue) mlwidth(thin)) ///
			(scatter sr month if ym >= 721, mcolor(red) mstyle(circle) mlwidth(thin)) ///
			, ylabel(0 (5) 25, nogrid) ///
			xlabel(1 "Jan" 3 "Mar" 5 "May" 7 "Jul" 9 "Sep" 11 "Nov" 12.5 " ",nogrid) ///
			xscale(range(0 13)) ///
			ytitle("Suicide Rate") ///
			xtitle("") ///
			title("a2. Seasonality: all", pos(11) size(3.5)) ///
			legend(order(1 2) label(1 "2017 Feb - 2020 Jan (3 years)") label(2 "2020 Feb - 2020 Oct") ring(0) pos(4) rowgap(0.4) size(2) keygap(0.4)) ///
			scheme(plotplainblind)
			
		graph save "$figure/Ex2/Ex2_a2", replace
	
********************************************************************************
	
	* residualized: all
		
		use "$data\working_data\working_data.dta", replace	
		sort city_id year month		
				
		ppmlhdfe sr [w=pop], absorb(city_id#month city_id#c.ym, savefe) cluster(city_id) eform
			egen fe1 = max(__hdfe1__), by(city_id month)
			egen meanfe1 = mean(fe1),by(city_id)			
			egen fe2 = max(__hdfe1__), by(city_id)	
			egen meanfe2 = mean(fe2),by(city_id)				
			predictnl yhat_wos_ln = xb()
			predictnl yhat_ws_ln = xb() + (fe1-meanfe1) + (fe2-meanfe2)*ym
			gen yhat_wos = exp(yhat_wos_ln)
			gen yhat_ws = exp(yhat_ws_ln)
			gen seasonality = yhat_ws - yhat_wos
			gen yhat = sr - seasonality
												
		collapse (mean) sr yhat [w=pop], by(ym year month) 
		
		graph twoway (line yhat ym, lcolor(red*0.8)) ///
			, ylabel(0 (5) 25, nogrid) /// 
			xlabel(684 "17-Jan" 696 "18-Jan" 708 "19-Jan" 720 "20-Jan" 728 " ", nogrid) ///
			xscale(range(678 734)) ///
			xline(720, lcolor(gs10) lpattern(shortdash) lwidth(vthin)) ///
			ytitle("Suicide Rate") ///
			xtitle("") ///
			title("a3. Remove trend & seasonality: all", pos(11) size(3.5)) ///
			legend(off) ///
			scheme(plotplainblind)		
			
		graph save "$figure/Ex2/Ex2_a3", replace
			
********************************************************************************

	* trend: region
		
		use "$data\working_data\working_data.dta", replace	
		sort city_id year month		
		
		collapse (mean) sr [w=pop], by(ym year month pref_id) 

		foreach i in 1 13 29 40 {
			
			if "`i'" == "1" local k = "Hokkaido"
			if "`i'" == "13" local k = "Tokyo"
			if "`i'" == "29" local k = "Nara"
			if "`i'" == "40" local k = "Fukuoka"
			
			if "`i'" == "1" local l = "b1"
			if "`i'" == "13" local l = "c1"
			if "`i'" == "29" local l = "d1"
			if "`i'" == "40" local l = "e1"
						
			graph twoway (line sr ym if pref_id == `i',  lcolor(blue*0.8) mlcolor(white)) ///
				, ylabel(0 (5) 25, nogrid) /// 
				xlabel(684 "17-Jan" 696 "18-Jan" 708 "19-Jan" 720 "20-Jan" 728 " ",nogrid) ///
				xscale(range(678 734)) ///
				xline(720, lcolor(gs10) lpattern(shortdash) lwidth(vthin)) ///
				ytitle("Suicide Rate") ///
				xtitle("") ///
				title("`l'. Suicide trend: `k'", pos(11) size(3.5)) ///
				legend(off) ///
				scheme(plotplainblind)
				
			graph save "$figure/Ex2/Ex2_`l'", replace
			
			}			
			
********************************************************************************

	* seasonality: region

		use "$data\working_data\working_data.dta", replace	
		sort city_id year month		
		
		collapse (mean) sr [w=pop], by(ym year month pref_id) 
		
		egen monthsr_ = mean(sr) if ym >= 685 & ym <= 720, by(month pref_id)
		egen monthsr = max(monthsr_), by(month pref_id)

		foreach i in 1 13 29 40 {
			
			if "`i'" == "1" local k = "Hokkaido"
			if "`i'" == "13" local k = "Tokyo"
			if "`i'" == "29" local k = "Nara"
			if "`i'" == "40" local k = "Fukuoka"
			
			if "`i'" == "1" local l = "b2"
			if "`i'" == "13" local l = "c2"
			if "`i'" == "29" local l = "d2"
			if "`i'" == "40" local l = "e2"
			
			graph twoway (scatter monthsr month if pref_id == `i', mcolor(blue) mlwidth(thin)) ///
				(scatter sr month if ym >= 721 & pref_id == `i', mcolor(red) mstyle(circle) mlwidth(thin)) ///
				, ylabel(0 (5) 25, nogrid) ///
				xlabel(1 "Jan" 3 "Mar" 5 "May" 7 "Jul" 9 "Sep" 11 "Nov" 12.5 " ",nogrid) ///
				xscale(range(0 13)) ///
				ytitle("Suicide Rate") ///
				xtitle("") ///
				title("`l'. Seasonality: `k'", pos(11) size(3.5)) ///
				legend(off) ///
				scheme(plotplainblind)
				
			graph save "$figure/Ex2/Ex2_`l'", replace
			}
		
********************************************************************************
	
	* residualized: region		

		use "$data\working_data\working_data.dta", replace	
		sort city_id year month		
		
		ppmlhdfe sr [w=pop], absorb(city_id#month city_id#c.ym, savefe) cluster(city_id) eform
			egen fe1 = max(__hdfe1__), by(city_id month)
			egen meanfe1 = mean(fe1),by(city_id)			
			egen fe2 = max(__hdfe1__), by(city_id)	
			egen meanfe2 = mean(fe2),by(city_id)				
			predictnl yhat_wos_ln = xb()
			predictnl yhat_ws_ln = xb() + (fe1-meanfe1) + (fe2-meanfe2)*ym
			gen yhat_wos = exp(yhat_wos_ln)
			gen yhat_ws = exp(yhat_ws_ln)
			gen seasonality = yhat_ws - yhat_wos
			gen yhat = sr - seasonality
									
		collapse (mean) sr yhat [w=pop], by(ym year month pref_id) 
		
		foreach i in 1 13 29 40 {
			
			if "`i'" == "1" local k = "Hokkaido"
			if "`i'" == "13" local k = "Tokyo"
			if "`i'" == "29" local k = "Nara"
			if "`i'" == "40" local k = "Fukuoka"
			
			if "`i'" == "1" local l = "b3"
			if "`i'" == "13" local l = "c3"
			if "`i'" == "29" local l = "d3"
			if "`i'" == "40" local l = "e3"
			
			graph twoway (line yhat ym if pref_id == `i', lcolor(red*0.8)) ///
				, ylabel(0 (5) 25, nogrid) /// 
				xlabel(684 "17-Jan" 696 "18-Jan" 708 "19-Jan" 720 "20-Jan" 728 " ", nogrid) ///
				xscale(range(678 734)) ///
				xline(720, lcolor(gs10) lpattern(shortdash) lwidth(vthin)) ///
				ytitle("Suicide Rate") ///
				xtitle("") ///
				title("`l'. Remove trend & seasonality: `k'", pos(11) size(3.5)) ///
				legend(off) ///
				scheme(plotplainblind)		
				
		graph save "$figure/Ex2/Ex2_`l'", replace
			}
	
********************************************************************************

	* graph combine
		
		graph combine "$figure\Ex2\Ex2_a1" "$figure\Ex2\Ex2_a2" "$figure\Ex2\Ex2_a3" "$figure\Ex2\Ex2_b1" "$figure\Ex2\Ex2_b2" "$figure\Ex2\Ex2_b3" "$figure\Ex2\Ex2_c1" "$figure\Ex2\Ex2_c2" "$figure\Ex2\Ex2_c3" "$figure\Ex2\Ex2_d1" "$figure\Ex2\Ex2_d2" "$figure\Ex2\Ex2_d3" "$figure\Ex2\Ex2_e1" "$figure\Ex2\Ex2_e2" "$figure\Ex2\Ex2_e3", col(3) row(7) xsize(12) ysize(12) imargin(3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3) graphregion(margin(tiny) fcolor(white) lcolor(white)) iscale(0.35)
	
		graph save "$figure/Ex2/Ex2", replace
		graph export "$figure/fig_png/Ex2.png", replace width(3000)
		graph export "$figure/fig_eps/Ex2.eps", replace as(eps)
		graph export "$figure/fig_pdf/Ex2.pdf", replace
				
		