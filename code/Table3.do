	
	// Creating Balance Tables and Graphs

	use "${directory}/constructed/analysis-ayush-panel.dta", clear

  // Transform Analysis Variables
	foreach var of varlist g_6-g_10 {
		recode `var' (1 2 = 0)(3 = 1) //Create only yesno values for these variables
	}

	separate correct, by(case) // Calculate correct management by cases

	forvalues i= 1/4  {
		label variable correct`i' Case`i'
	}

	drop correct7

	clonevar cb1 = correct if cp_18 == 1 //Indicator for correct management and male provider
	clonevar cb2 = correct if cp_18 == 0 //Indicator for correct management and female provider

	label variable cb1 "Male Provider & Correct Manag."
	label variable cb2 "Female Provider & Correct Manag."

	keep if wave == 0

	unab Balance : cp_17_* cp_18 cp_19 cp_20 cp_21 
	unab Process : g_* cp_14d_mm checklist_essential_pct
	unab Quality : correct* cb* dr_1 dr_4 re_1 re_3 re_4 med_any med med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9
					
	 // Create balance table graphs 
	foreach i in Balance Process Quality {
		forest reg ///
		(``i'' ) ///
		, t(trial_assignment)  controls(i.case) vce(cluster qutub_id) ///
		graphopts(xtitle("") ylab(,notick nogrid labsize(vsmall)) ///
		title("{bf:`i' Indicators}", position(11) size(small)) ///
		xlab(, labsize(vsmall)) graphregion(color(white) lwidth(large)) ///
		xtit("{&larr} Favors Control    Favors Treated {&rarr}",size(vsmall))) 

			graph save "${directory}/outputs/`i'.gph", replace 
	}
	
	graph combine ///
		"${directory}/outputs/Balance.gph" ///
		"${directory}/outputs/Process.gph" ///
		"${directory}/outputs/Quality.gph", ///
		xcommon ysize(10)  cols(1) ///
		graphregion(color(white) lwidth(large))
	
	graph export "${directory}/outputs/Balance_graphs.eps", replace 
	
	foreach i in Balance Process Quality{ // Create balance tables 
		iebaltab ``i' ' ///
			, grpvar(trial_assignment) control(1) covariates(i.case) vce(cluster qutub_id) ///
					replace rowvarlabel ///
						save("${directory}/outputs/Table3_`i'.xlsx")
		}
	
	//End of dofile
	
