// Construct release ready data

// Ayush SP data
use "${git}/raw/sp-raw.dta" , clear

  replace ppia_facility_1 = 1 if ppia_facility_0 == 1

  lab var med_k_any_1 "Unlabelled"
  lab var med_k_any_12 "Psychiatric"
  lab var med_k_any_8 "Anti-Ulcer"
  lab var med_k_any_10 "Anti-Allergy"
  lab var med_k_any_13 "Other Type"
  lab var med_k_any_16 "Cough Syrup"
  lab var med_k_any_2 "Injectable"
  lab var med_l_any_1 "Anti-TB"
  lab var med_k_any_11 "Cardiac"
  lab var med_k_any_5 "Homeopathic"
  lab var med_k_any_4 "Ayurvedic"
  lab var correct "Correct"
  lab var dr_4 "Referral"
  lab var time "Duration (Mins)"
  lab var g11 "SP Provider Rating"

  egen med_dispense = rowmean(med_a_*)
    replace med_dispense = 2-med_dispense
    lab var med_dispense "Proportion Dispensed"

  replace round = round + 1
  lab def round 1 "Round 1" 2 "Round 2"
    lab val round round

  ren qutub_id fid
  drop qutub*

  merge m:1 fid using "${git}/raw/codefile.dta" , keep(3) nogen
  replace dr_4 = 0 if dr_4 == 3

  egen fidcode = group(fid)
    lab var fidcode "Provider Code"

  replace med_any = med > 0

  replace p_2b = p_2b/100
    lab var p_2b "Meds Price (x100)"
    lab var p_2 "Meds Price Known"
    lab var p_2a "Meds Itemized"

  pca g1-g10
  predict index_sub
    label var index_sub "Non-Medical"

  lab var trial_assignment "Assigned Treatment"
  clonevar ppia_trial = trial_assignment

  gen r2 = round == 2
    lab var r2 "Round 2"
  gen ttreat_rct = ppia_trial*r2
    lab var ttreat_rct "RCT DID Interaction (ITT)"
  gen ttreat_tot = ppia_facility_1*r2
    lab var ttreat_tot "DID Interaction (TOT)"

  drop *unlab*

  isid round form, sort
  duplicates drop round fidcode case, force

  // Save two-period data
  save "${git}/data/ayush-long.dta" , replace

  // Save baseline data
  preserve
    keep if round == 1
      merge 1:1 form using "${git}/raw/baseline-unlab.dta" , keep(1 3) nogen
      replace med_unl_anti = 0 if med_unl_anti == .
        lab var med_unl_anti "Unlabelled Antibiotic"
      replace med_unl_ster = 0 if med_unl_ster == .
        lab var med_unl_ster "Unlabelled Steroid"

      gen any_steroid = (med_unl_ster == 1 | med_k_any_9 == 1)
        lab var any_steroid "Any Steroid"
        lab var med_k_any_9 "Labeled Steroid"
      gen any_antibio = (med_unl_anti == 1 | med_k_any_6 == 1)
        lab var any_antibio "Any Antibiotic"
        lab var med_k_any_6 "Labeled Antibiotic"
        lab var med_l_any_3 "Broad-Spectrum Antibiotic"
        lab var med_k_any_13 "Other Type"
      gen any_antister = (any_steroid == 1 | any_antibio == 1)
        lab var any_antister "Any Antibiotic or Steroid"

    order * , seq
    save "${git}/data/ayush-baseline.dta", replace

    // Create wide version
    labelcollapse (mean) ///
      ppia_trial correct dr_4 re_1 re_3   ///
      checklist time p index_sub g11 ///
      med_unl_anti med_unl_ster ///
      any_antister any_antibio any_steroid ///
      med_k_any_1 med_k_any_4 med_k_any_8 med_k_any_10  ///
      med_k_any_5 med_k_any_7 med_k_any_13 ///
      med_k_any_16 med_k_any_17 ///
      med_k_any_6 med_k_any_9 med_l_any_2 med_l_any_3 ///
      , by(fidcode) fast

      ren * *_bl
      ren fidcode_bl fidcode

      tempfile baseline
        save `baseline' , replace
  restore

  // Save endline data
  keep if round == 2
    merge 1:1 form using "${git}/raw/endline-unlabelled.dta" ///
      , keepusing(med_b2*) update replace keep(1 3 4 5) nogen

    merge 1:1 form using "${git}/raw/endline-unlab.dta" , nogen
      replace med_unl_anti = 0 if med_unl_anti == .
        lab var med_unl_anti "Unlabelled Antibiotic"
      replace med_unl_ster = 0 if med_unl_ster == .
        lab var med_unl_ster "Unlabelled Steroid"

    gen any_steroid = (med_unl_ster == 1 | med_k_any_9 == 1)
      lab var any_steroid "Any Steroid"
      lab var med_k_any_9 "Labeled Steroid"
    gen any_antibio = (med_unl_anti == 1 | med_k_any_6 == 1)
      lab var any_antibio "Any Antibiotic"
      lab var med_k_any_6 "Labeled Antibiotic"
      lab var med_l_any_3 "Broad-Spectrum Antibiotic"
      lab var med_k_any_13 "Other Type"
    gen any_antister = (any_steroid == 1 | any_antibio == 1)
      lab var any_antister "Any Antibiotic or Steroid"

      merge m:1 fidcode using `baseline'

  order * , seq
    replace ppia_trial = ppia_trial_bl if ppia_trial == .
  save "${git}/data/ayush-heckman.dta", replace
  drop if _merge == 2
    drop _merge
  save "${git}/data/ayush-endline.dta", replace

// Public sector and hospital data
use "https://github.com/bbdaniels/mumbai-public/raw/main/constructed/sp-data.dta" , clear

  ren qutub_id fid
  unab vars :  *

  append using "${git}/data/ayush-long.dta" , gen(a)
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
    lab var index_sub "Non-Medical Index"

  pca med_k_any_? med_l_any_?
  predict index_bad
    lab var index_bad "Medications Index"

  pca re_1 re_3 re_4
  predict index_good
    lab var index_good "TB Testing Index"

  save "${git}/data/sp-pubpri.dta" , replace

// End
