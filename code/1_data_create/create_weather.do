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

	* creating wide station location
		
		import excel  using "$data\raw_data\weather\matome.xlsx", sheet("selected_station") firstrow clear
		
		rename latitude station_lat
		rename longtitude station_lon
		gen id = 1
			
		reshape wide station_lat station_lon, i(id) j(station_id)
		
		save "$data\do_file\weather\station.dta", replace
		
	* using population center
	
		import excel using "$data\raw_data\weather\pop_center.xlsx", sheet("city_location") firstrow clear
		
		rename longtitude city_lon
		rename latitude city_lat
		
		destring city_lon city_lat, replace
		gen id = 1
		
		merge m:1 id using "$data\do_file\weather\station.dta"
		drop _merge
		
		reshape long station_lat station_lon, i(city_id) j(station_id)
		drop id 
		
		save "$data\do_file\weather\city_station.dta", replace
		
		
	*  creating weather wide data
		
		import excel  using "$data\raw_data\weather\matome.xlsx", sheet("temp") firstrow clear
		drop latitude longtitude
		save "$data\do_file\weather\station_temp.dta", replace
		
		import excel  using "$data\raw_data\weather\matome.xlsx", sheet("prec") firstrow clear
		drop latitude longtitude
		drop if station_id == .
		save "$data\do_file\weather\station_prec.dta", replace
		
	* creating ranking
		
		use "$data\do_file\weather\city_station.dta", clear
		
		geodist city_lat city_lon station_lat station_lon, gen(distance)
		egen rank = rank(distance), by(city_id)
		drop if rank > 7
		
		merge m:1 station_id using "$data\do_file\weather\station_temp.dta"
		drop _merge
		merge m:1 station_id using "$data\do_file\weather\station_prec.dta"
		drop _merge
				
		gen distance2 = 1/distance^2
		egen sum_dis2 = total(distance2), by(city_id)
		gen weight = distance2/sum_dis2
					
		foreach u of var temp201201-temp202010 prec201201-prec202010{
			gen weight_`u' = `u'*weight
			egen w`u' = total(weight_`u'),by(city_id)
		}
	*	
			
		drop weight_temp* weight_prec*
		drop temp* prec*
		drop city_lon city_lat station_lat station_lon distance station_id rank distance2 sum_dis2 weight

		sort city_id
		
		by city_id: gen id = _n
		keep if id == 1
		drop id
			
		rename wtemp* temp*
		rename wprec* prec*

		reshape long temp prec, i(city_id) j(date)
		drop if city_id == . 

		tostring date, replace
		gen year = substr(date, 1, 4)
		gen month = substr(date, 5,2)
		destring year month, replace
		drop date
		
		save "$data\do_file\weather.dta", replace
		