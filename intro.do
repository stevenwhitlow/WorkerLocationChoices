///1
cd "/media/steven/525 GB Hard Disk/data/"
use "usa_00018.dta", replace
cd "/media/steven/525 GB Hard Disk/data/stata/"

drop if age<18
drop if age>64
keep if sex==1
drop if gq==0 | gq==3 | gq==4
drop if school==2
drop if gradeatt>0 &!missing(gradeatt)
drop if ind1990>939
keep if labforce==2
keep if wkswork2>0
keep if classwkrd>= 20 & classwkrd<=28

//for testing
//gen dropped = rnormal(0,1)
//keep if dropped>0.99

replace perwt = perwt*0.5 if year==1970

keep if wkswork2>0
keep if classwkrd>= 20 & classwkrd<=28

gen agecat = 1 if age <25
replace agecat = 2 if age>24 & age<35
replace agecat = 3 if age>34 & age<45
replace agecat = 4 if age>44 & age<55
replace agecat = 5 if age>54 & age<65

gen hispanic = hispan != 0
gen black = race==2 & hispanic == 0
gen white = race==1 & black == 0 & hispanic == 0

gen racecat = 1 if hispanic== 1
replace racecat = 2 if black== 1
replace racecat = 3 if white== 1
replace racecat = 4 if missing(racecat)

gen statecode = statefip
replace statecode = statecode - 1 if statecode>2
replace statecode = statecode - 1 if statecode>5
replace statecode = statecode - 1 if statecode>11
replace statecode = statecode - 1 if statecode>39
replace statecode = statecode - 1 if statecode>47

gen birthplace = bpl
replace birthplace = birthplace - 1 if birthplace>2
replace birthplace = birthplace - 1 if birthplace>5
replace birthplace = birthplace - 1 if birthplace>11
replace birthplace = birthplace - 1 if birthplace>39
replace birthplace = birthplace - 1 if birthplace>47

gen imm = (citizen==2|citizen==3)
replace imm = (bpld>=15000 & bpld!=90011 & bpld!=90021) if year==1960 | (year==1970 & missing(imm))

gen manufacturing = ind1990>99 & ind1990<400

gen particip = labforce == 2 	//In labour force (all)
gen unemployed = empstat == 2	//In labour force, unemployed
gen employed = empstat == 1		//In labour force, employed

gen stayer = birthplace == statecode

gen married=marst==1|marst==2

gen child_18 = nchild>0

gen yrs_school = 17 if educ<6
replace yrs_school = 19 if educ==6 //& educd==60
replace yrs_school = 21 if (educ>6 & educ<10) //| educd==65
replace yrs_school = 23 if educ>9

gen pot_exp = age-yrs_school
gen pot_exp2 = pot_exp^2
gen pot_exp3 = pot_exp^3
gen pot_exp4 = pot_exp^4

gen educ_cat = educ<6
replace educ_cat = 2 if educ==6 //& educd==60
replace educ_cat = 3 if (educ>6 & educ<10) //| educd==65
replace educ_cat = 4 if educ>9

gen high_skill = (educ_cat==3|educ_cat==4)

gen exp_grp_8 = 1 if pot_exp>=1 & pot_exp<=5
replace exp_grp_8 = 2 if pot_exp>=6 & pot_exp<=10
replace exp_grp_8 = 3 if pot_exp>=11 & pot_exp<=15
replace exp_grp_8 = 4 if pot_exp>=16 & pot_exp<=20
replace exp_grp_8 = 5 if pot_exp>=21 & pot_exp<=25
replace exp_grp_8 = 6 if pot_exp>=26 & pot_exp<=30
replace exp_grp_8 = 7 if pot_exp>=31 & pot_exp<=35
replace exp_grp_8 = 8 if pot_exp>=36 & pot_exp<=40

drop if missing(exp_grp_8)
drop if missing(educ_cat)

gen exp_grp_4 = 1 if exp_grp_8==1|exp_grp_8==2
replace exp_grp_4 = 2 if exp_grp_8==3|exp_grp_8==4
replace exp_grp_4 = 3 if exp_grp_8==5|exp_grp_8==6
replace exp_grp_4 = 4 if exp_grp_8==7|exp_grp_8==8

gen exp_grp_2 = 1 if exp_grp_4==1|exp_grp_4==2
replace exp_grp_2 = 2 if exp_grp_4==3|exp_grp_4==4

egen educ4_exp8_grp = group(educ_cat exp_grp_8)
egen educ4_exp4_grp = group(educ_cat exp_grp_4)
egen educ4_exp2_grp = group(educ_cat exp_grp_2)
gen educ4_exp1_grp = educ_cat
egen educ2_exp8_grp = group(high_skill exp_grp_8)
egen educ2_exp4_grp = group(high_skill exp_grp_4)
gen educ2_exp1_grp = high_skill
egen educ2_exp2_grp = group(high_skill exp_grp_2)

gen count = 1

gen CPI = 29.6 if year==1960
replace CPI = 38.8 if year==1970
replace CPI = 82.4 if year==1980
replace CPI = 130.7 if year==1990
replace CPI = 172.2 if year==2000
replace CPI = 218.1 if year==2010

replace incwage=25000*1.5 if incwage==25000 & year==1960
replace incwage=50000*1.5 if incwage==50000 & year==1970
replace incwage=75000*1.5 if incwage==75000 & year==1980


gen minwage = 2.90 if year==1980
replace minwage = 3.35 if year==1990
replace minwage = 5.15 if year==2000
replace minwage = (1/3)*5.85 + (1/3)*6.55 + (1/3)*7.25 if year==2010
replace minwage = 1 if year==1960
replace minwage = 1.15 if year==1970

compress
save do.dta, replace
//save do_intro.dta, replace
