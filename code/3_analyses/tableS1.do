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

	* Summary Statistics
	
		use "$data\working_data\working_data.dta", replace	
		
		local sr = "sr sr_male sr_female sr_ch sr_ad sr_el"
								
		format `sr' %9.3f	
		
		gen before = 0
		gen first_ob = 0
		gen second_ob = 0
		
		replace before = 1 if year <= 2019	
		replace before = 1 if year <= 2020 & month == 1
		replace first_ob = 1 if year == 2020 & month >= 2 & month <= 6
		replace second_ob = 1 if year == 2020 & month >= 7
		
		sum `sr' [w=pop], format		
		sum `sr' [w=pop] if before == 1, format
		sum `sr' [w=pop] if first_ob == 1, format
		sum `sr' [w=pop] if second_ob == 1, format
	
********************************************************************************
	
		use "$data\working_data\working_data_jobstatus.dta", replace	
		sort city_id year month
		
		local sr = "srself sremp srunemp srhousewife srretire"
		
		gen before = 0
		gen first_ob = 0
		gen second_ob = 0
		
		replace before = 1 if year <= 2019	
		replace before = 1 if year <= 2020 & month == 1
		replace first_ob = 1 if year == 2020 & month >= 2 & month <= 6
		replace second_ob = 1 if year == 2020 & month >= 7
		
		sum `sr' [w=pop], format		
		sum `sr' [w=pop] if before == 1, format
		sum `sr' [w=pop] if first_ob == 1, format
		sum `sr' [w=pop] if second_ob == 1, format
		
		
		
		