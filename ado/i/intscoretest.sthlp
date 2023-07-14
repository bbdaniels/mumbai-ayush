

{smcl}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{stata help intscoretest:intscoretest} {hline 1} performs a score test on the interactions between the treatment variable and fixed effects as in Gibbons et al. (2014).} {p_end}
{p2colreset}{...}



{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{opt intscoretest: } {cmd:y} {cmd:Tr} {cmd:FEg} [{varlist}] {ifin} 
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
{stata help intscoretest:intscoretest} performs the score test on the interactions between the treatment variable and the fixed effects. 
                
{marker options}{...}
{title:Options}

{dlgtab:SE/Robust}

{phang}
For homoskedastic errors, ignore the {it:vce()}and {it:cluster()} options. For heteroskedastic-robust standard errors, use the option {it:vce(robust)} and for cluster-robust standard errors, specify {it:cluster(clustervar)}.; see
{helpb vce_option:[R] {it:vce_option}}.


{marker examples}{...}
{title:Example 1:} Joint Score Test: Interactions between the treatment variable and the fixed effects.

{pstd}Open example data set.{p_end}
{phang2}{stata adopath ++ "CensusData.dta": sysuse} {stata sysuse  censusdata.dta, clear : CensusData}{p_end}

{pstd}Perform the score test on the interactions between the treatment variable and the 
    fixed effects.{p_end}

{phang2}{stata intscoretest lnww educ age_dum: intscoretest lnww educ age_dum}{p_end}


{title:Example 2:} Joint Score Test for heteroskedastic-robust standard errors. 

{pstd}Perform the score test on the interactions for heteroskedastic-robust standard errors.{p_end}

{phang2}{stata intscoretest lnww educ age_dum, vce(robust):intscoretest lnww educ age_dum, vce(robust)}{p_end}

{pstd}  {cmd:vce(robust)} uses the robust or sandwich estimator of variance. This estimator is robust to some types of misspecification so long as the observations are independent. {p_end}


{title:Example 3:} Joint Score Test for cluster-robust standard errors. 

{pstd}Perform the score test on the interactions for cluster-robust standard errors.{p_end}

{phang2}{stata intscoretest lnww educ age_dum, cluster(statefip): intscoretest lnww educ age_dum, cluster(statefip)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{stata help intscoretest:intscoretest} stores the following in {cmd:e()}:
		
{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(dof)}}number of (denominator) degrees of freedom{p_end}
{synopt:{cmd:e(pchange)}}Individual test v.s Joint test{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom {p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom{p_end}
{synopt:{cmd:e(F)}}F statistic{p_end}
{synopt:{cmd:e(rmse)}}root mean squared error{p_end}
{synopt:{cmd:e(mss)}}model sum of squares{p_end}
{synopt:{cmd:e(rss)}}residual sum of squares{p_end}
{synopt:{cmd:e(r2)}}R-squared{p_end}
{synopt:{cmd:e(r2_a)}}adjusted R-squared{p_end}
{synopt:{cmd:e(ll)}}log likelihood under additional assumption of i.i.d. normal errors{p_end}
{synopt:{cmd:e(rank)}}rank of e(V){p_end}
{synopt:{cmd:e(cluster)}}number of observations included in a cluster{p_end}
{synopt:{cmd:e(stat)}}statistic value{p_end}
{synopt:{cmd:e(pval)}}probability-value{p_end} 
     
{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(properties)}}b V{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(model)}}{cmd:ols} or {cmd:iv}{p_end}
{synopt:{cmd:e(title)}}title in estimation output when {cmd:vce()} is not{cmd:ols}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(marginsok)}}predictions allowed by margins{p_end}
{synopt:{cmd:e(vce)}}vcetype specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(cmd)}}program used to implement regression{p_end}
{synopt:{cmd:e(predict)}}program used to implement predict{p_end}
{synopt:{cmd:e(estat_cmd)}}program used to implement estat{p_end}
			 
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
Gibbons, Charles E., Suarez Serrato, Juan Carlos. & Urbancic, Michael B. 2014. "Broken or Fixed Effects?"
{p_end}
