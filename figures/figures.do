cd ../
use pre_regression_small.dta, replace

preserve
	drop if birthplace>51
	collapse (mean) prob_stay_state [fweight=perwt], by(birthplace educ2_exp2_grp year)
	rename birthplace statecode
	merge 1:1 statecode educ2_exp2_grp year using imm_dens_state_educ2_exp2.dta, nogen
	drop if statecode==9
	twoway (scatter prob_stay imm_dens if year==2010, graphregion(color(white)) bgcolor(white) ylab(0(0.2)1, nogrid) legend(off) ytitle("Probability of staying in state of birth, 2010") xtitle("Immigrant density in state of birth, 2010")) (lfit prob_stay imm_dens if year==2010, graphregion(color(white)) bgcolor(white) ylab(0(0.2)1, nogrid) legend(off))
	translate @Graph "/home/steven/Documents/ma/figures/figure1.pdf", name("Graph")
restore

preserve
	collapse stayer [fweight=perwt],by(year statecode educ2_exp2_grp)
	gen mover = 1 - stayer 
	merge 1:1 statecode year educ2_exp2_grp using imm_dens_state_educ2_exp2.dta, nogen
	drop if statecode==9
	twoway (scatter mover imm_dens if year==2010, graphregion(color(white)) bgcolor(white) ylab(0(0.2)1, nogrid) legend(off) ytitle("Percentage of native workers not born in state, 2010") xtitle("State immigrant density, 2010")) (lfit mover imm_dens if year==2010, graphregion(color(white)) bgcolor(white) ylab(0(0.2)1, nogrid) legend(off))
	translate @Graph "/home/steven/Documents/ma/figures/figure2.pdf", name("Graph")
restore

preserve
	drop if birthplace>51
	collapse (mean) prob_stay_state [fweight=perwt], by(birthplace educ2_exp2_grp year)
	rename birthplace statecode
	merge 1:1 statecode educ2_exp2_grp year using imm_dens_state_educ2_exp2.dta, nogen
	drop if statecode==9
	sort statecode educ2_exp2_grp year
	by statecode educ2_exp2_grp: gen imm_change =  imm - imm[_n-4]
	by statecode educ2_exp2_grp: gen prob_change =  prob - prob[_n-4]
	twoway (scatter prob_change imm_change if year==2010, graphregion(color(white)) bgcolor(white) ylab(-0.6(0.2)0.6, nogrid) legend(off) ytitle("Change in probability of staying in birth state, 1980-2010") xtitle("Change in immigrant density in birth state, 1970-2010")) (lfit prob_change imm_change if year==2010, graphregion(color(white)) bgcolor(white) ylab(-0.6(0.2)0.6, nogrid) legend(off))
	translate @Graph "/home/steven/Documents/ma/figures/figure3.pdf", name("Graph")
restore

preserve
	bys statecode educ4_exp8_grp year: egen mean_ln_real_wage = mean(ln_real_wage)
	gen relative_wage = ln_real_wage - mean_ln_real_wage
	keep if stayer==0
	collapse relative [fweight=perwt],by(year statecode educ2_exp2_grp)
	merge 1:1 statecode year educ2_exp2_grp using imm_dens_state_educ2_exp2.dta, nogen
	drop if statecode==9
	sort statecode educ2_exp2_grp year
	twoway (scatter rel imm if year==2010, graphregion(color(white)) bgcolor(white) ylab(, nogrid) legend(off) ytitle("Relative wage of movers to state, 2010") xtitle("Immigrant density in state, 2010")) (lfit rel imm if year==2010, graphregion(color(white)) bgcolor(white) ylab(, nogrid) legend(off))
	translate @Graph "/home/steven/Documents/ma/figures/figure4.pdf", name("Graph")
restore

