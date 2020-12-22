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
		
		local period = "c.post#c.period1 c.post#c.period2 c.post#c.period3 c.post#c.period4 c.post#c.period5 c.post#c.period6 c.post#c.period7 c.post#c.period8 c.post#c.period9"
				
	* regression
		
		cap erase $tables/tableS3/tableS3.txt
		cap erase $tables/tableS3/tableS3.xls
		
		* regression
		
		ppmlhdfe sr `period' [w=pop], absorb(city_id#month city_id#nyear) cluster(city_id) eform
		outreg2 using $tables/tableS3/tableS3.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
				
		foreach i in male female {
			if "`i'" == "male" local k = "2"
			if "`i'" == "female" local k = "3"
			
			ppmlhdfe sr_`i' `period' [w=pop_`i'], absorb(city_id#month city_id#nyear) cluster(city_id) eform
			outreg2 using $tables/tableS3/tableS3.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
			}
				*
				
		foreach i in ad el {
			if "`i'" == "ad" local k = "5"
			if "`i'" == "el" local k = "6"
			
			ppmlhdfe sr_`i' `period' [w=pop_`i'], absorb(city_id#month city_id#nyear) cluster(city_id) eform
			outreg2 using $tables/tableS3/tableS3.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
			}
				*
	
********************************************************************************
		
	* child
		
		use "$data\working_data\working_data_child.dta", replace	
				
	* reg
			
		local period = "c.post#c.period1 c.post#c.period2 c.post#c.period3 c.post#c.period4 c.post#c.period5 c.post#c.period6 c.post#c.period7 c.post#c.period8 c.post#c.period9"
		
		ppmlhdfe sr_ch `period' [w=pop_ch], absorb(pref_id#month pref_id#nyear) cluster(pref_id) eform
		outreg2 using $tables/tableS3/tableS3.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
			
			
			
			