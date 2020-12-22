*==============================================================================*
* Project: COVID and suicide					    			          	   *
* Date:   2020 Mar                                                             *
* Author:                                             						   *
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
	global dir= "/Users/shoheiokamoto/Dropbox/macro_suicide\suicide\"
}

global data "$dir/data"
global results "$dir/results"
global figure  "$dir/figures"

********************************************************************************
	
	use "$data\do_file\suicide.dta", replace	
	
		replace city_id = city_id/10
		replace city_id = floor(city_id)
		
	destring self emp no_job student no_job_student housewife unemp retire unemp_others job_unknown home building traffic sea mountain place_others place_unknown hanging poison coal jump dive means_others means_unknown reason_family reason_health reason_economy reason_job reason_relationship reason_school reason_others reason_unknown past_yes past_no past_unknown, replace force
								 
	drop suicide suicide_rate suicide_annualrate age20 age20_29 age30_39 age40_49 age50_59 age60_69 age70_79 age80 age_unknown partner_yes partner_no partner_unknown home building traffic sea mountain place_others place_unknown hanging poison coal jump dive means_others means_unknown time0_2 time2_4 time4_6 time6_8 time8_10 time10_12 time12_14 time14_16 time16_18 time18_20 time20_22 time22_24 time_unknown sun mon tue wed thu fri sat dow_unknown past_yes past_no past_unknown
				
		egen job_total = rowmax(self emp student housewife unemp retire unemp_others job_unknown)
		egen max_job_total = max(job_total), by(city_id)
		drop if max_job_total < 1 | max_job_total == .
		
		fillin city_id year month	
		
		merge m:1 city_id using "$data\do_file\pop.dta"
		drop _merge	
					
		drop if year <= 2015
		drop if year == 2016 & month <= 10
		drop if year == 2020 & month >= 11
		
		save "$data\do_file\merged_data_jobstatus.dta", replace
