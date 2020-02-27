	
	
	use "${directory}/constructed/fig_3.dta", clear
	
	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9 
				   
	foreach i in `quality' { //Saving value labels 
		local lbl`i': variable label `i'	
	}
	
	mat case7=J(12,3,0) //Constructing a matrix to save results in 
	
	matrix rownames case7 = "`lblcorrect'" "`lbldr_1'"  "`lbldr_4'" "`lblre_1'"  "`lblre_3'" "`lblre_4'" ///
						 "`lblmed_any'" "`lblpolypharmacy'"  "`lblmed_l_any_1'" "`lblmed_l_any_2'"  "`lblmed_l_any_3'" ///
						 "`lblmed_k_any_9'"  
				   
	matrix colnames case7 = "Incorrect" "Correct" "_n"
	
		
	local row =1 
	
	foreach i in `quality'{ 
		tabstat `i', by(`i'1) save 
		mat case7[`row', 1] = r(Stat1) //Mean of output of case7 when incorrect output in case1
		mat case7[`row', 2] = r(Stat2) //Mean of output of case7 when correct output in case1
		mat case7[`row', 3] = `row'
		
	local row =`row' + 1 
	}
	
		
	forvalues i = 1/12{ //Rounding off values in the matrix 
		forvalues j = 1/2{
			matrix case7[`i', `j'] = round(case7[`i',`j'], 0.001)
		}
	}
	
	  
	 gen incorret_case = case7[_n,1] in 1/12 //Storing column-1 values of the matrix
	 gen correct_case = case7[_n,2] in 1/12  //Storing column-2 values of the matrix
	 gen quality_indicators = case7[_n,3] in 1/12 //Storing column-3 values of the matrix
	  
	  
	  label define lblindicator 1 "`lblcorrect'" 2 "`lbldr_1'" 3 "`lbldr_4'" 4 "`lblre_1'" 5  "`lblre_3'" 6 "`lblre_4'" ///
						7 "`lblmed_any'" 8 "`lblpolypharmacy'" 9 "`lblmed_l_any_1'" 10 "`lblmed_l_any_2'" 11 "`lblmed_l_any_3'" ///
						12 "`lblmed_k_any_9'"  
				   
	  label values quality_indicators lblindicator //Value labels for quality_indicators
	  
	  scatter quality_indicators incorret_case, ylabel(1 2 3 4 5 6 7 8 9 10 11 12, valuelabel) || scatter quality_indicators correct_case , legend(order(1 	"Incorrect" 2 "Correct"))||  pcarrow quality_indicators incorret_case quality_indicators correct_case, ytitle("Quality Indicators") title("Difference in Case7 Outputs") //Fig_3
	 
	graph export "${directory}/outputs/Consistency_Case7.eps", replace  //Exporting Fig_3 
	
---
