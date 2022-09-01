// Data constuction for transition analysis

// Cleanup: Wave 0 -----------------------------------------------------------------------------
	use "${directory}/data/sp-wave-0.dta" , clear

	tostring form dr_5b_no re_1_a med_h_1 med_j_2 cp_13 med_f_2 med_f_3 re_*_c re_2_c re_11_a re_12_*_* cp_12 cp_12_3 re_4_a, force replace


	save "${directory}/constructed/sp-wave-0.dta" , replace

// Cleanup: Wave 1 -----------------------------------------------------------------------------
	use "${directory}/data/sp-wave-1.dta" , clear

	tostring form re_1_a dr_3a dr_5a_no dr_5b_no med_h_1 med_j_2 re_12_2 re_12_3 re_12_4 re_12_*_* sp3_h_24_2 , force replace
	replace re_1 = 1 if re_1 > 1

	rename g* g_*

	replace dr_4 = 0 if dr_4 == 3

	save "${directory}/constructed/sp-wave-1.dta" , replace

// Append --------------------------------------------------------------------------------------
use "${directory}/constructed/sp-wave-0.dta"

  	qui append using ///
  	"${directory}/constructed/sp-wave-1.dta" ///
  	, gen(wave) force
  	label def wave 0 "Pre-PPIA" 1 "PPIA"
  	label val wave wave

  	drop *given

  // Cleaning

  	drop sample
  	keep if qutub_sample > 6 // Keeping only AYUSH samples

  	lab var correct "Correct"
  	lab var dr_4 "Referral"

  	label define case 7 "SP7", add
  	label values case case

  	label define trial_assignment 0 control 1 treatment
  	label values trial_assignment trial_assignment

  // New variables

    // Engagement indicator
    gen engaged = 0
    forvalues i = 0/1 {
      replace engaged = 1 if wave == `i' & ppia_facility_`i' == 1
    }
      lab var engaged "PPIA in Current Round"
      lab val engaged yesno

    // Create sample types PPIA Control and Treatment
  	clonevar qutub_sample_updated = qutub_sample
  		recode qutub_sample_updated (7 = 10) if (trial_assignment == 0) // Trial control
  		  lab def qutub_sample 10 "Control" , modify
  		recode qutub_sample_updated (7 = 11) if (trial_assignment == 1) // Trial treatment
  		  lab def qutub_sample 11 "Treatment" , modify
  		replace qutub_sample_updated = 8 if (qutub_sample_updated == 7) // Non-assigned but labeled as trial

    // Create indicator for any medicine prescribed
  	replace med_any = 0 if med == 0
  	replace med_any = 1 if (med!=0 & med<.)
      lab var med_any "Any Medication"

    // Creating indicator for provider age groups
    	gen cp_17_a = (cp_17 == 1)
    	label variable cp_17_a "Provider Age < 30"

    	gen cp_17_b = (cp_17 == 2)
    	label variable cp_17_b "Provider Age 30-50"

    	gen cp_17_c = (cp_17 == 3)
    	label variable cp_17_c "Provider Age >50"

      lab val cp_17_? yesno

    // Label cleaning
  	label variable correct "Correct"
  	label variable med_l_any_1 "TB Treatment"

    lab def wave 0 "Baseline" 1 "Endline" , modify

    gen group = .
      replace group = 1 if trial_assignment == 1
      replace group = 2 if trial_assignment == 0
      replace group = 3 if trial_assignment == . ///
        & ppia_facility_0 == 0 
      replace group = 4 if trial_assignment == . ///
        & ppia_facility_0 == 1

      lab def group ///
        1 "Experimental Treatment" ///
        2 "Experimental Control" ///
        3 "Observational PPIA" ///
        4 "Observational Non-PPIA" 
      lab val group group

  // Save
  compress
	save "${directory}/constructed/analysis-ayush-panel.dta" , replace


// Creating data for analysis of Observational groups
use "${directory}/constructed/analysis-ayush-panel.dta", clear

	keep if qutub_sample_updated == 8 | qutub_sample_updated == 9

	drop if (case == 7)

	gen d_t = (wave == 0 & ppia_facility_0 == 1)  | (wave == 1 & ppia_facility_1 == 1)
    lab var d_t "PPIA in Round"
    lab val d_t yesno

	egen check = group(ppia_facility_0 ppia_facility_1), label

	save "${directory}/constructed/nontrial.dta", replace

// -------------------------------------------------------------------------------------

// Create LONG data for Diff-in-Diff
use "${directory}/constructed/analysis-ayush-panel.dta", clear

	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any med med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9

	keep qutub_id qutub_sample_updated trial_treatment trial_assignment case wave `quality'
	keep if qutub_sample_updated == 10 | qutub_sample_updated == 11
	// drop if case == 7

	gen d_treat = trial_assignment // Dummy for trial_assignment
  lab var d_treat "Assigned to Treatment"
    lab val d_treat yesno

	gen d_tot = trial_treatment // Dummy for trial_treatment
    lab var d_treat "Joined PPIA in Wave 1"
    lab val d_tot yesno

	gen d_post = wave // Dummy for before or after treatment
  	lab var d_post "Post-intervention Period"
    lab val d_post yesno

	gen d_treatXpost = d_treat * d_post // Dummy for trial_assignment X treatment
    lab var d_treatXpost "Treatment + Post-intervention"
    lab val d_treatXpost yesno

	gen d_totXpost = d_tot * d_post // Dummy for trial_treatment X treatment
    lab var d_totXpost "PPIA + Post-intervention"
    lab val d_totXpost yesno

	save "${directory}/constructed/analysis-trial-did.dta", replace


// End of dofile
