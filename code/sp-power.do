// Simulate power of SP studies with mismatched cases

// Data generation program -----------------------------------------------------
cap prog drop datagen
prog def datagen

  syntax anything /// anything = correlation of 1 and 2
    , effect(string asis)

  clear
  set obs 300
  gen uid = _n

  // Set up case distribution
  gen assignment = _n <= 150
  gen treatment = (_n <= 120) | (_n > 270)

    isid uid, sort
    randtreat , gen(case0)

    isid uid, sort
    randtreat , gen(case1)

  // Create overall fixed effects
  gen p_fe = rnormal()

    // Set correlation between C1 and C2
    corr2data p_fe0 p_fe1 , cov(1 , `anything' \ `anything' , 1)

  // SP structure
  reshape long case , i(uid) j(round)
    gen treated = treatment * round

  // Outcomes
  gen temp = round*runiform() + treatment*runiform() ///
    + p_fe + (case * p_fe1) + ((1 - case) * p_fe0) ///
    + (case * runiform()) + rnormal()
  egen outcome = std(temp)
  replace outcome = outcome + `effect'*treatment*round

  // Test
  xtset uid round
  reg outcome treated round treatment i.case , cl(uid)

end // -------------------------------------------------------------------------

cap mat drop results
foreach eff of numlist 0.1(.05).4 {
  foreach corr of numlist 0(.1)1 {
    forv iter = 1/100 {
      qui datagen `corr' , effect(`eff')
      mat a = r(table)
      mat a = a[....,1]
      mat a = a' , `corr' , `eff'

      mat results = nullmat(results) ///
        \ a
    }
  }
}

clear
svmat results , n(col)

gen sig = pvalue < 0.05
// graph bar sig, by(c11) over(c10)

tostring c11, format(%3.2f) gen(eff) force

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
