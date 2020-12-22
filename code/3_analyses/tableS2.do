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
								
	* regression
		
		cap erase $tables/tableS2/tableS2.txt
		cap erase $tables/tableS2/tableS2.xls
		
		* regression
		
		ppmlhdfe sr c.post#c.first c.post#c.second [w=pop], absorb(city_id#month city_id#nyear) cluster(city_id) eform
		outreg2 using $tables/tableS2/tableS2.xls, dec(2) append nocon noobs noaster ci label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
				
		foreach i in male female {
			if "`i'" == "male" local k = "2"
			if "`i'" == "female" local k = "3"
			
			ppmlhdfe sr_`i' c.post#c.first c.post#c.second [w=pop_`i'], absorb(city_id#month city_id#nyear) cluster(city_id) eform
			outreg2 using $tables/tableS2/tableS2.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
			}
				*
				
		foreach i in ad el {
			if "`i'" == "ad" local k = "5"
			if "`i'" == "el" local k = "6"
			
			ppmlhdfe sr_`i' c.post#c.first c.post#c.second [w=pop_`i'], absorb(city_id#month city_id#nyear) cluster(city_id) eform
			outreg2 using $tables/tableS2/tableS2.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
			}
				*
	
********************************************************************************
		
	* child
		
		use "$data\working_data\working_data_child.dta", replace	
	
	* reg
	
		ppmlhdfe sr_ch c.post#c.first c.post#c.second [w=pop_ch], absorb(pref_id#month pref_id#nyear) cluster(pref_id) eform
		outreg2 using $tables/tableS2/tableS2.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
			
			
			
			