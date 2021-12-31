use ../pre_regression_small.dta, clear
gen intensive=0
foreach y of numlist 5 7 10 12 14 22 29 31 33 3 21 40 44 47 48{
	replace intensive=1 if statecode==`y'
}

preserve
	collapse (mean) prob_stay_state if stayer==1 [fweight=perwt], by(statecode year intensive)
	merge 1:1 statecode year using pop_all_statecode.dta, nogen
	bys year: sum prob_stay if intensive==0 & (year==1970|year==2010) [aweight=pop_all]
	bys year: sum prob_stay if intensive==1 & (year==1970|year==2010)  [aweight=pop_all]
	bys year: sum prob_stay if statecode==5 & (year==1970|year==2010)  [aweight=pop_all]
	sum intensive [fweight=perwt] if year==2010
	gen born_intensive=0
	foreach y of numlist 5 7 10 12 14 22 29 31 33 3 21 40 44 47 48{
		replace born_intensive=1 if birthplace==`y'
	}
	sum intensive if born_intensive==0 & year==2010 [fweight=perwt]
	sum intensive if born_intensive==1 & year==2010 [fweight=perwt]
	sum intensive if born_intensive==1 & year==2010 & statecode!=birthplace [fweight=perwt]
restore

preserve
collapse (mean) prob_stay_state if stayer==1 & educ2==0 [fweight=perwt], by(statecode year intensive)
	merge 1:1 statecode year using pop_all_statecode.dta, nogen
	bys year: sum prob_stay if intensive==0 & (year==1970|year==2010) [aweight=pop_all]
	bys year: sum prob_stay if intensive==1 & (year==1970|year==2010)  [aweight=pop_all]
	bys year: sum prob_stay if statecode==5 & (year==1970|year==2010)  [aweight=pop_all]
restore

preserve
collapse (mean) prob_stay_state if stayer==1 & educ2==1 [fweight=perwt], by(statecode year intensive)
	merge 1:1 statecode year using pop_all_statecode.dta, nogen
	bys year: sum prob_stay if intensive==0 & (year==1970|year==2010) [aweight=pop_all]
	bys year: sum prob_stay if intensive==1 & (year==1970|year==2010)  [aweight=pop_all]
	bys year: sum prob_stay if statecode==5 & (year==1970|year==2010)  [aweight=pop_all]
restore
