// Cleanup: Wave 0 -----------------------------------------------------------------------------
use "${directory}/data/sp-wave-0.dta" , clear

///Why using force?

tostring dr_5b_no re_1_a med_h_1 med_j_2 cp_13 med_f_2 med_f_3 re_*_c re_2_c re_11_a re_12_*_* cp_12 cp_12_3 re_4_a, force replace


replace dr_5b_no="-99" if strpos(dr_5b_no, "-99")
replace dr_5b_no="015268" if dr_5b_no=="X 015268"
replace dr_5b_no="035106" if dr_5b_no=="35106"
replace dr_5b_no="002414" if dr_5b_no=="02414"

//why converting re_1_a(price) re_4_a to string and what's price==.a?

//re_12_a_1 re_12_a_2 re_12_a_3 re_12_a_4  have only . and .a values?

//med_h_1 has values both -99, . diff b/w the two? what to do with 99?

//same with med_j_2. also, why as string variables?

// med_f_2 med_f_3 contain -99 and . and why not converting other med_f_*

//re_12_c_* (networked lab has values . 0 1 , why converting to string)

save "${directory}/data/sp-wave-0.dta" , replace

//Wave 1

use "${directory}/data/sp-wave-1.dta" , clear
tostring form re_1_a dr_3a dr_5a_no dr_5b_no med_h_1 med_j_2 re_12_2 re_12_3 re_12_4 re_12_*_* sp3_h_24_2 , force replace
replace re_1 = 1 if re_1 > 1

rename g* g_*

save "${directory}/data/sp-wave-1.dta" , replace

// Append --------------------------------------------------------------------------------------
use "${directory}/data/sp-wave-0.dta", clear 
  tostring form , replace

qui append using ///
  "${directory}/data/sp-wave-1.dta" ///
  /// "${directory}/data/sp-wave-2.dta" ///
  , gen(wave) force
  label def wave 0 "Pre-PPIA" 1 "PPIA" // 2 "Post-PPIA"
  label val wave wave

  drop *given

  


