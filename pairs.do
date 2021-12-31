///3
cd "/media/steven/525 GB Hard Disk/data/dta/"
use "do.dta", replace

//Within a conspuma-metarea pair:

preserve
	collapse (sum) count [fweight=perwt] if metarea!=0, by(conspuma metarea year high_skill)
	rename count pop_bin_pumamet
	sort conspuma high_skill year
	by conspuma high_skill: gen pop_change_bin_pumamet = log(pop_bin_pumamet) - log(pop_bin_pumamet[_n-1])
	save pop_bin_pumamet.dta, replace
restore

			//By 4 categories:
preserve
	collapse (sum) count [fweight=perwt] if metarea!=0, by(conspuma metarea year educ_cat)
	rename count pop_category_pumamet
	sort conspuma educ_cat year
	by conspuma educ_cat: gen pop_change_cat_pumamet = log(pop_category_pumamet) - log(pop_category_pumamet[_n-1])
	save pop_category_pumamet.dta, replace
restore

		//All
preserve
	collapse (sum) count [fweight=perwt] if metarea!=0, by(conspuma metarea year)
	rename count pop_all_pumamet
	sort conspuma year
	by conspuma: gen pop_change_all_pumamet = log(pop_all_pumamet) - log(pop_all_pumamet[_n-1])
	save pop_all_pumamet.dta, replace
restore

//Native-born only
preserve
	collapse (sum) count [fweight=perwt] if metarea!=0 & imm==0, by(conspuma metarea year high_skill)
	rename count pop_bin_pumamet_nat
	sort conspuma high_skill year
	by conspuma high_skill: gen pop_change_bin_pumamet_nat = log(pop_bin_pumamet_nat) - log(pop_bin_pumamet_nat[_n-1])
	save pop_bin_pumamet.dta, replace
restore

		//By 4 categories:
preserve
	collapse (sum) count [fweight=perwt] if metarea!=0 & imm==0, by(conspuma metarea year educ_cat)
	rename count pop_category_pumamet_nat
	sort conspuma educ_cat year
	by conspuma educ_cat: gen pop_change_cat_pumamet_nat = log(pop_category_pumamet_nat) - log(pop_category_pumamet_nat[_n-1])
	save pop_category_pumamet_nat.dta, replace
restore

		//All
preserve
	collapse (sum) count [fweight=perwt] if metarea!=0 & imm==0, by(conspuma metarea year)
	rename count pop_all_pumamet_nat
	sort conspuma year
	by conspuma: gen pop_change_all_pumamet_nat = log(pop_all_pumamet_nat) - log(pop_all_pumamet_nat[_n-1])
	save pop_all_pumamet_nat.dta, replace
restore

///
/*Within-metarea population changes*/
///

egen tag = tag(metarea conspuma)
egen distinct_met = total(tag), by(metarea)  //Distinct metareas found in each PUMA
replace distinct_met = 1 if distinct_met==224 //Ignore conspumas not in MSA

//Other_change -> % change in population in native group in metarea EXCLUDING conspuma 'X'
//Puma_diff_change -> Difference in % change between conspuma `x' and rest of metarea
by metarea: gen other_change_bin = (pop_change_bin_metarea*pop_bin_metarea - pop_change_bin_pumamet*pop_bin_metarea)/(pop_bin_metarea - pop_bin_pumamet) if metarea != 0
by metarea: gen diff_change_bin = pop_bin_conspuma - other_change if metarea != 0
replace diff_change_bin = 0 if missing(puma_diff_change_bin)
preserve
	collapse (mean) diff_change_bin [fweight=perwt], by(conspuma year)
	rename diff_change_bin puma_diff_change_bin
	save puma_diff_change_bin.dta, replace
restore

by metarea: gen other_change_all = (pop_change_all_metarea*pop_all_metarea - pop_change_all_pumamet*pop_all_metarea)/(pop_all_metarea - pop_all_pumamet) if metarea != 0
by metarea: gen puma_diff_change_all = pop_all_conspuma - other_change_all if metarea != 0
replace puma_diff_change_all = 0 if missing(puma_diff_change_all)


save do.dta, replace
