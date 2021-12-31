///2
cd "/media/steven/525 GB Hard Disk/data/stata/"
use "do.dta", clear

set tracedepth 1
set trace on
///
/*Unemployment and Participation rates by PUMA, Skill, and Immigration status*/
///
/*
preserve

collapse (mean) particip unemployed employed [fweight=perwt], by(statecode high_skill year imm)

	gen unemployment_rate = unemployed/particip
	rename particip participation_rate
	save rates_by_puma_and_imm.dta, replace

	foreach x in unemployment participation{
				gen `x'_rate_nat2 = `x'_rate if imm==0
				gen `x'_rate_imm2 = `x'_rate if imm==1

				bys statecode high_skill year: egen `x'_rate_nat = mean(`x'_rate_nat2)
				bys statecode high_skill year: egen `x'_rate_imm = mean(`x'_rate_imm2)
				drop `x'_rate_nat2 `x'_rate_imm2
	}
	save rates_by_puma.dta, replace

restore
*/
///
/*Hours worked by PUMA, Skill, and Immigration status*/
///


//Intervalled:
gen weeks_worked = wkswork1
//gen weeks_worked =  7.908908 if wkswork2 == 1
//replace weeks_worked = 21.4308 if wkswork2 == 2
//replace weeks_worked = 32.77569 if wkswork2 == 3
/*replace weeks_worked = 36.38367 if wkswork2 == 3 & missing(weeks_worked)
replace weeks_worked = 42.42923 if wkswork2 == 4 & missing(weeks_worked)
replace weeks_worked = 48.2008 if wkswork2 == 5 & missing(weeks_worked)
replace weeks_worked = 51.85403 if wkswork2 == 6 & missing(weeks_worked)*/
replace weeks_worked=6.5*(wkswork2==1) + 20*(wkswork2==2) + 33*(wkswork2==3) + 43.5*(wkswork2==4) + 48.5*(wkswork2==5) + 51*(wkswork2==6) if missing(weeks_worked)
gen hours_worked = weeks_worked*uhrswork					//hours worked per year

replace hours_worked=weeks_worked*7.5*(hrswork2==1) + weeks_worked*22*(hrswork2==2) + weeks_worked*32*(hrswork2==3) + weeks_worked*37*(hrswork2==4) + weeks_worked*40*(hrswork2==5) + weeks_worked*44.5*(hrswork2==6) + weeks_worked*54*(hrswork2==7) + weeks_worked*60*(hrswork2==8) if missing(hours_worked)

//replace hours_worked = 37*weeks_worked if (year==1960|year==1970) & hrswork2==4
//replace hours_worked = 40*weeks_worked if (year==1960|year==1970) & hrswork2==5
//replace hours_worked = 44.5*weeks_worked if (year==1960|year==1970) & hrswork2==6
//replace hours_worked = 54*weeks_worked if (year==1960|year==1970) & hrswork2==7
//replace hours_worked = 60*weeks_worked if (year==1960|year==1970) & hrswork2==8

gen real_hourly_wage = (incwage*215.965)/(CPI*hours_worked)
gen real_min_wage = (minwage*215.965)/(CPI)
drop if real_min_wage>0.75*real_hourly_wage
//gen hours_worked = wkswork1*uhrswork

save do.dta, replace

keep if imm==0
save nat.dta, replace
use "do.dta", clear
keep if imm==1
save imm.dta, replace
use "do.dta", clear

