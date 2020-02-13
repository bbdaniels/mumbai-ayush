// Master file for Mumbai Public Sector analysis

// Set global directory locations
global rawdata "/Users/bbdaniels/Box/Papers/Ruchika PPIA"
global directory "/Users/bbdaniels/GitHub/mumbai/mumbai-ppia"

// Install packages ------------------------------------------------------------------------------
sysdir set PLUS "${directory}/ado/"

  net install "http://www.stata.com/users/kcrow/tab2xl", replace
  ssc install tabcount , replace
  ssc install ietoolkit , replace
  ssc install betterbar , replace
  ssc install randtreat , replace
  cap ssc install forest

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


// Part 2: Build constructed data from raw data ------------------------------------------------

*  do "${directory}/code/construct.do"

// Part 3: Analysis ----------------------------------------------------------------------------

*  do "${directory}/code/analysis.do"

// Have a lovely day!
