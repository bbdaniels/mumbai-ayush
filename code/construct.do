// Data constuction for transition analysis

// Cleanup: Wave 0 -----------------------------------------------------------------------------
	use "${directory}/data/sp-wave-0.dta" , clear

	tostring form dr_5b_no re_1_a med_h_1 med_j_2 cp_13 med_f_2 med_f_3 re_*_c re_2_c re_11_a re_12_*_* cp_12 cp_12_3 re_4_a, force replace

	save "${directory}/data/sp-wave-0.dta" , replace

// Cleanup: Wave 1 -----------------------------------------------------------------------------
	use "${directory}/data/sp-wave-1.dta" , clear

	tostring form re_1_a dr_3a dr_5a_no dr_5b_no med_h_1 med_j_2 re_12_2 re_12_3 re_12_4 re_12_*_* sp3_h_24_2 , force replace
replace re_1 = 1 if re_1 > 1

	rename g* g_*

	save "${directory}/data/sp-wave-1.dta" , replace

// Append --------------------------------------------------------------------------------------
	use "${directory}/data/sp-wave-0.dta"


	qui append using ///
	"${directory}/data/sp-wave-1.dta" ///
  /// "${directory}/data/sp-wave-2.dta" ///
	, gen(wave) force
	label def wave 0 "Pre-PPIA" 1 "PPIA" // 2 "Post-PPIA"
	label val wave wave

	drop *given

// Cleaning ------------------------------------------------------------------------------------

	drop sample
	keep if qutub_sample > 6 //Keeping only AYUSH samples

	lab var correct "Correct"
	lab var dr_4 "Referral"

	label define case 7 "SP7", add
	label values case case

	label define trial_assignmentlbl 0 control 1 treatment
	label values trial_assignment trial_assignmentlbl




// New variables -------------------------------------------------------------------------------

  // Engagement indicator
  gen engaged = 0
  forvalues i = 0/2 {
    replace engaged = 1 if wave == `i' & ppia_facility_`i' == 1
  }

	clonevar qutub_sample_updated=qutub_sample // Creating sample types PPIA Control and Treatment
		recode qutub_sample_updated (7 = 10) if trial_assignment == 0
		lab def qutub_sample 10 "Control" , modify
		recode qutub_sample_updated 7 = 11 if trial_assignment == 1
		lab def qutub_sample 11 "Treatment" , modify
		replace qutub_sample_updated = 8 if qutub_sample_updated == 7

	replace med_any = 0 if med == 0 //Creating indicator for any medicine prescribed
	replace med_any = 1 if (med!=0 & med<.)

	gen polypharmacy = . //Creating indicator for mutiple medicines prescribed
	replace polypharmacy = 0 if (med == 0 | med == 1)
	replace polypharmacy = 1 if (med > 1  & med < .)
	label variable polypharmacy polypharmacy
	label values polypharmacy yesno

	gen cp_17_a = . //Creating indicator for provider age <30
	replace cp_17_a = 1 if cp_17 == 1
	replace cp_17_a = 0 if (cp_17 == 2 | cp_17 == 3)
	label variable cp_17_a "Provider age < 30"

	gen cp_17_b = . // Creating indicator for provider age 30-50
	replace cp_17_b = 1 if cp_17 == 2
	replace cp_17_b = 0 if (cp_17 == 1 | cp_17 == 3)
	label variable cp_17_b "Provider age 30-50"

	gen cp_17_c = . // Creating indicator for provider age>50
	replace cp_17_c = 1 if cp_17 == 3
	replace cp_17_c = 0 if (cp_17 == 1 | cp_17 == 2)
	label variable cp_17_c "Provider age >50"

	label variable correct "Correct Management"





// Save -------------------------------------------------------------------------------
	save "${directory}/constructed/sp_both.dta" , replace

---

iecodebook export ///
  using "${directory}/constructed/sp-ayush.dta" ///
  , copy hash reset replace text


// End of dofile

use "${directory}/constructed/sp-ayush.dta"
