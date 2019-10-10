// Analysis for PPIA


// Joiners
use "${directory}/constructed/sp-private.dta" , clear
  lab def ppia_facility_1 0 "Non-PPIA" 1 "Joined PPIA"
  lab val ppia_facility_1 ppia_facility_1

  lab def qutub_sample ///
    1 "Comparison Locations" 2 "PPIA Locations" 3 "Non-Networked Locations" , replace

  graph bar re_4 if case == 1, ///
    over(wave) asy over(ppia_facility_1) by(qutub_sample , r(1)) ///
    blabel(bar , format(%3.2f)) ylab(0 "0%" .25 "25%" .5 "50%") ytit("Case 1")

    graph save "${directory}/outputs/gx1.gph" , replace

  graph bar re_4 if case == 2, ///
    over(wave) asy over(ppia_facility_1) by(qutub_sample , r(1)) ///
    blabel(bar , format(%3.2f)) ylab(${pct}) ytit("Case 2")

    graph save "${directory}/outputs/gx2.gph" , replace

  graph combine ///
    "${directory}/outputs/gx1.gph" ///
    "${directory}/outputs/gx2.gph" ///
  , c(1)

  graph export "${directory}/outputs/gx-all.eps" , replace


// End of dofile
