// Stack data for rwolf, aes

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
