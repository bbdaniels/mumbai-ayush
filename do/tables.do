// Tables for AYUSH RCT paper

// Table: Difference between types
use "${git}/data/sp-pubpri.dta" , clear

local variables ///
  correct index_good dr_4 re_1 re_3 re_4  ///
  index_bad med_l_any_3 med_l_any_2 med_k_any_9 ///
  checklist time p index_sub g11

  iebaltab ///
  `variables' ///
  , groupvar(type) control(0) savexlsx("${git}/outputs/t-pubpri.xlsx") ///
    cov(i.case) vce(cluster fidcode) replace nonote stats(pair(beta)) ///
    rowvarlabels

********************************************************************************
// All medications regressions + AES
********************************************************************************

qui ayushreg ///
  any_antister ///
  any_antibio med_unl_anti med_k_any_6 ///
  any_steroid med_unl_ster med_k_any_9 ///
  med_l_any_2 med_l_any_3 ///
  using "${git}/outputs/t-antister.xlsx"

qui ayushreg ///
  med_k_any_1 med_k_any_4 med_k_any_5 med_k_any_7 ///
  med_k_any_8 med_k_any_10 med_k_any_13 ///
  med_k_any_16 med_k_any_17 med_k_any_50 ///
  using "${git}/outputs/t-medications.xlsx"

qui ayushreg  ///
  correct dr_4 re_1 re_3 ///
  checklist time p index_sub g11 ///
  using "${git}/outputs/t-quality.xlsx"

-
// Rwolf leftover

    rwolf `variables' ///
      , method(regress) ///
        indepvar(ttreat_rct) controls(round ppia_trial i.case) ///
        vce(cluster fidcode) cluster(fidcode)

      mat result = e(RW)'
      outwrite result using "${git}/outputs/t4-reg-itt-rw.xlsx" ///
      , replace col(`labels')

// TOT FS/Rwolf leftover
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

  rwolf `variables' ///
    , method(ivregress) iv(ttreat_rct ppia_trial) ///
      indepvar(ttreat_tot ppia_facility_1) controls(round i.case) ///
      vce(cluster fidcode) cluster(fidcode)

    mat result = e(RW_ttreat_tot)'
    outwrite result using "${git}/outputs/t4-reg-tot-rw.xlsx" ///
    , replace col(`labels')

// End
