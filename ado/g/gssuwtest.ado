capture program drop GSSUwtest
*! version 2 JCSS 12jul2014
program GSSUwtest, eclass byable(recall)
	version 9.2
	syntax varlist(numeric) [if] [in] [aw fw pw iw] [,vce(string) cluster(varname)]
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
		capture drop weight_GSSU 
		capture drop t_`t'
		capture drop I`FEG'*

		tempname cvarn
		tempvar ty esample 
		
		reg `y' `t' `FEG' `x' `if' `in' [`weight' `exp'], noconstant
		gen `esample' = e(sample) 
		
		tab `FEG' if `esample', matcell(f)
		tab `FEG', gen(I`FEG'_)

		reg `t' I`FEG'* `x' if `esample' [`weight' `exp'], noconstant		
		predict t_`t' if `esample', r 

		reg `y' I`FEG'* `x' if `esample' [`weight' `exp'], noconstant		
		predict `ty' if `esample', r 				
		
		
		gen weight_GSSU = 0 
		foreach varname of varlist I`FEG'_* {
			sum t_`t' if `varname' == 1  & `esample' 
			scalar `cvarn' = r(Var)
			replace weight_GSSU =  1/`cvarn' if `varname' == 1  & `esample' 
		}
		drop I`FEG'_1

		replace t_`t' = t_`t'*sqrt(weight_GSSU) if  `esample'
		replace `ty' = `ty'*sqrt(weight_GSSU)	if  `esample'	
		
		reg `ty' t_`t' if  `esample' [`weight' `exp'],  noconstant
		est sto SWE
		
		reg `y' `t' I`FEG'* `x' if `esample' [`weight' `exp']
		est sto FE
		}
		
		suest SWE FE , cluster(`cluster') vce(`vce')
		
		test _b[FE_mean:`t'] = _b[SWE_mean:t_`t']

		scalar pchange = 100*(_b[SWE_mean:t_`t'] - _b[FE_mean:`t']) / _b[FE_mean:`t']
		
		display as text "Percentage change in estimate 100*(Sw-FE)/FE %: " as result pchange as text "%"
		
		qui: capture drop t_`t'
		qui: capture drop drop I`FEG'* 
		
end
