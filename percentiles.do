//5
cd "/media/steven/525 GB Hard Disk/data/stata/"
use "do.dta", replace

compress

keep if classwkr==2
drop if classwkrd==29
drop if school==2
drop if gradeatt>0 &!missing(gradeatt)
keep if incwage>0 //only keep people with +ve earnings
drop if classwkrd==25
drop if ind1990>939
drop if wkswork2==0 //<3 35hrs
drop if uhrswork==0 //Few hours worked per month / less than 35 hours per week worked O&P etc.
drop if hrswork2==0 & (year==1960|year==1970)
drop if wkswork2==0 //<3 35hrs

gen real_wage = (incwage*215.965)/(CPI*weeks_worked)
//replace real_wage = minwage*(75/CPI)*uhrswork if real_wage/uhrswork<((minwage*uhrswork)(75/CPI))
gen ln_real_wage = ln(real_wage)
gen ln_real_inc = ln((incwage*215.965)/(CPI))

///
/*Percentiles, national*/
///

do /figures/percentile_figure.do

preserve
	keep if imm==1
	save imm.dta, replace
restore

keep if imm==0
save nat.dta, replace

compress

save percent_final.dta, replace
save do.dta, replace
