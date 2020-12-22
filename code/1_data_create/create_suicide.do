*==============================================================================*
* Project: COVID and suicide in Japan			    			          	   *
* Date:   2020 Sep                                                             *
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
global results "$dir/results"
global figure  "$dir/figures"

********************************************************************************
			
	* 2016
	* July~Mar

	foreach n in 16{
	foreach i in 10 11 12{
	
		local k = (2000 + `n')*100 + `i'
	
		import excel city_id county_name county_id suicide suicide_rate suicide_annualrate age20 age20_29 age30_39 age40_49 age50_59 age60_69 age70_79 age80 age_unknown partner_yes partner_no partner_unknown self emp no_job student no_job_student housewife unemp retire unemp_others job_unknown home building traffic sea mountain place_others place_unknown hanging poison coal jump dive means_others means_unknown time0_2 time2_4 time4_6 time6_8 time8_10 time10_12 time12_14 time14_16 time16_18 time18_20 time20_22 time22_24 time_unknown sun mon tue wed thu fri sat dow_unknown reason_family reason_health reason_economy reason_job reason_relationship reason_school reason_others reason_unknown past_yes past_no past_unknown using "$data\raw_data\suicide\suicide`k'.xls", clear cellrange(B8)
		
		gen year = 2000 + `n'
		gen month  =  `i'

		save "$data\do_file\suicide\suicide`k'.dta", replace
			}
			}
			*
	
	* 2017 ~ 2019
	* July~Mar

	foreach n in 17 18 19 {
	foreach i in 1 2 3 4 5 6 7 8 9 10 11 12{
	
		local k = (2000 + `n')*100 + `i'
	
		import excel city_id county_name county_id suicide suicide_rate suicide_annualrate age20 age20_29 age30_39 age40_49 age50_59 age60_69 age70_79 age80 age_unknown partner_yes partner_no partner_unknown self emp no_job student no_job_student housewife unemp retire unemp_others job_unknown home building traffic sea mountain place_others place_unknown hanging poison coal jump dive means_others means_unknown time0_2 time2_4 time4_6 time6_8 time8_10 time10_12 time12_14 time14_16 time16_18 time18_20 time20_22 time22_24 time_unknown sun mon tue wed thu fri sat dow_unknown reason_family reason_health reason_economy reason_job reason_relationship reason_school reason_others reason_unknown past_yes past_no past_unknown using "$data\raw_data\suicide\suicide`k'.xls", clear cellrange(B8)
		
		gen year = 2000 + `n'
		gen month  =  `i'

		save "$data\do_file\suicide\suicide`k'.dta", replace
			}
			}
			*
	
	
	* 2020
	*  ~ June

	foreach n in 20 {
	foreach i in 1 2 3 4 5 6 7 8 9 10{
	
		local k = (2000 + `n')*100 + `i'
	
		import excel city_id county_name county_id suicide suicide_rate suicide_annualrate age20 age20_29 age30_39 age40_49 age50_59 age60_69 age70_79 age80 age_unknown partner_yes partner_no partner_unknown self emp no_job student no_job_student housewife unemp retire unemp_others job_unknown home building traffic sea mountain place_others place_unknown hanging poison coal jump dive means_others means_unknown time0_2 time2_4 time4_6 time6_8 time8_10 time10_12 time12_14 time14_16 time16_18 time18_20 time20_22 time22_24 time_unknown sun mon tue wed thu fri sat dow_unknown reason_family reason_health reason_economy reason_job reason_relationship reason_school reason_others reason_unknown past_yes past_no past_unknown using "$data\raw_data\suicide\suicide`k'.xls", clear cellrange(B8)
		
		gen year = 2000 + `n'
		gen month  =  `i'

		save "$data\do_file\suicide\suicide`k'.dta", replace
			}
			}
			*

********************************************************************************
	
	clear all
	
	foreach i in 16{ 	
	foreach v in 10 11 12{
		append using "$data\do_file\suicide\suicide20`i'`v'.dta"
		}
		}
		*
	
	foreach i in 17 18 19{ 	
	foreach v in 01 02 03 04 05 06 07 08 09 10 11 12{
		append using "$data\do_file\suicide\suicide20`i'`v'.dta"
		}
		}
		*
			
	foreach i in 20{ 	
	foreach v in 01 02 03 04 05 06 07 08 09 10{
		append using "$data\do_file\suicide\suicide20`i'`v'.dta"
		}
		}
		*
			
	save "$data\do_file\suicide.dta", replace
	
