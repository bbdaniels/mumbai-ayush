
///Load data

use "${directory}/constructed/sp_both.dta", clear

// Tabulating SP cases in qutub_sample_updated in wave 0 and 1

	local row = 6  // Starting row to export a table in row 6 in excel
	local row2 = 4 // Starting row2 to give headings to tables exported 

putexcel set "${directory}/outputs/sp_case_tabs.xlsx", replace

forvalues i = 8/11 {
		tab2xl case if qutub_sample_updated == `i' & wave == 0 ///
			using "${directory}/outputs/sp_case_tabs.xlsx" , col(1) row(`row')
		tab2xl case if qutub_sample_updated == `i' & wave == 1 ///
			using "${directory}/outputs/sp_case_tabs.xlsx" , col(6) row(`row')
		putexcel B`row2' = "Wave-0", hcenter bold
		putexcel G`row2' = "Wave-1", hcenter bold 
		local row2 = `row2'+12
		local row = `row'+12
		}
		
	
putexcel D2:F2 = "SP cases for each sample" ///
	, merge font(calibri,13) bold underline
putexcel D2:F2 = " Sample: AYUSH NON-PPIA" ///
	, merge font(calibri,13) bold underline
putexcel D14:F14 = "Sample: AYUSH PPIA" ///
	, merge font(calibri,13) bold underline
putexcel D26:F26 = "Sample: AYUSH Trial Control" ///
	, merge font(calibri,13) bold underline
putexcel D38:G38 = "Sample: AYUSH Trial Treatment" ///
	, merge font(calibri,13) bold underline

// Tracking cases across rounds

keep qutub_id case wave qutub_sample_updated
	duplicates drop
	forvalues w = 0/1 {
		forvalues i = 1/4 {
			gen is_`i' = case == `i' if wave == `w'
			bys qutub_id: egen has`i'_`w' = max(is_`i')
			replace has`i'_`w' = 0 if has`i'_`w' == .
			drop is_`i'
		}
	}
	
// Keeping one of each ID
sort qutub_id case
egen tag = tag(qutub_id)
keep if tag == 1
	
// Calculating crosstabs of visits for each case and sample
local row = 2
local rowinc = 3

foreach sample in 8 9 10 11 {
		forv i = 1/4 {
		dis "`sample'_`i'"
		
			tabcount has`i'_0 has`i'_1, v1(0/1) v2(0/1) zero ///
			, if qutub_sample_updated == `sample' ///
			, matrix(s`sample'_`i')
			
			matrix rownames s`sample'_`i' = "Wave0-No" "Wave0-Yes"
				matrix colnames s`sample'_`i' = "Wave1-No" "Wave1-Yes" 
			}
			}
		
		
//Saving crosstabs in excel 		
putexcel set "${directory}/outputs/sp_crosstabs.xlsx", modify 
 
local row = 4
forvalues j = 8/11{
	local ncol = 1
	forvalues i = 1/4{
		local col: word `ncol' of `c(ALPHA)'
		putexcel `col'`row' = "SP`i'"
		putexcel `col'`row' = matrix(s`j'_`i'), names
		local ncol = `ncol'+4
		}
		local row = `row'+6
		}
 
 local row1 = 4
 local row2 = 6
 forvalues j = 1/4{
	local ncol1 = 1
	local ncol2 = 3
	forvalues i = 1/4{
		local col1: word `ncol1' of `c(ALPHA)'
		local col2: word `ncol2' of `c(ALPHA)'
		putexcel `col1'`row1':`col2'`row2' ///
		, fpattern(solid, "192 192 192") border(all) 
		local ncol1 = `ncol1'+4
		local ncol2 = `ncol2'+4
		}
		
		local row1 = `row1'+6
		local row2 = `row2'+6
		}
		
local row1 = 5
local row2 = 6
forvalues j = 1/4{
	local ncol1 = 2
	local ncol2 = 3
	forvalues i = 1/4{
		local col1: word `ncol1' of `c(ALPHA)'
		local col2: word `ncol2' of `c(ALPHA)'
		putexcel `col1'`row1':`col2'`row2' ///
		, fpattern(none) border(all) 
		local ncol1 = `ncol1'+4
		local ncol2 = `ncol2'+4
		}
		local row1 = `row1'+6
		local row2 = `row2'+6
		}		
		
putexcel G2:I2=" Sample: AYUSH NON-PPIA" ///
	, merge font(calibri,13) bold underline
putexcel G8:I8="Sample: AYUSH PPIA" ///
	, merge font(calibri,13) bold underline
putexcel G14:I14="Sample: AYUSH Trial Control" ///
	, merge font(calibri,13) bold underline
putexcel G20:J20="Sample: AYUSH Trial Treatment" ///
	, merge font(calibri,13) bold underline

// Creating Balance Tables 

use "${directory}/constructed/sp_both.dta", clear


foreach var of varlist g_6-g_10 {
		recode `var' (1 2 = 0)(3 = 1)
		}

separate correct, by(case)

forvalues i= 1/4  {
	label variable correct`i' Case`i'
}

drop correct7

clonevar cb1 = correct if cp_18 == 1
clonevar cb2 = correct if cp_18 == 0

label variable cb1 "Male Provider & Correct Manag."
label variable cb2 "Female Provider & Correct Manag."

keep if wave == 0


iebaltab ///
	cp_17_* cp_18 cp_19 cp_20 cp_21 ///
	g_* cp_14d_mm checklist_essential_pct ///
	correct* cb* dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_1 med_l_any_2 ///
	med_l_any_3 med_k_any_9 ///
		, grpvar(trial_assignment) control(1) covariates(i.case) vce(cluster qutub_id) ///
				replace rowvarlabel ///
					save("${directory}/outputs/balance_table.xlsx") 
			
				
putexcel set "${directory}/outputs/balance_table.xlsx", modify

putexcel A4:F17 , fpattern(solid, "204 255 255 ") border(all)
putexcel A18:F43 , fpattern(solid, " 204 255 204") border (all)
putexcel A44:F79 , fpattern(solid, "255 255 153  ") border (all)

putexcel H4, fpattern(solid, "204 255 255 ") border(all)
putexcel H5, fpattern(solid, "204 255 204 ") border(all)
putexcel H6, fpattern(solid, "255 255 153 ") border(all)

putexcel I4:J4="Balance variable", merge 
putexcel I5:J5="Process Indicator", merge 
putexcel I6:J6="Quality Outcome", merge 

/// Graph of balance tables

/// Clustering of errors??

forest reg ///
	(cp_17_* cp_18 cp_19 cp_20 cp_21) ///
	, t(trial_assignment)  controls(i.case) ///
	  vce(cluster qutub_id) ///
	  graphopts(title("Balance Variable") ///
	  xtitle("{&larr} Favors Control      Favors Treatment {&rarr}"))

graph export "${directory}/outputs/balance_variables.eps", replace

forest reg ///
	(g_* cp_14d_mm checklist_essential_pct) ///
	, t(trial_assignment) bh controls(i.case) graphopts(title("Process Indicators") ///
		xtitle(" {&larr}Favors Control          Favors Treatment {&rarr}"))

graph export "${directory}/outputs/Process_Indicators.eps", replace

forest reg ///
	(correct* cb* dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_1 med_l_any_2 ///
	med_l_any_3 med_k_any_9) ///
	, t(trial_assignment) bh controls(i.case) graphopts(title("Quality Outcomes") ///
		xtitle("{&larr}Favors Control      Favors Treatment {&rarr}"))

graph export "${directory}/outputs/Quality_Outcomes.eps", replace


---







			




