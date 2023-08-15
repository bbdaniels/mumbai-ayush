// Master file for Mumbai AYUSH analysis

// Setup
global aux "/Users/bbdaniels/Library/CloudStorage/Box-Box/Qutub/MUMBAI/"
global box "/Users/bbdaniels/Library/CloudStorage/Box-Box/Qutub/MUMBAI/constructed"
global git "/Users/bbdaniels/GitHub/mumbai-ayush"
ieboilstart, v(16.1) adopath("${git}/ado" , strict)

// Install ado-files

  ssc install iefieldkit
  ssc install ietoolkit
  ssc install rwolf

  net install binsreg, from("https://raw.githubusercontent.com/nppackages/binsreg/master/stata")
  net install grc1leg, from("http://www.stata.com/users/vwiggins")
  net install st0085_2.pkg, from("http://www.stata-journal.com/software/sj14-2/")

  net from https://github.com/bbdaniels/stata/raw/main/
    net install labelcollapse
    net install betterbar
    net install sumstats
    net install outwrite
    net install forest, replace

// Graph scheming

  copy "https://github.com/graykimbrough/uncluttered-stata-graphs/raw/master/schemes/scheme-uncluttered.scheme" ///
    "${git}/ado/scheme-uncluttered.scheme" , replace

  set scheme uncluttered , perm
  graph set eps fontface "Helvetica"

// Globals

  global pct 0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%"
  global pct50 0 "0%" .25 "25%" .5 "50%"
  global pct20 0 "0%" .05 "5%" .1 "10%" .15 "15%" .2 "20%"
  global hist_opts ylab(, format(%9.0f) angle(0) axis(2)) yscale(noline alt axis(2)) ytit("Frequency (Histogram)", axis(2)) ytit(, axis(1)) yscale(alt)


// Globals

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
  global bar lc(white) lw(thin) la(center) fi(100)

// Run code past here





// Have a lovely day!
