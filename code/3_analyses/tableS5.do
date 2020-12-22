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
					
	* main
	
		cap erase $tables/tableS5/tableS5.txt
		cap erase $tables/tableS5/tableS5.xls
		
		ppmlhdfe sr treat_post  [w=pop], absorb(city_id#month city_id#nyear) cluster(city_id) eform
		outreg2 using $tables/tableS5/tableS5.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
									
	* first and second wave
		
		ppmlhdfe srad_male c.post#c.soe c.post#c.nosoe c.post#c.second [w=pop_ad_male], absorb(city_id#month city_id#nyear) cluster(city_id) eform
		outreg2 using $tables/tableS5/tableS5.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
			
		ppmlhdfe srad_female c.post#c.soe c.post#c.nosoe c.post#c.second [w=pop_ad_female], absorb(city_id#month city_id#nyear) cluster(city_id) eform
		outreg2 using $tables/tableS5/tableS5.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
			
		ppmlhdfe srel_male c.post#c.soe c.post#c.nosoe c.post#c.second [w=pop_el_male], absorb(city_id#month city_id#nyear) cluster(city_id) eform
		outreg2 using $tables/tableS5/tableS5.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
			
		ppmlhdfe srel_female c.post#c.soe c.post#c.nosoe c.post#c.second [w=pop_el_female], absorb(city_id#month city_id#nyear) cluster(city_id) eform
		outreg2 using $tables/tableS5/tableS5.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
											
********************************************************************************	
	
	* child
		
		use "$data\working_data\working_data_child.dta", replace	
				
	* regression
	
		ppmlhdfe sr_ch c.post#c.pre c.post#c.close c.post#c.after [w=pop_ch], absorb(pref_id#month pref_id#nyear) cluster(pref_id) eform
		outreg2 using $tables/tableS5/tableS5.xls, dec(2) append nocon noobs ci noaster label eform addstat(Obs., e(N)) addtext(City-by-year Fixed Effect,  "YES", City-by-mon Fixed Effect, "YES") 
			
		