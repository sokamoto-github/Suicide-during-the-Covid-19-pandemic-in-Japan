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

	
	import delimited "$data\raw_data\pop/pop.csv", clear rowrange(10) varnames(nonames) 

	rename v3 city_id
	rename v6 pop
	rename v8 pop_male
	rename v10 pop_female
	rename v12 pop_ch
	rename v14 pop_ch_male
	rename v16 pop_ch_female
	rename v18 pop_ad
	rename v20 pop_ad_male
	rename v22 pop_ad_female
	rename v24 pop_el
	rename v26 pop_el_male
	rename v28 pop_el_female
	
	drop v1 v2 v4 v5 v7 v9 v11 v13 v15 v17 v19 v21 v23 v25 v27 v29

	foreach v of varlist pop pop_male pop_female pop_ch pop_ch_male pop_ch_female pop_ad pop_ad_male pop_ad_female pop_el pop_el_male pop_el_female {
		replace `v' = subinstr(`v',",","",.)
		destring `v', replace
		replace `v' = `v'/1000000
		}
		* changed to per million
	
	save "$data/do_file/pop", replace

	