foreach k of numlist 2 4 {
foreach l of numlist 1 2 4 8 {

preserve
collapse (sum) hours_worked [fweight=perwt], by(statecode educ`k'_exp`l'_grp year)
	gen ln_hours_worked_educ`k'_exp`l' = ln(hours_worked)
	save hours_worked_educ`k'_exp`l'.dta, replace
restore

preserve
collapse (sum) hours_worked if imm==1 [fweight=perwt], by(statecode educ`k'_exp`l'_grp year)
	gen ln_hours_worked_imm_educ`k'_exp`l' = ln(hours_worked)
	save hours_worked_imm_educ`k'_exp`l'.dta, replace
restore


//National

preserve
collapse (sum) hours_worked [fweight=perwt], by(educ`k'_exp`l'_grp year)
	gen ln_hours_worked_educ`k'_exp`l' = ln(hours_worked)
	save hours_worked_national_educ`k'_exp`l'.dta, replace
restore

preserve
collapse (sum) hours_worked if imm==1 [fweight=perwt], by(educ`k'_exp`l'_grp year)
	gen ln_hours_worked_cat = ln(hours_worked)
	save hours_worked_national_imm_educ`k'_exp`l'.dta, replace
restore

///
/*Foreign-born share*/
///

use do.dta, replace

//By high- or low-skill:
preserve
	collapse (mean) imm [fweight=perwt], by(statecode year educ`k'_exp`l'_grp)
	rename imm imm_dens_state_educ`k'_exp`l'
	save imm_dens_state_educ`k'_exp`l'.dta, replace
restore

///National:
//By high- or low-skill:
preserve
	collapse (mean) imm [fweight=perwt], by(year educ`k'_exp`l'_grp)
	rename imm imm_dens_educ`k'_exp`l'
	save imm_dens_nat_educ`k'_exp`l'.dta, replace
restore

///
/*Population*/
//

//By high- or low-skill:
foreach x in statecode{
preserve
	collapse (sum) count [fweight=perwt], by(`x' year educ`k'_exp`l'_grp)
	rename count pop_`x'_educ`k'_exp`l'
	sort `x' educ`k'_exp`l'_grp year
	by `x' educ`k'_exp`l'_grp: gen pop_chg_state_educ`k'_exp`l' = log(pop_`x'_educ`k'_exp`l') - log(pop_`x'_educ`k'_exp`l'[_n-1])
	save pop_`k'_`l'_`x'.dta, replace
restore

//National:
//By high- or low-skill:
preserve
	collapse (sum) count [fweight=perwt], by(year educ`k'_exp`l'_grp)
	rename count pop_nat_educ`k'_exp`l'
	sort educ`k'_exp`l'_grp year
	by educ`k'_exp`l'_grp: gen pop_chg_nat_educ`k'_exp`l' = log(pop_nat_educ`k'_exp`l') - log(pop_nat_educ`k'_exp`l'[_n-1])
	save pop_`k'_`l'_national.dta, replace
restore
	}
}
/*
//Only native-born:

foreach x in statecode{
preserve
	collapse (sum) count [fweight=perwt] if imm==0, by(`x' year educ_exp_grp_bin)
	rename count pop_bin_`x'_nat
	sort `x' educ_exp_grp_bin year
	by `x' educ_exp_grp_bin: gen pop_change_bin_`x'_nat = log(pop_bin_`x'_nat) - log(pop_bin_`x'_nat[_n-1])
	save pop_bin_`x'_nat.dta, replace
restore

//By 4 categories:
preserve
	collapse (sum) count [fweight=perwt] if imm==0, by(`x' year educ_exp_grp)
	rename count pop_category_`x'_nat
	sort `x' educ_exp_grp year
	by `x' educ_exp_grp: gen pop_change_cat_`x'_nat = log(pop_category_`x'_nat) - log(pop_category_`x'_nat[_n-1])
	save pop_category_`x'_nat.dta, replace
restore

//All
preserve
	collapse (sum) count [fweight=perwt] if imm==0, by(`x' year)
	rename count pop_all_`x'_nat
	sort `x' year
	by `x': gen pop_change_all_`x'_nat = log(pop_all_`x'_nat) - log(pop_all_`x'_nat[_n-1])
	save pop_all_`x'_nat.dta, replace
restore
}

//National:
//By high- or low-skill:
preserve
	collapse (sum) count [fweight=perwt] if imm==0, by(year educ_exp_grp_bin)
	rename count pop_bin_national_nat
	sort educ_exp_grp_bin year
	save pop_bin_national_nat.dta, replace
restore

//By categories:
preserve
	collapse (sum) count [fweight=perwt] if imm==0, by(year educ_exp_grp)
	rename count pop_category_national_nat
	sort educ_exp_grp year
	save pop_category_national_nat.dta, replace
restore

//Only immigrant:

foreach x in statecode{
preserve
	collapse (sum) count [fweight=perwt] if imm==1, by(`x' year educ_exp_grp_bin)
	rename count pop_bin_`x'_imm
	sort `x' educ_exp_grp_bin year
	by `x' educ_exp_grp_bin (year): gen pop_change_bin_`x'_imm = log(pop_bin_`x'_imm[6]) - log(pop_bin_`x'_imm[1])
	save pop_bin_`x'_imm.dta, replace
restore

//By 4 categories:
preserve
	collapse (sum) count [fweight=perwt] if imm==1, by(`x' year educ_exp_grp)
	rename count pop_category_`x'_imm
	sort `x' educ_exp_grp year
	by `x' educ_exp_grp: gen pop_change_cat_`x'_imm = log(pop_category_`x'_imm[6]) - log(pop_category_`x'_imm[1])
	save pop_category_`x'_imm.dta, replace
restore

//All
preserve
	collapse (sum) count [fweight=perwt] if imm==1, by(`x' year)
	rename count pop_all_`x'_imm
	sort `x' year
	by `x': gen pop_change_all_`x'_imm = log(pop_all_`x'_imm) - log(pop_all_`x'_imm[_n-1])
	save pop_all_`x'_imm.dta, replace
restore
}*/

//All
preserve
	collapse (sum) count [fweight=perwt], by(statecode year)
	rename count pop_all_statecode
	sort statecode year
	gen lnpop_all_statecode = ln(pop_all_statecode)
	by statecode: gen pop_chg_state_all = ln(pop_all_statecode) - ln(pop_all_statecode[_n-1])
	save pop_all_statecode.dta, replace
restore
}

//Foreign born share - All
preserve
	collapse (mean) imm [fweight=perwt], by(statecode year)
	rename imm imm_dens_puma_all
	save employment_imm_dens_all.dta, replace
restore

///
/*Share of high- and low-skill, by PUMA and year*/
///

use nat.dta, replace
collapse (mean) high_skill [fweight=perwt], by(statecode year)
	rename high_skill nat_share_high
	gen nat_share_low = 1 - nat_share_high
	gen ratio = nat_share_high/nat_share_low
	sort statecode year
	by statecode: gen ratio_diff = ratio - ratio[_n-1]
	save ratio_by_state.dta, replace

use nat.dta, replace
collapse (mean) high_skill [fweight=perwt], by(year)
	rename high_skill nat_share_high
	gen nat_share_low = 1 - nat_share_high
	save shares_national.dta, replace

///
/*Age, by immigration status, metarea, and year*/
///

use nat.dta, replace
collapse (mean) age [fweight=perwt] if imm==0, by(statecode year)
	sort statecode year
	by statecode: gen age_diff_nat = age - age[_n-1]
save age_state_nat.dta, replace

use imm.dta, replace
collapse (mean) age [fweight=perwt] if imm==1, by(statecode year)
	sort statecode year
	by statecode: gen age_diff_imm = age - age[_n-1]
merge 1:1 statecode year using age_state_nat.dta,nogen
save age_state.dta, replace
!rm -rf age_state_nat.dta

///
/*Manufacturing Share*/
///

use do.dta, clear
preserve
	collapse (mean) manufacturing [fweight=perwt], by(statecode year)
	sort statecode year
	by statecode: gen manuf_chg = manufacturing - manufacturing[_n-1]
	by statecode: gen manuf_80 = manufacturing[1]
	save manufacturing.dta, replace
restore


//National:
//By high- or low-skill:
/*preserve
	collapse (sum) count [fweight=perwt] if imm==1, by(year educ_exp_grp_bin)
	rename count pop_bin_national_imm
	sort educ_exp_grp_bin year
	by educ_exp_grp_bin (year): gen pop_change_bin_national_imm = log(pop_bin_national_imm[6]) - log(pop_bin_national_imm[1])
	save pop_bin_national_imm.dta, replace
restore

//By categories:
preserve
	collapse (sum) count [fweight=perwt] if imm==1, by( year educ_exp_grp)
	rename count pop_category_national_imm
	sort educ_exp_grp year
	by educ_exp_grp (year): gen pop_change_cat_national_imm = log(pop_category_national_imm[6]) - log(pop_category_national_imm[1])
	save pop_category_national_imm.dta, replace
restore
*/
save do.dta, replace
save do_shares.dta, replace
