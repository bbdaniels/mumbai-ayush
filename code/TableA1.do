	
	// Number of providers for each case presentation in wave-0 and wave-1
use "${directory}/constructed/analysis-ayush-panel.dta", clear

	keep qutub_id case wave qutub_sample_updated
		duplicates drop
		forvalues w = 0/1 {
			forvalues i = 1/4 {
				gen is_`i' = case == `i' if wave == `w' // Identify case type
				bys qutub_id: egen has`i'_`w' = max(is_`i') // Identify case types in each wave
				replace has`i'_`w' = 0 if has`i'_`w' == .
				drop is_`i'
			}
		}

  // Keep one of each ID
  	sort qutub_id case
  	egen tag = tag(qutub_id)
  	keep if tag == 1

  // Calculate crosstabs of visits for each case and sample
  	local row = 2
  	local rowinc = 3

  	foreach sample in 8 9 10 11 {
  		forv i = 1/4 {
  			dis "`sample'_`i'"

  			tabcount has`i'_0 has`i'_1, v1(0/1) v2(0/1) zero ///
  			, if qutub_sample_updated == `sample' ///
  			, matrix(s`sample'_`i') // Save crosstabs in a matrix

  			matrix rownames s`sample'_`i' = "Wave0-No" "Wave0-Yes" 
  				matrix colnames s`sample'_`i' = "Wave1-No" "Wave1-Yes"  
  			}
  		}


  //Save crosstabs in excel
  	putexcel set "${directory}/outputs/TableA1_SP_Crosstabs.xlsx", modify

  	local row = 4 
  	forvalues j = 8/11{
  		local ncol = 1 
  		forvalues i = 1/4{
  			local col: word `ncol' of `c(ALPHA)' //Identify columns in excel
  			putexcel `col'`row' = "SP`i'" 
  			putexcel `col'`row' = matrix(s`j'_`i'), names //Exporti matrix 
  			local ncol = `ncol'+4 
  			}
  			local row = `row'+6 
  		}

  	local row1 = 4 //Format the exported matrices
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

  	local row1 = 5 //Format the exported matrices
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

		//End of dofile
		
