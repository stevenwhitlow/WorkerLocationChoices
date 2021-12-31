///6
cd "/media/steven/525 GB Hard Disk/data/stata/"
use "do.dta", replace
keep if imm==0

///
/*Stayer probabilities*/
///

save correction_start.dta, replace

foreach x of numlist 1960 1970 1980 1990 2000 2010{
		use correction_start.dta, clear
		keep if imm==0
		keep if year==`x'

		egen cell_stayer = group(birthplace sex racecat agecat educ4_exp8_grp married child_18)
		egen cell_mover = group(birthplace sex racecat agecat educ4_exp8_grp)

		preserve

			collapse (mean) stayer birthplace [fweight=perwt], by(cell_stayer year)
			rename stayer prob_stay_state
			save `x'_stayer_probabilities.dta,replace

		restore

		preserve
			collapse (sum) count [fweight=perwt], by(cell_mover statecode year)
			bys cell_mover year: egen total_count = sum(count)
			gen prob_move_to_state = count/total_count
			drop total_count
			save `x'_mover_probabilities.dta,replace
		restore

		foreach y of numlist 5 7 10 12 14 22 29 31 33 3 21 40 44 47 48{
			preserve
				collapse (sum) count [fweight=perwt], by(cell_mover statecode year)
					bys cell_mover year: egen total_count = sum(count)
					fillin statecode cell_mover
					replace count=0 if missing(count)
					sort cell_mover statecode year
					bys cell_mover: gen prob_move_`y' = count[`y']/total_count
					drop if _fillin==1
					keep cell_mover prob_move_`y' year
					duplicates drop
					compress
					save `x'_`y'_probabilities.dta, replace
			restore
			}

		merge m:1 cell_stayer using `x'_stayer_probabilities.dta
		!rm -rf `x'_stayer_probabilities.dta
		drop _merge
		merge m:1 cell_mover statecode using `x'_mover_probabilities.dta
		!rm -rf `x'_mover_probabilities.dta
		drop _merge

		foreach y of numlist 5 7 10 12 14 22 29 31 33 44 3 21 40 47 48{
		merge m:1 cell_mover year using `x'_`y'_probabilities.dta, nogen
		!rm -rf `x'_`y'_probabilities.dta
		}

		rowsort prob_move_5-prob_move_44, gen(intensive_prob1-intensive_prob10) descend
		drop intensive_prob6-intensive_prob10

		rowsort prob_move_5-prob_move_48, gen(intensive_probalt1-intensive_probalt15) descend
		drop intensive_probalt6-intensive_probalt15

		foreach y of numlist 5 7 10 12 14 22 29 31 33 44 3 21 40 47 48{
			foreach z of numlist 1 2 3 4 5 {
				replace intensive_prob`z'=0 if (prob_move_`y'==intensive_prob`z' & statecode==`y') | (prob_move_`y'==intensive_prob`z' & birthplace==`y')
				replace intensive_probalt`z'=0 if (prob_move_`y'==intensive_probalt`z' & statecode==`y') | (prob_move_`y'==intensive_probalt`z' & birthplace==`y')
			}
		drop prob_move_`y'
		}
		compress
		save `x'_data_wages_clean.dta,replace
}

use 1980_data_wages_clean.dta,replace
append using 1990_data_wages_clean.dta
append using 2000_data_wages_clean.dta
append using 2010_data_wages_clean.dta
append using 1960_data_wages_clean.dta
append using 1970_data_wages_clean.dta
!rm -rf *_data_wages_clean.dta

gen prob_move = 0
gen prob_move2 = 0
replace prob_move = prob_move_to_state if birthplace!=statecode
replace prob_move2 = prob_move_to_state^2 if birthplace!=statecode

gen prob_stay_state2 = prob_stay_state^2
//rowsort
save pre_correction.dta, replace

