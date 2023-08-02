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

// End
