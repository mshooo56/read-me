/////////////////////
////////////////thesis project
//// Mobina Shojaei

////Generalized Synthetic Control code
////////////////////////////////one digit


clear

cd  "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\22"

use "im_reg.dta"

gen group_s = substr(tariff, 1, 1)

/// Calculate mean to remove duplicates by aggregation

gen tarjihi = 0
replace tarjihi = 1 if group== 1 & month_yr>= 139702
collapse gap realvalue_im, by( group_s tarjihi tariff month_yr)

/// Remove groups that contain only treatment or only control units.

sort group_s month_yr
by group_s: egen sum_subsidy = total(tarjihi)
by group_s: egen count_obs  = count(tarjihi)

drop if sum_subsidy == 0 | sum_subsidy == count_obs 

drop sum_subsidy count_obs

destring group_s, replace
format group_s %01.0f



//// product FE

local hs_list 0 1 2 3 4 5 6 7 8 9
* Create a postfile to store results efficiently without clearing memory
postfile results_s_m str3 group double att double SE double pvalue double gap double SE_g double pvalue_g using "gsynth_unit_gap_onedigit.dta", replace

* Loop through each HS code
foreach hs of local hs_list {
    * Run generalized synthetic control
    capture gsynth realvalue_im tarjihi gap if group_s == `hs', ///
        index(tariff month_yr) ///
        estimator("ife") ///
        min_T0(8) ///
        se ///
        inference("nonparametric")
   
    * Check if gsynth ran successfully
    if _rc == 0 {
        * Check if matrices exist
        capture confirm matrix e(coef)
        local beta_ok = (_rc == 0)
        capture confirm matrix e(att_avg)
        local att_ok = (_rc == 0)
        
        if `beta_ok' & `att_ok' {
            matrix beta = e(coef)
            matrix att_av = e(att_avg)
            
            * Display matrix structure for debugging
            matrix list beta
            matrix list att_av
            
            * Check if matrices have enough columns
            if colsof(beta) >= 5 & colsof(att_av) >= 5 {
                post results_s_m ("`hs'") (att_av[1,1]) (att_av[1,2]) (att_av[1,5]) (beta[1,1]) (beta[1,2]) (beta[1,5])
            }
            else {
                display "Warning: Matrices for HS `hs' do not have enough columns."
                post results_s_m ("`hs'") (.) (.) (.) (.) (.) (.)
            }
        }
        else {
            display "Warning: Matrices e(coef) or e(att_avg) not found for HS `hs'."
            post results_s_m ("`hs'") (.) (.) (.) (.) (.) (.)
        }
    }
    else {
        display "Warning: gsynth failed for HS `hs' with error code " _rc
        post results_s_m ("`hs'") (.) (.) (.) (.) (.) (.)
    }
}
postclose results_s_m

/// time FE

local hs_list 0 1 2 3 4 5 6 7 8 9
* Create a postfile to store results efficiently without clearing memory
postfile results_s_m str3 group double att double SE double pvalue double gap double SE_g double pvalue_g using "gsynth_time_gap_onedigit.dta", replace

* Loop through each HS code
foreach hs of local hs_list {
    * Run generalized synthetic control
    capture gsynth realvalue_im tarjihi gap if group_s == `hs', ///
        index(tariff month_yr) ///
        estimator("ife") force("time") ///
        min_T0(8) ///
        se ///
        inference("nonparametric")
   
    * Check if gsynth ran successfully
    if _rc == 0 {
        * Check if matrices exist
        capture confirm matrix e(coef)
        local beta_ok = (_rc == 0)
        capture confirm matrix e(att_avg)
        local att_ok = (_rc == 0)
        
        if `beta_ok' & `att_ok' {
            matrix beta = e(coef)
            matrix att_av = e(att_avg)
            
            * Display matrix structure for debugging
            matrix list beta
            matrix list att_av
            
            * Check if matrices have enough columns
            if colsof(beta) >= 5 & colsof(att_av) >= 5 {
                post results_s_m ("`hs'") (att_av[1,1]) (att_av[1,2]) (att_av[1,5]) (beta[1,1]) (beta[1,2]) (beta[1,5])
            }
            else {
                display "Warning: Matrices for HS `hs' do not have enough columns."
                post results_s_m ("`hs'") (.) (.) (.) (.) (.) (.)
            }
        }
        else {
            display "Warning: Matrices e(coef) or e(att_avg) not found for HS `hs'."
            post results_s_m ("`hs'") (.) (.) (.) (.) (.) (.)
        }
    }
    else {
        display "Warning: gsynth failed for HS `hs' with error code " _rc
        post results_s_m ("`hs'") (.) (.) (.) (.) (.) (.)
    }
}
postclose results_s_m
////////////////time and product FE

