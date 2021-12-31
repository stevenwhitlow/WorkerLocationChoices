cd "/media/steven/525 GB Hard Disk/data/stata/"
set max_memory 10g
use pre_regression_small.dta, replace
set matsize 11000

foreach k of numlist 2 4{
  foreach l of numlist 2 4{
    cd "/media/steven/525 GB Hard Disk/data/stata/"
    use pre_regression_small.dta, clear
    drop if year==1960
    drop if statecode==9
    egen cluster_groups = group(statecode educ`k'_exp`l'_grp year)
    merge m:1 statecode year educ`k'_exp`l'_grp using imm_dens_state_educ`k'_exp`l'.dta, nogen
    merge m:1 statecode year educ`k'_exp`l'_grp using state_shift_share_`k'_`l'.dta, nogen
    reghdfe ln_real_wage imm_dens c.prob_stay_state#i.year c.prob_stay_state2#i.year c.prob_move#i.year c.prob_move2#i.year c.intensive_prob1#i.year c.intensive_prob1_2#i.year c.intensive_prob2#i.year c.intensive_prob2_2#i.year c.intensive_prob3#i.year c.intensive_prob3_2#i.year  c.intensive_prob4#i.year c.intensive_prob4_2#i.year  c.intensive_prob5#i.year c.intensive_prob5_2#i.year  [fweight=perwt], absorb(i.statecode##i.year i.educ`k'#i.year i.exp_grp_`l'#i.year i.exp_grp_`l'##i.educ`k' i.statecode#i.educ`k' i.exp_grp_`l'#i.educ`k'#i.statecode) vce(cluster cluster_groups)

testparm c.prob_stay_state#i.year c.prob_stay_state2#i.year c.prob_move#i.year c.prob_move2#i.year

testparm c.intensive_prob1#i.year c.intensive_prob1_2#i.year c.intensive_prob2#i.year c.intensive_prob2_2#i.year c.intensive_prob3#i.year c.intensive_prob3_2#i.year c.intensive_prob4#i.year c.intensive_prob4_2#i.year  c.intensive_prob5#i.year c.intensive_prob5_2#i.year 

testparm c.prob_stay_state#i.year c.prob_stay_state2#i.year c.prob_move#i.year c.prob_move2#i.year c.intensive_prob1#i.year c.intensive_prob1_2#i.year c.intensive_prob2#i.year c.intensive_prob2_2#i.year c.intensive_prob3#i.year c.intensive_prob3_2#i.year  c.intensive_prob4#i.year c.intensive_prob4_2#i.year  c.intensive_prob5#i.year c.intensive_prob5_2#i.year

    ivreghdfe ln_real_wage c.prob_stay_state#i.year c.prob_stay_state2#i.year c.prob_move#i.year c.prob_move2#i.year c.intensive_prob1#i.year c.intensive_prob1_2#i.year c.intensive_prob2#i.year c.intensive_prob2_2#i.year c.intensive_prob3#i.year c.intensive_prob3_2#i.year  c.intensive_prob4#i.year c.intensive_prob4_2#i.year  c.intensive_prob5#i.year c.intensive_prob5_2#i.year  (imm_dens=shift_share) [fweight=perwt],  absorb(i.statecode##i.year i.educ`k'#i.year i.exp_grp_`l'#i.year i.exp_grp_`l'##i.educ`k' i.statecode#i.educ`k' i.exp_grp_`l'#i.educ`k'#i.statecode) cluster(cluster_groups)

testparm c.prob_stay_state#i.year c.prob_stay_state2#i.year c.prob_move#i.year c.prob_move2#i.year

testparm c.intensive_prob1#i.year c.intensive_prob1_2#i.year c.intensive_prob2#i.year c.intensive_prob2_2#i.year c.intensive_prob3#i.year c.intensive_prob3_2#i.year c.intensive_prob4#i.year c.intensive_prob4_2#i.year  c.intensive_prob5#i.year c.intensive_prob5_2#i.year 

testparm c.prob_stay_state#i.year c.prob_stay_state2#i.year c.prob_move#i.year c.prob_move2#i.year c.intensive_prob1#i.year c.intensive_prob1_2#i.year c.intensive_prob2#i.year c.intensive_prob2_2#i.year c.intensive_prob3#i.year c.intensive_prob3_2#i.year  c.intensive_prob4#i.year c.intensive_prob4_2#i.year  c.intensive_prob5#i.year c.intensive_prob5_2#i.year

testparm c.prob_stay_state#i.year c.prob_stay_state2#i.year c.prob_move#i.year c.prob_move2#i.year c.intensive_prob1#i.year c.intensive_prob1_2#i.year c.intensive_prob2#i.year c.intensive_prob2_2#i.year c.intensive_prob3#i.year c.intensive_prob3_2#i.year  c.intensive_prob4#i.year c.intensive_prob4_2#i.year  c.intensive_prob5#i.year c.intensive_prob5_2#i.year
}
}
