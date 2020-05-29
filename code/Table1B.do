
	// Tabulating case interactions for the 4 provider samples in wave-0 and wave-1
	use "${directory}/constructed/analysis-ayush-panel.dta", clear

	local row = 6  
	local row2 = 4 

	putexcel set "${directory}/outputs/Table1B_CaseVisits.xlsx", replace

	forvalues i = 8/11 {
		tab2xl case if qutub_sample_updated == `i' & wave == 0 ///
			using "${directory}/outputs/Table1B_CaseVisits.xlsx" , col(1) row(`row') //Export tables for Wave0
		tab2xl case if qutub_sample_updated == `i' & wave == 1 ///
			using "${directory}/outputs/Table1B_CaseVisits.xlsx" , col(6) row(`row') // Export tables for Wave1
		putexcel B`row2' = "Wave-0", hcenter bold 
		putexcel G`row2' = "Wave-1", hcenter bold 
		local row2 = `row2'+12
		local row = `row'+12 // Update row and row2 to rows where next table should be exported
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
		
	// End of dofile
	
