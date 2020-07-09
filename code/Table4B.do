

	//Outcomes for Case 7

	use "${directory}/constructed/analysis-ayush-panel-case-7.dta", clear

					
	local quality "dr_1 dr_4 re_1 med_any med med_l_any_2 med_l_any_3 med_k_any_9 sp7_id_1"
	
	local quality2 "dr_1 dr_4 re_1 med_any med_l_any_2 med_l_any_3 med_k_any_9 sp7_id_1"

	valuelabels `quality', name(t4) columns(8) //Create Matrix
	
	mat t4 = r(t4)

	matrix colnames t4 = "Control" "Treatment" "Effect" "Std Error" ///
						 "P-Value" "Effect" "Std Error" "P-Value"

	local row = 1

	foreach i in `quality' {
		quietly reg `i' trial_assignment, vce(cluster qutub_id) // ITT
		mat t4[`row', 3] = r(table)[1,1] //Effect
		mat t4[`row', 4] = r(table)[2,1] //Standard Error
		mat t4[`row', 5] = r(table)[4,1] //P value

		qui ivregress 2sls `i' (trial_treatment = trial_assignment), vce(cluster qutub_id) //TOT
		
		mat t4[`row', 6] = r(table)[1,1] //Effect
		mat t4[`row', 7] = r(table)[2,1] //Standard Error
		mat t4[`row', 8] = r(table)[4,1] //P value

		qui tabstat `i', by(trial_assignment) save

		mat t4[`row',1] = r(Stat1) //Mean of output of Case 7 for control groups
		mat t4[`row',2]= r(Stat2) //Mean of output of Case7 for treated groups

		local row = `row' + 1

	}
	
	local nRows `= rowsof(t4)' 
	
	forvalues i = 1/`nRows'{ //Rounding off values 
		forvalues j = 1/8{
			matrix t4[`i', `j'] = round(t4[`i',`j'], 0.001)
		}
	}

	putexcel set "${directory}/outputs/Table4B_Case7.xlsx", replace //Save results in excel

	putexcel D5 = matrix(t4), names
	forvalues  i = 5/7{
		putexcel G1`i':L1`i' = "."
	}
	putexcel E4:F4 = "Mean", merge hcenter
	putexcel H4 = "ITT"
	putexcel K4 = "TOT"
	putexcel D19:I19 = "* The last 4 indicators are all constant and equal to 0", merge
	putexcel D20:G20 = "* Std Errors clustered at individual level",merge
	putexcel G2:J2 = "Effect on quality indicators of Case7", merge hcenter bold


	forest reg /// Graph for ITT
	(`quality2') ///
		, t(trial_assignment) vce(cluster qutub_id) bh sort(global) ///
		graphopts($graph_opts ///
	xtitle("Effect of PPIA program (ITT)", size(medsmall)) ///
	xlab( -.40 "-40%" -0.2 "-20%" 0 "0%"  0.2 "20%" 0.4 "40%", labsize(medsmall)) ylab(,labsize(medsmall))) 

		
		
		graph save "${directory}/outputs/ITT-SP7.gph", replace

    forest ivregress 2sls /// Graph for TOT
	(`quality2') ///
		, t((trial_treatment = trial_assignment)) vce(cluster qutub_id) bh sort(global) ///
		graphopts($graph_opts ///
	xtitle("Effect of PPIA program (TOT)", size(medsmall)) ///
	xlab( -.40 "-40%" -0.2 "-20%" 0 "0%"  0.2 "20%" 0.4 "40%", labsize(medsmall)) ylab(,labsize(medsmall))) 
		
		graph save "${directory}/outputs/TOT-SP7.gph", replace

		graph combine ///
			"${directory}/outputs/ITT-SP7.gph" ///
			"${directory}/outputs/TOT-SP7.gph" ///
			, ysize(3) xcom altshrink rows(1) ///
			 graphregion(color(white) lwidth(large))
			

	graph export "${directory}/outputs/TOT&ITT-Case7.eps", replace
	graph export "${directory}/outputs/TOT&ITT-Case7.png", width(1000) replace

// End of dofile