preserve
	bys statecode educ2_exp2_grp year: egen mean_ln_real_wage = mean(ln_real_wage)
	gen relative_wage = ln_real_wage - mean_ln_real_wage
	keep if stayer==0
	collapse relative [fweight=perwt],by(year statecode educ2_exp2_grp)
	merge 1:1 statecode year educ2_exp2_grp using imm_dens_state_educ2_exp2.dta, nogen
	drop if statecode==9
	sort statecode educ2_exp2_grp year
	by statecode educ2_exp2_grp: gen rel_change =  relative - relative[_n-4]
	by statecode educ2_exp2_grp: gen imm_change =  imm - imm[_n-4]
	twoway (scatter rel_ imm_change if year==2010, graphregion(color(white)) bgcolor(white) ylab(-0.3(0.1)0.3, nogrid) legend(off) ytitle("Change in relative wage of movers to state, 1970-2010") xtitle("Change in immigrant density in state, 1970-2010")) (lfit rel_ imm_change if year==2010, graphregion(color(white)) bgcolor(white) ylab(-0.3(0.1)0.3, nogrid) legend(off))
	translate @Graph "/home/steven/Documents/ma/figures/figure5.pdf", name("Graph")
restore


preserve
	bys statecode educ4_exp8_grp year: egen mean_ln_real_wage = mean(ln_real_wage)
	gen relative_wage = ln_real_wage - mean_ln_real_wage
	keep if stayer==0
	collapse relative [fweight=perwt],by(year educ2_exp2_grp birthplace)
	gen statecode = birthplace
	drop if statecode>51
	merge 1:1 statecode year educ2_exp2_grp using imm_dens_state_educ2_exp2.dta, nogen
	drop if statecode==9
	sort statecode educ2_exp2_grp year
	by statecode educ2_exp2_grp: gen rel_change =  relative - relative[_n-4]
	by statecode educ2_exp2_grp: gen imm_change =  imm - imm[_n-4]
	twoway (scatter rel_ imm_change if year==2010, graphregion(color(white)) bgcolor(white) ylab(-0.3(0.1)0.3, nogrid) legend(off) ytitle("Change in relative wage of movers from birth state") xtitle("Change in immigrant density in state of birth, 1970-2010")) (lfit rel_ imm_change if year==2010, graphregion(color(white)) bgcolor(white) ylab(-0.3(0.1)0.3, nogrid) legend(off))
	translate @Graph "/home/steven/Documents/ma/figures/figure6.pdf", name("Graph")
restore

preserve
	collapse (mean) stayer [fweight=perwt], by(statecode educ2_exp2_grp year)
	gen mover = 1 - stayer
	merge 1:1 statecode year educ2_exp2_grp using imm_dens_state_educ2_exp2.dta, nogen
	drop if statecode==9
	sort statecode educ2_exp2_grp year
	by statecode educ2_exp2_grp: gen move_change =  mover - mover[_n-4]
	by statecode educ2_exp2_grp: gen imm_change =  imm - imm[_n-4]
	twoway (scatter move_ imm_change if year==2010, graphregion(color(white)) bgcolor(white) ylab(-0.6(0.2)0.6, nogrid) legend(off) ytitle("Change in percent of native workers born outside state") xtitle("Change in state immigrant density, 1970-2010")) (lfit move_ imm_change if year==2010, graphregion(color(white)) bgcolor(white) ylab(-0.6(0.2)0.6, nogrid) legend(off))
	translate @Graph "/home/steven/Documents/ma/figures/figure7.pdf", name("Graph")
restore

