capture program drop GSSUgetrdone
*! version 1  JCSS 05oct2013
program GSSUgetrdone, eclass byable(recall)
	version 9.2
	syntax varlist(numeric) [if] [in] [aweight pweight iweight fweight], [cluster(varname)] [file(name)] 
	marksample touse
	
    tokenize `varlist'
    local y `1'
    macro shift
    local t `1'    
    macro shift
    local FEG `1'    
    macro shift
    local x `*'

	tempname label 

	quietly{
	est clear 
	**1 FE Cluster 
	areg `y' `t' `x' `if' `in', a(`FEG')  cluster(`cluster') 
	est sto reg1 

	**2 IWE Cluster 	
	GSSUtest `y'  `t' `FEG' `x' `if' `in', cluster(`cluster') 
	est sto reg2 

	scalar JtestS = e(W_s) 
	scalar Jtestp = e(W_p)	 
	scalar pchange = e(pchange) 
	scalar ItestS = el(e(ItB),1,rowsof(e(ItV)))/sqrt(el(e(ItV),rowsof(e(ItV)),rowsof(e(ItV))))
	scalar Itestp = 2*ttail(e(dof),abs(ItestS))

	est restore reg2 
	estadd scalar JtestS = JtestS
	estadd scalar Jtestp = Jtestp
	estadd scalar ItestS = ItestS
	estadd scalar Itestp = Itestp
	est store reg2 
	
	**3 RWE Cluster 		
	GSSUwtest `y'  `t' `FEG' `x' `if' `in', cluster(`cluster') 
	mat bk = e(b) 
	mat b = bk[1,1]
	mat bfe = bk[1,3]
	scalar pchange = ((el(bk,1,1)-el(bk,1,3))/el(bk,1,3))*100
	scalar ItestS = r(chi2)
	scalar Itestp = r(p)

	mat V = e(V) 
	mat V = V[1,1] 
	local N = e(N) 
	ereturn scalar N = nobs
	matrix colname b = `t'		
	matrix rowname V = `t'
	matrix colname V = `t'
	ereturn post b V, obs(`N') depname(`y') 
	ereturn local model "cmd" 
	ereturn local cmd "cmd"
	ereturn local title "cmd"	 
	ereturn display 
	est sto reg3 
	
	//	di "testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest"
	
	* Run Score test 
	intscoretest `y'  `t' `FEG' `x' `if' `in', cluster(`cluster') 
	scalar JtestS = e(stat) 
	scalar Jtestp = e(pval)	 

	est restore reg3
	estadd scalar JtestS = JtestS
	estadd scalar Jtestp = Jtestp
	estadd scalar ItestS = ItestS
	estadd scalar Itestp = Itestp
	estadd scalar pchange = pchange 
	est store reg3 

	**4 FE Cluster 
	areg `y' `t' `x' `if' `in', a(`FEG') 
	est sto reg4 

	**5 IWE No Cluster 	
	GSSUtest `y'  `t' `FEG' `x' `if' `in'
	est sto reg5 

	scalar JtestS = e(W_s) 
	scalar Jtestp = e(W_p)	 
	scalar pchange = e(pchange) 
	scalar ItestS = el(e(ItB),1,rowsof(e(ItV)))/sqrt(el(e(ItV),rowsof(e(ItV)),rowsof(e(ItV))))
	scalar Itestp = 2*ttail(e(dof),abs(ItestS))

	est restore reg5 
	estadd scalar JtestS = JtestS
	estadd scalar Jtestp = Jtestp
	estadd scalar ItestS = ItestS
	estadd scalar Itestp = Itestp
	est store reg5 
	
	**6 RWE No Cluster 		
	GSSUwtest `y'  `t' `FEG' `x' `if' `in'
	mat bk = e(b) 
	mat b = bk[1,1]
	mat bfe = bk[1,3]
	scalar pchange = ((el(bk,1,1)-el(bk,1,3))/el(bk,1,3))*100
	scalar ItestS = r(chi2)
	scalar Itestp = r(p)

	mat V = e(V) 
	mat V = V[1,1] 
	local N = e(N) 
	ereturn scalar N = nobs
	matrix colname b = `t'		
	matrix rowname V = `t'
	matrix colname V = `t'
	ereturn post b V, obs(`N') depname(`y') 
	ereturn local model "cmd" 
	ereturn local cmd "cmd"
	ereturn local title "cmd"	 
	ereturn display 
	est sto reg6 
	
	* Run Score test 
	intscoretest `y'  `t' `FEG' `x' `if' `in', cluster(`cluster') 
	scalar JtestS = e(stat) 
	scalar Jtestp = e(pval)	 

	est restore reg6
	estadd scalar JtestS = JtestS
	estadd scalar Jtestp = Jtestp
	estadd scalar ItestS = ItestS
	estadd scalar Itestp = Itestp
	estadd scalar pchange = pchange 
	est store reg6 

}
	esttab reg* ,b(3) se(3) replace star(* 0.10 ** 0.05 *** 0.01) mtitles("FE Cluster" "IWE Cluster" "RWE Cluster" "FE No Cluster" "IWE No Cluster" "RWE No Cluster") keep(`t') 	stats(JtestS Jtestp ItestS Itestp pchange)
	esttab reg* using `file'.csv ,b(3) se(3) replace star(* 0.10 ** 0.05 *** 0.01) mtitles("FE Cluster" "IWE Cluster" "RWE Cluster" "FE No Cluster" "IWE No Cluster" "RWE No Cluster") keep(`t') 	stats(JtestS Jtestp ItestS Itestp pchange)

end
