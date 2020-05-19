	
	
	use "${directory}/constructed/fig_4.dta", clear

	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any  ///
		med_l_any_2 med_l_any_3 med_k_any_9
				   
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
		mat x[`row', 2] = `i'[1,1]/(`i'[1,1]+ `i'[2,1])
		mat x[`row', 3] = `row'
		local ++row
	}
	
	
	forvalues i = 1/`nRows'{ //Rounding off values in the matrix
		forvalues j = 1/2{
			matrix x[`i', `j'] = round(x[`i',`j'], 0.01)
		}
	}
	
	svmat float x , names(matcol)
	
	label define lblindicator 1 "`lblcorrect'" 2 "`lbldr_1'" 3 "`lbldr_4'" ///
	4 "`lblre_1'" 5  "`lblre_3'" 6 "`lblre_4'" 7 "`lblmed_any'" ///
	8 "`lblmed_l_any_2'" 9 "`lblmed_l_any_3'" ///
	10 "`lblmed_k_any_9'"
	label values x_n lblindicator 

	
	graph hbar xSensitivity xSpecificity  , ///
		over(x_n, label(labsize(small))) blabel(bar) intensity(50) /// 
		legend(order(1 "Sensitivity" 2 "Specificity")) legend(size(small)) ///
		ylab(,notick nogrid) ///
		graphregion(color(white) lwidth(large))
	
	graph export "${directory}/outputs/fig2A.png", replace
	
	// Fig3B
	
	use "${directory}/constructed/fig_3.dta", clear

	unab quality : correct dr_1 dr_4 re_1 re_3 med_any  ///
		med_l_any_2 med_l_any_3 med_k_any_9
				   
	local nRows = 0
    foreach i in `quality' {
      local ++nRows
	  local lbl`i': variable label `i'
    }

    mat x = J(`nRows',3,0)
	matrix colnames x = "Sensitivity" "Specificity" "_n"
	
	local row = 1 
	foreach i in `quality'{
		tab `i'1 `i', matcell(`i')
		mat x[`row', 1] = `i'[2,2]/(`i'[1,2]+ `i'[2,2])
		mat x[`row', 2] = `i'[1,1]/(`i'[1,1]+ `i'[2,1])
		mat x[`row', 3] = `row'
		local ++row
	}
	
	
	forvalues i = 1/`nRows'{ //Rounding off values in the matrix
		forvalues j = 1/2{
			matrix x[`i', `j'] = round(x[`i',`j'], 0.01)
		}
	}
	
	svmat float x , names(matcol)
	
	label define lblindicator 1 "`lblcorrect'" 2 "`lbldr_1'" 3 "`lbldr_4'" ///
	4 "`lblre_1'" 5  "`lblre_3'" 6 "`lblmed_any'" ///
	 7 "`lblmed_l_any_2'" ///
	8 "`lblmed_l_any_2'" 9 "`lblmed_k_any_9'"
	label values x_n lblindicator 

	
	graph hbar xSensitivity xSpecificity  , ///
		over(x_n, label(labsize(small))) blabel(bar) intensity(50) /// 
		legend(order(1 "Sensitivity" 2 "Specificity")) legend(size(small)) ///
		ylab(,notick nogrid) ///
		graphregion(color(white) lwidth(large))

	graph export "${directory}/outputs/fig2B.png", replace 
		
		

  
  
	  
	
	
	
	
	
