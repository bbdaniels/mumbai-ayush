// Data constuction for transition analysis

// Cleanup: Wave 0
use "${directory}/data/sp-wave-0.dta" , clear
tostring dr_5b_no re_1_a re_12_a_1 re_12_a_2 med_h_1 med_j_2  cp_13 med_f_2 med_f_3 re_*_c re_2_c re_11_a re_12_a_4 re_12_*_* cp_12 cp_12_3 med_h_1 med_j_2 re_4_a, force replace

save "${directory}/data/sp-wave-0.dta" , replace

// Cleanup: Wave 1
use "${directory}/data/sp-wave-1.dta" , clear
tostring form re_1_a dr_3a dr_5a_no dr_5b_no med_h_1 med_j_2 re_12_2 re_12_3 re_12_4 re_12_*_* sp3_h_24_2 , force replace
replace re_1 = 1 if re_1 > 1

save "${directory}/data/sp-wave-1.dta" , replace

/*
// Cleanup: Wave 2
use "${directory}/data/sp-wave-2.dta" , clear
tostring form re_9_b re_9_c re_10_c re_11_a re_12_a_4 med_f_2 med_f_3 med_b12_12 med_b2_12 dr_5a_no re_12_2, replace
replace re_1 = 1 if re_1 > 1

save "${directory}/data/sp-wave-2.dta" , replace
*/

// Append

use "${directory}/data/sp-wave-0.dta"
  tostring form , replace

qui append using ///
  "${directory}/data/sp-wave-1.dta" ///
  /// "${directory}/data/sp-wave-2.dta" ///
  , gen(wave) force
  label def wave 0 "Pre-PPIA" 1 "PPIA" // 2 "Post-PPIA"
  label val wave wave

  drop *given

// Cleaning

drop sample
drop if qutub_sample > 6

lab var correct "Correct"
lab var dr_4 "Referral"

  // Engagement indicator
  gen engaged = 0
  forvalues i = 0/2 {
    replace engaged = 1 if wave == `i' & ppia_facility_`i' == 1
  }

iecodebook export ///
  using "${directory}/constructed/sp-data.dta" ///
  , copy hash reset replace text

// End of dofile
