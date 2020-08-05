// Figures.

// Figure 1. CONSORT diagram for Experimental Cohort

// Figure 2. Baseline-endline changes for Observational Cohort
use "${directory}/constructed/nontrial.dta", clear

  local x = 0
  foreach var of varlist correct dr_4 re_1 re_3 {
    local ++x
    local i : word `x' of `c(ALPHA)'

    local title : var label `var'
    qui reg `var' i.check##i.wave i.case , cl(qutub_id)
      qui margins check#wave

    marginsplot , ${graph_opts} legend(on) title("Panel `i': `title'" , justification(left) color(black) span pos(11)) ///
      plot1opts(lc(gray) mc(white) lw(none) mlc(gray) msize(*3)) ci1opts(lc(gray) ) ///
      plot2opts(lc(black) mc(black) lw(none) mlc(black) msize(*3)) ci2opts(lc(black)) ///
      ylab(0 "0%" 0.1 "10%" 0.2 "20%" 0.3 "30%" ,notick nogrid) ///
      ytit("") xtit("") xoverhang ///
      xscale(noline) yline(0 , lc(gray)) ///
      xlab(1 "Never PPIA" 2 "PPIA Endline Only" 3 "PPIA Baseline Only" 4 "Always PPIA")

    graph save "${directory}/outputs/`var'.gph", replace

  }

  grc1leg ///
  	"${directory}/outputs/correct.gph" ///
  	"${directory}/outputs/dr_4.gph" ///
  	"${directory}/outputs/re_1.gph" ///
  	"${directory}/outputs/re_3.gph" ///
  ,	legendfrom("${directory}/outputs/correct.gph") c(2) altshrink xcom ycom ///
  	graphregion(color(white))

    graph save  "${directory}/outputs/fig-2.gph" , replace
    graph combine  "${directory}/outputs/fig-2.gph" , ysize(5)
    graph export  "${directory}/outputs/fig-2.eps" , replace

// Figure 3. Baseline balance for Experimental Cohort
use "${directory}/constructed/analysis-ayush-panel.dta", clear
  keep if wave == 0 // use baseline only

  //Create only yesno values for some variables
	foreach var of varlist g_6-g_10 {
		recode `var' (1 2 = 0)(3 = 1)
	}

	unab balance : cp_17_* cp_18 cp_21
	unab process : g_1 g_2 g_3 g_4 g_5 g_6 g_7 g_8 g_9 g_10
	unab quality : correct* dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9

	forest reg ///
		(`balance')(`quality')(`process') ///
		, t(trial_assignment)  controls(i.case) ///
      bh vce(cluster qutub_id) ///
	  graphopts($graph_opts ysize(5) ///
			xtit("{&larr} Favors Control   Favors Treated {&rarr}", size(small)) ///
			xlab(-.2 "-20%" -0.1 "-10%" 0 "0%" 0.1 "10%" .2 "20%"   , labsize(small)) ///
			ylab(,labsize(small)) )

			graph export "${directory}/outputs/fig-3.eps", replace

// Figure 4. Difference-in-differences PPIA impact estimates

  // TB Cases
  use "${directory}/constructed/analysis-trial-did.dta" if case < 7, clear

    local quality "correct dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"

    // Panel A. Diff in Diff ITT
    forest reg ///
      (`quality') ///
        , t(d_treatXpost) controls(i.case d_post) ///
        vce(cluster qutub_id) bh ///
    graphopts($graph_opts title("Panel A: Tuberculosis ITT") ///
    	xtitle("Effect of PPIA program", size(medsmall)) ///
    	xlab(-.40 "-40%" -0.2 "-20%" 0 "0%"  0.2 "20%" 0.4 "40%", labsize(medsmall)) ylab(,labsize(medsmall)))

      graph save "${directory}/outputs/fig-4a.gph", replace

    // Panel B. Diff in Diff TOT
    forest ivregress 2sls ///
      (`quality') ///
        , t((d_totXpost d_tot  = d_treat d_treatXpost)) controls(i.case d_post) ///
        vce(cluster qutub_id) bh  ///
    graphopts($graph_opts title("Panel B: Tuberculosis TOT") ///
    	xtitle("Effect of PPIA program", size(medsmall)) ///
    	xlab(-.40 "-40%" -0.2 "-20%" 0 "0%"  0.2 "20%" 0.4 "40%", labsize(medsmall)) ylab(,labsize(medsmall)))

      graph save "${directory}/outputs/fig-4b.gph", replace

  // Asthma Case
  use "${directory}/constructed/analysis-trial-did.dta" if case == 7, clear

    local quality "dr_1 dr_4 re_1 med_any med_l_any_2 med_l_any_3 med_k_any_9"

    // Panel A. Diff in Diff ITT
    forest reg ///
      (`quality') ///
        , t(d_treatXpost) controls(d_post) ///
        vce(cluster qutub_id) bh ///
    graphopts($graph_opts title("Panel C: Asthma ITT") ///
    	xtitle("Effect of PPIA program", size(medsmall)) ///
    	xlab(-.40 "-40%" -0.2 "-20%" 0 "0%"  0.2 "20%" 0.4 "40%", labsize(medsmall)) ylab(,labsize(medsmall)))

      graph save "${directory}/outputs/fig-4c.gph", replace

    // Panel B. Diff in Diff TOT
    forest ivregress 2sls ///
      (`quality') ///
        , t((d_totXpost d_tot  = d_treat d_treatXpost)) controls(d_post) ///
        vce(cluster qutub_id) bh  ///
    graphopts($graph_opts title("Panel D: Asthma TOT") ///
    	xtitle("Effect of PPIA program", size(medsmall)) ///
    	xlab(-.40 "-40%" -0.2 "-20%" 0 "0%"  0.2 "20%" 0.4 "40%", labsize(medsmall)) ylab(,labsize(medsmall)))

      graph save "${directory}/outputs/fig-4d.gph", replace

  // Combine
  graph combine ///
    "${directory}/outputs/fig-4a.gph" ///
    "${directory}/outputs/fig-4b.gph" ///
    "${directory}/outputs/fig-4c.gph" ///
    "${directory}/outputs/fig-4d.gph" ///
  , c(2) xcom

    graph save  "${directory}/outputs/fig-4.gph" , replace
    graph combine  "${directory}/outputs/fig-4.gph" , ysize(5)
    graph export "${directory}/outputs/fig-4.eps", replace

// End of do-file
