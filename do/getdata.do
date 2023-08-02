// Prep non-shareable data

// Baseline unlabelled medications
import excel using "${aux}/data/raw/wave-0/Med Cleaning/Unlabelled_Entry.Devinder.xlsx" , clear first
  drop in 1/2

  save "${git}/data/baseline-unlab.dta" , replace

import excel using "${aux}/data/raw/wave-0/Med Cleaning/Unlabelled_Entry.Purshottam.xlsx" , clear first
  drop in 1/2
  append using "${git}/data/baseline-unlab.dta"

  drop if form == ""
  keep form med_k_
  bys form: gen med = _n
  destring med_k_ , replace
  reshape wide med_k_ , i(form) j(med)

  egen med_unl_anti = anymatch(med_k_?) , v(6)
  egen med_unl_ster = anymatch(med_k_?) , v(9)

  save "${git}/data/baseline-unlab.dta" , replace

// Endline unlabelled medications
import excel using "${aux}/data/raw/wave-1/Med Cleaning/Unlabelled_Entry.Template_iserdd.xlsx" , clear first
  drop in 1/2

  drop if med_no == ""
  keep form med_k_
  split med_k_ , p(,)
    drop med_k_

  destring med_k_? , replace

  egen med_unl_anti = anymatch(med_k_?) , v(6)
  egen med_unl_ster = anymatch(med_k_?) , v(9)

  save "${git}/data/endline-unlab.dta" , replace


// PPIA data
use "/Users/bbdaniels/Library/CloudStorage/Box-Box/Qutub/MUMBAI/constructed/ppia-patients.dta" , clear
collapse (count) ppia_n = provider_n_patients , by(path_providerid)
  ren path_providerid uatbc_facilitycode
  lab var ppia_n "PPIA Patients"
  tempfile ppia
  save `ppia'

// Codefile
use "${box}/Master_Code_File.dta" , clear
  keep if qutub_sample > 6
  merge m:1 uatbc_facilitycode using `ppia' , keep(1 3) nogen

  keep qutub_id qutub_sample ppia_facility_0 ppia_facility_1 ppia_n trial_assignment
  ren qutub_id fid

  iecodebook export ///
    using "${git}/data/codefile.xlsx" ///
    , save sign reset replace

// End
