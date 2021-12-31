cd "/media/steven/525 GB Hard Disk/data/stata/"
use pre_correction.dta
drop datanum-pernum
drop famsize-white
gen educ4 = educ_cat
gen educ2 = high_skill
drop educ_cat high_skill
foreach z of numlist 1 2 3 4 5 {
  gen intensive_prob`z'_2 = intensive_prob`z'^2
  gen intensive_probalt`z'_2 = intensive_prob`z'^2
}
compress
save pre_regression_small.dta, replace
log using regressions.smcl, replace
set matsize 11000

foreach k of numlist 2 4{
  foreach l of numlist 2 4 8{
    use pre_regression_small.dta, clear
    drop if year==1960
    drop if statecode==9
    egen cluster_groups = group(statecode educ`k'_exp`l'_grp year)
    merge m:1 statecode year educ`k'_exp`l'_grp using imm_dens_state_educ`k'_exp`l'.dta, nogen
    merge m:1 statecode year educ`k'_exp`l'_grp using state_shift_share_`k'_`l'.dta, nogen
    reg ln_real_wage imm_dens i.statecode##i.year i.educ`k'#i.year i.exp_grp_`l'#i.year i.exp_grp_`l'##i.educ`k'
    reg ln_real_wage imm_dens i.statecode##i.year i.educ`k'#i.year i.exp_grp_`l'#i.year i.exp_grp_`l'##i.educ`k' i.exp_grp_`l'#i.educ`k'#i.statecode
    ivregress 2sls ln_real_wage i.statecode##i.year i.educ`k'#i.year i.exp_grp_`l'#i.year i.exp_grp_`l'##i.educ`k' i.exp_grp_`l'#i.educ`k'#i.statecode (imm_dens=shift_share) [fweight=perwt], vce(cluster cluster_groups)
    estat firststage
    reg ln_real_wage imm_dens prob_stay_state prob_stay_state2 prob_move prob_move2 i.statecode##i.year i.educ`k'#i.year i.exp_grp_`l'#i.year i.exp_grp_`l'##i.educ`k'
    reg ln_real_wage imm_dens prob_stay_state prob_stay_state2 prob_move prob_move2 i.statecode##i.year i.educ`k'#i.year i.exp_grp_`l'#i.year i.exp_grp_`l'##i.educ`k' i.exp_grp_`l'#i.educ`k'#i.statecode
    ivregress 2sls ln_real_wage prob_stay_state prob_stay_state2 prob_move prob_move2 i.statecode##i.year i.educ`k'#i.year i.exp_grp_`l'#i.year i.exp_grp_`l'##i.educ`k' i.exp_grp_`l'#i.educ`k'#i.statecode (imm_dens=shift_share) [fweight=perwt], vce(cluster cluster_groups)
    estat firststage
    reg ln_real_wage imm_dens prob_stay_state prob_stay_state2 prob_move prob_move2 intensive_prob1 intensive_prob1_2 intensive_prob2 intensive_prob2_2 i.statecode##i.year i.educ`k'#i.year i.exp_grp_`l'#i.year i.exp_grp_`l'##i.educ`k'
    reg ln_real_wage imm_dens prob_stay_state prob_stay_state2 prob_move prob_move2 intensive_prob1 intensive_prob1_2 intensive_prob2 intensive_prob2_2 i.statecode##i.year i.educ`k'#i.year i.exp_grp_`l'#i.year i.exp_grp_`l'##i.educ`k' i.exp_grp_`l'#i.educ`k'#i.statecode
    ivregess 2sls ln_real_wage prob_stay_state prob_stay_state2 prob_move prob_move2 intensive_prob1 intensive_prob1_2 intensive_prob2 intensive_prob2_2 i.statecode##i.year i.educ`k'#i.year i.exp_grp_`l'#i.year i.exp_grp_`l'##i.educ`k' i.exp_grp_`l'#i.educ`k'#i.statecode (imm_dens=shift_share) [fweight=perwt], vce(cluster cluster_groups)
    estat firststage
    reg ln_real_wage imm_dens prob_stay_state prob_stay_state2 prob_move prob_move2 intensive_probalt1 intensive_probalt1_2 intensive_probalt2 intensive_probalt2_2 i.statecode##i.year i.educ`k'#i.year i.exp_grp_`l'#i.year i.exp_grp_`l'##i.educ`k'
    reg ln_real_wage imm_dens prob_stay_state prob_stay_state2 prob_move prob_move2 intensive_probalt1 intensive_probalt1_2 intensive_probalt2 intensive_probalt2_2 i.statecode##i.year i.educ`k'#i.year i.exp_grp_`l'#i.year i.exp_grp_`l'##i.educ`k' i.exp_grp_`l'#i.educ`k'#i.statecode
    ivregress 2sls ln_real_wage prob_stay_state prob_stay_state2 prob_move prob_move2 intensive_probalt1 intensive_probalt1_2 intensive_probalt2 intensive_probalt2_2 i.statecode##i.year i.educ`k'#i.year i.exp_grp_`l'#i.year i.exp_grp_`l'##i.educ`k' i.exp_grp_`l'#i.educ`k'#i.statecode (imm_dens=shift_share) [fweight=perwt], vce(cluster cluster_groups)
    estat firststage
  }
}

log close
