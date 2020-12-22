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
	
	use "$data\do_file\merged_data.dta", replace
	
		* changing to zero if no record
	
		foreach v of varlist suicide suicide_male suicide_female age20 age20_29 age30_39 age40_49 age50_59 age60_69 age70_79 age80 age_unknown age20_male age20_29_male age30_39_male age40_49_male age50_59_male age60_69_male age70_79_male age80_male age20_female age20_29_female age30_39_female age40_49_female age50_59_female age60_69_female age70_79_female age80_female partner_yes partner_no partner_unknown time0_2 time2_4 time4_6 time6_8 time8_10 time10_12 time12_14 time14_16 time16_18 time18_20 time20_22 time22_24 time_unknown sun mon tue wed thu fri sat dow_unknown {	
		replace `v' = 0 if `v' == .
		}		
				
								
	* controlling for the date difference
	
		foreach v of varlist suicide suicide_male suicide_female age20 age20_29 age30_39 age40_49 age50_59 age60_69 age70_79 age80 age_unknown age20_male age20_29_male age30_39_male age40_49_male age50_59_male age60_69_male age70_79_male age80_male age20_female age20_29_female age30_39_female age40_49_female age50_59_female age60_69_female age70_79_female age80_female partner_yes partner_no partner_unknown  time0_2 time2_4 time4_6 time6_8 time8_10 time10_12 time12_14 time14_16 time16_18 time18_20 time20_22 time22_24 time_unknown sun mon tue wed thu fri sat dow_unknown {		
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

	* create outcomes 
	
		* age
		
		gen child = age20
		gen adult = age20_29 + age30_39 + age40_49 + age50_59 + age60_69
		gen elderly = age70_79 + age80		
		
		gen sr_ch = (child)/pop_ch
		gen sr_ad = (adult)/pop_ad
		gen sr_el = (elderly)/pop_el
							
		foreach i in male female{
			gen child_`i' = age20_`i'
			gen adult_`i' = age20_29_`i' + age30_39_`i' + age40_49_`i' + age50_59_`i' + age60_69_`i'
			gen elderly_`i' = age70_79_`i' + age80_`i'	
			}
			*			
		gen sr_male= (suicide_male)/pop_male
		gen sr_female = (suicide_female)/pop_female
						
	* all
	
		gen sr = (suicide)/pop
	
	* gender
	
		gen srch_male = child_male/pop_ch_male
		gen srch_female = child_female/pop_ch_female
		gen srad_male = adult_male/pop_ad_male
		gen srad_female = adult_female/pop_ad_female
		gen srel_male = elderly_male/pop_el_male
		gen srel_female = elderly_female/pop_el_female
				
		gen srchel_male = (child_male+elderly_male)/(pop_ch_male+pop_el_male)
		gen srchel_female = (child_female+elderly_female)/(pop_ch_female+pop_el_female)
	
	* weather
	
		gen tempsq = temp * temp
		gen precsq = prec * prec
		
********************************************************************************	
		
	* treatment and post period create		
	* treat: year == 2020
	* post: month == 2~10
	* treat_post = 2020, month 2~10
		
		
		* period = 0 if january
		
		gen period = 0
		replace period = month - 1 if month <= 10
		replace period = month - 13 if month >= 11
	
		* nyear = 1 if Nov 2016 - Oct 2017
		* nyear = 2 if Nov 2017 - Oct 2018
		* nyear = 3 if Nov 2018 - Oct 2019
		* nyear = 4 if Nov 2019 - Oct 2020
		
		gen nyear = 0
		replace nyear = year - 2016 if month <= 10
		replace nyear = year - 2015 if month >= 11
		
		* treat = 1 if month = 2~10
		
		gen treat = 0
		replace treat = 1 if period >= 1
		
		* post = 1 if nyear = 4
		
		gen post = 0 
		replace post = 1 if nyear >= 4
		
		gen treat_post = treat * post
			
	* create event 
		
		for num 1/9: gen DX = 0
		for num 1/9: replace DX = 1 if period == X & year == 2020
		
		gen D0 = 0
		replace D0 = 1 if year == 2020 & period == 0
				
		for num 1/2: gen FDX = 0
		for num 1/2: replace FDX = 1 if period == -X & year == 2019
		
		gen base = 0				
		
	* create period dummy
	
		for num 1/9: gen periodX = 0
		for num 1/9: replace periodX = 1 if period == X
		
	* first = Feb-jun
	* second = jul-oct
	
		gen first = period1 + period2 + period3 + period4 + period5
		gen second = period6 + period7 + period8 + period9
	
	* gen soe
		gen soe = period3 + period4
		gen nosoe = period1 + period2 + period5
	
	* gen ym
	
		gen ym = ym(year, month)	

********************************************************************************	

	* drop not using data
	
keep city_id county_name county_id suicide year month pref_id suicide_male suicide_female temp prec pop pop_male pop_female pop_ch pop_ch_male pop_ch_female pop_ad pop_ad_male pop_ad_female pop_el pop_el_male pop_el_female child adult elderly child_male adult_male elderly_male child_female adult_female elderly_female sr sr_ch sr_ad sr_el sr_male sr_female srch_male srch_female srad_male srad_female srel_male srel_female srchel_male srchel_female tempsq precsq period nyear treat post treat_post D1 D2 D3 D4 D5 D6 D7 D8 D9 D0 FD1 FD2 base period1 period2 period3 period4 period5 period6 period7 period8 period9 first second soe nosoe ym

		save "$data\working_data\working_data.dta", replace
		
		
		
		
		