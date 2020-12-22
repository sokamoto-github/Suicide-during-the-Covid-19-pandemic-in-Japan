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
									
		local event = "FD2 FD1 base D1 D2 D3 D4 D5 D6 D7 D8 D9"
		
	* regression
		
		cap erase $tables/tableS4/tableS4.txt
		cap erase $tables/tableS4/tableS4.xls
		
		* regression
		
		ppmlhdfe sr `event'  [w=pop], absorb(month#city_id nyear#city_id) cluster(city_id) eform
		outreg2 using $tables/tableS4/tableS4.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
		
		foreach i in male female {
			if "`i'" == "male" local k = "2"
			if "`i'" == "female" local k = "3"
			
			ppmlhdfe sr_`i' `event' [w=pop_`i'], absorb(month#city_id nyear#city_id) cluster(city_id) eform
			outreg2 using $tables/tableS4/tableS4.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
			}
				*
				
		foreach i in ad el {
			if "`i'" == "ad" local k = "5"
			if "`i'" == "el" local k = "6"
			
			ppmlhdfe sr_`i' `event'  [w=pop_`i'], absorb(month#city_id nyear#city_id) cluster(city_id) eform
			outreg2 using $tables/tableS4/tableS4.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
			}
				*
	
********************************************************************************
		
	* child
	
		use "$data\working_data\working_data_child.dta", replace	
				
		local event = "FD2 FD1 base D1 D2 D3 D4 D5 D6 D7 D8 D9"
			
	* reg
				
		ppmlhdfe sr_ch `event' [w=pop_ch], absorb(month#pref_id nyear#pref_id) cluster(pref_id) eform
		outreg2 using $tables/tableS4/tableS4.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
			
			
			