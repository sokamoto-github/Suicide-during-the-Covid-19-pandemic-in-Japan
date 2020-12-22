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

	* job status
	
		cap erase $tables/tableS6/tableS6.txt
		cap erase $tables/tableS6/tableS6.xls
	
		foreach i in sremp srretire srunemp srself srhousewife {		
			ppmlhdfe `i' c.post#c.first c.post#c.second  [w=pop], absorb(city_id#month city_id#nyear) cluster(city_id) eform
			outreg2 using $tables/tableS6/tableS6.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
		}	
				
		ppmlhdfe srstudent c.post#c.before_close c.post#c.sch_close c.post#c.after_close  [w=pop], absorb(city_id#month city_id#nyear) cluster(city_id) eform
		outreg2 using $tables/tableS6/tableS6.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
		
			
			