///
/*Adjustment of wages by year*/
///
/*
sort sex year

egen state_cells = group(educ_exp_grp statecode)
egen state_cells_bin = group(educ_exp_grp_bin statecode)



foreach x of numlist 1980 1990 2000 2010 1960 1970{
	areg ln_real_wage i.racecat if year==`x' [aweight=perwt], absorb(state_cells)
	predict wages1, d

	if `x'==1980{
					gen adjusted_ln_wage_alt = wages1 + _b[_cons] if year==`x'
				}
				else {
					replace adjusted_ln_wage_alt = wages1 + _b[_cons] if year==`x'
				}
				drop wages1
}

foreach x of numlist 1980 1990 2000 2010 1960 1970{
	areg ln_real_wage i.racecat  c.prob_stay_state#i.stayer c.prob_stay_state2#i.stayer prob_move prob_move2 if year==`x' [aweight=perwt], absorb(state_cells)
	predict wages1, d

				if `x'==1980{
					gen adjusted_ln_wage_sel_alt = wages1 + _b[_cons] if year==`x'
				}
				else {
					replace adjusted_ln_wage_sel_alt = wages1 + _b[_cons] if year==`x'
				}
				drop wages1
}

foreach x of numlist 1980 1990 2000 2010 1960 1970{
	areg ln_real_wage i.racecat  c.prob_stay_state#i.stayer#i.statecode c.prob_stay_state2#i.stayer#i.statecode c.prob_move#i.statecode c.prob_move2#i.statecode if year==`x' [aweight=perwt], absorb(state_cells)
	predict wages1, d

				if `x'==1980{
					gen adjusted_ln_wage_sel_alt_st = wages1 + _b[_cons] if year==`x'
				}
				else {
					replace adjusted_ln_wage_sel_alt_st = wages1 + _b[_cons] if year==`x'
				}
				drop wages1
}

foreach x of numlist 1980 1990 2000 2010 1960 1970{
	areg ln_real_inc i.racecat if year==`x' [aweight=perwt], absorb(state_cells)
	predict wages1, d

	if `x'==1980{
					gen adjusted_ln_inc_alt = wages1 + _b[_cons] if year==`x'
				}
				else {
					replace adjusted_ln_inc_alt = wages1 + _b[_cons] if year==`x'
				}
				drop wages1
}

foreach x of numlist 1980 1990 2000 2010 1960 1970{
	areg ln_real_inc i.racecat  c.prob_stay_state#i.stayer c.prob_stay_state2#i.stayer prob_move prob_move2 if year==`x' [aweight=perwt], absorb(state_cells)
	predict wages1, d

				if `x'==1980{
					gen adjusted_ln_inc_sel_alt = wages1 + _b[_cons] if year==`x'
				}
				else {
					replace adjusted_ln_inc_sel_alt = wages1 + _b[_cons] if year==`x'
				}
				drop wages1
}

foreach x of numlist 1980 1990 2000 2010 1960 1970{
	areg ln_real_inc i.racecat  c.prob_stay_state#i.stayer#i.statecode c.prob_stay_state2#i.stayer#i.statecode c.prob_move#i.statecode c.prob_move2#i.statecode if year==`x' [aweight=perwt], absorb(state_cells)
	predict wages1, d

				if `x'==1980{
					gen adjusted_ln_inc_sel_alt_st = wages1 + _b[_cons] if year==`x'
				}
				else {
					replace adjusted_ln_inc_sel_alt_st = wages1 + _b[_cons] if year==`x'
				}
				drop wages1
}


foreach x of numlist 1980 1990 2000 2010 1960 1970{
	areg ln_real_inc i.racecat  c.prob_stay_state#i.stayer#i.educ_cat c.prob_stay_state2#i.stayer#i.educ_cat c.prob_move#i.educ_cat c.prob_move2#i.educ_cat if year==`x' [aweight=perwt], absorb(state_cells)
	predict wages1, d

				if `x'==1980{
					gen adjusted_ln_inc_sel_educ = wages1 + _b[_cons] if year==`x'
				}
				else {
					replace adjusted_ln_inc_sel_educ = wages1 + _b[_cons] if year==`x'
				}
				drop wages1
}

foreach x of numlist 1980 1990 2000 2010 1960 1970{
	areg ln_real_wage i.racecat  c.prob_stay_state#i.stayer#i.educ_cat c.prob_stay_state2#i.stayer#i.educ_cat c.prob_move#i.educ_cat c.prob_move2#i.educ_cat if year==`x' [aweight=perwt], absorb(state_cells)
	predict wages1, d

				if `x'==1980{
					gen adjusted_ln_wage_sel_educ = wages1 + _b[_cons] if year==`x'
				}
				else {
					replace adjusted_ln_wage_sel_educ = wages1 + _b[_cons] if year==`x'
				}
				drop wages1
}

compress

	keep if imm==0
	save nat_adj.dta, replace


	collapse (mean) ln_real_inc ln_real_wage adjusted_ln_wage_alt adjusted_ln_wage_sel_alt adjusted_ln_wage_sel_alt_st adjusted_ln_inc_alt adjusted_ln_inc_sel_alt adjusted_ln_inc_sel_alt_st adjusted_ln_inc_sel_educ adjusted_ln_wage_sel_educ educ_cat exp_grp_d (sum) perwt [aweight=perwt], by(statecode year educ_exp_grp)
	save incomes_by_cell.dta, replace
	use nat_adj.dta, clear
	collapse (mean) ln_real_inc ln_real_wage adjusted_ln_wage_alt adjusted_ln_wage_sel_alt adjusted_ln_wage_sel_alt_st adjusted_ln_inc_alt adjusted_ln_inc_sel_alt adjusted_ln_inc_sel_alt_st adjusted_ln_inc_sel_educ adjusted_ln_wage_sel_educ educ_cat exp_grp (sum) perwt [aweight=perwt], by(statecode year educ_exp_grp_bin)
	save incomes_by_cell_bin.dta, replace
	use nat_adj.dta, clear
	collapse (mean) ln_real_inc ln_real_wage educ_cat exp_grp_d  adjusted_ln_wage_alt adjusted_ln_wage_sel_alt adjusted_ln_wage_sel_alt_st adjusted_ln_inc_alt adjusted_ln_inc_sel_alt adjusted_ln_inc_sel_alt_st adjusted_ln_inc_sel_educ adjusted_ln_wage_sel_educ (sum) perwt  [aweight=perwt], by(year educ_exp_grp)
	save incomes_by_cell_nat.dta, replace
	use nat_adj.dta, clear
	collapse (mean) ln_real_inc ln_real_wage adjusted_ln_wage_alt adjusted_ln_wage_sel_alt adjusted_ln_wage_sel_alt_st adjusted_ln_inc_alt adjusted_ln_inc_sel_alt adjusted_ln_inc_sel_alt_st adjusted_ln_inc_sel_educ adjusted_ln_wage_sel_educ educ_cat exp_grp  (sum) perwt  [aweight=perwt], by(year educ_exp_grp_bin)
	save incomes_by_cell_nat_bin.dta, replace

/*
preserve
/*forvalues y = 1/8 {
	use nat.dta, replace
	keep if statecode > 0 + ((51/8)*(`y'-1)) & statecode <= ((51/8)*`y') //divide 543 metsinto 8 equal groups

	forvalues x = 5(5)95{
		display `x'
		bys year statecode: egen p`x'_state = pctile(ln_real_wage), p(`x')	//percentiles within each met
	}

	forvalues x = 5(5)95{
		display `x'
		bys year high_skill statecode: egen p`x'_state_bin = pctile(ln_real_wage), p(`x')
	}

	collapse p*_state p*_state_bin, by(year statecode high_skill imm)
	save state_percentiles_pt`y'.dta, replace
}

use state_percentiles_pt1.dta, replace
forvalues x = 2/8{
	append using state_percentiles_pt`x'.dta
}
save state_percentiles2.dta, replace*/
/*
forvalues y = 5/8 {
	use nat_adj.dta, replace
	keep if statecode > 0 + ((51/8)*(`y'-1)) & statecode <= ((51/8)*`y') //divide 543 metsinto 8 equal groups

	forvalues x = 5(5)95{
		display `x'
		bys year statecode: egen p`x'_state = pctile(adjusted_ln_inc), p(`x')	//percentiles within each met
	}

	forvalues x = 5(5)95{
		display `x'
		bys year high_skill statecode: egen p`x'_state_bin = pctile(adjusted_ln_inc), p(`x')
	}

	collapse p*_state p*_state_bin, by(year statecode high_skill imm)
	save state_percentiles_pt`y'_adj.dta, replace
}

use state_percentiles_pt1_adj.dta, replace
forvalues x = 2/8{
	append using state_percentiles_pt`x'_adj.dta
}
save state_percentiles_adj2.dta, replace

forvalues y = 1/8 {
	use nat_adj.dta, replace
	keep if statecode > 0 + ((51/8)*(`y'-1)) & statecode <= ((51/8)*`y') //divide 543 metsinto 8 equal groups

	forvalues x = 5(5)95{
		display `x'
		bys year statecode: egen p`x'_state = pctile(adjusted_ln_inc_sel), p(`x')	//percentiles within each met
	}

	forvalues x = 5(5)95{
		display `x'
		bys year high_skill statecode: egen p`x'_state_bin = pctile(adjusted_ln_inc_sel), p(`x')
	}

	collapse p*_state p*_state_bin, by(year statecode high_skill imm)
	save state_percentiles_pt`y'_adj_sel.dta, replace
}

use state_percentiles_pt1_adj_sel.dta, replace
forvalues x = 2/8{
	append using state_percentiles_pt`x'_adj_sel.dta
}
save state_percentiles_adj_sel2.dta, replace

forvalues y = 1/32{
foreach x of numlist 1980 1990 2000 2010 1960 1970{
	areg ln_real_wage i.racecat if year==`x' & educ_exp_grp==`y' [aweight=perwt], absorb(statecode)
		predict wages1, d
	if `x'==1980 & `y'==1{
		gen adjusted_ln_wage_pool = wages1 + _b[_cons]
	}
	else {
		replace adjusted_ln_wage_pool = wages1 + _b[_cons] if year==`x' & educ_exp_grp==`y'
	}
	drop wages1

}
}

forvalues y = 1/32{
foreach x of numlist 1980 1990 2000 2010 1960 1970{
	areg ln_real_wage i.racecat   c.prob_stay_state#i.stayer c.prob_stay_state2#i.stayer prob_move prob_move2 if year==`x' & educ_exp_grp==`y' [aweight=perwt], absorb(statecode)
	predict wages1, d
	if `x'==1980 & `y'==1{
		gen adjusted_ln_wage_sel_pool = wages1 + _b[_cons]
	}
	else {
		replace adjusted_ln_wage_sel_pool = wages1 + _b[_cons] if year==`x' & educ_exp_grp==`y'
	}
	drop wages1

}
}

forvalues y = 1/16{
foreach x of numlist 1980 1990 2000 2010 1960 1970{
	areg ln_real_wage i.racecat  if year==`x' & educ_exp_grp_bin==`y' [aweight=perwt], absorb(statecode)
		predict wages1, d
	if `x'==1980 & `y'==1{
		gen adjusted_ln_wage_pool_bin = wages1 + _b[_cons]
	}
	else {
		replace adjusted_ln_wage_pool_bin = wages1 + _b[_cons] if year==`x' & educ_exp_grp_bin==`y'
	}
	drop wages1
}
}

forvalues y = 1/16{
foreach x of numlist 1980 1990 2000 2010 1960 1970{
	areg ln_real_wage i.racecat  c.prob_stay_state#i.stayer c.prob_stay_state2#i.stayer prob_move prob_move2 if year==`x' & educ_exp_grp_bin==`y' [aweight=perwt], absorb(statecode)
	predict wages1, d
	if `x'==1980 & `y'==1{
		gen adjusted_ln_wage_sel_pool_bin = wages1 + _b[_cons]
	}
	else {
		replace adjusted_ln_wage_sel_pool_bin = wages1 + _b[_cons] if year==`x' & educ_exp_grp_bin==`y'
	}
	drop wages1
}
}

///////

forvalues y = 1/32{
foreach x of numlist 1980 1990 2000 2010 1960 1970{
	areg ln_real_inc i.racecat  if year==`x' & educ_exp_grp==`y' [aweight=perwt], absorb(statecode)
		predict wages1, d
	if `x'==1980 & `y'==1{
		gen adjusted_ln_inc_pool = wages1 + _b[_cons]
	}
	else {
		replace adjusted_ln_inc_pool = wages1 + _b[_cons] if year==`x' & educ_exp_grp==`y'
	}
	drop wages1

}
}

forvalues y = 1/32{
foreach x of numlist 1980 1990 2000 2010 1960 1970{
	areg ln_real_inc i.racecat  c.prob_stay_state#i.stayer c.prob_stay_state2#i.stayer prob_move prob_move2 if year==`x' & educ_exp_grp==`y' [aweight=perwt], absorb(statecode)
	predict wages1, d
	if `x'==1980 & `y'==1{
		gen adjusted_ln_inc_sel_pool = wages1 + _b[_cons]
	}
	else {
		replace adjusted_ln_inc_sel_pool = wages1 + _b[_cons] if year==`x' & educ_exp_grp==`y'
	}
	drop wages1

}
}

forvalues y = 1/16{
foreach x of numlist 1980 1990 2000 2010 1960 1970{
	areg ln_real_inc i.racecat  if year==`x' & educ_exp_grp_bin==`y' [aweight=perwt], absorb(statecode)
		predict wages1, d
	if `x'==1980 & `y'==1{
		gen adjusted_ln_inc_pool_bin = wages1 + _b[_cons]
	}
	else {
		replace adjusted_ln_inc_pool_bin = wages1 + _b[_cons] if year==`x' & educ_exp_grp_bin==`y'
	}
	drop wages1
}
}

forvalues y = 1/16{
foreach x of numlist 1980 1990 2000 2010 1960 1970{
	areg ln_real_inc i.racecat  c.prob_stay_state#i.stayer c.prob_stay_state2#i.stayer prob_move prob_move2 if year==`x' & educ_exp_grp_bin==`y' [aweight=perwt], absorb(statecode)
	predict wages1, d
	if `x'==1980 & `y'==1{
		gen adjusted_ln_inc_sel_pool_bin = wages1 + _b[_cons]
	}
	else {
		replace adjusted_ln_inc_sel_pool_bin = wages1 + _b[_cons] if year==`x' & educ_exp_grp_bin==`y'
	}
	drop wages1
}
}

save do.dta, replace
*/
*/
