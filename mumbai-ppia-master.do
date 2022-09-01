// Master file for Mumbai Public Sector analysis

// Set global directory locations
global rawdata "/Users/bbdaniels/Library/CloudStorage/Box-Box/_Papers/PPIA AYUSH"
global directory "/Users/bbdaniels/GitHub/mumbai-ayush"

// Install packages ------------------------------------------------------------------------------
sysdir set PLUS "${directory}/ado/"
sysdir set PERSONAL "${directory}/"

  set scheme uncluttered

  net install "http://www.stata.com/users/kcrow/tab2xl", replace
  ssc install tabcount , replace
  ssc install tabout , replace
  ssc install ietoolkit , replace
  ssc install betterbar , replace
  ssc install randtreat , replace
  ssc install xsvmat, replace
  ssc install iefieldkit, replace

  net from "https://github.com/bbdaniels/stata/raw/main/"
    net install forest , replace



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


// Part 2: Build constructed data from raw data ------------------------------------------------

  run "${directory}/code/construct.do"

// Part 3: Analysis ----------------------------------------------------------------------------

  run "${directory}/code/figures.do
  run "${directory}/code/tables.do



// Have a lovely day!
