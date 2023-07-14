capture program drop GSSUtest
*! version 6  JCSS 12jul2014
program GSSUtest, eclass byable(recall)
	version 9.2
	syntax varlist(numeric) [if] [in] [aweight pweight iweight fweight] [,vce(string) cluster(varname)]
	marksample touse
	
    tokenize `varlist'
    local y `1'
    macro shift
    local t `1'    
    macro shift	
    local FEG `1'    
    macro shift
    local x `*'
	
	quietly{

		capture drop I`FEG'*
		capture drop _est_FE 
		capture drop _est_IWE

		tempname V Var f b diff xshort xlong label ndof nobs nom M
		tempvar cons _est_FE _est_IWE esample 

		// Generate interactions and prepare macros for regressions
		gen `cons' = 1
		tab `FEG' `if' `in', gen(I`FEG'_)
		drop I`FEG'_1
		local xshort `cons' `x' 
		local label cons `x' 		
		foreach varname of varlist I`FEG'_* {
			gen `t'X`varname' = `varname'*`t'
			local xshort `xshort' `varname'
			local label `label' `varname'
		}
		local xshort `xshort' `t'
		local label `label' `t'
		local xlong `xshort'
		foreach varname of varlist `t'XI* {
			local xlong `xlong' `varname'
			local intname `intname' `varname'
		}

		// Run FE and IWE estimations and combine with SUEST
		regress `y' `xshort' `if' `in' [`weight' `exp'], noconstant
		scalar rankFE = e(df_m)
		scalar nobs = e(N)
		scalar ndof = e(df_r)
		estimates store FE
		regress `y' `xlong' `if' `in' [`weight' `exp'], noconstant
		estimates store IWE
		gen `esample' = e(sample) 

		suest FE IWE, `vce' cluster(`cluster')

		nlcom [FE_mean]`t'
		mat results = (el(r(b),1,1), sqrt(el(r(V),1,1)), 2*ttail(ndof,abs(el(r(b),1,1)/sqrt(el(r(V),1,1)))) )

		matrix ebSUS = e(b)
		matrix eVSUS = e(V)
		}
		
		local cols = colsof(ebSUS)
		forvalues i = 1/`cols' {
 			if el(eVSUS,`i',`i') == 0 { 
				drop I`FEG'* `t'X* _est_FE _est_IWE
				display as text "  "
 				display as text "Error: Some variables were dropped in the FE or IWE regressions." 				
 				display as text "Please make sure all variables can be included in all regressions and run GSSUtest again"
				display as text "  "
 				error			
 			}
          }	
		quietly{
		// Wald test 
		test [IWE_mean]`intname'
		scalar W_dof = r(df)
		scalar W_s = r(chi2)
		scalar W_p = r(p)

		// Drop variables 
		drop I`FEG'* `t'X* _est_FE _est_IWE
		
		// Generate Matrix for Linear Combinations
		tab `FEG' if `esample' [`weight' `exp'], matcell(f)
		scalar numFE = r(r)
		matrix f = f'/r(N)
		matrix f = f[1,2...]
					
		matrix eb = e(b)
		matrix eV = e(V)		
		matrix eb = (eb[1,1..rankFE],eb[1,rankFE+2..2*rankFE+numFE]) 
		matrix eV = (eV[1..rankFE,1..rankFE], eV[1..rankFE,rankFE+2..2*rankFE+numFE] \ eV[rankFE+2..2*rankFE+numFE,1..rankFE], eV[rankFE+2..2*rankFE+numFE,rankFE+2..2*rankFE+numFE])		
		
		// Sample Weights
		matrix Sw = (J(rankFE,rankFE,0), I(rankFE), (J(rankFE-1,numFE-1,0) \ f ))
		matrix SwB = Sw*eb'
		matrix SwV = Sw*eV*Sw'

		mat results = (results, el(SwB,rankFE,1), sqrt(el(SwV,rankFE,rankFE)), 2*ttail(ndof,abs(el(SwB,rankFE,1)/sqrt(el(SwV,rankFE,rankFE))))  )
		mat results = (results, el(results,1,5)/el(results,1,2))
		
		// Individual Test
		matrix Itest = Sw-(I(rankFE), J(rankFE,rankFE+numFE-1,0))
		matrix ItB = Itest*eb' 
		matrix ItV = Itest*eV*Itest' 		

		// Joint Test 
		matrix iItV = invsym(ItV)
		matrix Jtest = ItB'*iItV*ItB  
		scalar Jtest = Jtest[1,1]
		scalar pval = 1 - chi2(rankFE,Jtest)

		// Percentage Change 
		scalar pchange = 100*ItB[rankFE,1]/(SwB[rankFE,1]-ItB[rankFE,1])	
		mat results = (results, pchange, W_s, W_dof, W_p, el(ItB,rankFE,1)/sqrt(el(ItV,rankFE,rankFE)), 2*ttail(ndof,abs(el(ItB,rankFE,1)/sqrt(el(ItV,rankFE,rankFE)))), Jtest, rankFE, pval)
		matrix colnames results = "FE_b" "FE_se" "FE_pval" "IWE_b" "IWE_se" "IWE_pval" "SE Ratio (IWE/FE)" "b %Change (IWE-FE)/FE" "Wald_s" "Wald_dof" "Wald_pval" "Ind Test_s" "Ind Test_pval" "Joint Test_s" "Joint Test_dof" "Joint Test_pval"
		matrix rownames results = "`y', `FEG'"
		
		// Reshape before posting 
		matrix SwB = SwB'
		matrix ItB = ItB' 
								
		matrix colnames SwB = `label' 
		matrix rownames SwV = `label' 
		matrix colnames SwV = `label'		
		matrix colnames ItB = `label' 
		matrix rownames ItV = `label' 
		matrix colnames ItV = `label'		
		
		//matrix drop iItV Itest Sw f 
		capture drop I`FEG'*
		capture drop _est_FE 
		capture drop _est_IWE
	}	
	
	//Display F-test results 
	display as text "  " 	
	display as text "Joint Wald Test for Interactions"
	display as text "chi2(" as result W_dof as text " ) =  " as result W_s 
	display as text "Prob > chi2 =  " as result W_p
		
	//Display GSSU test results
	matrix eb = ItB 
	matrix eV = ItV 	
	ereturn post eb eV, depname(`y') 
	display as text "  " 	
	display as text "Individual Tests of Equality of Sample Weighted Effect with Fixed Effects Model"
	ereturn display 
	display as text "  " 
	display as text "Joint Test of Equality of Sample Weighted Effect with Fixed Effects Model" 
	display as text "chi2(" as result rankFE as text " ) =  " as result Jtest 
	display as text "Prob > chi2 =  " as result pval
		
	//Display regression results for SwTE
	scalar ndof = ndof - (numFE-1)
	ereturn scalar N = nobs
	ereturn scalar dof = ndof	
	matrix eb = SwB 
	matrix eV = SwV 	
	ereturn repost b = eb V = eV
	display as text "  " 
	display as text "Sample Weighted Regression Estimates"
	ereturn display 
	display as text "  " 	
	display as text "Percentage change in estimate 100*(Sw-FE)/FE %: " as result pchange as text "%"	
	
	// Return Other Stuff
	ereturn matrix ebSUS ebSUS 
	ereturn matrix eVSUS eVSUS 		
	ereturn matrix SwB SwB 
	ereturn matrix SwV SwV 	
	ereturn matrix ItB ItB
	ereturn matrix ItV ItV
	ereturn matrix f f 
	ereturn matrix Itest Itest
	ereturn matrix Sw Sw
	ereturn matrix iItV iItV 
	ereturn scalar pchange = pchange
	ereturn scalar Jtest = Jtest
	ereturn scalar pval = pval
	ereturn scalar Chi2dof = rankFE	
	ereturn scalar W_s = W_s
	ereturn scalar W_p = W_p
	ereturn scalar W_dof = W_dof
	ereturn matrix results = results
	
    ereturn local model "ols" 
    ereturn local cmd "GSSUtest"
    ereturn local depvar "`y'"
    ereturn local title "GSSU Test of Equality of Sample Weighted Effect with Fixed Effects Model and Sample Weighted Tr Estimates"	 
end
