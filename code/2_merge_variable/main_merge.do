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
	
		fillin city_id year month
	
	* drop irrelevant variables
	
		drop self emp no_job student no_job_student housewife unemp retire unemp_others job_unknown home building traffic sea mountain place_others place_unknown hanging poison coal jump dive means_others means_unknown reason_family reason_health reason_economy reason_job reason_relationship reason_school reason_others reason_unknown past_yes past_no past_unknown
		
		
	* pref_id
	
		gen pref_id = city_id/ 10000
		replace pref_id = floor(pref_id)
	
	* merge
		
		merge 1:1 city_id year month using "$data\do_file\suicide_gender.dta"
		drop _merge
				
		drop if city_id == .
		
		merge 1:1 city_id year month using "$data\do_file\weather.dta"
		drop _merge
		
		replace city_id = city_id/10
		replace city_id = floor(city_id)
		
		merge m:1 city_id using "$data\do_file\pop.dta"
		drop _merge		
				
		drop if year <= 2015
		drop if year == 2016 & month <= 10
		drop if year == 2020 & month >= 11
		
		egen maxsuicide = max(suicide), by(city_id)
		drop if maxsuicide == .
		drop maxsuicide
		
	* create two dataset
	
		/* drop these city because of duplications
			11002 北海道札幌市 （計）
			41009 宮城県仙台市 （計）
			111007 埼玉県さいたま市 （計）
			121002 千葉県千葉市 （計）
			131008 東京都特別区 （計）
			141003 神奈川県横浜市 （計）
			141305 神奈川県川崎市 （計）
			141500 神奈川県相模原市 （計）
			151009 新潟県新潟市 （計）
			221007 静岡県静岡市 （計）
			221309 静岡県浜松市 （計）
			231002 愛知県名古屋市 （計）
			261009 京都府京都市 （計）
			271004 大阪府大阪市 （計）
			271403 大阪府堺市 （計）
			281000 兵庫県神戸市 （計）
			331007 岡山県岡山市 （計）
			341002 広島県広島市 （計）
			401005 福岡県北九州市 （計）
			401307 福岡県福岡市 （計）
			431001 熊本県熊本市 （計）
		*/ 
		
		gen mastercity = 0
		
		foreach i in 4100 1100 11100 12100 13100 14100 14130 14150 15100 22100 22130 23100 26100 27100 27140 28100 33100 34100 40100 40130 43100 {
			replace mastercity = 1 if city_id == `i'
			}
			*
			
			gen dataset1 = 0
			replace dataset1 = 1 if mastercity == 0
			
			
		keep if dataset1 == 1
		
		
		save "$data\do_file\merged_data.dta", replace
	