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

// Cleaning ------------------------------------------------------------------------------------

	drop sample
	keep if qutub_sample > 6 // Keeping only AYUSH samples

	lab var correct "Correct"
	lab var dr_4 "Referral"

	label define case 7 "SP7", add
	label values case case

	label define trial_assignment 0 control 1 treatment
	label values trial_assignment trial_assignment

// New variables -------------------------------------------------------------------------------

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
	label variable correct "Correct Management"

// Save -------------------------------------------------------------------------------
  compress
	save "${directory}/constructed/analysis-ayush-panel.dta" , replace

// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------

// Create LONG data for Diff-in-Diff
use "${directory}/constructed/analysis-ayush-panel.dta", clear

	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any med med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9

	keep qutub_id qutub_sample_updated trial_treatment trial_assignment case wave `quality'
	keep if qutub_sample_updated == 10 | qutub_sample_updated == 11
	drop if case == 7

	save "${directory}/constructed/analysis-trial-panel.dta", replace

// Create data for Diff-in-Diff ------------------------------------------------
use "${directory}/constructed/analysis-trial-panel.dta", clear

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

// Creating WIDE data for analysis with lags ------------------------------------
use "${directory}/constructed/analysis-trial-panel.dta", clear

	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any med med_l_any_1 med_l_any_2 ///
	  med_l_any_3 med_k_any_9

	foreach i in `quality' trial_assignment trial_treatment qutub_sample_updated {
		local `i' : variable label `i'
	}

  duplicates drop qutub_id case wave , force // 1 extra observation

	reshape wide ///
    `quality' qutub_sample_updated trial_assignment trial_treatment ///
		, i(qutub_id case) j(wave)

	unab quality1: correct1 dr_11 dr_41 re_11 re_31 re_41 med_any1 med1 med_l_any_11 med_l_any_21 ///
    med_l_any_31 med_k_any_91

	rename (`quality1') (`quality') // Rename Round 1 variables -- Round 0 have "0" suffix

  // Keep only one trial assignment
	rename trial_assignment1 trial_assignment
	rename trial_treatment1 trial_treatment
	drop trial_assignment0 trial_treatment0

  // Keep only one qutub_sample_updated
	rename qutub_sample_updated1 qutub_sample_updated
	drop qutub_sample_updated0

	foreach i in `quality' trial_assignment trial_treatment qutub_sample_updated {
		label variable `i' "``i''"
		cap label variable `i'0 "``i'' (Lag)"
	}

  drop med_l_any_1*
  compress
	save "${directory}/constructed/analysis-trial-wide.dta", replace // Saving data for lagged-variables analysis

//Creating data for Fig_2B: Case 1 + 7 sensitivity and specificity 
use "${directory}/constructed/analysis-ayush-panel.dta", clear

	keep if wave == 1 & (case == 1 | case == 7)

	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any med med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9

	local j = 1 //Saving value labels
	foreach i in `quality'{
		local x`j' : variable label `i'
		local j = `j' + 1
	}

	keep qutub_id qutub_sample_updated trial_treatment trial_assignment case  `quality'

	reshape wide correct dr_1 dr_4 re_1 re_3 re_4 med_any med med_l_any_1 med_l_any_2 /// Converting data to wide
				   med_l_any_3 med_k_any_9 qutub_sample_updated trial_assignment trial_treatment ///
					, i(qutub_id) j (case)

	unab quality7: correct7 dr_17 dr_47 re_17 re_37 re_47 med_any7 med7 med_l_any_17 med_l_any_27 ///
				   med_l_any_37 med_k_any_97
				   

	rename (`quality7') (`quality')
	
	local j = 1 //Provide value labels
	foreach i in `quality' {
		label variable `i' "`x`j''"
		local j = `j' + 1
	}

	save "${directory}/constructed/fig_2B.dta", replace //Saving data for fig3

// Creating data for Fig_2A: Case 1 sensitivity and specificity
use "${directory}/constructed/analysis-ayush-panel.dta", clear

	keep if (case == 1)

	unab quality : checklist correct dr_1 dr_4 re_1 re_3 re_4 med_any med med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9

	local j = 1 //Save value labels
	foreach i in `quality'{
		local x`j' : variable label `i'
		local j = `j' + 1
	}

	keep checklist qutub_id qutub_sample_updated trial_treatment trial_assignment wave `quality'

	reshape wide checklist correct dr_1 dr_4 re_1 re_3 re_4 med_any med med_l_any_1 med_l_any_2 /// Convert data to wide
				   med_l_any_3 med_k_any_9 qutub_sample_updated trial_assignment trial_treatment ///
					, i(qutub_id) j (wave)

	unab quality1: checklist1 correct1 dr_11 dr_41 re_11 re_31 re_41 med_any1 med1 med_l_any_11 med_l_any_21 ///
				   med_l_any_31 med_k_any_91

	rename (`quality1') (`quality')

	local j = 1 // Provide value labels
	foreach i in `quality' {
		label variable `i' "`x`j''"
		local j = `j' + 1
	}

  save "${directory}/constructed/fig_2A.dta", replace

// Creating data for analysis of non-trial groups

	use "${directory}/constructed/analysis-ayush-panel.dta", clear

	keep if qutub_sample_updated == 8 | qutub_sample_updated == 9

	drop if (case == 7)

	gen d_t = (wave == 0 & ppia_facility_0 == 1)  | (wave == 1 & ppia_facility_1 == 1)
    lab var d_t "PPIA in Round"
    lab val d_t yesno

	egen check = group(ppia_facility_0 ppia_facility_1), label

	save "${directory}/constructed/nontrial.dta", replace

// Creating data for analysis of Case-7

	use "${directory}/constructed/analysis-ayush-panel.dta", clear

	keep if qutub_sample_updated == 10 | qutub_sample_updated == 11

	keep if case == 7

	save "${directory}/constructed/analysis-ayush-panel-case-7.dta", replace

// End of dofile
