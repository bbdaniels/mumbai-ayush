// Table. Case interactions for the 4 provider samples by round

	use "${directory}/constructed/analysis-ayush-panel.dta", clear

  egen type = group(wave qutub_sample_updated) , label
  tabout type case using "${directory}/outputs/t-1b.xls" , replace

// End of do-file
