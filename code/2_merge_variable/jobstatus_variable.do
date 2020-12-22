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
	
	use "$data\do_file\merged_data_jobstatus.dta", replace
			
	* changing to zero if no record
	
		foreach v of varlist self emp no_job student no_job_student housewife unemp retire unemp_others job_unknown reason_family reason_health reason_economy reason_job reason_relationship reason_school reason_others reason_unknown {	
		replace `v' = 0 if `v' == .
		}		
		
	* controlling for the date difference
	
		foreach v of varlist self emp no_job student no_job_student housewife unemp retire unemp_others job_unknown reason_family reason_health reason_economy reason_job reason_relationship reason_school reason_others reason_unknown {		
		replace `v' = `v' * (31/31) if month == 1 | month == 3 | month == 5 | month == 7 | month == 8 | month == 10 | month == 12 
		replace `v' = `v' * (31/30) if month == 4 | month == 6 | month == 9 | month == 11 
		replace `v' = `v' * (31/29) if month == 2 & year == 2016
		replace `v' = `v' * (31/29) if month == 2 & year == 2020
		replace `v' = `v' * (31/28) if month == 2 & year == 2017
		replace `v' = `v' * (31/28) if month == 2 & year == 2018
		replace `v' = `v' * (31/28) if month == 2 & year == 2019
	}
	*
				
********************************************************************************

	* job
		
		replace unemp = unemp + unemp_others
		drop unemp_others no_job_student		
		
		foreach i in self emp student unemp housewife retire job_unknown {
			gen sr`i' = `i'/pop
			}
	
	* job unclassified
		
		gen job = self + emp + unemp + housewife + retire + student
		gen srjob = job/pop
		
		gen all = job + job_unknown
		gen srall = all/pop
		

********************************************************************************		
					
	* treat: year == 2020
	* post: month == 1, 2, 3, 4, 5
	* treat_post = 2020, month 1~5
		
		gen period = 0
		replace period = month - 1 if month <= 10
		replace period = month - 13 if month >= 11

		gen nyear = 0
		replace nyear = year - 2016 if month <= 10
		replace nyear = year - 2015 if month >= 11
		
		gen treat = 0
		replace treat = 1 if period >= 1
		
		gen post = 0 
		replace post = 1 if nyear >= 4
		
		gen treat_post = treat * post
		
	* period
		
		sort city_id year month
						
		for num 1/9: gen periodX = 0
		for num 1/9: replace periodX = 1 if period == X
		
	* first outbreak: Feb ~ June
	* school close: March and April
	*　second outbreak: July ~ Oct
				
		gen first = period1 + period2 + period3 + period4 + period5
		gen second = period6 + period7 + period8 + period9
		
		gen sch_close = period2 + period3
		gen before_close = period1
		gen after_close =  period4 + period5 + period6 + period7 + period8 + period9
						
		
********************************************************************************		
		
		keep city_id county_name county_id self emp no_job student housewife unemp retire job_unknown year month pop job_total max_job_total srall srself sremp srstudent srunemp srhousewife srretire srjob_unknown period nyear treat post treat_post first second sch_close before_close after_close	period* 	
		
		save "$data\working_data\working_data_jobstatus.dta", replace
					
		
		
		
		
		