///////////////////////////////////////
local hs_list 0 1 2 3 4 5 6 7 8 9
* Create a postfile to store results efficiently without clearing memory
postfile results_s_m str3 group double att double SE double pvalue double gap double SE_g double pvalue_g using "gsynth_two_way_gap_onedigit.dta", replace

* Loop through each HS code
foreach hs of local hs_list {
    * Run generalized synthetic control
    capture gsynth realvalue_im tarjihi gap if group_s == `hs', ///
        index(tariff month_yr) ///
        estimator("ife") force("two-way") ///
        min_T0(8) ///
        se ///
        inference("nonparametric")
   
    * Check if gsynth ran successfully
    if _rc == 0 {
        * Check if matrices exist
        capture confirm matrix e(coef)
        local beta_ok = (_rc == 0)
        capture confirm matrix e(att_avg)
        local att_ok = (_rc == 0)
        
        if `beta_ok' & `att_ok' {
            matrix beta = e(coef)
            matrix att_av = e(att_avg)
            
            * Display matrix structure for debugging
            matrix list beta
            matrix list att_av
            
            * Check if matrices have enough columns
            if colsof(beta) >= 5 & colsof(att_av) >= 5 {
                post results_s_m ("`hs'") (att_av[1,1]) (att_av[1,2]) (att_av[1,5]) (beta[1,1]) (beta[1,2]) (beta[1,5])
            }
            else {
                display "Warning: Matrices for HS `hs' do not have enough columns."
                post results_s_m ("`hs'") (.) (.) (.) (.) (.) (.)
            }
        }
        else {
            display "Warning: Matrices e(coef) or e(att_avg) not found for HS `hs'."
            post results_s_m ("`hs'") (.) (.) (.) (.) (.) (.)
        }
    }
    else {
        display "Warning: gsynth failed for HS `hs' with error code " _rc
        post results_s_m ("`hs'") (.) (.) (.) (.) (.) (.)
    }
}
postclose results_s_m
////////////////////////
//////////////////////
clear

cd  "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\22"

use "im_reg.dta"

/// group by  HS2
gen group_s = substr(tariff, 1, 2)

/// Calculate mean to remove duplicates by aggregation

gen tarjihi = 0
replace tarjihi = 1 if group== 1 & month_yr>= 139702
collapse gap realvalue_im, by( group_s tarjihi tariff month_yr)

/// Remove groups that contain only treatment or only control units.

sort group_s month_yr
by group_s: egen sum_subsidy = total(tarjihi)
by group_s: egen count_obs  = count(tarjihi)

drop if sum_subsidy == 0 | sum_subsidy == count_obs 

drop sum_subsidy count_obs

destring group_s, replace
format group_s %02.0f
///////////////// 
*** run code for which group
/////////////////////////////product FE

local hs_list 01 02 03 04 05 06 07 09 10 11 12 13 14 15 17 18 19 20 21 22 23 25 26 27 28 29 30 31 32 33 34 35 37 38 39 40 42 44 47 48 49 50 51 52 54 55 56 58 59 61 63 68 69 70 71 72 73 74 75 76 78 79 80 81 82 83 84 85 86 87 89 90 94 95 96 98
* Create a postfile to store results efficiently without clearing memory
postfile results_s_m str3 group double att double SE double pvalue double gap double SE_g double pvalue_g using "gsynth_unit_gap_twodigit.dta", replace

