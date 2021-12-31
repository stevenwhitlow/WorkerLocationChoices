//4
cd "/media/steven/525 GB Hard Disk/data/stata/"
use "nat.dta", replace
append using "imm.dta"
compress

//set tracedepth 1
//set trace on
///
/*Immigration shift-share*/
///

//Counrtry grouping:

/*Americas*/
gen country_group = 1 if bpl==200														//Mexico
replace country_group = 2 if bpl==210												//Central America
replace country_group = 3 if bpl==250												//Cuba
replace country_group = 4 if bpl>250 & bpl<400 							//Other Caribbean
replace country_group = 5 if bpld==30025										//Colombia
replace country_group = 6 if bpl==300 & country_group!=5		//Other South America
																																									//6
replace country_group = 7 if bpl==150 | bpl==155 | bpl==160 | bpl==199	//Canada / Atlantic islands

/*Europe*/
replace country_group = 8 if bpl>409 & bpl<415 														//UK and Ireland
replace country_group = 9 if bpl>399 & bpl<405 | bpl==419									//Scandinavia
replace country_group = 10 if bpl>419 &bpl<430														//France, Benelux, Switzerland
replace country_group = 12 if bpl>429 & bpl<441 | bpl==531								//Southern Europe(incl. Cyprus)
replace country_group = 13 if bpl==450 | bpl==453													//Austria & Germany
replace country_group = 14 if bpl==455																		//Poland
replace country_group = 15 if bpl==457																		//Yugoslavia/Former Yugoslavia
replace country_group = 16 if bpl>450 & bpl<460 & missing(country_group)	//Other Central/Eastern Europe
replace country_group = 17 if bpl>459 & bpl<500														//Former USSR

/*East Asia*/
replace country_group = 18 if bpl==500 	//China
replace country_group = 19 if bpl==501 	//Japan
replace	country_group = 20 if bpl==502 	//Korea

/*SE Asia*/
replace country_group = 21 if bpl==511	//Cambodia
replace country_group = 22 if bpl==513	//Laos
replace country_group = 23 if bpl==518	//Vietnam
replace country_group = 24 if bpl==515	//Phillipines
replace country_group = 25 if bpl==516	//Thailand
replace country_group = 26 if bpl>509 & bpl<520 & missing(country_group) //SE Asia Other

/*SW Asia*/
replace country_group = 27 if bpl==521 | bpl==523 | bpl==524 //Indian Subcontinent
replace country_group = 28 if bpl==520											//Afghanistan
replace country_group = 29 if bpl==522											//Iran

/*Middle East*/
replace country_group = 30 if bpl==542											//Turkey
replace country_group = 31 if bpl==536|bpl==538|bpl==539|bpl==540|bpl==543|bpl==544|bpl==545|bpl==546	//Arab Peninsula
replace country_group = 32 if bpl>529 & bpl<548 & missing(country_group)	//Middle East

/*Africa*/
replace country_group = 33 if bpl==600 & bpld<60020 //North Africa
replace country_group = 34 if bpl==600 & bpld>60019 //Sub-Saharan Africa

/*Oceania*/
replace country_group = 35 if bpl==700							//Aus & NZ
replace country_group = 36 if bpl==710							//Pacific Islands

/*Other*/
replace country_group = 37 if bpl==900|bpl==950			//Abroad(unknown), at sea, NEC

compress
replace birthplace=5000 if imm==0 & !missing(country_group)

save do.dta, replace
keep if imm==1


use imm_shift_start.dta, replace
foreach k of numlist 2 4{
foreach l of numlist 1 2 4 8{
//Population of country group, by year:
foreach x of numlist 1960 1970 1980 1990 2000 2010{
	preserve
		collapse (sum) count [fweight=perwt] if year==`x', by(country_group educ`k'_exp`l'_grp)
		rename count group_pop
		gen year = `x'
		save group_pop_ed`k'_ex`l'_`x'.dta, replace
	restore
}

preserve
	use group_pop_ed`k'_ex`l'_1980.dta, clear
	append using group_pop_ed`k'_ex`l'_1990.dta
	append using group_pop_ed`k'_ex`l'_2000.dta
	append using group_pop_ed`k'_ex`l'_2010.dta
	append using group_pop_ed`k'_ex`l'_1960.dta
	append using group_pop_ed`k'_ex`l'_1970.dta
	bys country_group educ`k'_exp`l'_grp (year): gen country_chg = (group_pop) - (group_pop[1]) if year!=1960
	save group_pop_ed`k'_ex`l'.dta, replace
restore
	}
}

