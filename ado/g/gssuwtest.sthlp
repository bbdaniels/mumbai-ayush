{smcl}



{title:Title}

{p2colset 5 20 22 2}{...}
{p2col:{stata help GSSUwtest:GSSUwtest} {hline 2} estimates the RWE as in Gibbons et al. (2014) and performs the specification test of equality between the OLS estimate and the RWE.} {p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{opt GSSUwtest: } {cmd:y} {cmd:Tr} {cmd:FEg} [{varlist}] {ifin} 
   [{cmd:,} {it:options}]
   
{synoptset 20 tabbed}{...}
{p2col 5 20 24 2:Where:}{p_end}
{synopt:{cmd:y}}dependent variable{p_end}
{synopt:{cmd:Tr}}independent variable of interest (e.g., treatment){p_end}
{synopt:{cmd:Feg}}categorical variable indexing the fixed effect group{p_end}
{synopt:{cmd:varlist}}additional control variables.{p_end}
   
   
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}} for heteroskedastic-robust standard errors, use the option vce(robust) {p_end}

{synopt :{opth cluster(cluster)}} for cluster-robust standard errors, specify cluster(clustervar) {p_end}

{synoptline}


{marker syntax}{...}
{title:Description}  
   
{pstd}
{stata help GSSUwtest:GSSUwtest} estimates the RWE and performs the specification test of equality between the OLS estimate and the RWE. 

	
{marker options}{...}
{title:Options}

{dlgtab:SE/Robust}

{phang}
For homoskedastic errors, ignore the {it:vce()}and {it:cluster()} options. For heteroskedastic-robust standard errors, use the option {it:vce(robust)} and for cluster-robust standard errors, specify {it:cluster(clustervar)}; see
{helpb vce_option:[R] {it:vce_option}}.


{marker examples}{...}
{title:Example 1:} Estimation of the RWE. 

{pstd}Open example data set included in GSSU package.{p_end}
{phang2}{stata adopath ++ "CensusData.dta": sysuse} {stata sysuse  censusdata.dta, clear : CensusData}{p_end}

{pstd} Estimate the RWE & perform the specification test equality between the OLS estimate and the RWE.{p_end}

{phang2}{stata GSSUwtest lnww educ age_dum: GSSUwtest lnww educ age_dum}{p_end}


{title:Example 2:} Estimation of the RWE including additional covariates with heteroskedastic-robust standard errors. 

{pstd}Estimate the RWE including additional covariates and perform the specification test equality between the OLS estimate and the RWE for heteroskedastic-robust standard errors. {p_end}

{phang2}{stata GSSUwtest lnww educ age_dum black bvb_dum, vce(robust) :GSSUwtest lnww educ age_dum black bvb_dum   , vce(robust)}{p_end}

{pstd}  {cmd:vce(robust)} uses the robust or sandwich estimator of variance. This estimator is robust to some types of misspecification so long as the observations are independent. {p_end}


{title:Example 3:} Estimation of the RWE for cluster-robust standard errors. 

{pstd}Estimate the RWE and perform the specification test equality between the OLS estimate and the RWE for cluster-robust standard errors.{p_end}

{phang2}{stata GSSUwtest lnww educ age_dum black bvb_dum , cluster(statefip): GSSUwtest lnww educ age_dum black bvb_dum , cluster(statefip)}{p_end}


{title:Example 4:} Comparing sample frequencies and implied OLS weights. 

{pstd}{stata help GSSUwtest:GSSUwtest} saves the estimation weights for the weighted regression in a variable named {cmd:weight_GSSU}. To compare sample frequencies to the implied OLS weights follow these steps. {p_end}

{phang2}{cmd:. replace  weight_GSSU = (1/weight_GSSU)^2}{p_end}
{phang2}{cmd:. sum weight_GSSU}{p_end}
{phang2}{cmd:. replace weight_GSSU = weight_GSSU/(r(mean)) }{p_end}
{phang2}{cmd:. bysort age_dum : gen age_dum_freq = _N }{p_end}
{phang2}{cmd:. sum age_dum_freq }{p_end}
{phang2}{cmd:. replace age_dum_freq = 100*age_dum_freq / r(N) }{p_end}
{phang2}{cmd:. replace weight_GSSU = weight_GSSU*age_dum_freq }{p_end}
{phang2}{cmd:. table age_dum, c( m age_dum_f m weight_GSSU )  }{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{stata help GSSUwtest:GSSUwtest} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:suest}{p_end}
{synopt:{cmd:e(eqnames1)}}mean lnvar{p_end}
{synopt:{cmd:e(eqnames2)}}mean lnvar{p_end}
{synopt:{cmd:e(names)}}names under which estimation results were stored via estimates store{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(vce)}}vcetype specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(properties)}}b V{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}



{marker author}{...}
{title:Author & Maintainer}
{phang}
Juan Carlos Suarez Serrato. 
Duke University and NBER. jc@jcsuarez.com
{p_end}

{marker references}{...}
{title:References}
{phang}
Gibbons, Charles E., Suarez Serrato, Juan Carlos, & Urbancic, Michael B. 2014. "Broken or Fixed Effects?"
{p_end}
