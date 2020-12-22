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
		
		cap erase $tables/tableS7/tableS7.txt
		cap erase $tables/tableS7/tableS7.xls
		
		foreach i in 1 0 {
		foreach v in basesr covid incomepc {
			
			if "`v'" == "basesr" local k = "1"
			if "`v'" == "covid" local k = "2"
			if "`v'" == "incomepc" local k = "3"
			
			if "`i'" == "1" local g = "high"
			if "`i'" == "0" local g = "low"
									
			ppmlhdfe sr c.post#c.first c.post#c.second  [w=pop] if gp_`v' == `i', absorb(month#city_id nyear#city_id) cluster(city_id) eform
			outreg2 using $tables/tableS7/tableS7.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-month Fixed Effect, "YES", het, `v', group, "`g'") 
		}
		}
		
		
		