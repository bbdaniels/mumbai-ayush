capture program drop intscoretest
*! version 5  JCSS 26jun2010
// requires ssc intall distinct 
program intscoretest, eclass byable(recall)
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
		tempname V Var f b diff xshort xlong label ndof nobs nom M res scoreK clusters interactions id statjc
		tempvar cons _est_FE _est_CRC

		capture drop t_`t'
		capture drop I`FEG'*

		// Generate interactions and prepare macros for regressions
		gen `cons' = 1
		tab `FEG', gen(I`FEG'_)
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
		scalar `interactions' =  0		
		foreach varname of varlist `t'XI* {
			local xlong `xlong' `varname'
			local intname `intname' `varname'
			scalar `interactions' =  `interactions'+1 		
		}

		// Run main specification with FE 
		regress `y' `xshort' `if' `in' [`weight' `exp'], noconstant
		scalar rankFE = e(df_m)
		scalar nobs = e(N)
		
		predict `res', r   
		scalar `scoreK' =  0
		foreach varname of varlist `xlong' { 
			gen score_`varname' = `res'*`varname'
	 		scalar `scoreK' =  `scoreK'+1
		}
		tabstat score*, stat(sum) save
		mat m_score = r(StatTotal) 
		

		matrix H = 0*I(`scoreK')

		if strlen("`cluster'")==0 {
// Robust Std Errors 
			matrix accum XX = score_* , nocons 
			scalar `clusters' = nobs 	
	    } 
	 	 else {	 
 // Clustereed SEs
 			sort `cluster'
			matrix opaccum XX = `xlong' , nocons group(`cluster') opvar(`res')
			distinct `cluster'
			scalar `clusters' = r(ndistinct) 	 	 
		}

		matrix H = XX
		matrix C = (J(`interactions',`scoreK'-`interactions',0),I(`interactions'))
		matrix iH = invsym(H) 
		// Finite sample correction 
		matrix stat = m_score*iH*C'*invsym(C*iH*C')*C*iH*m_score'/(`clusters'/(`clusters'-1)*(nobs-1)/(nobs-rankFE))
		// No finite sample correction 
//		matrix stat = m_score*iH*C'*invsym(C*iH*C')*C*iH*m_score'
		scalar `statjc' = stat[1,1]
//		scalar pval = 1 - chi2(`interactions',stat)
		
		di `interactions'
		di `statjc'
		scalar pval = chi2tail(`interactions',`statjc')		
		
		capture drop I`FEG'_* 
		capture drop score_* 
		capture drop `t'XI*
		
		}
			//Display Score results 
		display as text "  " 	
		display as text "Joint Score Test for Interactions"
		display as text "chi2(" as result `interactions' as text " ) =  " as result `statjc'
		display as text "Prob > chi2 =  " as result pval
		ereturn scalar cluster = `clusters'
		ereturn scalar stat = `statjc'
		ereturn scalar dof = `interactions'
		ereturn scalar pval = pval				
end 
