
	
	
	use "${directory}/constructed/table_3.dta", clear
	
	replace dr_4 = 0 if dr_4 == 3
	
	egen check_wave = group(check wave), label
	
	unab quality: correct dr_4 re_1
	
	foreach i in `quality' { //Saving value labels
		local lbl`i': variable label `i'
	}
	
	mat fig1=J(1,10,0)
	matrix colnames fig1 = "00_0" "00_1" "01_0" "01_1" "10_0" "10_1" "11_0" "11_1" "n_0" "n_1"
	
	mat fig1[1,9] = 1
	mat fig1[1,10] = 2 
	
	set scheme s2color
	
	foreach i in `quality' {
	
		tabstat `i', by(check_wave) save
		
		local column = 1 
		
		forvalues column = 1/8{
		mat fig1[1, `column'] = r(Stat`column') 
		local column = `column' +1
		}
		
		preserve
			svmat float fig1 , names(matcol)
			keep fig1*
			gen id = _n
			reshape long fig100_ fig101_ fig110_ fig111_ fig1n_, i(id) j(wave)
			
			label define lblindicator 1 "Baseline" 2 "Endline"
			label values fig1n_ lblindicator
			
			scatter fig100_ fig1n_, c(l) || scatter fig101_ fig1n_, c(l) || ///
			scatter fig110_ fig1n_, c(l) || scatter fig111_ fig1n_, c(l) ///
			ytitle("") xtitle("`lbl`i''") /// 
			legend( order(1 "Did not take PPIA program in baseline and endline" ///
			2 "Did not take PPIA program in baseline but took it in endline" ///
			3 "Took PPIA program in baseline but not in endline" ///
			4 "Took PPIA program in baseline and endline") region(lcolor(white))) ///
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
	
	
	graph export "${directory}/outputs/fig1_nontrial.png", replace 
	
	
