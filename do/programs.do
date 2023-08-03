// Regression setup
cap prog drop ayushreg
prog def ayushreg
syntax anything using

  local rw = subinstr(`"`using'"',".xlsx","-rw.xlsx",.)

  // Baseline regression
  use "${git}/data/ayush-baseline.dta" if ppia_trial != . & case < 7, clear

  rwolf `anything' ///
    , method(regress) ///
      indepvar(ppia_trial) controls(i.case) ///
      vce(cluster fidcode) cluster(fidcode)

      mat result = e(RW)'

      outwrite result `rw' ///
      , replace col(`labels') sheet("Baseline")

  pca `anything'
  predict index
    lab var index "PCA"
    clonevar index_bl = index

  preserve
    collapse (mean) index_bl , by(fidcode)
    tempfile index
    save `index'
  restore

  qui foreach var of varlist index `anything' {
    reg `var' ppia_trial i.case , vce(cluster fidcode)
      est sto `var'
    local labels `"`labels' "`:var label `var''" "'
  }

  prestack `anything' ///
  , gen(medtype) cl(cluster) sd(sd)

  reg medtype ppia_trial i.case  i.cluster [pweight = 1/sd] ///
    , vce(cluster fidcode)

    est sto aes

  preserve
    ren medtype medtype_bl
    collapse (mean) medtype_bl , by(fidcode cluster)
    tempfile aes
    save `aes'
  restore

  outwrite aes index `anything' ///
    `using' ///
    , replace col("AES" `labels') stats(N r2) sheet("Baseline") drop(i.cluster)

  // Results table: ITT
  estimates clear
  local labels ""
  use "${git}/data/ayush-endline.dta" if ppia_trial != . & case < 7, clear

  rwolf `anything' ///
    , method(regress) ///
      indepvar(ppia_trial) controls(i.case) ///
      vce(cluster fidcode) cluster(fidcode)

      mat result = e(RW)'

      outwrite result `rw' ///
      , modify col(`labels') sheet("ITT")

    pca `anything'
    predict index
      lab var index "PCA"

    qui foreach var of varlist index `anything' {
      reg `var' ppia_trial i.case , vce(cluster fidcode)

      est sto `var'
      local labels `"`labels' "`:var label `var''" "'
    }

  prestack `anything' ///
  , gen(medtype) cl(cluster) sd(sd)

  reg medtype ppia_trial i.case i.cluster [pweight = 1/sd] ///
    , vce(cluster fidcode)

  est sto aes

  outwrite aes index `anything' ///
    `using' ///
    , modify col("AES" `labels') stats(N r2) sheet("ITT") drop(i.cluster)

  // Results table: TOT
  estimates clear
  local labels ""
  use "${git}/data/ayush-endline.dta" if ppia_trial != . & case < 7, clear

  rwolf `anything' ///
    , method(ivregress) iv(ppia_trial) ///
      indepvar(ppia_facility_1) controls(round i.case) ///
      vce(cluster fidcode) cluster(fidcode)

    mat result = e(RW)'
    outwrite result `rw' ///
    , modify col(`labels') sheet("TOT")

    pca `anything'
    predict index
      lab var index "PCA"

    qui foreach var of varlist index `anything' {
      ivregress 2sls `var' ///
        (ppia_facility_1  = ppia_trial) ///
        i.case , vce(cluster fidcode)

      est sto `var'
      estat firststage, all
        estadd scalar f1 = r(singleresults)[1,4] :`var'
      local labels `"`labels' "`:var label `var''" "'
    }

  prestack `anything' ///
  , gen(medtype) cl(cluster) sd(sd)

  ivregress 2sls medtype (ppia_facility_1  = ppia_trial) ///
      i.case i.cluster [pweight = 1/sd] ///
    , vce(cluster fidcode)

  est sto aes

  outwrite aes index `anything' ///
    `using' ///
    , modify col("AES" `labels') stats(N r2 f1) sheet("TOT") drop(i.cluster)

  // Results table: ITT + baseline (ANCOVA)
  estimates clear
  local labels ""
    clear
    tempfile x
    save `x' , emptyok

    qui foreach var in `anything' {
      use "${git}/data/ayush-endline.dta" if ppia_trial != . & case < 7, clear
      keep `var' ppia_trial case fidcode `var'_bl
        ren `var'_bl lag
        append using `x'
        save `x' , replace
    }

    rwolf `anything' ///
      , method(regress) ///
        indepvar(ppia_trial) controls(lag i.case) ///
        vce(cluster fidcode) cluster(fidcode)

        mat result = e(RW)'

        outwrite result `rw' ///
        , modify col(`labels') sheet("ANCOVA")

    use "${git}/data/ayush-endline.dta" if ppia_trial != . & case < 7, clear
    merge m:1 fidcode using  `index' , keep(3) keepusing(index_bl) nogen

    pca `anything'
    predict index
      lab var index "PCA"

    gen lag = .
      lab var lag "Lagged Outcome"

    qui foreach var of varlist index `anything' {
      replace lag = `var'_bl
      reg `var' ppia_trial lag i.case , vce(cluster fidcode)

      est sto `var'
      local labels `"`labels' "`:var label `var''" "'
    }

  prestack `anything' ///
  , gen(medtype) cl(cluster) sd(sd)

  merge m:1 fidcode cluster using `aes' , keep(3) nogen
  replace lag = medtype_bl

  reg medtype ppia_trial lag i.case i.cluster [pweight = 1/sd] ///
    , vce(cluster fidcode)

  est sto aes

  outwrite aes index `anything' ///
    `using' ///
    , modify col("AES" `labels') stats(N r2) sheet("ANCOVA") drop(i.cluster)

  // Results table: Asthma
  estimates clear
  local labels ""
  use "${git}/data/ayush-endline.dta" if ppia_trial != . & case == 7, clear

  rwolf `anything' ///
    , method(regress) ///
      indepvar(ppia_trial) controls(i.case) ///
      vce(cluster fidcode) cluster(fidcode)

      mat result = e(RW)'

      outwrite result `rw' ///
      , modify col(`labels') sheet("Asthma")

    pca `anything'
    predict index
      lab var index "PCA"

    qui foreach var of varlist index `anything' {
      reg `var' ppia_trial i.case , vce(cluster fidcode)

      est sto `var'
      local labels `"`labels' "`:var label `var''" "'
    }

  prestack `anything' ///
  , gen(medtype) cl(cluster) sd(sd)

  reg medtype ppia_trial i.case i.cluster [pweight = 1/sd] ///
    , vce(cluster fidcode)

  est sto aes

  outwrite aes index `anything' ///
    `using' ///
    , modify col("AES" `labels') stats(N r2) sheet("Asthma") drop(i.cluster)

