// Analysis for unlabeled medications

// All medications regressions -- LASSO
use "${git}/data/ayush-baseline.dta" , clear

  forest reg ///
    (any_antister) ///
    (any_antibio med_unl_anti med_k_any_6  ) ///
    (any_steroid med_unl_ster med_k_any_9  ) ///
    , t(ppia_trial) c(i.case) bh  ///
      graph(xtit("Balance of Treatment Assignment") title("Baseline Balance") ///
            xlab(-0.1 "-10%" -0.05 "-5%" 0 "Zero" 0.05 "+5%" .1 "+10%"))

    graph save "${git}/outputs/lasso-baseline-antister.gph" , replace

  forest reg ///
    (med_k_any_1 med_k_any_4 med_k_any_5  med_k_any_7 ///
     med_k_any_8  med_k_any_10 med_k_any_11 med_k_any_13 ///
     med_k_any_15 med_k_any_16 med_k_any_17 med_k_any_50) ///
     , t(ppia_trial) c(i.case) bh ///
       graph(xtit("Balance of Treatment Assignment") title("Baseline Balance") ///
             xlab(-0.1 "-10%" -0.05 "-5%" 0 "Zero" 0.05 "+5%" .1 "+10%"))

    graph save "${git}/outputs/lasso-baseline-othermeds.gph" , replace

use "${git}/data/ayush-endline.dta" , clear

  forest lasso linear ///
    (any_antister) ///
    (any_antibio med_unl_anti med_k_any_6  ) ///
    (any_steroid med_unl_ster med_k_any_9  ) ///
    , t((ppia_trial)) c(i.case *bl) bh ///
      graph(xtit("ITT Effect of Treatment Assignment") title("Endline LASSO") ///
            xlab(-0.1 "-10%" -0.05 "-5%" 0 "Zero" 0.05 "+5%" .1 "+10%"))

    graph save "${git}/outputs/lasso-endline-antister.gph" , replace

  forest lasso linear ///
    (med_k_any_1 med_k_any_4 med_k_any_5  med_k_any_7 ///
     med_k_any_8  med_k_any_10 med_k_any_11 med_k_any_13 ///
     med_k_any_15 med_k_any_16 med_k_any_17 med_k_any_50) ///
     , t((ppia_trial)) c(i.case *bl) bh ///
       graph( xtit("ITT Effect of Treatment Assignment") title("Endline LASSO") ///
             xlab(-0.1 "-10%" -0.05 "-5%" 0 "Zero" 0.05 "+5%" .1 "+10%"))

    graph save "${git}/outputs/lasso-endline-othermeds.gph" , replace

    graph combine ///
    "${git}/outputs/lasso-baseline-antister.gph" ///
    "${git}/outputs/lasso-baseline-othermeds.gph" ///
    "${git}/outputs/lasso-endline-antister.gph" ///
    "${git}/outputs/lasso-endline-othermeds.gph" ///
    , altshrink

    graph export "${git}/outputs/lasso-meds.pdf" , replace


// All medications regressions -- AES
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




// Medicine level
/*
use "${git}/data/sp-ayush.dta" if round == 2, clear


  keep med_k_* med_l_* case med_b2* ppia_trial

  gen uid = _n

  reshape long med_k_ med_l_ med_b2_ , i(uid) j(med)
    ren med_k_ type
    ren med_l_ anti
    ren med_b2_ desc

    replace anti = 3 if type == 6 & anti == .

  drop *any*
  drop if type == .
  replace type = 50 if type == 0

  keep if ppia_trial < .
  keep if type == 1

  preserve
    keep desc
    ren desc desc2
    tempfile blank
    save `blank'
  restore
    cross using `blank'
    strdist desc desc2

  cap prog drop rstringer
  prog def rstringer , rclass
  preserve
    bsample
    su strdist
    return scalar mean = r(mean)
  restore
  end

  simulate m = r(mean) ///
    , reps(100) : rstringer

  preserve
  keep if ppia_trial == 0
    keep desc
    ren desc desc2
    tempfile treat
    save `treat'
  restore
  keep if ppia_trial == 1
  cross using `treat'
  strdist desc desc2
*/

// End
