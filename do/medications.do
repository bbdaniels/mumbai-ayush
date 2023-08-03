// Analysis for unlabeled medications

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
      reps(1000) : kl_test

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
      reps(1000) : kl_test

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

  graph export "${git}/outputs/kl-meds.pdf" , replace

********************************************************************************
// All medications regressions -- LASSO
********************************************************************************

  // Baseline
  use "${git}/data/ayush-baseline.dta" , clear

  forest reg ///
    (any_antister) ///
    (any_antibio med_unl_anti med_k_any_6  ) ///
    (any_steroid med_unl_ster med_k_any_9  ) ///
    , t(ppia_trial) c(i.case) bh  ///
      graph(xtit("Balance of Treatment Assignment") title("Baseline Balance") ///
            xlab(-0.1 "-10%" -0.05 "-5%" 0 "Zero" 0.05 "+5%" .1 "+10%") xoverhang)

    graph save "${git}/outputs/lasso-baseline-antister.gph" , replace

  forest reg ///
    (med_k_any_1 med_k_any_4 med_k_any_5  med_k_any_7 ///
     med_k_any_8  med_k_any_10 med_k_any_11 med_k_any_13 ///
     med_k_any_15 med_k_any_16 med_k_any_17 med_k_any_50) ///
     , t(ppia_trial) c(i.case) bh ///
       graph(xtit("Balance of Treatment Assignment") title("Baseline Balance") ///
             xlab(-0.1 "-10%" -0.05 "-5%" 0 "Zero" 0.05 "+5%" .1 "+10%") xoverhang)

    graph save "${git}/outputs/lasso-baseline-othermeds.gph" , replace

  // Endline
  use "${git}/data/ayush-endline.dta" , clear

  forest lasso linear ///
    (any_antister) ///
    (any_antibio med_unl_anti med_k_any_6  ) ///
    (any_steroid med_unl_ster med_k_any_9  ) ///
    , t((ppia_trial)) c(i.case *bl) bh ///
      graph(xtit("ITT Effect of Treatment Assignment") title("Endline LASSO") ///
            xlab(-0.1 "-10%" -0.05 "-5%" 0 "Zero" 0.05 "+5%" .1 "+10%") xoverhang)

    graph save "${git}/outputs/lasso-endline-antister.gph" , replace

  forest lasso linear ///
    (med_k_any_1 med_k_any_4 med_k_any_5  med_k_any_7 ///
     med_k_any_8  med_k_any_10 med_k_any_11 med_k_any_13 ///
     med_k_any_15 med_k_any_16 med_k_any_17 med_k_any_50) ///
     , t((ppia_trial)) c(i.case *bl) bh ///
       graph( xtit("ITT Effect of Treatment Assignment") title("Endline LASSO") ///
             xlab(-0.1 "-10%" -0.05 "-5%" 0 "Zero" 0.05 "+5%" .1 "+10%") xoverhang)

    graph save "${git}/outputs/lasso-endline-othermeds.gph" , replace

  // Combine
  graph combine ///
  "${git}/outputs/lasso-baseline-othermeds.gph" ///
  "${git}/outputs/lasso-baseline-antister.gph" ///
  "${git}/outputs/lasso-endline-othermeds.gph" ///
  "${git}/outputs/lasso-endline-antister.gph" ///
  , altshrink xcom

  graph export "${git}/outputs/lasso-meds.pdf" , replace

********************************************************************************
// All medications regressions -- AES
********************************************************************************

use "${git}/data/ayush-endline.dta" , clear

local variables ///
  correct index_good dr_4 re_1 re_3   ///
  index_bad med_l_any_3 med_l_any_2 med_k_any_9 ///
  checklist time p index_sub g11

  // Results table: ITT
  estimates clear
  local labels ""
  use "${git}/data/ayush-cross-section.dta" if ppia_trial != . & case < 7, clear

    gen lag = .
      lab var lag "Lagged Outcome"

    qui foreach var of varlist `variables' {
      replace lag = `var'_bl
      reg `var' ppia_trial lag i.case , vce(cluster fidcode)

      est sto `var'
      local labels `"`labels' "`:var label `var''" "'
    }

    outwrite `variables' ///
      using "${git}/outputs/t5-cs-reg-itt.xlsx" ///
      , replace col(`labels') stats(N r2)

  prestack ///
    any_antister any_antibio any_steroid ///
    med_k_any_? med_k_any_?? med_l_any_? med_unl_???? ///
  , gen(medtype) cl(cluster) sd(sd)

  reg medtype ppia_trial i.case i.cluster [pweight = 1/sd] ///
  , vce(cluster cluster fidcode)

// End
