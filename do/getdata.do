// Get raw data from box

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
  recode g* (1/2=0)(3/max=1)


  replace round = round + 1
  lab def round 1 "Round 1" 2 "Round 2"
    lab val round round

  ren qutub_id fid
  drop qutub*

  merge m:1 fid using "${git}/data/ppia-codefile.dta" , keep(3)
  replace dr_4 = 0 if dr_4 == 3

  drop *given

  iecodebook export ///
    using "${git}/data/sp-ayush.xlsx" ///
    , save sign reset replace


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

  iecodebook export ///
    using "${git}/data/sp-pubpri.xlsx" ///
    , save sign reset replace

// End
