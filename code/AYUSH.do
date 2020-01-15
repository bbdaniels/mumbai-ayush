use "/Users/RuchikaBhatia/GitHub/mumbai-ppia/data/sp-wave-0.dta", clear
gen wave=0
append using "/Users/RuchikaBhatia/GitHub/mumbai-ppia/data/sp-wave-1.dta" , force
replace wave=1 if wave==.

save "/Users/RuchikaBhatia/GitHub/mumbai-ppia/data/sp-both.dta" , replace

use "/Users/RuchikaBhatia/GitHub/mumbai-ppia/data/sp-both.dta", clear

//Installing packages 
net install http://www.stata.com/users/kcrow/tab2xl, replace
ssc install tabcount




//Modifying case label
label define case 7 "SP7", add
label values case case


// Creating different group for AYUSH_trial control and treatment 
keep if qutub_sample >= 7

clonevar qutub_sample_updated=qutub_sample
recode qutub_sample_updated (7=10) if trial_assignment==0
	lab def qutub_sample 10 "Treatment" , modify
recode qutub_sample_updated 7=11 if trial_assignment==1
	lab def qutub_sample 11 "Control" , modify
	
replace qutub_sample_updated = 8 if qutub_sample_updated == 7



// Tabulating SP cases in qutub_sample_updated in wave 0 and 1

local row=6
local row2=4

putexcel set "${directory}/outputs/sp_case_tabs.xlsx", modify

forvalues i=8/11{
		tab2xl case if qutub_sample_updated==`i' & wave==0 using "${directory}/outputs/sp_case_tabs.xlsx" , col(1) row(`row')
		tab2xl case if qutub_sample_updated==`i' & wave==1 using "${directory}/outputs/sp_case_tabs.xlsx" , col(6) row(`row')
		putexcel B`row2'="Wave-0", hcenter bold
		putexcel G`row2'="Wave-1", hcenter bold 
		local row2=`row2'+12
		local row=`row'+12
		}
		
	
putexcel D2:F2="SP cases for each sample", merge font(calibri,13) bold underline
putexcel D2:F2=" Sample: AYUSH NON-PPIA", merge font(calibri,13) bold underline
putexcel D14:F14="Sample: AYUSH PPIA", merge font(calibri,13) bold underline
putexcel D26:F26="Sample: AYUSH Trial Control", merge font(calibri,13) bold underline
putexcel D38:G38="Sample: AYUSH Trial Treatment", merge font(calibri,13) bold underline



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
local row=2
local rowinc=3
cap erase "${directory}/outputs/sp_crosstabs.xlsx"
foreach sample in 8 9 10 11 {
		forv i = 1/4 {
		dis "`sample'_`i'"
		
			tabcount has`i'_0 has`i'_1, v1(0/1) v2(0/1) zero , if qutub_sample_updated == `sample' ///
			, matrix(s`sample'_`i')
			
			matrix rownames s`sample'_`i'="Wave0-No" "Wave0-Yes"
				matrix colnames s`sample'_`i'="Wave1-No" "Wave1-Yes" 
			}
			}
		
		
//Saving crosstabs in an excel 		
putexcel set "${directory}/outputs/sp_crosstabs.xlsx", modify 
 
 local row=4
 forvalues j=8/11{
	local ncol=1
	forvalues i=1/4{
		local col: word `ncol' of `c(ALPHA)'
		putexcel `col'`row'= "SP`i'"
		putexcel `col'`row'= matrix(s`j'_`i'), names
		local ncol=`ncol'+4
		}
		local row=`row'+6
		}
 
 local row1=4
 local row2=6
 forvalues j=1/4{
	local ncol1=1
	local ncol2=3
	forvalues i=1/4{
		local col1: word `ncol1' of `c(ALPHA)'
		local col2: word `ncol2' of `c(ALPHA)'
		putexcel `col1'`row1':`col2'`row2', fpattern(solid, "192 192 192") border(all) 
		local ncol1=`ncol1'+4
		local ncol2=`ncol2'+4
		}
		
		local row1=`row1'+6
		local row2=`row2'+6
		}
		
local row1=5
local row2=6
forvalues j=1/4{
	local ncol1=2
	local ncol2=3
	forvalues i=1/4{
		local col1: word `ncol1' of `c(ALPHA)'
		local col2: word `ncol2' of `c(ALPHA)'
		putexcel `col1'`row1':`col2'`row2', fpattern(none) border(all) 
		local ncol1=`ncol1'+4
		local ncol2=`ncol2'+4
		}
		local row1=`row1'+6
		local row2=`row2'+6
		}		
		
putexcel G2:I2=" Sample: AYUSH NON-PPIA", merge font(calibri,13) bold underline
putexcel G8:I8="Sample: AYUSH PPIA", merge font(calibri,13) bold underline
putexcel G14:I14="Sample: AYUSH Trial Control", merge font(calibri,13) bold underline
putexcel G20:J20="Sample: AYUSH Trial Treatment", merge font(calibri,13) bold underline

//Creating balance tables

ssc install ietoolkit

ssc install betterbar

ssc install forest



use "/Users/RuchikaBhatia/GitHub/mumbai-ppia/data/sp-both.dta", clear

keep if qutub_sample >= 7

clonevar qutub_sample_updated=qutub_sample
recode qutub_sample_updated (7=10) if trial_assignment==0
	lab def qutub_sample 10 "Control" , modify
recode qutub_sample_updated 7=11 if trial_assignment==1
	lab def qutub_sample 11 "Treatment" , modify
	
replace qutub_sample_updated = 8 if qutub_sample_updated == 7



/// Balance tables Include correct case management?

putexcel set "${directory}/outputs/balance_tables_2.xlsx", replace
local j=3

forvalues i=1/7{
	logistic ce_`i' trial_assignment
	putexcel C`j' = etable
	local j=`j'+2
}

local row=5
forvalues i=1/7{
	putexcel C`row':I`row', nformat(";;;")
	local row=`row'+2
}

local row=4
foreach x in ce_1 ce_2 ce_3 ce_4 ce_5 ce_6 ce_7{
	describe `x'
	local varlabel : var label `x'
	putexcel B`row':C`row' = ("`varlabel'"), merge
	local row=`row'+2
}

putexcel D3:I17, border(all)

putexcel B3:B17, border(left)
putexcel B3:B17, border(bottom)
putexcel B3:B17, border(top)
putexcel H3:I3, merge
putexcel C16, border(bottom)
putexcel B3:I3 B17:I17, fpattern(solid, "128 128 128")

local row=4
forvalues i=1/7{
	putexcel B`row', fpattern(solid, "192 192 192")
	local row=`row'+2
}

local row=3
forvalues i=1/7{
	putexcel B`row':C`row'="", merge
	local row=`row'+2
}
 
putexcel D3:I3, hcenter

//Graphing out balance table
label define trial_assignmentlbl 0 Control 1 Treatment, modify

label values trial_assignment trial_assignmentlbl

forest logit (ce_1 ce_2 ce_3 ce_4 ce_5 ce_6 ce_7) , t(trial_assignment) or

graph save "Graph" "${directory}/outputs/BalanceTable_Graph.gph"



//iebaltab i.ce_1  if wave==0, grpvar(trial_assignment) save("${directory}/outputs/balance_tables_2.xlsx") rowvarlabels




