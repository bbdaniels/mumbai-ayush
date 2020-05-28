// Master file for Mumbai Public Sector analysis

// Set global directory locations
global rawdata "/Users/bbdaniels/Box/_Papers/Ruchika PPIA"
global directory "/Users/RuchikaBhatia/GitHub/mumbai-ppia"

// Install packages ------------------------------------------------------------------------------
sysdir set PLUS "${directory}/ado/"

  net install "http://www.stata.com/users/kcrow/tab2xl", replace
  ssc install tabcount , replace
  ssc install ietoolkit , replace
  ssc install betterbar , replace
  ssc install randtreat , replace

  net from "https://github.com/bbdaniels/stata/raw/master/"
    net install forest , replace

  set scheme uncluttered

// Globals -------------------------------------------------------------------------------------

  // title
  global title justification(left) color(black) span pos(11)

  // Options for -twoway- graphs
  global tw_opts ///
  	title(, justification(left) color(black) span pos(11)) ///
  	graphregion(color(white) lc(white) lw(med)) bgcolor(white) ///
  	ylab(,angle(0) nogrid) xtit(,placement(left) justification(left)) ///
  	yscale(noline) xscale(noline) legend(region(lc(none) fc(none)))

  // Options for -graph- graphs
  global graph_opts ///
  	title(, justification(left) color(black) span pos(11)) ///
  	graphregion(color(white) lc(white) lw(med)) bgcolor(white) ///
  	ylab(,angle(0) nogrid) ytit(,placement(left) justification(left))  ///
  	yscale(noline) legend(region(lc(none) fc(none)))

  // Options for histograms
  global hist_opts ///
  	ylab(, angle(0) axis(2)) yscale(off alt axis(2)) ///
  	ytit(, axis(2)) ytit(, axis(1))  yscale(alt)

  // Useful stuff

  global pct `" 0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%" "'
  global numbering `""(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" "(9)" "(10)""'
  global bar lc(white) lw(thin) la(center) fi(100) // ← Remove la(center) for Stata < 15


// Part 1: Load datafiles into Git location ----------------------------------------------------

  // Hashdata command to import data from remote repository
  qui run "${directory}/ado/iecodebook.ado"

  iecodebook export "${rawdata}/data/sp-wave-0.dta" ///
     using "${directory}/data/sp-wave-0.dta" ///
     , replace copy hash text

  iecodebook export "${rawdata}/data/sp-wave-1.dta" ///
     using "${directory}/data/sp-wave-1.dta" ///
     , replace copy hash text

// Programs 
	// Program 1- Create a matrix with rownames
	capture program drop valuelabels
	program define valuelabels, rclass
	
	syntax varlist, name(str) columns(int) 
	local tRows = 0
    foreach i in `varlist' {
      local thisLabel: variable label `i'
      local rowNames = `" `rowNames' "`thisLabel'"  "'
      local tRows=`tRows'+1
    }
	mat t = J(`tRows', `columns',0)
    matrix rownames t = `rowNames'
	return mat `name' = t
	end
	
	// Program 2 - Create sensitivity and specificity graphs 
	capture program drop sensitivity
	program define sensitivity 
	
	syntax varlist, fig(str)
	
	use "${directory}/constructed/fig_`fig'.dta", clear
	
	local nRows = 0 //Create value labels
    foreach i in `varlist' {
		local ++nRows
		label define lblindicator `nRows' "`: variable label `i''", modify 
    }

    mat x = J(`nRows',3,0)
	matrix colnames x = "Sensitivity" "Specificity" "_n"
	
	local row = 1 // Store sensitivity and specificity values in a matrix
	
	
	foreach i in `varlist'{
		if "`fig’" == "2A" {
			tab `i'0 `i', matcell(`i') 
		}
		else if "`fig'" == "2B" {
			tab `i'1 `i', matcell(`i')
		}
			mat x[`row', 1] = `i'[2,2]/(`i'[1,2]+ `i'[2,2])
			mat x[`row', 2] = `i'[1,1]/(`i'[1,1]+ `i'[2,1])
			mat x[`row', 3] = `row'
			local ++row	

	}
	
	forvalues i = 1/`nRows'{ //Rounding off values in the matrix
		forvalues j = 1/2{
			matrix x[`i', `j'] = round(x[`i',`j'], 0.01)
		}
	}
	
	svmat float x , names(matcol) //Create variables from matrix
	
	label values x_n lblindicator 

	graph hbar xSensitivity xSpecificity  , ///
		over(x_n, label(labsize(small))) blabel(bar) intensity(50) /// 
		legend(order(1 "Sensitivity" 2 "Specificity")) legend(size(small)) ///
		ylab(,notick nogrid) ///
		graphregion(color(white) lwidth(large))
		
	graph export "${directory}/outputs/fig`fig'.eps", replace
	end
	
// Part 2: Build constructed data from raw data ------------------------------------------------

  run "${directory}/code/construct.do"

// Part 3: Analysis ----------------------------------------------------------------------------

  run "${directory}/code/AYUSH.do"
  run "${directory}/code/Table_2.do"
  run "${directory}/code/Table_3.do"
  run "${directory}/code/Table_4.do"
  run "${directory}/code/Table_5.do"
  run "${directory}/code/Fig1_NonTrial.do"
  run "${directory}/code/Sensitivity_and_Specificity.do"
  

// Have a lovely day!
