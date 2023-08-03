********************************************************************************
// Medicine usage and combinations
********************************************************************************

use "${git}/data/ayush-long.dta" , clear

  foreach var of varlist med_k_any_* med_l_any_* {
    local label : var lab `var'
    local label : word 1 of `label'
    label var `var' "`label'"
  }

  lab var med_k_any_12 "Psychiatric"
  lab var med_k_any_8 "Ulcer"
  lab var med_k_any_10 "Allergy"
  lab var med_k_any_13 "Other"
  lab var med_k_any_16 "Syrup"
  lab var med_k_any_2 "Injectable"
  lab var med_l_any_1 "HRZE"
  lab var med_l_any_3 "Antibiotic"

  betterbarci med_k_any_1 med_k_any_4 med_k_any_5 med_k_any_9 med_l_any_3 med_l_any_2 med_l_any_1 ///
     med_k_any_2 med_k_any_3 med_k_any_7 med_k_any_8 med_k_any_10 med_k_any_11 ///
     med_k_any_12 med_k_any_13 med_k_any_14 med_k_any_15 med_k_any_16 med_k_any_17 med_k_any_50 ///
    , pct barlab xlab(${pct}) xoverhang barc(gray)

    graph export "${git}/outputs/f-medications.pdf" , replace

  foreach var of varlist med_k_any_1 med_k_any_4 med_k_any_5 med_k_any_9 med_l_any_3 med_l_any_2 med_l_any_1 ///
     med_k_any_2 med_k_any_3 med_k_any_7 med_k_any_8 med_k_any_10 med_k_any_11 ///
     med_k_any_12 med_k_any_13 med_k_any_14 med_k_any_15 med_k_any_16 med_k_any_17 med_k_any_50 {
    local label : var lab `var'
    clonevar `label' = `var'
    local vars "`vars' `label'"
  }

  pca `vars'

  loadingplot , max(20) mlabang(30) mlabpos(12) ///
    yscale(noline) xscale(noline) yline(0 , lc(gray)) xline(0 , lc(gray)) ///
    ylab(-.5 -.25 0 .25 .5) xlab(-.5 -.25 0 .25 .5) ///
    mc(black) mlabc(black) title("")

    graph export "${git}/outputs/f-combinations.pdf" , replace

********************************************************************************
// Unlabelled medications KL divergence
********************************************************************************

  // Null distribution loop
  cap prog drop kl_test
  prog def kl_test , rclass

    qui replace ppia_trial = runiform() > 0.5
    kl
    return scalar kl = r(kl)

  end

  // Baseline
  use "${git}/data/ayush-baseline.dta" if ppia_trial != . & case < 7 , clear

    kl
    local result = `r(kl)'

    simulate kl = r(kl) , ///
      reps(5000) : kl_test

    su kl
      local mean = r(mean)
    _pctile kl, p(2.5 97.5)

    histogram kl ///
    , frac width(0.005) ls(none) fc(black%50) barwidth(0.004) ///
      xline(`result' , lc(black)) xline(`r(r1)' `r(r2)') xtit("") title("Baseline") ///
      ytit("Distribution Under Null") ylab(0 "0%" .05 "5%") ///
      xlab(`mean' "{&mu}" `r(r1)' "{&larr} {&alpha}/2" `result' "{&uarr}" `r(r2)' "{&alpha}/2 {&rarr} ")

      graph save "${git}/outputs/kl-baseline.gph" , replace

  // Endline
  use "${git}/data/ayush-endline.dta" if ppia_trial != . & case < 7 , clear

    kl
    local result = `r(kl)'

    simulate kl = r(kl) , ///
      reps(5000) : kl_test

    su kl
      local mean = r(mean)
    _pctile kl, p(2.5 97.5)

    histogram kl ///
    , frac width(0.005) ls(none) fc(black%50) barwidth(0.004) ///
      xline(`result' , lc(black)) xline(`r(r1)' `r(r2)') xtit("") title("Endline") ///
      ytit("Distribution Under Null") ylab(0 "0%" .05 "5%") ///
      xlab(`mean' "{&mu}" `r(r1)' "{&larr} {&alpha}/2" `result' "{&uarr}" `r(r2)' "{&alpha}/2 {&rarr} ")

      graph save "${git}/outputs/kl-endline.gph" , replace

  // Combine
  graph combine ///
  "${git}/outputs/kl-baseline.gph" ///
  "${git}/outputs/kl-endline.gph" ///
  , c(1)

  graph export "${git}/outputs/f-kl-divergence.pdf" , replace

********************************************************************************
// All medications regressions -- LASSO
********************************************************************************

  // Baseline
  use "${git}/data/ayush-baseline.dta" , clear

  forest reg ///
    (correct dr_4 re_1 re_3 ///
    checklist time p index_sub g11) ///
    , t(ppia_trial) c(i.case) bh  ///
      graph(xtit("Standardized Balance") title("Baseline Balance") ///
      xlab(0 "0" -.25 "-0.25" .25 "+0.25") xoverhang note("")) d

    graph save "${git}/outputs/lasso-baseline-quality.gph" , replace

  forest reg ///
    (any_antister ///
    any_antibio med_unl_anti med_k_any_6 ///
    any_steroid med_unl_ster med_k_any_9 ///
    med_l_any_2 med_l_any_3) ///
    , t(ppia_trial) c(i.case) bh  ///
      graph(xtit("Standardized Balance") title("Baseline Balance") ///
      xlab(0 "0" -.25 "-0.25" .25 "+0.25") xoverhang note("")) d

    graph save "${git}/outputs/lasso-baseline-antister.gph" , replace

  forest reg ///
    (med_k_any_1 med_k_any_4 med_k_any_5 med_k_any_7 ///
    med_k_any_8 med_k_any_10 med_k_any_13 ///
    med_k_any_16 med_k_any_17) ///
     , t(ppia_trial) c(i.case) bh ///
       graph(xtit("Standardized Balance") title("Baseline Balance") ///
       xlab(0 "0" -.25 "-0.25" .25 "+0.25") xoverhang note("")) d

    graph save "${git}/outputs/lasso-baseline-othermeds.gph" , replace

  // Endline
  use "${git}/data/ayush-endline.dta" , clear

  forest lasso linear ///
    (correct dr_4 re_1 re_3 ///
    checklist time p index_sub g11) ///
    , t((ppia_trial)) c(i.case *bl) bh ///
      graph(xtit("Standardized ITT") title("Endline LASSO") ///
      xlab(0 "0" -.25 "-0.25" .25 "+0.25") xoverhang note("")) d

    graph save "${git}/outputs/lasso-endline-quality.gph" , replace

  forest lasso linear ///
    (any_antister ///
    any_antibio med_unl_anti med_k_any_6 ///
    any_steroid med_unl_ster med_k_any_9 ///
    med_l_any_2 med_l_any_3) ///
    , t((ppia_trial)) c(i.case *bl) bh ///
      graph(xtit("Standardized ITT") title("Endline LASSO") ///
      xlab(0 "0" -.25 "-0.25" .25 "+0.25") xoverhang note("")) d

    graph save "${git}/outputs/lasso-endline-antister.gph" , replace

  forest lasso linear ///
    (med_k_any_1 med_k_any_4 med_k_any_5 med_k_any_7 ///
    med_k_any_8 med_k_any_10 med_k_any_13 ///
    med_k_any_16 med_k_any_17) ///
     , t((ppia_trial)) c(i.case *bl) bh ///
       graph( xtit("Standardized ITT") title("Endline LASSO") ///
       xlab(0 "0" -.25 "-0.25" .25 "+0.25") xoverhang note("")) d

    graph save "${git}/outputs/lasso-endline-othermeds.gph" , replace

  // Combine
  graph combine ///
  "${git}/outputs/lasso-baseline-othermeds.gph" ///
  "${git}/outputs/lasso-baseline-antister.gph" ///
  "${git}/outputs/lasso-baseline-quality.gph" ///
  "${git}/outputs/lasso-endline-othermeds.gph" ///
  "${git}/outputs/lasso-endline-antister.gph" ///
  "${git}/outputs/lasso-endline-quality.gph" ///
  , altshrink xcom c(3)

  graph export "${git}/outputs/f-balance-lasso.pdf" , replace

// End
