
	 use "${directory}/constructed/fig_4.dta", clear

	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9

	foreach i in `quality' { //Saving value labels
		local lbl`i': variable label `i'
	}

	mat case1=J(11,3,0) //Constructing a matrix to save results in

	matrix rownames case1 = "`lblcorrect'" "`lbldr_1'"  "`lbldr_4'" "`lblre_1'"  "`lblre_3'" "`lblre_4'" ///
						 "`lblmed_any'" "`lblmed_l_any_1'" "`lblmed_l_any_2'"  "`lblmed_l_any_3'" ///
						 "`lblmed_k_any_9'"

	matrix colnames case1 = "Incorrect" "Correct" "_n"

	local row =1

	foreach i in `quality'{
		tabstat `i', by(`i'0) save
		mat case1[`row', 1] = r(Stat1) //Mean of output of case1(wave-1) when incorrect output in case1(eave-0)
		mat case1[`row', 2] = r(Stat2) //Mean of output of case1(wave-1) when correct output in case1(eave-0)
		mat case1[`row', 3] = `row'

	local row =`row' + 1
	}


	forvalues i = 1/11{ //Rounding off values in the matrix
		forvalues j = 1/2{
			matrix case1[`i', `j'] = round(case1[`i',`j'], 0.001)
		}
	}


	  gen incorret_case = case1[_n,1] in 1/12 //Storing column-1 values of the matrix
	  gen correct_case = case1[_n,2] in 1/12 //Storing column-2 values of the matrix
	  gen quality_indicators = case1[_n,3] in 1/12 //Storing column-3 values of the matrix


	  label define lblindicator 1 "`lblcorrect'" 2 "`lbldr_1'" 3 "`lbldr_4'" 4 "`lblre_1'" 5  "`lblre_3'" 6 "`lblre_4'" ///
						7 "`lblmed_any'" 8 "`lblmed_l_any_1'" 9 "`lblmed_l_any_2'" 10 "`lblmed_l_any_3'" ///
						11 "`lblmed_k_any_9'"
	  label values quality_indicators lblindicator //Value labels for quality_indicators


	  tw /// Construct Figure 4
      (scatter quality_indicators incorret_case, mc(black) msize(*2) ylabel(1 2 3 4 5 6 7 8 9 10 11, valuelabel)) ///
      (pcarrow quality_indicators incorret_case quality_indicators correct_case , lw(thin) lc(black) mc(black)) ///
    , ytitle("") ///
      legend(on order(1 "Not Observed in Wave 0" 2 "Observed in Wave 0")) yscale(reverse noline) xscale(noline) ylab(,notick)

	  graph export "${directory}/outputs/Consistency_Case1.eps", replace //Exporting Fig_4

	  
	  
	   tw ///
	   (scatter quality_indicators incorret_case, /*mc(black) msize(*2*/ ylabel(1 2 3 4 5 6 7 8 9 10 11 12, valuelabel)) ///
	   || scatter quality_indicators correct_case , legend(order(1 	"Incorrect" 2 "Correct"))||  pcarrow quality_indicators incorret_case quality_indicators correct_case, ytitle("Quality Indicators") title("Difference in Case7 Outputs") //Fig_3
// End of dofile