* Loop through each HS code
foreach hs of local hs_list {
    * Run generalized synthetic control
    capture gsynth realvalue_im tarjihi gap if group_s == `hs', ///
        index(tariff month_yr) ///
        estimator("ife") ///
        min_T0(8) ///
        se ///
        inference("nonparametric")
   
    * Check if gsynth ran successfully
    if _rc == 0 {
        * Check if matrices exist
        capture confirm matrix e(coef)
        local beta_ok = (_rc == 0)
        capture confirm matrix e(att_avg)
        local att_ok = (_rc == 0)
        
        if `beta_ok' & `att_ok' {
            matrix beta = e(coef)
            matrix att_av = e(att_avg)
            
            * Display matrix structure for debugging
            matrix list beta
            matrix list att_av
            
            * Check if matrices have enough columns
            if colsof(beta) >= 5 & colsof(att_av) >= 5 {
                post results_s_m ("`hs'") (att_av[1,1]) (att_av[1,2]) (att_av[1,5]) (beta[1,1]) (beta[1,2]) (beta[1,5])
            }
            else {
                display "Warning: Matrices for HS `hs' do not have enough columns."
                post results_s_m ("`hs'") (.) (.) (.) (.) (.) (.)
            }
        }
        else {
            display "Warning: Matrices e(coef) or e(att_avg) not found for HS `hs'."
            post results_s_m ("`hs'") (.) (.) (.) (.) (.) (.)
        }
    }
    else {
        display "Warning: gsynth failed for HS `hs' with error code " _rc
        post results_s_m ("`hs'") (.) (.) (.) (.) (.) (.)
    }
}
postclose results_s_m

/// time FE

local hs_list 01 02 03 04 05 06 07 09 10 11 12 13 14 15 17 18 19 20 21 22 23 25 26 27 28 29 30 31 32 33 34 35 37 38 39 40 42 44 47 48 49 50 51 52 54 55 56 58 59 61 63 68 69 70 71 72 73 74 75 76 78 79 80 81 82 83 84 85 86 87 89 90 94 95 96 98
* Create a postfile to store results efficiently without clearing memory
postfile results_s_m str3 group double att double SE double pvalue double gap double SE_g double pvalue_g using "gsynth_time_gap_twodigit.dta", replace

* Loop through each HS code
foreach hs of local hs_list {
    * Run generalized synthetic control
    capture gsynth realvalue_im tarjihi gap if group_s == `hs', ///
        index(tariff month_yr) ///
        estimator("ife") force("time") ///
        min_T0(8) ///
        se ///
        inference("nonparametric")
   
    * Check if gsynth ran successfully
    if _rc == 0 {
        * Check if matrices exist
        capture confirm matrix e(coef)
        local beta_ok = (_rc == 0)
        capture confirm matrix e(att_avg)
        local att_ok = (_rc == 0)
        
        if `beta_ok' & `att_ok' {
            matrix beta = e(coef)
            matrix att_av = e(att_avg)
            
            * Display matrix structure for debugging
            matrix list beta
            matrix list att_av
            
            * Check if matrices have enough columns
            if colsof(beta) >= 5 & colsof(att_av) >= 5 {
                post results_s_m ("`hs'") (att_av[1,1]) (att_av[1,2]) (att_av[1,5]) (beta[1,1]) (beta[1,2]) (beta[1,5])
            }
            else {
                display "Warning: Matrices for HS `hs' do not have enough columns."
                post results_s_m ("`hs'") (.) (.) (.) (.) (.) (.)
            }
        }
        else {
            display "Warning: Matrices e(coef) or e(att_avg) not found for HS `hs'."
            post results_s_m ("`hs'") (.) (.) (.) (.) (.) (.)
        }
    }
    else {
        display "Warning: gsynth failed for HS `hs' with error code " _rc
        post results_s_m ("`hs'") (.) (.) (.) (.) (.) (.)
    }
}
postclose results_s_m

// time and product FE

local hs_list 01 02 03 04 05 06 07 09 10 11 12 13 14 15 17 18 19 20 21 22 23 25 26 27 28 29 30 31 32 33 34 35 37 38 39 40 42 44 47 48 49 50 51 52 54 55 56 58 59 61 63 68 69 70 71 72 73 74 75 76 78 79 80 81 82 83 84 85 86 87 89 90 94 95 96 98
* Create a postfile to store results efficiently without clearing memory
postfile results_s_m str3 group double att double SE double pvalue double gap double SE_g double pvalue_g using "gsynth_two_way_gap_twodigit.dta", replace

