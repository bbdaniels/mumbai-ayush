// Get raw data from box

// Codefile
use "${box}/Master_Code_File.dta" , clear
  keep if qutub_sample > 6

  keep qutub_id qutub_sample ppia_facility_0 ppia_facility_1 uatbc_facilitycode trial_assignment
  ren qutub_id fid

  iecodebook export ///
    using "${git}/data/codefile.xlsx" ///
    , save sign reset replace

// SP data
use "${box}/sp-wave-0.dta" , clear
append using "${box}/sp-wave-1.dta" , gen(round) force

  replace round = round + 1
  lab def round 1 "Round 1" 2 "Round 2"
    lab val round round

  ren qutub_id fid
  drop qutub*

  merge m:1 fid using "${git}/data/ppia-codefile.dta" , keep(3)
  replace dr_4 = 0 if dr_4 == 3

  drop *given

  iecodebook export ///
    using "${git}/data/sp-data.xlsx" ///
    , save sign reset replace



// End
