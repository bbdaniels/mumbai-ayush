// ---------------------------------------------------------------------------------------------
// Tabulating SP cases in qutub_sample_updated in wave 0 and 1
use "${directory}/constructed/sp_both.dta", clear

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
use "${directory}/constructed/sp_both.dta", clear

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

	use "${directory}/constructed/sp_both.dta", clear

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
	unab Quality : correct* cb* dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9

	foreach i in Balance Process Quality{ // Creating balance tables for the 3 kinds of variables
		iebaltab ``i' ' ///
			, grpvar(trial_assignment) control(1) covariates(i.case) vce(cluster qutub_id) ///
					replace rowvarlabel ///
						save("${directory}/outputs/balance_table_`i'.xlsx")
		}

	unab Balance : cp_17_* cp_18 cp_19 cp_20 cp_21 //Varlists for the types of variables for balance table graphs
	unab Process : g_* cp_14d_mm checklist_essential_pct
	unab Quality : correct* cb* dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_1 med_l_any_2 ///
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

	
 //	-------------------------
	// Diff in Diff ITT and TOT 
	
	use "${directory}/constructed/sp_analysis.dta", clear 
	
	gen d_treat = 0 if trial_assignment == 0 // Creating dummy for trial_assignment
	replace d_treat = 1 if trial_assignment == 1 
	
	gen d_tot = 0 if trial_treatment == 0 // Creating dummy for trial_treatment
	replace d_tot = 1 if trial_treatment == 1 
	
	gen d_post = 0 if wave == 0  // Creating dummt for before or after treatment 
	replace d_post = 1 if wave == 1 
	
	gen d_treatXpost = d_treat * d_post //Creating dummy for trial_assignment X treatment
	
	gen d_totXpost = d_tot * d_post // Creating dummy for trial_treatment X treatment 
	
	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9 
	
	ivregress 2sls dr_1  (d_totXpost d_tot  = d_treat d_treatXpost) d_post i.case, vce(cluster qutub_id) first 
	
	forest ivregress 2sls /// Diff in Diff TOT
	(`quality') ///
		, t((d_totXpost d_tot  = d_treat d_treatXpost)) controls(i.case d_post) ///
		vce(cluster qutub_id) bh graphopts(title("TOT")) sort(global)
		
		graph save "${directory}/outputs/TOT.gph", replace
		
		  
	forest reg /// Diff in Diff ITT 
	(`quality') ///
		, t(d_treatXpost) controls(d_treat d_post i.case) ///
		vce(cluster qutub_id) bh graphopts(title("ITT")) sort(global)
		
		graph save "${directory}/outputs/ITT.gph", replace
		
		graph combine ///
			"${directory}/outputs/ITT.gph" ///
			"${directory}/outputs/TOT.gph" 
		
	foreach i in `quality' { //IV 2SLS 
		ivregress 2sls `i' i.case d_post (d_treatXpost d_treat d_treatXpost = d_tot d_totXpost), vce(cluster qutub_id)
	}
	
	
	// ANCOVA ITT AND TOT
	
	use "${directory}/constructed/sp_analysis.dta", clear 
	
	egen unique_id = concat(qutub_id case wave) //Creating a unique id 
	egen tag = tag(unique_id)
	drop if tag == 0
	drop unique_id tag med_l_any_1
	
	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_2 ///
				   med_l_any_3 med_k_any_9 
	
	reshape wide correct dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_2 /// Converting data to wide 
				   med_l_any_3 med_k_any_9 qutub_sample_updated trial_assignment trial_treatment ///
					, i(qutub_id case) j (wave)
					
				   
	rename trial_assignment0 trial_assignment // Keeping only one trial_assignment
	rename trial_treatment0 trial_treatment
	drop trial_assignment1 trial_treatment1 
	
	
	unab quality1: correct1 dr_11 dr_41 re_11 re_31 re_41 med_any1 polypharmacy1 med_l_any_21 ///
				   med_l_any_31 med_k_any_91
				   
	rename (`quality1') (`quality') //Renaming lagged variables to include in forest 

		
	forest reg /// Forest for ITT
	(`quality') ///
		, t(trial_assignment) controls(i.case @0) ///
		vce(cluster qutub_id) bh graphopts(title("ITT")) sort(global)
		
		graph save "${directory}/outputs/ITT.gph", replace
		
    forest ivregress 2sls /// Forest for TOT
	(`quality') ///
		, t((trial_treatment = trial_assignment)) controls(i.case @0) ///
		vce(cluster qutub_id) bh graphopts(title("TOT")) sort(global)
		
		graph save "${directory}/outputs/TOT.gph", replace
		
		graph combine ///
			"${directory}/outputs/ITT.gph" ///
			"${directory}/outputs/TOT.gph" 
		
		 
	foreach i in `quality' { // ANCOVA FOR TOT 
		ivregress 2sls `i'  i.case `i'0 (trial_treatment = trial_assignment), vce(cluster qutub_id)
		}
		
	/* Using forest*/

	//Outocomes for Case 7 
	
	use "${directory}/constructed/sp_both.dta", clear
	
	keep if qutub_sample_updated == 10 | qutub_sample_updated == 11
	
	keep if case == 7
	
	unab quality :  dr_1 dr_4 re_1 med_any polypharmacy  med_l_any_2 ///
				   med_l_any_3 med_k_any_9 
	
	forest reg /// Forest for ITT
	(`quality') ///
		, t(trial_assignment) ///
		vce(cluster qutub_id) bh graphopts(title("ITT")) sort(global)
		
		graph save "${directory}/outputs/ITT.gph", replace
		
    forest ivregress 2sls /// Forest for TOT
	(`quality') ///
		, t((trial_treatment = trial_assignment)) ///
		vce(cluster qutub_id) bh graphopts(title("TOT")) sort(global)
		
		graph save "${directory}/outputs/TOT.gph", replace
		
		graph combine ///
			"${directory}/outputs/ITT.gph" ///
			"${directory}/outputs/TOT.gph" ///
			, c(1) xcom
	
		
	graph save "${directory}/outputs/TOT_Case7.eps", replace */
	
	
	//Outocomes for Case 7 with Case 1 Outcomes as control
	
	use "${directory}/constructed/sp_both.dta", clear 
	
	keep if wave == 1 //Case7 present only in Wave1 
	
	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9 
	
	keep qutub_id qutub_sample_updated trial_treatment trial_assignment case `quality'
	keep if qutub_sample_updated == 10 | qutub_sample_updated == 11 
	
	preserve 
	keep if case == 7 

	drop case 
	save "${directory}/constructed/sp_case7.dta", replace 
	restore
	
	keep if case == 1 
	foreach i in `quality' {
	 rename `i' `i'_1
	}
	drop case 
	
	merge 1:1 qutub_id using "${directory}/constructed/sp_case7.dta"
	
	drop if _merge != 3
	
	forest reg /// Forest for ITT
	(`quality') ///
		, t(@_1) ///
		vce(cluster qutub_id) bh graphopts(title("xxxx")) sort(global)
		
		
	
	foreach i in `quality' {
		reg `i'_7 trial_assignment `i'_1, vce(cluster qutub_id)
	}
	
	
	
	/*
	rename _1 to 0? shuold work?
	
	forest reg ///
	(`) ///
		, t(trial_assignment) c(????) ///
		vce(cluster qutub_id) 
		
		graph save "${directory}/outputs/ITT_Case7.eps", replace*/
	
	
	//Outocomes for Case 1 in wave 1 with Case 1 Outcomes in wave 0 as control
	
	use "${directory}/constructed/sp_analysis.dta", clear 
	
	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9 

	
	preserve 
	keep if case == 1 & wave == 0 
	foreach i in `quality' {
	 rename `i' `i'_0
	}
	save "case1_0.dta", replace
	
	restore 
	
	keep if case == 1 & wave == 1
	
	
	merge 1:1 qutub_id using "case1_0"
	
		forest reg /// Forest for ITT
	(`quality') ///
		, t(@_0) ///
		vce(cluster qutub_id) bh graphopts(title("xxxx")) sort(global)
		
	
	
	foreach i in `quality' {
		reg `i'_1 trial_assignment `i'_0, vce(cluster qutub_id)
	}
		
	/* forest ?? */
	
	//Non-assigned 
	
	use "${directory}/constructed/sp_both.dta", clear 
	
	keep if qutub_sample_updated == 8 | qutub_sample_updated == 9 
	
	
	unab quality : correct dr_1 dr_4 re_1 re_3 re_4 med_any polypharmacy med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9 
				   
	drop if case == 7 
	
	gen d_t = (wave == 0 & ppia_facility_0 == 1)  | (wave == 1 & ppia_facility_1 == 1)
	
	reg correct d_t wave i.case, vce(cluster qutub_id)
	
	forest reg ///
	(`quality') ///
		, t(d_t) controls(wave i.case i.qutub_sample_updated) ///
		vce(cluster qutub_id) 
	
	forest reg ///
	(`quality') ///
		, t(d_t) controls(wave i.case) ///
		vce(cluster qutub_id) 
		
		
	
	

	
	
	gen d_PPIA = 0 if qutub_sample_updated == 8
	replace d_PPIA = 1 if qutub_sample_updated == 9 
	
	gen d_time = 0 if  ppia_facility_0 ==0 | ppia_facility_1 == 0
	gen d_time =1 if ppia_facility_0 ==1 | ppia_facility_1 == 1 
	
	gen d_PPIAXwave = d_PPIA * d_time
	
	drop if case == 7 
	
	forest reg ///
	(`quality') ///
		, t(d_PPIA) controls(wave i.case) ///
		vce(cluster qutub_id) 
		graph export "${directory}/outputs/ITT_Non-Trial.eps", replace
	
	forest reg ///
	(`quality') ///
		, t(d_PPIAXwave) controls(d_PPIA wave i.case) ///
		vce(cluster qutub_id) 
		graph export "${directory}/outputs/DiffinDiff_Non-Trial.eps", replace
	
// Have a great day!
