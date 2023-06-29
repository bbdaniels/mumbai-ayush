// Tables for AYUSH RCT paper

// Table: Descriptives
// Combination level
use "${git}/data/sp-ayush.dta" , clear

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

    graph export "${git}/outputs/meds-1.png" , width(3000) replace

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

    graph export "${git}/outputs/meds-2.png" , width(3000) replace

// Medicine level
use "${git}/data/sp-ayush.dta" , clear

  keep med_k_* med_l_* case

  gen uid = _n

  reshape long med_k_ med_l_ , i(uid) j(med)
    ren med_k_ type
    ren med_l_ anti

    replace anti = 3 if type == 6 & anti == .

  drop *any*
  drop if type == .
  replace type = 50 if type == 0

// Table: Baseline balance
use "${git}/data/sp-ayush.dta" if round == 1 , clear

local variables ///
  correct index_good dr_4 re_1 re_3 re_4  ///
  med index_bad med_l_any_3 med_l_any_2 med_k_any_9 ///
  checklist time p index_sub g11

  iebaltab ///
  `variables' ///
  , groupvar(trial_assignment) control(0) savexlsx("${git}/outputs/t3-balance-rct.xlsx") ///
    cov(i.case) vce(cluster fidcode) replace nonote stats(pair(beta)) ///
    rowvarlabels

  forest reg ///
    (correct index_good index_bad index_sub) ///
    (dr_4 re_1 re_3 re_4) ///
    (med med_l_any_3 med_l_any_2 med_k_any_9) ///
    (checklist time p g11) ///
  , d t(trial_assignment) c(i.case) vce(cluster fidcode) ///
    bh sort(local) graph(xtit("Baseline Imbalance by Assignment"))

    graph export "${git}/outputs/balance-rct.png" , width(3000) replace

// Table: Difference between types
use "${git}/data/sp-pubpri.dta" , clear

local variables ///
  correct index_good dr_4 re_1 re_3 re_4  ///
  index_bad med_l_any_3 med_l_any_2 med_k_any_9 ///
  checklist time p index_sub g11

  iebaltab ///
  `variables' ///
  , groupvar(type) control(0) savexlsx("${git}/outputs/t4-provider-type.xlsx") ///
    cov(i.case) vce(cluster fidcode) replace nonote stats(pair(beta)) ///
    rowvarlabels

// Table: Main Results

local variables ///
  correct index_good dr_4 re_1 re_3   ///
  index_bad med_l_any_3 med_l_any_2 med_k_any_9 ///
  checklist time p index_sub g11

  // Results table: ITT
  estimates clear
  local labels ""
  use "${git}/data/sp-ayush.dta" if ppia_trial != . & case < 7, clear

    qui foreach var of varlist `variables' {
      reg `var' ttreat_rct ppia_trial round i.case , vce(cluster fidcode)

      est sto `var'
      local labels `"`labels' "`:var label `var''" "'
    }

    outwrite `variables' ///
      using "${git}/outputs/t4-reg-itt.xlsx" ///
      , replace col(`labels') stats(N r2)

    rwolf `variables' ///
      , method(regress) ///
        indepvar(ttreat_rct) controls(round ppia_trial i.case) ///
        vce(cluster fidcode) cluster(fidcode)

      mat result = e(RW)'
      outwrite result using "${git}/outputs/t4-reg-itt-rw.xlsx" ///
      , replace col(`labels')

  // Results table: TOT
  estimates clear
  local labels ""
  use "${git}/data/sp-ayush.dta" if ppia_trial != . & case < 7 , clear

    qui foreach var of varlist `variables' {
      ivregress 2sls `var' ///
        (ttreat_tot ppia_facility_1  = ttreat_rct ppia_trial) ///
        round i.case ///
      , first vce(cluster fidcode)

      est sto `var'
      estat firststage, all
        estadd scalar f1 = r(singleresults)[1,4] :`var'
      estat firststage, all
        estadd scalar f2 = r(singleresults)[2,4] :`var'
      local labels `"`labels' "`:var label `var''" "'
    }

    outwrite `variables' ///
      using "${git}/outputs/t4-reg-tot.xlsx" ///
      , replace col(`labels') stats(N r2 f1 f2)

    rwolf `variables' ///
      , method(ivregress) iv(ttreat_rct ppia_trial) ///
        indepvar(ttreat_tot ppia_facility_1) controls(round i.case) ///
        vce(cluster fidcode) cluster(fidcode)

      mat result = e(RW_ttreat_tot)'
      outwrite result using "${git}/outputs/t4-reg-tot-rw.xlsx" ///
      , replace col(`labels')


