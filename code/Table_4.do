

	//Outocomes for Case 7 
	
	use "${directory}/constructed/table_4.dta", clear 
						 		
	mat t4=J(12,8,0) //Constructing a matrix 
			  
	unab quality :  dr_1 dr_4 re_1 med_any polypharmacy med_l_any_2 ///
				    med_l_any_3 med_k_any_9 
	 
	 foreach i in `quality' { //Saving value labels 
		local lbl`i': variable label `i'
	}	
	
	matrix rownames t4 = "`lbldr_1'"  "`lbldr_4'" "`lblre_1'"  ///
						 "`lblmed_any'" "`lblpolypharmacy'" "`lblmed_l_any_2'"  "`lblmed_l_any_3'" ///
						 "`lblmed_k_any_9'" "Correct Management" "Sputum AFB" "Gene Expert" "Started TB Treatment"
	 
	matrix colnames t4 = "Control" "Treatment" "Effect" "Std Error" "P-Value" "Effect" "Std Error" "P-Value" 		
	
	local row = 1  
	
	foreach i in `quality' {
		quietly reg `i' trial_assignment, vce(cluster qutub_id) // ITT 
		mat t4[`row', 3] = r(table)[1,1] //Effect
		mat t4[`row', 4] = r(table)[2,1] //Standard Error
		mat t4[`row', 5] = r(table)[4,1] //P value 
		
		quietly ivregress 2sls `i' (trial_treatment = trial_assignment), vce(cluster qutub_id) //TOT 
		mat t4[`row', 6] = r(table)[1,1] //Effect
		mat t4[`row', 7] = r(table)[2,1] //Standard Error 
		mat t4[`row', 8] = r(table)[4,1] //P value 
		
		quietly tabstat `i', by(trial_assignment) save 
		
		mat t4[`row',1] = r(Stat1) //Mean of output of Case 7 for control groups 
		mat t4[`row',2]= r(Stat2) //Mean of output of Case7 for treated groups 
		
		local row = `row' + 1

	}
	
	forvalues i = 1/12{ //Rounding off 
		forvalues j = 1/8{
			matrix t4[`i', `j'] = round(t4[`i',`j'], 0.001)
		}
	}
	
	putexcel set "${directory}/outputs/Table_4.xlsx", replace //Saving results in excel 
	
	putexcel D5 = matrix(t4), names 
	forvalues  i = 4/7{
		putexcel G1`i':L1`i' = "."
	}
	putexcel E4:F4 = "Mean", merge hcenter
	putexcel H4 = "ITT"
	putexcel K4 = "TOT"
	putexcel D19:I19 = "* The last 4 indicators are all constant and equal to 0", merge
	putexcel D20:G20 = "* Std Errors clustered at individual level",merge 
	putexcel G2:J2 = "Effect on quality indicators of Case7", merge hcenter bold 

				   
	forest reg /// Graph for ITT
	(`quality') ///
		, t(trial_assignment) ///
		vce(cluster qutub_id) bh graphopts(title("ITT-SP7")) sort(global)
		
		graph save "${directory}/outputs/ITT-SP7.gph", replace
		
		
    forest ivregress 2sls /// Graph for TOT
	(`quality') ///
		, t((trial_treatment = trial_assignment)) ///
		vce(cluster qutub_id) bh graphopts(title("TOT-SP7")) sort(global)
		
		graph save "${directory}/outputs/TOT-SP7.gph", replace
		
		graph combine ///
			"${directory}/outputs/ITT-SP7.gph" ///
			"${directory}/outputs/TOT-SP7.gph" ///
			, ysize(6) xcom altshrink c(1)
	
		
	graph export "${directory}/outputs/TOT&ITT-Case7.eps", replace 
	
------------	
	//Outocomes for Case 7 with Case 1 Outcomes as treatment

	
	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9 
				   
	foreach i in `quality' {
		reg `i' `i'_1, vce(cluster qutub_id)
	}
	
	mat t5=J(12,3,0)
	 
	 foreach i in `quality' {
		local lbl`i': variable label `i'
	}	
	
	matrix rownames t5 = "`lblcorrect'" "`lbldr_1'"  "`lbldr_4'" "`lblre_1'"  "`lblre_3'" "`lblre_4'" ///
						 "`lblmed_any'" "`lblpolypharmacy'"  "`lblmed_l_any_1'" "`lblmed_l_any_2'"  "`lblmed_l_any_3'" ///
						 "`lblmed_k_any_9'"  
	 
	 
	matrix colnames t5 = "Effect" "Std Error" "P-Value" 
	local row = 1  
	
	foreach i in `quality' {
		quietly reg `i' `i'_1, vce(cluster qutub_id)
		mat t5[`row', 1] = r(table)[1,1]
		mat t5[`row', 2] = r(table)[2,1]
		mat t5[`row', 3] = r(table)[4,1]
		
		local row = `row' + 1

	}
	
	forvalues i = 1/12{
		forvalues j = 1/3{
			matrix t5[`i', `j'] = round(t5[`i',`j'], 0.001)
		}
	}
	
	putexcel set "${directory}/outputs/Table_5.xlsx", replace 
	
	putexcel D5 = matrix(t5), names 
	
	putexcel D5:D17, hcenter bold fpattern(solid, "192 192 192") border(right, medium) 
	putexcel D5:D17, border(left, medium)
	putexcel D5:G5, hcenter bold fpattern(solid, "192 192 192") border(top, medium) 
	putexcel D5:G5, border(bottom, medium)
	putexcel G5:G17, border(right, medium)
	putexcel D17:G17, border(bottom, medium)
	
	putexcel C2:I2 = "SP-7 Outcomes with SP-1 Outcomes in Wave 1 as Control", merge bold underline font(calibri,14)
	
	
	forest reg /// Forest for ITT
	(`quality') ///
		, t(@_1) /// 
		vce(cluster qutub_id) bh graphopts(title("SP7 with outcome of SP1 as a control")) sort(global) //DOUBTTTTTT Include trial_assignment as control???? 
		
		graph export "${directory}/outputs/SP7 with SP1 as control.eps", replace
	
	
	//Outocomes for Case 1 in wave 1 with Case 1 Outcomes in wave 0 as control
	
	use "${directory}/constructed/sp_analysis.dta", clear 
	
	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9 


	preserve 
		keep if case == 1 & wave == 0 
		foreach i in `quality' {
			rename `i' `i'_0
		}
		save "${directory}/constructed/case1_0.dta", replace
	restore 
	
	keep if case == 1 & wave == 1
	
	merge 1:1 qutub_id using "${directory}/constructed/case1_0.dta"
	
	mat t6=J(12,3,0)
	 
	 foreach i in `quality' {
		local lbl`i': variable label `i'
	}	
	
	matrix rownames t6 = "`lblcorrect'" "`lbldr_1'"  "`lbldr_4'" "`lblre_1'"  "`lblre_3'" "`lblre_4'" ///
						 "`lblmed_any'" "`lblpolypharmacy'"  "`lblmed_l_any_1'" "`lblmed_l_any_2'"  "`lblmed_l_any_3'" ///
						 "`lblmed_k_any_9'"  
	 
	 
	matrix colnames t6 = "Effect" "Std Error" "P-Value" 
	local row = 1  
	
	foreach i in `quality' {
		quietly reg `i' `i'_0, vce(cluster qutub_id)
		mat t6[`row', 1] = r(table)[1,1]
		mat t6[`row', 2] = r(table)[2,1]
		mat t6[`row', 3] = r(table)[4,1]
		
		local row = `row' + 1

	}
	
	forvalues i = 1/12{
		forvalues j = 1/3{
			matrix t6[`i', `j'] = round(t6[`i',`j'], 0.001)
		}
	}
	
	putexcel set "${directory}/outputs/Table_6.xlsx", replace 
	
	putexcel D5 = matrix(t6), names 
	
	putexcel D5:D17, hcenter bold fpattern(solid, "192 192 192") border(right, medium) 
	putexcel D5:D17, border(left, medium)
	putexcel D5:G5, hcenter bold fpattern(solid, "192 192 192") border(top, medium) 
	putexcel D5:G5, border(bottom, medium)
	putexcel G5:G17, border(right, medium)
	putexcel D17:G17, border(bottom, medium)
	
	putexcel C2:H2 = "SP-7 Outcomes with SP-1 Outcomes in Wave 0 as Control", merge bold underline font(calibri,13.5)
	
	
		forest reg /// Forest for ITT
	(`quality') ///
		, t(@_0) ///
		vce(cluster qutub_id) bh graphopts(title("SP1 with Wave-0 SP1 as control")) sort(global)
		
	graph export "${directory}/outputs/SP1 with Wave-0 SP1 as control.eps", replace
		
