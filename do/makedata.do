// Get raw data from box

// PPIA data
use "/Users/bbdaniels/Library/CloudStorage/Box-Box/SP Raw/Mumbai/clean/mumbai-ppia.dta" , clear


// Codefile
use "${box}/Master_Code_File.dta" , clear
  keep if qutub_sample > 6

  keep qutub_id qutub_sample ppia_facility_0 ppia_facility_1 uatbc_facilitycode trial_assignment
  ren qutub_id fid

  iecodebook export ///
    using "${git}/data/codefile.xlsx" ///
    , save sign reset replace

// Ayush SP data
use "${box}/sp-wave-0.dta" , clear
  ren g_* g*
append using "${box}/sp-wave-1.dta" , gen(round) force
  recode g1-g10 (1/2=0)(3/max=1)

  replace ppia_facility_1 = 1 if ppia_facility_0 == 1

  replace round = round + 1
  lab def round 1 "Round 1" 2 "Round 2"
    lab val round round

  ren qutub_id fid
  drop qutub*

  merge m:1 fid using "${git}/data/ppia-codefile.dta" , keep(3)
  replace dr_4 = 0 if dr_4 == 3

  drop *given

  egen fidcode = group(fid)
    lab var fidcode "Provider Code"

  pca g1-g10
  predict index_sub
    lab var index_sub "Non-Medical Quality Index"

  pca med_l_any_3 med_l_any_2 med_k_any_9
  predict index_bad
    lab var index_bad "Unnecessary Medications Index"

  lab var trial_assignment "Assigned Treatment"
  clonevar ppia_trial = trial_assignment

  pca re_1 re_3 re_4
  predict index_good
    lab var index_good "TB Testing Index"

  gen r2 = round == 2
    lab var r2 "Round 2"
  gen ttreat_rct = ppia_trial*r2
    lab var ttreat_rct "RCT DID Interaction (ITT)"
  gen ttreat_tot = ppia_facility_1*r2
    lab var ttreat_tot "DID Interaction (TOT)"

  iecodebook export ///
    using "${git}/data/sp-ayush.xlsx" ///
    , save sign reset replace

  // Baseline balance
  preserve
  keep if round == 1
  save "${git}/data/ayush-baseline.dta", replace

  collapse (mean) ///
    correct index_good dr_4 re_1 re_3   ///
    index_bad med_l_any_3 med_l_any_2 med_k_any_9 ///
    checklist time p index_sub g11 ///
    , by(fidcode) fast

    ren * *_bl
    ren fidcode_bl fidcode

    tempfile baseline
      save `baseline' , replace

  restore

  // Baseline controls
  keep if round == 2
  merge m:1 fidcode using `baseline' , keep(1 3) nogen
  save "${git}/data/ayush-cross-section.dta", replace


// Public sector SP data
use "https://github.com/bbdaniels/mumbai-public/raw/main/constructed/sp-data.dta" , clear

  ren qutub_id fid
  unab vars :  *

  append using "${git}/data/sp-ayush.dta" , gen(a)
    drop if (case == 2 | case == 3 | case == 7) & a == 1
    replace case = 2 if case == 4 & a == 1
    drop a

  keep `vars'
  replace type = 0 if type == .
    lab def type 0 "AYUSH" , modify


  egen fidcode = group(fid)
    lab var fidcode "Provider Code"

  pca g1-g10
  predict index_sub
    lab var index_sub "Non-Medical Quality Index"

  pca med_l_any_3 med_l_any_2 med_k_any_9
  predict index_bad
    lab var index_bad "Unnecessary Medications Index"

  pca re_1 re_3 re_4
  predict index_good
    lab var index_good "TB Testing Index"

  iecodebook export ///
    using "${git}/data/sp-pubpri.xlsx" ///
    , save sign reset replace

// End