drop if year==1960
drop if statecode==9
egen cluster_groups = group(statecode educ2_exp2_grp year)
merge m:1 statecode year educ2_exp2_grp using imm_dens_state_educ2_exp2.dta, nogen
reghdfe ln_real_wage prob_stay_state prob_stay_state2 prob_move prob_move2 [fweight=perwt], absorb(i.statecode##i.year i.educ2#i.year i.exp_grp_2#i.year i.exp_grp_2##i.educ2 i.statecode#i.educ2 i.exp_grp_2#i.educ2#i.statecode) vce(cluster cluster_groups)
gen mean_error_term = _b[prob_stay_state]*(prob_stay_state) + _b[prob_stay_state2]*(prob_stay_state2) + _b[prob_move]*(prob_move) + _b[prob_move2]*(prob_move2)
rename mean_error_term relative


preserve
	keep if stayer==0
	collapse relative [fweight=perwt],by(year statecode educ2_exp2_grp)
	merge 1:1 statecode year educ2_exp2_grp using imm_dens_state_educ2_exp2.dta, nogen
	drop if statecode==9
	sort statecode educ2_exp2_grp year
	by statecode educ2_exp2_grp: gen rel_change =  relative - relative[_n-4]
	by statecode educ2_exp2_grp: gen imm_change =  imm - imm[_n-4]
	twoway (scatter rel_ imm_change if year==2010, graphregion(color(white)) bgcolor(white) ylab(-0.3(0.1)0.3, nogrid) legend(off) ytitle("Change in mean selectivity bias term of movers, 1970-2010") xtitle("Change in immigrant density in state, 1970-2010")) (lfit rel_ imm_change if year==2010, graphregion(color(white)) bgcolor(white) ylab(-0.3(0.1)0.3, nogrid) legend(off))
	translate @Graph "/home/steven/Documents/ma/figures/figure8.pdf", name("Graph")
restore

preserve
	keep if stayer==1
	collapse relative [fweight=perwt],by(year statecode educ2_exp2_grp)
	merge 1:1 statecode year educ2_exp2_grp using imm_dens_state_educ2_exp2.dta, nogen
	drop if statecode==9
	sort statecode educ2_exp2_grp year
	by statecode educ2_exp2_grp: gen rel_change =  relative - relative[_n-4]
	by statecode educ2_exp2_grp: gen imm_change =  imm - imm[_n-4]
	twoway (scatter rel_ imm_change if year==2010, graphregion(color(white)) bgcolor(white) ylab(-0.3(0.1)0.3, 	nogrid) legend(off) ytitle("Change in mean selectivity bias of stayers, 1970-2010") xtitle("Change in immigrant density in state, 1970-2010")) (lfit rel_ imm_change if year==2010, graphregion(color(white)) bgcolor(white) ylab(-0.3(0.1)0.3, nogrid) legend(off))
	translate @Graph "/home/steven/Documents/ma/figures/figure9.pdf", name("Graph")
restore


preserve
	collapse relative [fweight=perwt],by(year statecode educ2_exp2_grp stayer)
	merge m:1 statecode year educ2_exp2_grp using imm_dens_state_educ2_exp2.dta, nogen
	merge m:1 statecode year educ2_exp2_grp using pop_2_2_statecode.dta, nogen
	drop if statecode==9
	sort statecode educ2_exp2_grp year stayer
	by statecode educ2_exp2_grp year: gen rel_change =  relative - relative[_n-1]
	twoway (scatter rel_change imm if year==2010, graphregion(color(white)) bgcolor(white) ylab(-0.3(0.1)0.3, nogrid) legend(off) ytitle("Relative selectivity bias of native stayers, 2010") xtitle("Immigrant density in state, 2010")) (lfit rel_change imm  if year==2010, graphregion(color(white)) bgcolor(white) ylab(-0.3(0.1)0.3, nogrid) legend(off))
sum rel_change
sum rel_change if year==2010
sum rel_change [aweight=pop_state]
sum rel_change if year==2010 [aweight=pop_state]
	translate @Graph "/home/steven/Documents/ma/figures/figure10-1.pdf", name("Graph")
restore


preserve
	collapse relative [fweight=perwt],by(year statecode educ2_exp2_grp stayer)
	merge m:1 statecode year educ2_exp2_grp using imm_dens_state_educ2_exp2.dta, nogen
	drop if statecode==9
	sort statecode educ2_exp2_grp year stayer
	by statecode educ2_exp2_grp year: gen rel_change =  relative - relative[_n-1]
	collapse rel_change imm,by(statecode educ2_exp2_grp stayer)
	twoway (scatter rel_change imm, graphregion(color(white)) bgcolor(white) ylab(-0.3(0.1)0.3, nogrid) legend(off) ytitle("Mean relative selectivity bias of native stayers, 1970-2010") xtitle("Mean immigrant density in state, 1970-2010")) (lfit rel_change imm, graphregion(color(white)) bgcolor(white) ylab(-0.3(0.1)0.3, nogrid) legend(off))
	translate @Graph "/home/steven/Documents/ma/figures/figure10.pdf", name("Graph")
restore


