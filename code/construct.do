// Data constuction for transition analysis

// Cleanup: Wave 1
use "${directory}/data/sp-private-1.dta" , clear
tostring cp_13 med_f_2 med_f_3 re_*_c re_2_c re_10_b re_11_a re_12_a_4 re_12_*_* cp_12 cp_12_3 med_h_1 med_j_2 re_4_a, force replace

save "${directory}/data/sp-private-1.dta" , replace

// Cleanup: Wave 2
use "${directory}/data/sp-private-2.dta" , clear
tostring form dr_3a dr_5a_no dr_5b_no med_h_1 med_j_2 re_12_2 re_12_3 re_12_4 re_12_*_* sp3_h_24_2 t_1, force replace
replace re_1 = 1 if re_1 > 1

save "${directory}/data/sp-private-2.dta" , replace

// Append

use "${directory}/data/sp-private-1.dta"
  tostring form , replace

qui append using "${directory}/data/sp-private-2.dta" , gen(wave)
  label def wave 0 "Pre-PPIA" 1 "PPIA"
  label val wave wave

// Cleaning

drop if qutub_sample > 6

lab var correct "Correct"

hashdata using "${directory}/constructed/sp-private.dta" , reset replace

// End of dofile