foreach k of numlist 2 4{
foreach l of numlist 1 2 4 8{

foreach x of numlist 1960 1970 1980 1990 2000 2010{
	preserve
		collapse (sum) count [fweight=perwt] if year==`x', by(country_group statecode educ`k'_exp`l'_grp)
		rename count puma_group_pop
		gen year = `x'
		save puma_group_pop_ed`k'_ex`l'_`x'.dta, replace
	restore
}

	preserve
	use puma_group_pop_ed`k'_ex`l'_1980.dta, clear
	append using puma_group_pop_ed`k'_ex`l'_1990.dta
	append using puma_group_pop_ed`k'_ex`l'_2000.dta
	append using puma_group_pop_ed`k'_ex`l'_2010.dta
	append using puma_group_pop_ed`k'_ex`l'_1970.dta
	append using puma_group_pop_ed`k'_ex`l'_1960.dta
	merge m:1 country_group educ`k'_exp`l'_grp year using group_pop_ed`k'_ex`l'.dta, nogen
	fillin country_group educ year statecode
	sort statecode country_group year
	replace country_chg = 0 if missing(country_chg)
	replace puma_group_pop= 0 if missing(puma_group_pop)
	bys educ`k'_exp`l'_grp statecode country_group year: gen puma_share_country_group = puma_group_pop[1]/group_pop[1]
	drop if missing(country_group)
	save puma_country_group_shares.dta, replace
	bys educ`k'_exp`l'_grp statecode year: egen puma_shift_share_imm = sum(puma_share_country_group*country_chg)
	bys educ`k'_exp`l'_grp statecode year: egen puma_shift_share_imm_60 = sum(puma_share_country_group*group_pop)
	replace puma_shift_share_imm = puma_shift_share_imm_60 if year==1960
	merge m:1 educ`k'_exp`l'_grp statecode year using pop_`k'_`l'_statecode.dta, nogen
//	merge m:1 statecode educ`k'_exp`l'_grp year using pop_category_statecode_nat.dta, nogen
	gen shift_share = (puma_shift_share_imm/pop_statecode_educ`k'_exp`l')
//	gen shift_share2 = puma_shift_share_imm/pop_category_statecode_nat
	collapse shift_share /*shift_share2*/, by(statecode educ`k'_exp`l'_grp year)
//	bys statecode educ`k'_exp`l'_grp (year): gen shift_share_diff = shift_share - shift_share[_n-1]
	compress
	save state_shift_share_`k'_`l'.dta, replace
	restore
	}
}

/*
foreach k of numlist 2 4{
foreach l of numlist 1 2 4 8{
merge m:1 statecode year educ`k'_exp`l'_grp using state_shift_share_`k'_`l'.dta, nogen
!rm -rf state_shift_share_*
	}
}
*/

///////////////////////

//Population of country group, by year:
foreach x of numlist 1960 1970 1980 1990 2000 2010{
	preserve
		collapse (sum) count [fweight=perwt] if year==`x', by(country_group educ_exp_grp_bin)
		rename count group_pop
		gen year = `x'
		save group_pop_`x'.dta, replace
	restore
}

preserve
	use group_pop_1980.dta, clear
	append using group_pop_1990.dta
	append using group_pop_2000.dta
	append using group_pop_2010.dta
	append using group_pop_1960.dta
	append using group_pop_1970.dta
	bys country_group educ_exp_grp_bin (year): gen country_chg = (group_pop) - (group_pop[_n-1]) if year!=1960
	save group_pop.dta, replace
restore

foreach x of numlist 1960 1970 1980 1990 2000 2010{
	preserve
		collapse (sum) count [fweight=perwt] if year==`x', by(country_group statecode educ_exp_grp_bin)
		rename count puma_group_pop
		gen year = `x'
		save puma_group_pop_`x'.dta, replace
	restore
}
	preserve
	use puma_group_pop_1980.dta, clear
	append using puma_group_pop_1990.dta
	append using puma_group_pop_2000.dta
	append using puma_group_pop_2010.dta
	append using puma_group_pop_1960.dta
	append using puma_group_pop_1970.dta
	merge m:1 country_group educ_exp_grp_bin year using group_pop.dta
	drop _merge
	sort statecode country_group year
	replace country_chg = 0 if missing(country_chg)
	replace puma_group_pop= 0 if missing(puma_group_pop)
	bys educ_exp_grp_bin statecode country_group: gen puma_share_country_group = puma_group_pop[1]/group_pop[1]
	drop if missing(country_group)
	save puma_country_group_shares.dta, replace
	bys educ_exp_grp_bin statecode year: egen puma_shift_share_imm = sum(puma_share_country_group*country_chg)
	bys educ_exp_grp_bin statecode year: egen puma_shift_share_imm_60 = sum(puma_share_country_group*group_pop)
	replace puma_shift_share_imm = puma_shift_share_imm_60 if year==1960
	merge m:1 educ_exp_grp statecode year using pop_bin_statecode.dta, nogen
	gen shift_share = puma_shift_share_imm/pop_bin_statecode
	merge m:1 statecode educ_exp_grp_bin year using pop_bin_statecode_nat.dta, nogen
	gen shift_share2 = puma_shift_share_imm/pop_bin_statecode_nat
	collapse shift_share shift_share2, by(statecode educ_exp_grp_bin year)
	bys statecode educ_exp_grp_bin (year): gen shift_share_diff = shift_share - shift_share[_n-1]
	save state_shift_share_bin.dta, replace
	restore


compress
!rm -rf puma_group_pop_ed*
!rm -rf group_pop_ed*

//	save do.dta, replace
