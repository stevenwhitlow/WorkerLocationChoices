cd ../

use nat.dta
drop if year==1960
keep if classwkr==2
drop if classwkrd==29
drop if school==2
drop if gradeatt>0 &!missing(gradeatt)
keep if incwage>0 //only keep people with +ve earnings
drop if classwkrd==25
drop if ind1990>939
drop if uhrswork==0 //Few hours worked per month / less than 35 hours per week worked O&P etc.
drop if hrswork2==0 & (year==1960|year==1970)
drop if wkswork2<3 //35hrs

drop real_wage ln_real_*
gen real_wage = (incwage*215.965)/(CPI*weeks_worked)
gen ln_real_wage = ln(real_wage)
gen ln_real_inc = ln((incwage*215.965)/(CPI))

bys statecode educ2_exp2_grp year: egen n = count(ln_real_wage)
by statecode educ2_exp2_grp year: egen i = rank(ln_real_wage)
gen income_percentile_national = (i - 0.5) / n
drop n i

forvalues x = 1/99{
	display `x'
	bys statecode educ2_exp2_grp year: egen p`x'_cell = pctile(ln_real_wage), p(`x')
}

keep statecode educ2_exp2_grp year p*_cell
duplicates drop
save percentiles.dta, replace
use imm.dta, clear
drop if year==1960

keep if classwkr==2
drop if classwkrd==29
drop if school==2
drop if gradeatt>0 & !missing(gradeatt)
keep if incwage>0 //only keep people with +ve earnings
drop if classwkrd==25
drop if ind1990>939
drop if uhrswork==0 //Few hours worked per month / less than 35 hours per week worked O&P etc.
drop if hrswork2==0 & (year==1960|year==1970)
drop if wkswork2<3 35hrs

drop real_wage ln_real_*
gen real_wage = (incwage*215.965)/(CPI*weeks_worked)
gen ln_real_wage = ln(real_wage)
gen ln_real_inc = ln((incwage*215.965)/(CPI))

merge m:1 statecode educ2_exp2_grp year using percentiles.dta, nogen
gen p_cell_imm1 = 1
gen income_percentile_national = 1
forvalues x = 1/99{
if `x'<99{
	local pctile = `x' + 1
	replace income_percentile_national = `pctile' if ln_real_wage>p`x'_cell & ln_real_wage<=p`pctile'_cell & imm == 1
	gen p_cell_imm`pctile' = 1 if income_percentile_national == `pctile'
	replace p_cell_imm`pctile' = 0 if missing(p_cell_imm`pctile')
	replace p_cell_imm1 = 0 if income_percentile_national == `pctile'
	}
else {
	local pctile = `x' + 1
	replace income_percentile_national = `pctile' if ln_real_wage>p`x'_cell
	gen p_cell_imm`pctile' = 1 if income_percentile_national == `pctile'
	replace p_cell_imm`pctile' = 0 if missing(p_cell_imm`pctile')
	replace p_cell_imm1 = 0 if income_percentile_national == `pctile'
}
}

collapse (mean) p_cell_imm1-p_cell_imm100 (rawsum) perwt [fweight=perwt], by(high_skill year)
collapse (mean) p_cell_imm1-p_cell_imm100 [aweight=perwt], by(high_skill)

reshape long p_cell_imm, i(high_skill) j(percentile)
replace p_cell_imm = p_cell_imm*100
drop if (percentile == 1) | (percentile == 2) | (percentile == 99) | (percentile == 100)
label define skill_label 0 "Low skill" 1 "High skill"
label values high_skill skill_label
graph twoway (lowess p_cell_imm percentile, by(high_skill, note("")) yline(1) bwidth(0.1) graphregion(color(white)) bgcolor(white) legend(off) ytitle("Percentage of immigrants in native wage percentile") xtitle("Percentile of native wage distribution in state-education-experience cell"))
translate @Graph "/home/steven/Documents/ma/figures/figure16.pdf", name("Graph")





