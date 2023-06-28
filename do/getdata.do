// Get raw data from box

iecodebook export ///
  "${box}/data/raw/patna-samples.dta" ///
  using "${git}/data/patna-samples.xlsx" ///
  , save sign reset replace


// End
