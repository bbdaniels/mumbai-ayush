	
	
	//Diff in Diff on Non-Assigned Groups 
	
	use "${directory}/constructed/table_3.dta", clear
	
	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9 
	
	forest reg /// Graph for Diff in Diff in Non-Trial Groups 
	(`quality') ///
		, t(d_t) controls(wave i.check i.case i.qutub_sample_updated) ///
		vce(cluster qutub_id) 

		graph export "${directory}/outputs/Non-Trial_DiffinDiff.eps", replace 
		
	mat t3=J(12,7,0) //Constructing a matrix 
	local row = 1
	
	foreach i in `quality'{
		quietly reg `i' d_t wave i.check i.case i.qutub_sample_updated
		
		mat t3[`row', 5] = r(table)[1,1] //Effect
		mat t3[`row', 6] = r(table)[2,1] //Standard Error 
		mat t3[`row', 7] = r(table)[4,1] //P-value 
		
		
		quietly tabstat `i', by(check) save
		
		mat t3[`row',1] = r(Stat1)
		mat t3[`row',2] = r(Stat2)
		mat t3[`row',3] = r(Stat3)
		mat t3[`row',4] = r(Stat4)
		
		local row =`row' + 1
	
	}
	
	 foreach i in `quality' { //Saving value labels 
		local lbl`i': variable label `i'
	}	
	
	matrix rownames t3 = "`lblcorrect'" "`lbldr_1'"  "`lbldr_4'" "`lblre_1'"  "`lblre_3'" "`lblre_4'" ///
						 "`lblmed_any'" "`lblpolypharmacy'"  "`lblmed_l_any_1'" "`lblmed_l_any_2'"  "`lblmed_l_any_3'" ///
						 "`lblmed_k_any_9'"  
						 
	matrix colnames t3 = "00" "01" "10" "11" "Effect" "Std Error" "P-value"
	
		
	forvalues i = 1/12{ //Rounding off values 
		forvalues j = 1/7{
			matrix t3[`i', `j'] = round(t3[`i',`j'], 0.001)
		}
	}
	
	
	putexcel set "${directory}/outputs/Table_3.xlsx", replace //Saving results in excel 
	
	putexcel D7 = matrix(t3), names 
	putexcel E22= "00"
	putexcel F22:I22 = "No PPIA Facility in Wave 0 and Wave 1", merge
	putexcel E23= "01"
	putexcel F23:J23 = "No PPIA Facility in Wave 0 but present in Wave 1", merge
	putexcel E24= "10"
	putexcel F24:I24 = "PPIA Facility in Wave 0 but not in Wave 1", merge
	putexcel E25= "11"
	putexcel F25:I25 = "PPIA Facility in Wave 0 and Wave 1", merge
	putexcel E5:K5 = "Effect of PPIA on quality indicators in non-trail groups using Diff in Diff", merge hcenter bold 
	putexcel E27:H27 = "* Std Errors clustered at individual level", merge 
	putexcel E28:G28 = "*Controlled for SP Case", merge
---
