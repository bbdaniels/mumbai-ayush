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

	save "${directory}/constructed/sp-wave-1.dta" , replace

// Append --------------------------------------------------------------------------------------
	use "${directory}/constructed/sp-wave-0.dta"


	qui append using ///
	"${directory}/constructed/sp-wave-1.dta" ///
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

// Creating data for Diff in Diff and ANCOVA

	use "${directory}/constructed/sp_both.dta", clear

	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9

	keep qutub_id qutub_sample_updated trial_treatment trial_assignment case wave `quality'
	keep if qutub_sample_updated == 10 | qutub_sample_updated == 11
	drop if case == 7

	save "${directory}/constructed/sp_analysis.dta", replace

//Creating data for Diff in Diff
	use "${directory}/constructed/sp_analysis.dta", clear

	gen d_treat = 0 if trial_assignment == 0 // Creating dummy for trial_assignment
	replace d_treat = 1 if trial_assignment == 1

	gen d_tot = 0 if trial_treatment == 0 // Creating dummy for trial_treatment
	replace d_tot = 1 if trial_treatment == 1

	gen d_post = 0 if wave == 0  // Creating dummy for before or after treatment
	replace d_post = 1 if wave == 1

	gen d_treatXpost = d_treat * d_post //Creating dummy for trial_assignment X treatment

	gen d_totXpost = d_tot * d_post // Creating dummy for trial_treatment X treatment

	save "${directory}/constructed/sp_diff_in_diff.dta", replace

//Creating data for ANCOVA

	use "${directory}/constructed/sp_analysis.dta", clear

	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_2 ///
				   med_l_any_3 med_k_any_9

	local j = 1 //Saving label variables
	foreach i in `quality'{
		local x`j' : variable label `i'
		local j = `j' + 1
	}


	egen unique_id = concat(qutub_id case wave) //Creating a unique id
	egen tag = tag(unique_id)
	drop if tag == 0
	drop unique_id tag med_l_any_1

	reshape wide correct dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_2 ///
				   med_l_any_3 med_k_any_9 qutub_sample_updated trial_assignment trial_treatment ///
					, i(qutub_id case) j (wave)


	rename trial_assignment0 trial_assignment // Keeping only one trial_assignment
	rename trial_treatment0 trial_treatment
	drop trial_assignment1 trial_treatment1



	unab quality1: correct1 dr_11 dr_41 re_11 re_31 re_41 med_any1 polypharmacy1 med_l_any_21 ///
				   med_l_any_31 med_k_any_91

	rename (`quality1') (`quality') //Renaming lagged variables to include in forest

	local j = 1 //Providing value labels
	foreach i in `quality' {
		label variable `i' "`x`j''"
		local j = `j' + 1
	}

	save "${directory}/constructed/sp_ancova.dta", replace //Saving data for ANCOVA analysis

//Creating data for Fig_3

	use "${directory}/constructed/sp_both.dta", clear

	keep if qutub_sample_updated == 10 | qutub_sample_updated == 11

	keep if wave == 1

	keep if case == 1| case == 7

	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9


	local j = 1 //Saving value labels
	foreach i in `quality'{
		local x`j' : variable label `i'
		local j = `j' + 1
	}

	keep qutub_id qutub_sample_updated trial_treatment trial_assignment case  `quality'

	reshape wide correct dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_1 med_l_any_2 /// Converting data to wide
				   med_l_any_3 med_k_any_9 qutub_sample_updated trial_assignment trial_treatment ///
					, i(qutub_id) j (case)

	unab quality7: correct7 dr_17 dr_47 re_17 re_37 re_47 med_any7 polypharmacy7 med_l_any_17 med_l_any_27 ///
				   med_l_any_37 med_k_any_97

	rename (`quality7') (`quality')

	local j = 1 //Providing value labels
	foreach i in `quality' {
		label variable `i' "`x`j''"
		local j = `j' + 1
	}

	save "${directory}/constructed/fig_3.dta", replace //Saving data for fig3

 // Creating data for Fig_4


	use "${directory}/constructed/sp_both.dta", clear

	keep if qutub_sample_updated == 10 | qutub_sample_updated == 11

	keep if case == 1

	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9


	local j = 1 //Saving value labels
	foreach i in `quality'{
		local x`j' : variable label `i'
		local j = `j' + 1
	}


	keep qutub_id qutub_sample_updated trial_treatment trial_assignment wave `quality'

	reshape wide correct dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_1 med_l_any_2 /// Converting data to wide
				   med_l_any_3 med_k_any_9 qutub_sample_updated trial_assignment trial_treatment ///
					, i(qutub_id) j (wave)

	unab quality1: correct1 dr_11 dr_41 re_11 re_31 re_41 med_any1 polypharmacy1 med_l_any_11 med_l_any_21 ///
				   med_l_any_31 med_k_any_91

	rename (`quality1') (`quality')

	local j = 1 // Providing value labels
	foreach i in `quality' {
		label variable `i' "`x`j''"
		local j = `j' + 1
	}

	save "${directory}/constructed/fig_4.dta", replace

// Creating data for analysis of non-trial groups/table_3

	use "${directory}/constructed/sp_both.dta", clear

	keep if qutub_sample_updated == 8 | qutub_sample_updated == 9

	drop if case == 7

	gen d_t = (wave == 0 & ppia_facility_0 == 1)  | (wave == 1 & ppia_facility_1 == 1)

	egen check = group(ppia_facility_0 ppia_facility_1), label

	save "${directory}/constructed/table_3.dta", replace

// Creating data for analysis of Case-7/table_4

	use "${directory}/constructed/sp_both.dta", clear

	keep if qutub_sample_updated == 10 | qutub_sample_updated == 11

	keep if case == 7

	save "${directory}/constructed/table_4.dta", replace
---

iecodebook export ///
  using "${directory}/constructed/sp-ayush.dta" ///
  , copy hash reset replace text


// End of dofile