* Loop through each HS code
foreach hs of local hs_list {
    * Run generalized synthetic control
    capture gsynth realvalue_im tarjihi gap if group_s == `hs', ///
        index(tariff month_yr) ///
        estimator("ife") force("two-way") ///
        min_T0(8) ///
        se ///
        inference("nonparametric")
   
    * Check if gsynth ran successfully
    if _rc == 0 {
        * Check if matrices exist
        capture confirm matrix e(coef)
        local beta_ok = (_rc == 0)
        capture confirm matrix e(att_avg)
        local att_ok = (_rc == 0)
        
        if `beta_ok' & `att_ok' {
            matrix beta = e(coef)
            matrix att_av = e(att_avg)
            
            * Display matrix structure for debugging
            matrix list beta
            matrix list att_av
            
            * Check if matrices have enough columns
            if colsof(beta) >= 5 & colsof(att_av) >= 5 {
                post results_s_m ("`hs'") (att_av[1,1]) (att_av[1,2]) (att_av[1,5]) (beta[1,1]) (beta[1,2]) (beta[1,5])
            }
            else {
                display "Warning: Matrices for HS `hs' do not have enough columns."
                post results_s_m ("`hs'") (.) (.) (.) (.) (.) (.)
            }
        }
        else {
            display "Warning: Matrices e(coef) or e(att_avg) not found for HS `hs'."
            post results_s_m ("`hs'") (.) (.) (.) (.) (.) (.)
        }
    }
    else {
        display "Warning: gsynth failed for HS `hs' with error code " _rc
        post results_s_m ("`hs'") (.) (.) (.) (.) (.) (.)
    }
}
postclose results_s_m



////////////////////weight

//////////////////// calculate weight of which group
clear

cd  "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\22"

use "im_reg.dta"

gen group_s = substr(tariff, 1, 1)


gen tarjihi = 0
replace tarjihi = 1 if group == 1 & month_yr>= 139702
collapse gap realvalue_im, by( group_s tarjihi tariff month_yr)

/// Remove groups that contain only treatment or only control units.

sort group_s month_yr
by group_s: egen sum_subsidy = total(tarjihi)
by group_s: egen count_obs  = count(tarjihi)

drop if sum_subsidy == 0 | sum_subsidy == count_obs 

drop sum_subsidy count_obs

destring group_s, replace
format group_s %01.0f
egen im_m = total(realvalue_im), by(month_yr)
egen im_m_s = total(realvalue_im), by(month_yr group_s)
gen weight = (im_m_s/im_m)*100
collapse weight, by(group_s)
rename group_s group
save"group_weight_onedigit.dta"

//////////////////////////////////////////////////////////////////////////////////

clear

cd  "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\22"
use "gsynth_unit_gap_onedigit.dta"


destring group, replace
format group %01.0f
merge 1:1 group using "group_weight_onedigit.dta", nogen
gen sig_level = .
replace sig_level = 3 if pvalue < 0.001
replace sig_level = 2 if pvalue >= 0.001 & pvalue < 0.01
replace sig_level = 1 if pvalue >= 0.01 & pvalue < 0.05
replace sig_level = 0 if pvalue >= 0.05

* label
label define sig_label 0 "Not significant" 1 "p < 0.05" 2 "p < 0.01" 3 "p < 0.001"
label values sig_level sig_label

gen sig_level_gap = .
replace sig_level_gap = 3 if pvalue_g < 0.001
replace sig_level_gap = 2 if pvalue_g >= 0.001 & pvalue_g < 0.01
replace sig_level_gap = 1 if pvalue_g >= 0.01 & pvalue_g < 0.05
replace sig_level_gap = 0 if pvalue_g >= 0.05


label define sig_label_gap 0 "Not significant" 1 "p < 0.05" 2 "p < 0.01" 3 "p < 0.001"
label values sig_level_gap sig_label_gap
export excel group att pvalue sig_level gap pvalue_g sig_level_gap weight using "gap_att_unit_1digit.xlsx", firstrow(variables) replace

//////////////////////////////////////////////////////////////////////////////////


clear