// Table 5: Cross-sectional with baseline controls

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

    clear
      tempfile x
      save `x' , emptyok

    qui foreach var in `variables' {
      use "${git}/data/ayush-cross-section.dta" if ppia_trial != . & case < 7, clear
      keep `var' ppia_trial case fidcode `var'_bl
        ren `var'_bl lag
        append using `x'
        save `x' , replace
    }

    rwolf `variables' ///
      , method(regress) ///
        indepvar(ppia_trial) controls(lag i.case) ///
        vce(cluster fidcode) cluster(fidcode)

      mat result = e(RW)'
      outwrite result using "${git}/outputs/t5-cs-reg-itt-rw.xlsx" ///
      , replace col(`labels')

  // Results table: TOT
  estimates clear
  local labels ""
  use "${git}/data/ayush-cross-section.dta" if ppia_trial != . & case < 7, clear

    gen lag = .
      lab var lag "Lagged Outcome"

    qui foreach var of varlist `variables' {
      replace lag = `var'_bl

      ivregress 2sls `var' ///
        (ppia_facility_1  = ppia_trial) ///
        lag i.case ///
      , first vce(cluster fidcode)

      est sto `var'
      estat firststage, all
        estadd scalar f1 = r(singleresults)[1,4] :`var'
      estat firststage, all
        estadd scalar f2 = r(singleresults)[2,4] :`var'
      local labels `"`labels' "`:var label `var''" "'
    }

    outwrite `variables' ///
      using "${git}/outputs/t5-cs-reg-tot.xlsx" ///
      , replace col(`labels') stats(N r2 f1)

    clear
      tempfile x
      save `x' , emptyok

    qui foreach var in `variables' {
      use "${git}/data/ayush-cross-section.dta" if ppia_trial != . & case < 7, clear
      keep `var' ppia_facility_1 ppia_trial case fidcode `var'_bl
        ren `var'_bl lag
        append using `x'
        save `x' , replace
    }

    rwolf `variables' ///
      , method(ivregress) iv( ppia_trial) ///
        indepvar( ppia_facility_1) controls(lag i.case) ///
        vce(cluster fidcode) cluster(fidcode)

      mat result = e(RW)'
      outwrite result using "${git}/outputs/t5-cs-reg-tot-rw.xlsx" ///
      , replace col(`labels')


// Table 6: Asthma

local variables ///
  re_1   ///
  index_bad med_l_any_3  med_k_any_9 ///
  checklist time p index_sub g11

  // Results table: ITT
  estimates clear
  local labels ""
  use "${git}/data/ayush-cross-section.dta" if ppia_trial != . & case == 7, clear

    gen lag = .
      lab var lag "Lagged Outcome"

    qui foreach var of varlist `variables' {
      replace lag = `var'_bl
      reg `var' ppia_trial lag i.case , vce(cluster fidcode)

      est sto `var'
      local labels `"`labels' "`:var label `var''" "'
    }

    outwrite `variables' ///
      using "${git}/outputs/t6-as-reg-itt.xlsx" ///
      , replace col(`labels') stats(N r2)

    clear
      tempfile x
      save `x' , emptyok

    qui foreach var in `variables' {
      use "${git}/data/ayush-cross-section.dta" if ppia_trial != . & case == 7, clear
      keep `var' ppia_trial case fidcode `var'_bl
        ren `var'_bl lag
        append using `x'
        save `x' , replace
    }

    rwolf `variables' ///
      , method(regress) ///
        indepvar(ppia_trial) controls(lag i.case) ///
        vce(cluster fidcode) cluster(fidcode)

      mat result = e(RW)'
      outwrite result using "${git}/outputs/t6-as-reg-itt-rw.xlsx" ///
      , replace col(`labels')

  // Results table: TOT
  estimates clear
  local labels ""
  use "${git}/data/ayush-cross-section.dta" if ppia_trial != . & case == 7, clear

    gen lag = .
      lab var lag "Lagged Outcome"

    qui foreach var of varlist `variables' {
      replace lag = `var'_bl

      ivregress 2sls `var' ///
        (ppia_facility_1  = ppia_trial) ///
        lag i.case ///
      , first vce(cluster fidcode)

      est sto `var'
      estat firststage, all
        estadd scalar f1 = r(singleresults)[1,4] :`var'
      estat firststage, all
        estadd scalar f2 = r(singleresults)[2,4] :`var'
      local labels `"`labels' "`:var label `var''" "'
    }

    outwrite `variables' ///
      using "${git}/outputs/t6-as-reg-tot.xlsx" ///
      , replace col(`labels') stats(N r2 f1)

    clear
      tempfile x
      save `x' , emptyok

    qui foreach var in `variables' {
      use "${git}/data/ayush-cross-section.dta" if ppia_trial != . & case == 7, clear
      keep `var' ppia_facility_1 ppia_trial case fidcode `var'_bl
        ren `var'_bl lag
        append using `x'
        save `x' , replace
    }

    rwolf `variables' ///
      , method(ivregress) iv( ppia_trial) ///
        indepvar( ppia_facility_1) controls(lag i.case) ///
        vce(cluster fidcode) cluster(fidcode)

      mat result = e(RW)'
      outwrite result using "${git}/outputs/t6-as-reg-tot-rw.xlsx" ///
      , replace col(`labels')
// End
