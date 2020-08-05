// Tables

// Table 1B. Case interactions for the 4 provider samples by round
use "${directory}/constructed/analysis-ayush-panel.dta", clear

  egen type = group(wave qutub_sample_updated) , label
  tabout type case using "${directory}/outputs/tab-1b.xls" , replace

// Table 2. Baseline-endline changes for Observational Cohort
use "${directory}/constructed/nontrial.dta", clear

  rctreg ///
    correct dr_1 dr_4 re_1 re_3 re_4 ///
    med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
  using "${directory}/outputs/tab-2.xlsx" ///
  , treatment(wave) controls(i.case i.check) ///
    sd p format(%-9.3f) cl(qutub_id)

// Table 3. Baseline balance for Experimental Cohort
use "${directory}/constructed/analysis-ayush-panel.dta", clear
  keep if wave == 0 // use baseline only

  //Create only yesno values for some variables
	foreach var of varlist g_6-g_10 {
		recode `var' (1 2 = 0)(3 = 1)
	}

	unab balance : cp_17_* cp_18 cp_21
	unab process : g_1 g_2 g_3 g_4 g_5 g_6 g_7 g_8 g_9 g_10
	unab quality : correct* dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9

  rctreg ///
    `balance' `quality' `process' ///
  using "${directory}/outputs/tab-3.xlsx" ///
  , treatment(trial_assignment) controls(i.case) ///
    sd p format(%-9.3f) cl(qutub_id)

// Table 4. Difference-in-differences PPIA impact estimates
use "${directory}/constructed/analysis-trial-did.dta", clear

   rctreg ///
     correct dr_1 dr_4 re_1 re_3 re_4 ///
     med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
   using "${directory}/outputs/tab-4.xlsx" ///
   , treatment(d_treatXpost) controls(i.trial_assignment i.case i.wave) ///
     sd p format(%-9.3f) cl(qutub_id) iv(d_totXpost)

// End of do-file
