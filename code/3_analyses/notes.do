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

	* Introduction
	
		use "$data\working_data\working_data.dta", replace	
		
		local sr = "sr srad_male"
		
		format `sr' %9.3f	
		sum `sr' [w=pop], format
		
********************************************************************************

	* Methods: Data
		
		use "$data\do_file\merged_data.dta", replace
						
		foreach i in male female{
			gen child_`i' = age20_`i'
			gen adult_`i' = age20_29_`i' + age30_39_`i' + age40_49_`i' + age50_59_`i' + age60_69_`i'
			gen elderly_`i' = age70_79_`i' + age80_`i'	
			}
			*		
		
		* total suicide
		tabstat suicide, stat(sum)
		
		* male, adult-male
		egen total_suicide = sum(suicide)
		egen total_male = sum(suicide_male)
		egen total_admale = sum(adult_male)
		
		gen male_ratio = total_male/total_suicide
		gen admale_ratio = total_admale/total_suicide
		
		gen mean_suicide = total_suicide/48
		
		sum mean_suicide male_ratio admale_ratio

		* observations
		
		use "$data\working_data\working_data.dta", replace	
		
		table year month, c(count suicide)
		tabstat suicide, stat(count)
		
********************************************************************************

	* Methods: DID
		
		* change year
		
		use "$data\working_data\working_data.dta", replace	
		
		collapse sr [w=pop], by (year)
		foreach i in 2017 2019 {
			gen sr`i'_ = sr if year == `i'
			egen sr`i' = max(sr`i'_)
			}
		gen change = sr2019/sr2017 - 1
		sum change
		
		* change month
		
		use "$data\working_data\working_data.dta", replace	
		drop if year == 2020
		
		collapse sr [w=pop], by (month)
		foreach i in 1 2 {
			gen sr`i'_ = sr if month == `i'
			egen sr`i' = max(sr`i'_)
			}
		gen change = sr1/sr2 - 1
		sum change
		
		* zero 
		
		use "$data\working_data\working_data.dta", replace	
		
		egen srz_count = count(sr) if sr == 0
		egen srz_ch_count = count(sr_ch) if sr_ch == 0
		egen sr_count = count(sr) if sr < . 
	
		gen srz_r = srz_count/sr_count
		gen srz_ch_ratio = srz_ch_count/sr_count
		sum srz*
		

********************************************************************************
		
		* SI: Data
	
		use "$data\working_data\working_data_jobstatus.dta", replace	
		sort city_id year month
		
		local sr = "srself sremp srunemp srhousewife srretire"
				
		sum `sr' [w=pop], format
		
		table year month, c(count srself)
		
********************************************************************************
		
		* SI: interrupted analysis
		
		* change month
		
		use "$data\working_data\working_data.dta", replace	
		drop if year == 2020
		
		collapse sr [w=pop], by (month)
		foreach i in 1 2 {
			gen sr`i'_ = sr if month == `i'
			egen sr`i' = max(sr`i'_)
			}
		sum sr1 sr2
		
		
		
	
	
	
	
	