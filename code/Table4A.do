// Diff in Diff Output

  use "${directory}/constructed/analysis-trial-did.dta", clear
				 
  local quality "correct dr_1 dr_4 re_1 re_3 re_4 med_any med med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"

	valuelabels `quality', name(t2) columns(10) //Create matrix 
	
	mat t2 = r(t2)
	
    matrix colnames t2 = "Control" "Treatment" "Control" "Treatment" ///
						 "Effect" "Std Error" "P-Value" "Effect" ///
						 "Std Error" "P-Value"

  //4 groups according to wave and trial_assignment
  egen group = group(wave trial_assignment), label

 // Put statistics in matrix
  local row = 0
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

    quietly tabstat `i', by(group) save //Mean values of the 4 groups

    mat t2[`row',1] = r(Stat1)
    mat t2[`row',2] = r(Stat2)
    mat t2[`row',3] = r(Stat3)
    mat t2[`row',4] = r(Stat4)
  }

  local nRows `= rowsof(t2)'
  
  forvalues i = 1/`nRows'{ //Round off values
    forvalues j = 1/10 {
      matrix t2[`i', `j'] = round(t2[`i',`j'], 0.001)
    }
  }

  putexcel set "${directory}/outputs/Table4A_DID.xlsx", replace //Save results in excel

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

  forest ivregress 2sls /// Graph for Diff in Diff TOT
  (`quality') ///
    , t((d_totXpost d_tot  = d_treat d_treatXpost)) controls(i.case d_post) ///
    vce(cluster qutub_id) bh sort(global) ///
	graphopts(title("Diff in Diff : TOT") ///
	ylab(,notick nogrid) xlab(,notick nogrid) ///
	xtitle("Effect of treatment") ///
	graphregion(color(white) lwidth(large)))

    graph save "${directory}/outputs/Diff_in_Diff_TOT.gph", replace //Saving



  forest reg /// Graph for Diff in Diff ITT
  (`quality') ///
    , t(d_treatXpost) controls(d_treat d_post i.case) ///
    vce(cluster qutub_id) bh sort(global) ///
	graphopts(title("Diff in Diff : ITT") ///
	ylab(,notick nogrid) xlab(,notick nogrid) ///
	xtitle("Effect of treatment") ///
	graphregion(color(white) lwidth(large)))
		
    graph save "${directory}/outputs/Diff_in_Diff_ITT.gph", replace //Saving


  // ANCOVA ITT AND TOT

  use "${directory}/constructed/analysis-trial-wide.dta", clear

  unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any med med_l_any_2 ///
           med_l_any_3 med_k_any_9


  forest reg /// Graph for ITT usig ANCOVA
  (`quality') ///
    , t(trial_assignment) controls(i.case @0) ///
    vce(cluster qutub_id) bh sort(global) ///
	graphopts(title("ANCOVA : ITT") ///
	ylab(,notick nogrid) xlab(,notick nogrid) ///
	xtitle("Effect of treatment") ///
	graphregion(color(white) lwidth(large)))

    graph save "${directory}/outputs/ANCOVA_ITT.gph", replace

    forest ivregress 2sls /// Graph for TOT using ANCOVA
  (`quality') ///
    , t((trial_treatment = trial_assignment)) controls(i.case @0) ///
    vce(cluster qutub_id) bh sort(global) ///
	graphopts(title("ANCOVA : TOT") ///
	ylab(,notick nogrid) xlab(,notick nogrid) ///
	xtitle("Effect of treatment") ///
	graphregion(color(white) lwidth(large)))

    graph save "${directory}/outputs/ANCOVA_TOT.gph", replace //Saving

    graph combine ///
      "${directory}/outputs/Diff_in_Diff_ITT.gph" ///
      "${directory}/outputs/Diff_in_Diff_TOT.gph" ///
      "${directory}/outputs/ANCOVA_ITT.gph" ///
      "${directory}/outputs/ANCOVA_TOT.gph", xcommon ysize(6) altshrink ///
	  graphregion(color(white) lwidth(large))

    graph export "${directory}/outputs/DID_ANCOVA_Combine.eps", replace

// End of dofile
