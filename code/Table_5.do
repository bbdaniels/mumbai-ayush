
	//Time trend in the non-trial group
	
	use "${directory}/constructed/table_3.dta", clear

	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any med med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9
				   
	local quality1 "correct dr_1 dr_4 re_1 re_3 re_4 med_any med med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"

	forest reg /// Graph for difference across rounds in non-trial group
	(`quality') ///
		, t(wave) controls(i.check i.case) ///
		vce(cluster qutub_id)
		
	valuelabels `quality1', name(t5) columns(5) //Construct a matrix

	local row = 1

	foreach i in `quality'{
		quietly reg `i'  wave i.check i.case, vce(cluster qutub_id)

		mat t5[`row', 3] = r(table)[1,1] //Regression Estimate
		mat t5[`row', 4] = r(table)[2,1] //Standard Error
		mat t5[`row', 5] = r(table)[4,1] //P-value


		quietly tabstat `i', by(wave) save

		mat t5[`row',1] = r(Stat1)
		mat t5[`row',2] = r(Stat2)
		
		local row =`row' + 1

	}

	 foreach i in `quality' { //Saving value labels
		local lbl`i': variable label `i'
	}

	matrix rownames t5 = `rowNames'
	matrix colnames t5 = "Mean(Baseline)" "Mean(Endline)" "Regression Estimate" "Std Error" "P-value"


	local nRows `= rowsof(t5)'
	
	forvalues i = 1/`nRows'{ //Round off values
		forvalues j = 1/5{
			matrix t5[`i', `j'] = round(t5[`i',`j'], 0.001)
		}
	}

	putexcel set "${directory}/outputs/Table_5.xlsx", replace //Save results in excel

	putexcel D7 = matrix(t5), names
	
// End of dofile