cd  "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\22"
use "gsynth_time_gap_onedigit.dta"


destring group, replace
format group %01.0f
merge 1:1 group using "group_weight_onedigit.dta", nogen
gen sig_level = .
replace sig_level = 3 if pvalue < 0.001
replace sig_level = 2 if pvalue >= 0.001 & pvalue < 0.01
replace sig_level = 1 if pvalue >= 0.01 & pvalue < 0.05
replace sig_level = 0 if pvalue >= 0.05

*label
label define sig_label 0 "Not significant" 1 "p < 0.05" 2 "p < 0.01" 3 "p < 0.001"
label values sig_level sig_label

gen sig_level_gap = .
replace sig_level_gap = 3 if pvalue_g < 0.001
replace sig_level_gap = 2 if pvalue_g >= 0.001 & pvalue_g < 0.01
replace sig_level_gap = 1 if pvalue_g >= 0.01 & pvalue_g < 0.05
replace sig_level_gap = 0 if pvalue_g >= 0.05

label define sig_label_gap 0 "Not significant" 1 "p < 0.05" 2 "p < 0.01" 3 "p < 0.001"
label values sig_level_gap sig_label_gap
export excel group att pvalue sig_level gap pvalue_g sig_level_gap weight using "gap_att_time_1digit.xlsx", firstrow(variables) replace
////////////////////////////////////////////////////////////////////


clear

cd  "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\22"
use "gsynth_two_way_gap_onedigit.dta"


destring group, replace
format group %01.0f
merge 1:1 group using "group_weight_onedigit.dta", nogen
gen sig_level = .
replace sig_level = 3 if pvalue < 0.001
replace sig_level = 2 if pvalue >= 0.001 & pvalue < 0.01
replace sig_level = 1 if pvalue >= 0.01 & pvalue < 0.05
replace sig_level = 0 if pvalue >= 0.05

* label
label define sig_label 0 "Not significant" 1 "p < 0.05" 2 "p < 0.01" 3 "p < 0.001"
label values sig_level sig_label

gen sig_level_gap = .
replace sig_level_gap = 3 if pvalue_g < 0.001
replace sig_level_gap = 2 if pvalue_g >= 0.001 & pvalue_g < 0.01
replace sig_level_gap = 1 if pvalue_g >= 0.01 & pvalue_g < 0.05
replace sig_level_gap = 0 if pvalue_g >= 0.05


label define sig_label_gap 0 "Not significant" 1 "p < 0.05" 2 "p < 0.01" 3 "p < 0.001"
label values sig_level_gap sig_label_gap
export excel group att pvalue sig_level gap pvalue_g sig_level_gap weight using "gap_att_two_1digit.xlsx", firstrow(variables) replace
///////////////////////////////////////////////////////////////////////////////////
clear

cd  "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\22"

use "im_reg.dta"


gen tarjihi = 0
replace tarjihi = 1 if group == 1 & month_yr>= 139702
gen group_s = substr(tariff, 1, 2)

collapse gap realvalue_im, by( group_s tarjihi tariff month_yr)

/// Remove groups that contain only treatment or only control units.

sort group_s month_yr
by group_s: egen sum_subsidy = total(tarjihi)
by group_s: egen count_obs  = count(tarjihi)

drop if sum_subsidy == 0 | sum_subsidy == count_obs 

drop sum_subsidy count_obs

destring group_s, replace
format group_s %02.0f
egen im_m = total(realvalue_im), by(month_yr)
egen im_m_s = total(realvalue_im), by(month_yr group_s)
gen weight = (im_m_s/im_m)*100
collapse weight, by(group_s)
rename group_s group
save"group_weight_twodigit.dta"

//////////////////

/////////////////////////


clear

cd  "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\22"
use "gsynth_unit_gap_twodigit.dta"


destring group, replace
format group %02.0f
merge 1:1 group using "group_weight_twodigit.dta", nogen
gen sig_level = .
replace sig_level = 3 if pvalue < 0.001
replace sig_level = 2 if pvalue >= 0.001 & pvalue < 0.01
replace sig_level = 1 if pvalue >= 0.01 & pvalue < 0.05
replace sig_level = 0 if pvalue >= 0.05

