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
	
	* male
	
	foreach n in 16{
	foreach i in 10 11 12 {		
		local k = (2000 + `n')*100 + `i'
		
		import excel city_id county_name county_id suicide suicide_rate suicide_annualrate age20 age20_29 age30_39 age40_49 age50_59 age60_69 age70_79 age80 age_unknown partner_yes partner_no partner_unknown self emp no_job student no_job_student housewife unemp retire unemp_others job_unknown home building traffic sea mountain place_others place_unknown hanging poison coal jump dive means_others means_unknown time0_2 time2_4 time4_6 time6_8 time8_10 time10_12 time12_14 time14_16 time16_18 time18_20 time20_22 time22_24 time_unknown sun mon tue wed thu fri sat dow_unknown reason_family reason_health reason_economy reason_job reason_relationship reason_school reason_others reason_unknown past_yes past_no past_unknown using "$data\raw_data\suicide\suicide`k'.xls", clear cellrange(B8) sheet("男 (秘)")

		gen year = 2000 + `n'
		gen month =  `i'		
		
		save "$data\do_file\gender\suicide_male`k'.dta", replace
		}
		}
		*	
	
	foreach n in 17 18 19{
	foreach i in 1 2 3 4 5 6 7 8 9 10 11 12 {
		
		local k = (2000 + `n')*100 + `i'
		
		import excel city_id county_name county_id suicide suicide_rate suicide_annualrate age20 age20_29 age30_39 age40_49 age50_59 age60_69 age70_79 age80 age_unknown partner_yes partner_no partner_unknown self emp no_job student no_job_student housewife unemp retire unemp_others job_unknown home building traffic sea mountain place_others place_unknown hanging poison coal jump dive means_others means_unknown time0_2 time2_4 time4_6 time6_8 time8_10 time10_12 time12_14 time14_16 time16_18 time18_20 time20_22 time22_24 time_unknown sun mon tue wed thu fri sat dow_unknown reason_family reason_health reason_economy reason_job reason_relationship reason_school reason_others reason_unknown past_yes past_no past_unknown using "$data\raw_data\suicide\suicide`k'.xls", clear cellrange(B8) sheet("男 (秘)")

		gen year = 2000 + `n'
		gen month =  `i'		
		
		save "$data\do_file\gender\suicide_male`k'.dta", replace
		}
		}
		*	
	
	foreach n in 20 {
	foreach i in 1 2 3 4 5 6 7 8 9 10{
		
		local k = (2000 + `n')*100 + `i'
		
		import excel city_id county_name county_id suicide suicide_rate suicide_annualrate age20 age20_29 age30_39 age40_49 age50_59 age60_69 age70_79 age80 age_unknown partner_yes partner_no partner_unknown self emp no_job student no_job_student housewife unemp retire unemp_others job_unknown home building traffic sea mountain place_others place_unknown hanging poison coal jump dive means_others means_unknown time0_2 time2_4 time4_6 time6_8 time8_10 time10_12 time12_14 time14_16 time16_18 time18_20 time20_22 time22_24 time_unknown sun mon tue wed thu fri sat dow_unknown reason_family reason_health reason_economy reason_job reason_relationship reason_school reason_others reason_unknown past_yes past_no past_unknown using "$data\raw_data\suicide\suicide`k'.xls", clear cellrange(B8) sheet("男 (秘)")

		gen year = 2000 + `n'
		gen month =  `i'		
		
		save "$data\do_file\gender\suicide_male`k'.dta", replace
		}
		}			

********************************************************************************
		
	* female
	
	foreach n in 16{
	foreach i in 10 11 12 {		
		local k = (2000 + `n')*100 + `i'
		
		import excel city_id county_name county_id suicide suicide_rate suicide_annualrate age20 age20_29 age30_39 age40_49 age50_59 age60_69 age70_79 age80 age_unknown partner_yes partner_no partner_unknown self emp no_job student no_job_student housewife unemp retire unemp_others job_unknown home building traffic sea mountain place_others place_unknown hanging poison coal jump dive means_others means_unknown time0_2 time2_4 time4_6 time6_8 time8_10 time10_12 time12_14 time14_16 time16_18 time18_20 time20_22 time22_24 time_unknown sun mon tue wed thu fri sat dow_unknown reason_family reason_health reason_economy reason_job reason_relationship reason_school reason_others reason_unknown past_yes past_no past_unknown using "$data\raw_data\suicide\suicide`k'.xls", clear cellrange(B8) sheet("女 (秘)")

		gen year = 2000 + `n'
		gen month =  `i'		
		
		save "$data\do_file\gender\suicide_female`k'.dta", replace
		}
		}
		*	
	
	foreach n in 17 18 19{
	foreach i in 1 2 3 4 5 6 7 8 9 10 11 12 {
		
		local k = (2000 + `n')*100 + `i'
		
		import excel city_id county_name county_id suicide suicide_rate suicide_annualrate age20 age20_29 age30_39 age40_49 age50_59 age60_69 age70_79 age80 age_unknown partner_yes partner_no partner_unknown self emp no_job student no_job_student housewife unemp retire unemp_others job_unknown home building traffic sea mountain place_others place_unknown hanging poison coal jump dive means_others means_unknown time0_2 time2_4 time4_6 time6_8 time8_10 time10_12 time12_14 time14_16 time16_18 time18_20 time20_22 time22_24 time_unknown sun mon tue wed thu fri sat dow_unknown reason_family reason_health reason_economy reason_job reason_relationship reason_school reason_others reason_unknown past_yes past_no past_unknown using "$data\raw_data\suicide\suicide`k'.xls", clear cellrange(B8) sheet("女 (秘)")

		gen year = 2000 + `n'
		gen month =  `i'		
		
		save "$data\do_file\gender\suicide_female`k'.dta", replace
		}
		}
		*	
	
	foreach n in 20 {
	foreach i in 1 2 3 4 5 6 7 8 9 10{
		
		local k = (2000 + `n')*100 + `i'
		
		import excel city_id county_name county_id suicide suicide_rate suicide_annualrate age20 age20_29 age30_39 age40_49 age50_59 age60_69 age70_79 age80 age_unknown partner_yes partner_no partner_unknown self emp no_job student no_job_student housewife unemp retire unemp_others job_unknown home building traffic sea mountain place_others place_unknown hanging poison coal jump dive means_others means_unknown time0_2 time2_4 time4_6 time6_8 time8_10 time10_12 time12_14 time14_16 time16_18 time18_20 time20_22 time22_24 time_unknown sun mon tue wed thu fri sat dow_unknown reason_family reason_health reason_economy reason_job reason_relationship reason_school reason_others reason_unknown past_yes past_no past_unknown using "$data\raw_data\suicide\suicide`k'.xls", clear cellrange(B8) sheet("女 (秘)")

		gen year = 2000 + `n'
		gen month =  `i'		
		
		save "$data\do_file\gender\suicide_female`k'.dta", replace
		}
		}		

********************************************************************************
	
	* male 
	
	clear all		
	
	foreach n in 16{ 	
	foreach i in 10 11 12{
	
		local k = (2000 + `n')*100 + `i'
		append using "$data\do_file\gender\suicide_male`k'.dta"
		}
		}
		*
			
	foreach n in 17 18 19{ 	
	foreach i in 01 02 03 04 05 06 07 08 09 10 11 12{
	
		local k = (2000 + `n')*100 + `i'
		append using "$data\do_file\gender\suicide_male`k'.dta"
		}
		}
		*
			
	foreach n in 20{ 	
	foreach i in 01 02 03 04 05 06 07 08 09 10{
	
		local k = (2000 + `n')*100 + `i'
		append using "$data\do_file\gender\suicide_male`k'.dta"
		}
		}
		*
	
	foreach i in suicide age20 age20_29 age30_39 age40_49 age50_59 age60_69 age70_79 age80 {
		rename `i' `i'_male
			}
			*
	keep suicide_male age20_male age20_29_male age30_39_male age40_49_male age50_59_male age60_69_male age70_79_male age80_male city_id year month
	
	save "$data\do_file\gender\suicide_male.dta", replace
	
		
********************************************************************************

	* female 
	
	clear all		
	
	foreach n in 16{ 	
	foreach i in 10 11 12{
	
		local k = (2000 + `n')*100 + `i'
		append using "$data\do_file\gender\suicide_female`k'.dta"
		}
		}
		*
			
	foreach n in 17 18 19{ 	
	foreach i in 01 02 03 04 05 06 07 08 09 10 11 12{
	
		local k = (2000 + `n')*100 + `i'
		append using "$data\do_file\gender\suicide_female`k'.dta"
		}
		}
		*
			
	foreach n in 20{ 	
	foreach i in 01 02 03 04 05 06 07 08 09 10{
	
		local k = (2000 + `n')*100 + `i'
		append using "$data\do_file\gender\suicide_female`k'.dta"
		}
		}
		*
	
	foreach i in suicide age20 age20_29 age30_39 age40_49 age50_59 age60_69 age70_79 age80 {
		rename `i' `i'_female
			}
			*
	keep suicide_female age20_female age20_29_female age30_39_female age40_49_female age50_59_female age60_69_female age70_79_female age80_female city_id year month
	
	save "$data\do_file\gender\suicide_female.dta", replace	
	
********************************************************************************
 
	use "$data\do_file\gender\suicide_male.dta", clear 
	
	merge 1:1 city_id year month using "$data\do_file\gender\suicide_female.dta"
	drop _merge
	
	save "$data\do_file\suicide_gender.dta", replace

