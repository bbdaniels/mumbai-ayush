{smcl}

{title:Title}

{p2colset 9 20 22 2}{...}
{p2col :{stata help GSSUtest:GSSUtest}{hline 2}}estimates the IWE as in Gibbons et al. (2014) and performs the Wald test and the specification test of equality between the OLS estimate and the IWE. {p_end}
{p2colreset}{...}



{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{opt GSSUtest: } {cmd:y} {cmd:Tr} {cmd:FEg} [{varlist}] {ifin} 
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
{stata help GSSUtest:GSSUtest} estimates the IWE and performs the Wald test and the specification test of equality between the OLS estimate and the IWE. 


{marker options}{...}
{title:Options}

{dlgtab:SE/Robust}

{phang}
For homoskedastic errors, ignore the {it:vce()}and {it:cluster()} options. For heteroskedastic-robust standard errors, use the option {it:vce(robust)} and for cluster-robust standard errors, specify {it:cluster(clustervar)}.; see
{helpb vce_option:[R] {it:vce_option}}.


{marker examples}{...}
{title:Example 1:} Estimation of the IWE.

{pstd}Open example data set included in GSSU package.{p_end}
{phang2}{stata adopath ++ "CensusData.dta": sysuse} {stata sysuse  censusdata.dta, clear : CensusData}{p_end}

{pstd}Estimate the IWE and perform the Wald test and the specification test of equality 
    between the OLS estimate and the IWE.{p_end}

{phang2}{stata GSSUtest lnww educ age_dum: GSSUtest lnww educ age_dum}{p_end}


{title:Example 2:} Estimation of the IWE for heteroskedastic-robust standard errors.

{pstd}Estimate the IWE  including additional covariates and perform the Wald test and the specification test of equality between the OLS estimate and the IWE for heteroskedastic-robust standard errors. {p_end}

{phang2}{stata GSSUtest lnww educ age_dum black bvb_dum, vce(robust):GSSUtest  lnww educ age_dum black bvb_dum, vce(robust)}{p_end}

{pstd}  {cmd:vce(robust)} uses the robust or sandwich estimator of variance. This estimator is robust to some types of misspecification so long as the observations are independent. {p_end}


{title:Example 3:} Estimation of the IWE for cluster-robust standard errors. 

{pstd}Estimate the IWE and perform the Wald test and the specification test of equality 
    between the OLS estimate and the IWE for cluster-robust standard errors.{p_end}

{phang2}{stata GSSUtest lnww educ age_dum  black bvb_dum, cluster(age_dum): GSSUtest lnww educ age_dum  black bvb_dum, cluster(age_dum)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:GSSUtest} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(dof)}}number of degrees of freedom{p_end}
{synopt:{cmd:e(pchange)}}Percentage difference between OLS and IWE{p_end}
{synopt:{cmd:e(Jtest)}} Joint test of equality statistic{p_end}
{synopt:{cmd:e(pval)}} Joint test of equality p-value{p_end}
{synopt:{cmd:e(Chi2dof) }} Degrees-of-Freedom for test of equality {p_end}
{synopt:{cmd:e(W_s)}} Statistic for Joint Wald Test for Interactions{p_end}
{synopt:{cmd:e(W_p)}} P-value for Joint Wald Test for Interactions{p_end}
{synopt:{cmd:e(W_dof)}} Degrees-of-freedom for Wald test {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(properties)}}b V{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(model)}}{cmd:ols} or {cmd:iv}{p_end}
{synopt:{cmd:e(title)}}title in estimation output when {cmd:vce()} is not
             {cmd:ols}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector for IWE {p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix for IWE {p_end}
{synopt:{cmd:e(results)}} Matrix with combined results {p_end}

{marker author}{...}
{title:Author & Maintainer}
{phang}
Juan Carlos Suarez Serrato. 
Duke University and NBER. jc@jcsuarez.com
{p_end}

{marker references}{...}
{title:References}
{phang}
Gibbons Charles E., Suarez Serrato, Juan Carlos, & Urbancic, Michael B. 2014. "Broken or Fixed Effects?"
{p_end}