*label
label define sig_label 0 "Not significant" 1 "p < 0.05" 2 "p < 0.01" 3 "p < 0.001"
label values sig_level sig_label

gen sig_level_gap = .
replace sig_level_gap = 3 if pvalue_g < 0.001
replace sig_level_gap = 2 if pvalue_g >= 0.001 & pvalue_g < 0.01
replace sig_level_gap = 1 if pvalue_g >= 0.01 & pvalue_g < 0.05
replace sig_level_gap = 0 if pvalue_g >= 0.05

label define sig_label_gap 0 "Not significant" 1 "p < 0.05" 2 "p < 0.01" 3 "p < 0.001"
label values sig_level_gap sig_label_gap

preserve 
drop if sig_level == 0
export excel group att pvalue sig_level weight using "att_unit_2digit.xlsx", firstrow(variables) replace
restore


preserve 
drop if sig_level_gap == 0
export excel group gap pvalue_g sig_level_gap weight using "gap_unit_2digit.xlsx", firstrow(variables) replace
restore

//////////////////////////////////////////////////////////////////


clear

cd  "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\22"
use "gsynth_time_gap_twodigit.dta"


destring group, replace
format group %02.0f
merge 1:1 group using "group_weight_twodigit.dta", nogen
gen sig_level = .
replace sig_level = 3 if pvalue < 0.001
replace sig_level = 2 if pvalue >= 0.001 & pvalue < 0.01
replace sig_level = 1 if pvalue >= 0.01 & pvalue < 0.05
replace sig_level = 0 if pvalue >= 0.05

*label
label define sig_label 0 "Not significant" 1 "p < 0.05" 2 "p < 0.01" 3 "p < 0.001"
label values sig_level sig_label

gen sig_level_gap = .
replace sig_level_gap = 3 if pvalue_g < 0.001
replace sig_level_gap = 2 if pvalue_g >= 0.001 & pvalue_g < 0.01
replace sig_level_gap = 1 if pvalue_g >= 0.01 & pvalue_g < 0.05
replace sig_level_gap = 0 if pvalue_g >= 0.05


label define sig_label_gap 0 "Not significant" 1 "p < 0.05" 2 "p < 0.01" 3 "p < 0.001"
label values sig_level_gap sig_label_gap

preserve 
drop if sig_level == 0
export excel group att pvalue sig_level weight using "att_time_2digit.xlsx", firstrow(variables) replace
restore


preserve 
drop if sig_level_gap == 0
export excel group gap pvalue_g sig_level_gap weight using "gap_time_2digit.xlsx", firstrow(variables) replace
restore


///////////////////////////////////////////////////////////////////////////////////


clear

cd  "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\22"
use "gsynth_two_way_gap_twodigit.dta"


destring group, replace
format group %02.0f
merge 1:1 group using "group_weight_twodigit.dta", nogen
gen sig_level = .
replace sig_level = 3 if pvalue < 0.001
replace sig_level = 2 if pvalue >= 0.001 & pvalue < 0.01
replace sig_level = 1 if pvalue >= 0.01 & pvalue < 0.05
replace sig_level = 0 if pvalue >= 0.05

* label
label define sig_label 0 "Not significant" 1 "p < 0.05" 2 "p < 0.01" 3 "p < 0.001"
label values sig_level sig_label

gen sig_level_gap = .
replace sig_level_gap = 3 if pvalue_g < 0.001
replace sig_level_gap = 2 if pvalue_g >= 0.001 & pvalue_g < 0.01
replace sig_level_gap = 1 if pvalue_g >= 0.01 & pvalue_g < 0.05
replace sig_level_gap = 0 if pvalue_g >= 0.05

label define sig_label_gap 0 "Not significant" 1 "p < 0.05" 2 "p < 0.01" 3 "p < 0.001"
label values sig_level_gap sig_label_gap

preserve 
drop if sig_level == 0
export excel group att pvalue sig_level weight using "att_two_2digit.xlsx", firstrow(variables) replace
restore


preserve 
drop if sig_level_gap == 0
export excel group gap pvalue_g sig_level_gap weight using "gap_two_2digit.xlsx", firstrow(variables) replace
restore

//////////////////////////////////////////////////////////////////////





