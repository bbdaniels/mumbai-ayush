// Simulate power of SP studies with mismatched cases

// Get correlations for CXR for SP2-4

use "${directory}/constructed/sp_both.dta" , clear

  keep qutub_id case wave re_1
  duplicates drop qutub_id case wave , force
  reshape wide re_1 , i(qutub_id wave) j(case)

  collapse (firstnm) re_12 re_13 re_14 , by(qutub_id)

  corr re_12 re_13
  corr re_13 re_14
  corr re_12 re_14

// Data generation program -----------------------------------------------------
cap prog drop datagen
prog def datagen

  syntax /// anything = correlation of 1 and 2
    , effect(string asis)

  clear
  set obs 300
  gen uid = _n

  // Set up case distribution
  gen assignment = _n <= 150
  gen treatment = (_n <= 120) | (_n > 270)

    isid uid, sort
    randtreat , gen(case0) multiple(3) unequal(1/4 1/4 2/4)
      replace case0 = case0 + 2

    isid uid, sort
    randtreat , gen(case1) multiple(3) unequal(1/4 1/4 2/4)
      replace case1 = case1 + 2

  // Create overall fixed effects
  gen p_fe = rnormal()

    // Set correlation between C1 and C2
    corr2data p_fe2 p_fe3 p_fe4 , cov(1 , 0.1126 , 0.2393 \ 0.1126 , 1 , -0.0922 \ 0.2393 , -0.0922 , 1)

  // SP structure
  reshape long case , i(uid) j(round)
    gen treated = treatment * round
    expand 2 , gen(false)
    replace case = 1 if false == 1

  // Outcomes
  gen temp = round*runiform() + treatment*runiform() + p_fe ///
    + (case * runiform()) + rnormal()
  forv i = 2/4 {
    replace temp = temp + p_fe`i' if case == `i'
  }
  egen outcome = std(temp)
  replace outcome = outcome + `effect'*treatment*round

  // Test
  reg outcome treated round treatment i.case , cl(uid)

end // -------------------------------------------------------------------------

cap mat drop results
foreach eff of numlist 0.1(.05).4 {
  forv iter = 1/100 {
    qui datagen , effect(`eff')
    mat a = r(table)
    mat a = a[....,1]
    mat a = a' , `eff'

    mat results = nullmat(results) ///
      \ a
  }
}

clear
svmat results , n(col)

gen sig = pvalue < 0.05
// graph bar sig, by(c11) over(c10)

replace c10 = c10 * .5 // Convert to binary p.p. (sigma = 0.5)
tostring c10, format(%3.2f) gen(eff) force
graph bar sig , over(eff)
-
// Graph power
qui levelsof eff , local(effs)
  local x = 1
  foreach eff in `effs' {
    local graphs `"`graphs' (lpoly sig c10 if eff == "`eff'" , degree(1) lw(thick))"'
    local legend `"`x' "`eff'" `legend' "'
    local ++x
  }

  tw `graphs' ///
    , legend(on c(1) pos(3) title("Effect Size") order(`legend')) ///
      xtit("Correlation between Case 1 and Case 2 performance") ///
      ytit("Power") ylab(0 "0%" .2 "20%" .4 "40%" .6 "60%" .8 "80%" 1 "100%") ///
      yline(.8 , lc(black) lp(dash))

  graph export "${directory}/outputs/power-simulations.eps" , replace


// End of power calculations
