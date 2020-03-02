// ---------------------------------------------------------------------------------------------
// Tabulating SP cases in qutub_sample_updated in wave 0 and 1
	use "${directory}/constructed/analysis-ayush-panel.dta", clear

	local row = 6  // Starting row to export a table in row 6 in excel
	local row2 = 4 // Starting row2 to give headings to tables exported

	putexcel set "${directory}/outputs/sp_case_tabs.xlsx", replace

	forvalues i = 8/11 {
		tab2xl case if qutub_sample_updated == `i' & wave == 0 ///
			using "${directory}/outputs/sp_case_tabs.xlsx" , col(1) row(`row') //Exporting tables for Wave0
		tab2xl case if qutub_sample_updated == `i' & wave == 1 ///
			using "${directory}/outputs/sp_case_tabs.xlsx" , col(6) row(`row') // Exporting tables for Wave1
		putexcel B`row2' = "Wave-0", hcenter bold // Headings for table exported of Wave-0
		putexcel G`row2' = "Wave-1", hcenter bold // Headings for table exported of Wave-1
		local row2 = `row2'+12
		local row = `row'+12 // Updating row and row2 to rows where next table should be exported
		}

	putexcel D2:F2 = "SP cases for each sample" ///
		, merge font(calibri,13) bold underline // Heading for the excel sheet
	putexcel D2:F2 = " Sample: AYUSH NON-PPIA" ///
		, merge font(calibri,13) bold underline // Headings for each of the qutub_sample_updated
	putexcel D14:F14 = "Sample: AYUSH PPIA" ///
		, merge font(calibri,13) bold underline
	putexcel D26:F26 = "Sample: AYUSH Trial Control" ///
		, merge font(calibri,13) bold underline
	putexcel D38:G38 = "Sample: AYUSH Trial Treatment" ///
		, merge font(calibri,13) bold underline

// ---------------------------------------------------------------------------------------------
// Tracking cases across rounds
use "${directory}/constructed/analysis-ayush-panel.dta", clear

	keep qutub_id case wave qutub_sample_updated
		duplicates drop
		forvalues w = 0/1 {
			forvalues i = 1/4 {
				gen is_`i' = case == `i' if wave == `w' // Identifying case type
				bys qutub_id: egen has`i'_`w' = max(is_`i') // Identifying case types in each wave
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
  			, matrix(s`sample'_`i') // Saving crosstabs for each case for every qutub_sample_updated in a matrix

  			matrix rownames s`sample'_`i' = "Wave0-No" "Wave0-Yes" // Row Headings for the saved matrix
  				matrix colnames s`sample'_`i' = "Wave1-No" "Wave1-Yes"  // Col Headings for the saved matrix
  			}
  		}


  //Saving crosstabs in excel
  	putexcel set "${directory}/outputs/sp_crosstabs.xlsx", modify

  	local row = 4 // Exporting the first matrix in row 4 in excel
  	forvalues j = 8/11{
  		local ncol = 1 // Exporting the first matrix in col 1 in excel
  		forvalues i = 1/4{
  			local col: word `ncol' of `c(ALPHA)' //Identifying columns in excel
  			putexcel `col'`row' = "SP`i'" // Heading for the matrix exported
  			putexcel `col'`row' = matrix(s`j'_`i'), names //Exporting matrix in the specified location
  			local ncol = `ncol'+4 //Changing column for expoting the next matrix
  			}
  			local row = `row'+6 //Changing row for exporting the matrices of next qutub_sample_updated
  		}

  	local row1 = 4 //Formatting the exported matrices
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

  	local row1 = 5 //Formatting the exported matrices
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
  		, merge font(calibri,13) bold underline // Headings for each qutub_sample_updated
  	putexcel G8:I8="Sample: AYUSH PPIA" ///
  		, merge font(calibri,13) bold underline
  	putexcel G14:I14="Sample: AYUSH Trial Control" ///
  		, merge font(calibri,13) bold underline
  	putexcel G20:J20="Sample: AYUSH Trial Treatment" ///
  		, merge font(calibri,13) bold underline

// ---------------------------------------------------------------------------------------------
// Creating Balance Tables and Graphs

	use "${directory}/constructed/analysis-ayush-panel.dta", clear

  // Transforming Analysis Variables
	foreach var of varlist g_6-g_10 {
		recode `var' (1 2 = 0)(3 = 1) //Creating only yesno values for these variables
	}

	separate correct, by(case) // Calculating correct management by cases

	forvalues i= 1/4  {
		label variable correct`i' Case`i'
	}

	drop correct7

	clonevar cb1 = correct if cp_18 == 1 //Indicator for correct management and male provider
	clonevar cb2 = correct if cp_18 == 0 //Indicator for correct management and female provider

	label variable cb1 "Male Provider & Correct Manag."
	label variable cb2 "Female Provider & Correct Manag."

	keep if wave == 0

	unab Balance : cp_17_* cp_18 cp_19 cp_20 cp_21 //Varlists for the types of variables for balance table
	unab Process : g_* cp_14d_mm checklist_essential_pct
	unab Quality : correct* cb* dr_1 dr_4 re_1 re_3 re_4 med_any med med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9

	foreach i in Balance Process Quality{ // Creating balance tables for the 3 kinds of variables
		iebaltab ``i' ' ///
			, grpvar(trial_assignment) control(1) covariates(i.case) vce(cluster qutub_id) ///
					replace rowvarlabel ///
						save("${directory}/outputs/balance_table_`i'.xlsx")
		}

	unab Balance : cp_17_* cp_18 cp_19 cp_20 cp_21 //Varlists for the types of variables for balance table graphs
	unab Process : g_* cp_14d_mm checklist_essential_pct
	unab Quality : correct* cb* dr_1 dr_4 re_1 re_3 re_4 med_any med med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9

	foreach i in Balance Process Quality { // Creating balance table graphs for the 3 kinds of variables
		forest reg ///
		(``i' ') ///
			, t(trial_assignment)  controls(i.case) ///
			vce(cluster qutub_id) ///
			graphopts(title("`i' Variables"))


			graph save "${directory}/outputs/`i'.gph", replace // Saving the graphs
	}

	graph combine /// Combinig the above 3 graphs
			"${directory}/outputs/balance.gph" ///
			"${directory}/outputs/process.gph" ///
			"${directory}/outputs/quality.gph" ///
  , rows(3) altshrink xcommon ysize(7)


	graph export "${directory}/outputs/balance_table_graph.eps" , replace // Exporting the combined graph

// Have a great day!
