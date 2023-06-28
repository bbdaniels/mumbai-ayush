// Get raw data from box

use "${box}/Master_Code_File.dta" , clear
  keep if qutub_sample > 6

  keep qutub_id qutub_sample ppia_facility_0 ppia_facility_1 uatbc_facilitycode trial_assignment

iecodebook export ///
  "${box}/data/raw/patna-samples.dta" ///
  using "${git}/data/patna-samples.xlsx" ///
  , save sign reset replace


// End
