
	 use "${directory}/constructed/analysis-trial-did.dta", clear

	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any med med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9


	//Table 2

	 mat t2=J(12,10,0) //Constructing a matrix to save results in

	 foreach i in `quality' { //Saving value labels
		local lbl`i': variable label `i'
	}

	matrix rownames t2 = "`lblcorrect'" "`lbldr_1'"  "`lbldr_4'" "`lblre_1'"  "`lblre_3'" "`lblre_4'" ///
						 "`lblmed_any'" "`lblmed'"  "`lblmed_l_any_1'" "`lblmed_l_any_2'"  "`lblmed_l_any_3'" ///
						 "`lblmed_k_any_9'"

	matrix colnames t2 = "Control" "Treatment" "Control" "Treatment" "Effect" "Std Error" "P-Value" "Effect" "Std Error" "P-Value"

	 local row = 0

	 egen group = group(wave trial_assignment), label //4 groups according to wave and trial_assignment

	 foreach i in `quality' {

		local row = `row' + 1

		quietly reg `i' d_treatXpost d_treat d_post i.case, vce(cluster qutub_id) //Diff in Diff ITT

		mat t2[`row', 5] = _b[d_treatXpost] //Effect
		mat t2[`row', 6] = _se[d_treatXpost] //Standard Error
		mat t2[`row', 7] = 2*ttail(e(df_r), abs(_b[d_treatXpost]/_se[d_treatXpost])) //P-value

		quietly ivregress 2sls `i'  (d_totXpost d_tot  = d_treat d_treatXpost) d_post i.case, vce(cluster qutub_id) //Diff in Diff TOT

		mat t2[`row', 8] = _b[d_totXpost] //Effect
		mat t2[`row', 9] = _se[d_totXpost] //Standard Error
		mat t2[`row', 10] =  2*normal(-abs(_b[d_totXpost]/_se[d_totXpost])) //P value

		quietly tabstat `i', by(group) save //Means of the 4 groups

		mat t2[`row',1] = r(Stat1)
		mat t2[`row',2] = r(Stat2)
		mat t2[`row',3] = r(Stat3)
		mat t2[`row',4] = r(Stat4)
	 }

	forvalues i = 1/12{ //Rounding off values
		forvalues j = 1/10 {
			matrix t2[`i', `j'] = round(t2[`i',`j'], 0.001)
		}
	}

	putexcel set "${directory}/outputs/Table_2.xlsx", replace //Saving results in excel

	putexcel D7=matrix(t2), names

	putexcel E6:F6 = "Wave-0" ///
		, merge hcenter font(calibri,13) bold underline

	putexcel G6:H6 = "Wave-1" ///
		, merge hcenter font(calibri,13) bold underline

	putexcel I6:K6 = "ITT" ///
		, merge hcenter font(calibri,13) bold underline

	putexcel L6:N6 = "TOT" ///
		, merge hcenter font(calibri,13) bold underline

	putexcel E4:M4 = "Effect of PPIA on quality indicators using Difference in Difference", merge hcenter font(calibri,14) bold underline

	putexcel D21:H21 = "* Std Errors clustered at individial level", merge
	putexcel D22:F22 = "* Controlled for SP Case", merge

	set scheme uncluttered

	forest ivregress 2sls /// Graph for Diff in Diff TOT
	(`quality') ///
		, t((d_totXpost d_tot  = d_treat d_treatXpost)) controls(i.case d_post) ///
		vce(cluster qutub_id) bh graphopts(title("Diff in Diff : TOT")) sort(global)

		graph save "${directory}/outputs/Diff_in_Diff_TOT.gph", replace //Saving


	forest reg /// Graph for Diff in Diff ITT
	(`quality') ///
		, t(d_treatXpost) controls(d_treat d_post i.case) ///
		vce(cluster qutub_id) bh graphopts(title("Diff in Diff : ITT")) sort(global)

		graph save "${directory}/outputs/Diff_in_Diff_ITT.gph", replace //Saving


	// ANCOVA ITT AND TOT

	use "${directory}/constructed/analysis-trial-wide.dta", clear

	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any med med_l_any_2 ///
				   med_l_any_3 med_k_any_9


	forest reg /// Graph for ITT usig ANCOVA
	(`quality') ///
		, t(trial_assignment) controls(i.case @0) ///
		vce(cluster qutub_id) bh graphopts(title("ANCOVA : ITT")) sort(global)

		graph save "${directory}/outputs/ANCOVA_ITT.gph", replace

    forest ivregress 2sls /// Graph for TOT using ANCOVA
	(`quality') ///
		, t((trial_treatment = trial_assignment)) controls(i.case @0) ///
		vce(cluster qutub_id) bh graphopts(title("ANCOVA : TOT")) sort(global)

		graph save "${directory}/outputs/ANCOVA_TOT.gph", replace //Saving

		graph combine ///
			"${directory}/outputs/Diff_in_Diff_ITT.gph" ///
			"${directory}/outputs/Diff_in_Diff_TOT.gph" ///
			"${directory}/outputs/ANCOVA_ITT.gph" ///
			"${directory}/outputs/ANCOVA_TOT.gph" , xcommon ysize(6) altshrink

		graph export "${directory}/outputs/DID_ANCOVA_Combine.eps", replace

// End of dofile
