//3

///
/*Bartik shock*/
///

///2
cd "/media/steven/525 GB Hard Disk/data/stata/"
use "do.dta", replace

//2-digit industry code:/home/steven/Documents/Hours-worked-1.do
tostring ind1990, gen(ind_code)
replace ind_code = "0" + ind_code if ind1990<100
sort ind1990
gen ind_digit = substr(ind_code,1,2)
replace ind_digit = "94" if ind_digit == "95" | ind_digit == "96" //merge military codes

//Employment by industry group, by year:
foreach x of numlist 1960 1970 1980 1990 2000 2010{
	preserve
		collapse (sum) count [fweight=perwt] if year==`x', by(ind_digit)
		rename count ind_employ
		gen year = `x'
		save ind_employ_`x'.dta, replace
	restore
}

preserve
	use ind_employ_1980.dta, clear
	append using ind_employ_1960.dta
	append using ind_employ_1970.dta
	append using ind_employ_1990.dta
	append using ind_employ_2000.dta
	append using ind_employ_2010.dta
	!rm -rf ind_employ_*
	sort ind_digit year
	gen ind_chg = ln(ind_employ) - ln(ind_employ[_n-1]) if year!=1960
	save ind_employ.dta, replace
restore

save temp_ind.dta, replace

foreach x of numlist 1960 1970 1980 1990 2000 2010{
	collapse (sum) count [fweight=perwt] if year==`x', by(ind_digit statecode)
	rename count ind_employ
	preserve
		collapse (sum) ind_employ, by(statecode)
		rename ind_employ state_total_employ
		gen year = `x'
		save state_total_employ_`x'.dta, replace
	restore
	merge m:1 statecode using state_total_employ_`x'.dta
	!rm -rf state_total_employ*
	drop _merge
	save state_ind_employ_`x'.dta, replace
	use temp_ind.dta, replace
}

preserve
use state_ind_employ_1980.dta, clear
append using state_ind_employ_1970.dta
append using state_ind_employ_1960.dta
append using state_ind_employ_1990.dta
append using state_ind_employ_2000.dta
append using state_ind_employ_2010.dta
!rm -rf state_ind_employ*
merge m:1 ind_digit year using ind_employ.dta
gen share_ind_digit = ind_employ/state_total_employ
save state_ind_employ.dta, replace
bys statecode year: egen shift_share_industry = sum(share_ind_digit*ind_chg)
save bartik.dta, replace
restore

compress
save do.dta, replace
