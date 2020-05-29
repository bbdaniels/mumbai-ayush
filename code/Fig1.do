
	
	// Line graph for non-trial group
	
	use "${directory}/constructed/nontrial.dta", clear
	
	// 8 groups according to group and round 
	egen check_wave = group(check wave), label 
	
	unab quality: correct dr_4 re_1
	
	foreach i in `quality' { //Save value labels
		local lbl`i': variable label `i'
	}
	
	mat fig1=J(1,10,0)
	//colnames according to the group and round 
	matrix colnames fig1 = "00_0" "00_1" "01_0" "01_1" "10_0" "10_1" "11_0" "11_1" "n_0" "n_1"
	
	mat fig1[1,9] = 1
	mat fig1[1,10] = 2 
	
	set scheme s2color
	
	foreach i in `quality' { 
	
		tabstat `i', by(check_wave) save //Save mean values in matrix
		
		local column = 1 
		
		forvalues column = 1/8{
		mat fig1[1, `column'] = r(Stat`column') 
		local column = `column' +1
		}
		
		preserve
			svmat float fig1 , names(matcol) //Create variables from matrix
			
			keep fig1* //Reshape to long format 
			gen id = _n
			reshape long fig100_ fig101_ fig110_ fig111_ fig1n_, i(id) j(wave)
			
			label define lblindicator 1 "Baseline" 2 "Endline"
			label values fig1n_ lblindicator
			
			//Line graph for all the 4 groups
			
			scatter fig100_ fig1n_, c(l) || scatter fig101_ fig1n_, c(l) || ///
			scatter fig110_ fig1n_, c(l) || scatter fig111_ fig1n_, c(l) ///
			ytitle("") xtitle("`lbl`i''") /// 
			legend( order(1 "Remained out of the program" ///
			2 "Entered the program in endline" ///
			3 "Exited the program in endline" ///
			4 "Remained in the program") region(lcolor(white))) ///
			xlabel(1 2, valuelabel) ylabel(,angle(0)) legend(size(vsmall)) ///
			ylab(,notick nogrid) ///
		graphregion(color(white) lwidth(large))
			
			graph save "${directory}/outputs/`i'.gph", replace
		restore
		
	}
	
	grc1leg /// 
	"${directory}/outputs/correct.gph" ///
	"${directory}/outputs/dr_4.gph" /// 
	"${directory}/outputs/re_1.gph", ///
	legendfrom("${directory}/outputs/correct.gph") rows(1) altshrink ycommon ///
	graphregion(color(white))
	
	
	graph export "${directory}/outputs/fig1_nontrial.eps", replace 
	
	
