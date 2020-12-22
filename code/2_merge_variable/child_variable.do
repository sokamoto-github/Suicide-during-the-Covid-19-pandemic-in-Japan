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
		
		use "$data\working_data\working_data.dta", replace	
					
		collapse (sum) child pop_ch (mean) nyear period post treat, by(year month pref_id)
		
	* create event 
		
		for num 1/9: gen DX = 0
		for num 1/9: replace DX = 1 if period == X & year == 2020
		
		gen D0 = 0
		replace D0 = 1 if year == 2020 & period == 0
				
		for num 1/2: gen FDX = 0
		for num 1/2: replace FDX = 1 if period == -X & year == 2019
		
		gen base = 0				
		
	* creat treat_post
	
		gen sr_ch = child/pop_ch
		
		for num 1/9: gen periodX = 0
		for num 1/9: replace periodX = 1 if period == X
		
		gen first = period1 + period2 + period3 + period4 + period5
		gen second = period6 + period7 + period8 + period9
	
	* creat school	
		
		gen close = period2 + period3
		gen pre = period1
		gen after =  period4 + period5 + period6 + period7 + period8 + period9
	
********************************************************************************	

		save "$data\working_data\working_data_child.dta", replace
		