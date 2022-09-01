// Figures.

// Figure 1. CONSORT diagram for Experimental Cohort
use "${directory}/constructed/analysis-ayush-panel.dta", clear
  egen ptag = tag(qutub_id)
  bys qutub_id: egen minwave = min(wave)
  bys qutub_id: egen maxwave = max(wave)

  ta ptag
  ta ptag trial_assignment , m
  ta trial_assignment trial_treatment if ptag
  ta trial_assignment minwave if ptag
  ta trial_assignment maxwave if ptag

// Figure 2. Baseline-endline changes for Observational Cohort
use "${directory}/constructed/analysis-ayush-panel.dta", clear
  keep if case < 7
	
	expand 2 , gen(all)
	  replace group = 0 if all == 1
		lab def group 0 "Pooled" , add

  local x = 0
  foreach var of varlist correct dr_4 re_1 re_3 {
    local ++x
    local i : word `x' of `c(ALPHA)'

    local title : var label `var'
		
	  lab var `var' ""

    betterbar `var' , over(wave) by(group) barlab pct ci ///
      ${graph_opts} title("Panel `i': `title'") ///
      barcolor(gs12 gs8) ///
      legend(on) xoverhang yscale(noline) ///
      xlab(0 "0%" 0.1 "10%" 0.2 "20%" 0.3 "30%" .4 "40%")

    graph save "${directory}/outputs/`var'.gph", replace

  }

  grc1leg ///
  	"${directory}/outputs/correct.gph" ///
  	"${directory}/outputs/dr_4.gph" ///
  	"${directory}/outputs/re_1.gph" ///
  	"${directory}/outputs/re_3.gph" ///
  ,	legendfrom("${directory}/outputs/correct.gph") c(2) altshrink xcom ycom ///
  	graphregion(color(white))

    graph draw, ysize(5)
    graph export  "${directory}/outputs/fig-2.eps" , replace

// Figure 3. Baseline balance for Experimental Cohort
use "${directory}/constructed/analysis-ayush-panel.dta", clear
  keep if wave == 0 // use baseline only

  //Create only yesno values for some variables
	foreach var of varlist g_6-g_10 {
		recode `var' (1 2 = 0)(3 = 1)
	}
	
	lab var correct "Correct Management"

	unab balance : cp_17_* cp_18 cp_21
	unab process : g_1 g_2 g_3 g_4 g_5 g_6 g_7 g_8 g_9 g_10
	unab quality : correct* dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 ///
				   med_l_any_3 med_k_any_9

	forest reg ///
		(`balance' `quality' `process') ///
		, t(trial_assignment)  controls(i.case) ///
      vce(cluster qutub_id) ///
	  graphopts($graph_opts ysize(5) ///
			xtit("{&larr} Favors Control   Favors Treated {&rarr}", size(small)) ///
			xlab(-.2 "-20%" -0.1 "-10%" 0 "0%" 0.1 "+10%" .2 "+20%"   , labsize(small)) ///
			ylab(,labsize(small)) ) sort(global) mde

			graph export "${directory}/outputs/fig-3.eps", replace

// Figure 4. Difference-in-differences PPIA impact estimates

  // TB Cases
  use "${directory}/constructed/analysis-trial-did.dta" if case < 7, clear

    local quality "correct dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"

    // Panel A. Diff in Diff ITT
    forest reg ///
      (`quality') ///
        , t(d_treatXpost) controls(i.case d_post) ///
        vce(cluster qutub_id) mde sort(global) ///
    graphopts($graph_opts title("Panel A: Tuberculosis (ITT)") ///
    	xtitle("Effect of randomization to PPIA program offer", size(medsmall)) ///
      xlab(-0.15 "-15%" -0.1 "-10%" -0.05 "-5%"  0 "0%"  0.05 "+5%" 0.1 "+10%" 0.15 "+15%", labsize(medsmall)) ylab(,labsize(medsmall)))

      graph save "${directory}/outputs/fig-4a.gph", replace

    // Panel B. Diff in Diff TOT
    forest ivregress 2sls ///
      (`quality') ///
        , t((d_totXpost d_tot  = d_treat d_treatXpost)) controls(i.case d_post) ///
        vce(cluster qutub_id) mde  ///
    graphopts($graph_opts title("Panel B: Tuberculosis TOT") ///
    	xtitle("Effect of PPIA program", size(medsmall)) ///
    	xlab(-.40 "-40%" -0.2 "-20%" 0 "0%"  0.2 "+20%" 0.4 "+40%", labsize(medsmall)) ylab(,labsize(medsmall)))

      graph save "${directory}/outputs/fig-4b.gph", replace

  // Asthma Case
  use "${directory}/constructed/analysis-trial-did.dta" if case == 7, clear

    local quality "dr_1 dr_4 re_1 med_any med_l_any_2 med_l_any_3 med_k_any_9"

    // Panel A. Diff in Diff ITT
    forest reg ///
      (`quality') ///
        , t(d_treatXpost) controls(d_post) ///
        vce(cluster qutub_id) mde sort(global)  ///
    graphopts($graph_opts title("Panel B: Asthma (ITT)") ///
    	xtitle("Effect of randomization to PPIA program offer", size(medsmall)) ///
      xlab(-0.15 "-15%" -0.1 "-10%" -0.05 "-5%"  0 "0%"  0.05 "+5%" 0.1 "+10%" 0.15 "+15%", labsize(medsmall)) ylab(,labsize(medsmall)))

      graph save "${directory}/outputs/fig-4c.gph", replace

    // Panel B. Diff in Diff TOT
    forest ivregress 2sls ///
      (`quality') ///
        , t((d_totXpost d_tot  = d_treat d_treatXpost)) controls(d_post) ///
        vce(cluster qutub_id) mde  ///
    graphopts($graph_opts title("Panel D: Asthma TOT") ///
    	xtitle("Effect of PPIA program", size(medsmall)) ///
    	xlab(-.40 "-40%" -0.2 "-20%" 0 "0%"  0.2 "+20%" 0.4 "+40%", labsize(medsmall)) ylab(,labsize(medsmall)))

      graph save "${directory}/outputs/fig-4d.gph", replace

  // Combine
  graph combine ///
    "${directory}/outputs/fig-4a.gph" ///
    "${directory}/outputs/fig-4c.gph" ///
  , c(1) xcom altshrink

    graph draw, ysize(6)
    graph export "${directory}/outputs/fig-4.eps", replace

// End of do-file
