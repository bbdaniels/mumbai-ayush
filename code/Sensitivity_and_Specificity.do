	
	use "${directory}/constructed/fig_4.dta", clear

	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9
				   
	local nRows = 0
    foreach i in `quality' {
      local ++nRows
	  local lbl`i': variable label `i'
    }

    mat x = J(`nRows',3,0)
	matrix colnames x = "Sensitivity" "Specificity" "_n"
	
	local row = 1 
	foreach i in `quality'{
		tab `i'0 `i', matcell(`i')
		mat x[`row', 1] = `i'[2,2]/(`i'[1,2]+ `i'[2,2])
		mat x[`row', 2] = `i'[2,1]/(`i'[1,1]+ `i'[2,1])
		mat x[`row', 3] = `row'
		local ++row
	}
	
	
	gen sensitivity = x[_n,1] in 1/`nRows' 
	gen specificity = x[_n,2] in 1/`nRows' 
	gen quality_indicators = case1[_n,3] in 1/`nRows' 
	
	label define lblindicator 1 "`lblcorrect'" 2 "`lbldr_1'" 3 "`lbldr_4'" ///
	4 "`lblre_1'" 5  "`lblre_3'" 6 "`lblre_4'" 7 "`lblmed_any'" ///
	8 "`lblmed_l_any_1'" 9 "`lblmed_l_any_2'" 10 "`lblmed_l_any_3'" ///
	11 "`lblmed_k_any_9'"
	label values quality_indicators lblindicator 

	  tw ///
	   (scatter quality_indicators sensitivity, ylabel(1 2 3 4 5 6 7 8 9 10 11, valuelabel)) ///
	   || scatter quality_indicators specificity, ylabel(, angle(0)) ///
	   legend(on order(1 "Sensitivity" 2 "Specificity")) ///
	   yscale(reverse noline) xscale(noline) ylab(,notick)
	
	
	
	
	
	