end

// Stack data for AES

cap prog drop prestack
prog def prestack

  syntax anything , GENerate(string asis) CLuster(string asis) SD(string asis)

  preserve
    clear
    tempfile all
    save `all' , emptyok
  restore

  local x = 0
  qui foreach var of varlist `anything' {
  local ++x
  su `var'
  preserve
    gen `sd' = `r(sd)'
    clonevar `generate' = `var'
    gen `cluster' = `x'
    append using `all'
    save `all' , replace
  restore
  }

  use `all' , clear

end

// KL divergence for medications
cap prog drop kl
prog def kl , rclass

preserve
qui {
keep med_k_* case med_b2* ppia_trial
  gen uid = _n

reshape long med_k_ med_l_ med_b2_ , i(uid) j(med)
  ren med_k_ type
  ren med_b2_ desc
  keep if type == 1

  replace desc = upper(trim(itrim(desc)))
  replace desc = subinstr(desc,"(","",.)
  replace desc = subinstr(desc,")","",.)
  replace desc = subinstr(desc,"HALF","",.)
  replace desc = subinstr(desc,"SEMI","",.)
  replace desc = subinstr(desc,"AMOXYCILLIN","",.)
  replace desc = subinstr(desc,"DEXAMETHASONE","",.)
  replace desc = subinstr(desc,"RANITIDINE","",.)
  replace desc = subinstr(desc,"SYRUP","",.)
  replace desc = subinstr(desc,"+","",.)
  replace desc = subinstr(desc,"AND","",.)
  replace desc = subinstr(desc,"-","",.)
  replace desc = subinstr(desc,"CAPSULES","",.)
  replace desc = subinstr(desc,"CAPSULE","",.)
  replace desc = subinstr(desc,"&","",.)
  replace desc = upper(trim(itrim(desc)))

gen n = 1
collapse (sum) n , by(desc ppia_trial)
  keep if ppia_trial < .
reshape wide n , j(ppia_trial) i(desc)
  gen c0 = n0 == .
  bys c0 : gen c02 = _N
    replace n0 = 1/c02 if c0 == 1
    replace n0 = n0 - 1/c02 if c0 == 0
  gen c1 = n1 == .
  bys c1 : gen c12 = _N
    replace n1 = 1/c12 if c1 == 1
    replace n1 = n1 - 1/c12 if c1 == 0

  gen n = n0 +n1
  drop if n == .
  drop if desc == ""

egen N0 = sum(n0)
egen N1 = sum(n1)
gen p1 = n1/N1
gen p0 = n0/N0
gen kl = p0*ln(p0/p1)
gen check = sum(kl)

return scalar kl = check[`c(N)']
}

end

// End
