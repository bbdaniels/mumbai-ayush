

{smcl}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{stata help GSSUgetrdone:GSSUgetrdone} {hline 1} Runs {stata help GSSUtest:GSSUtest}, {stata help GSSUwtest:GSSUwtest}, and {stata help intscoretest: intscoretest} to estimate the IWE and RWE as in Gibbons et al. (2014) and performs specification tests  of equality between the OLS estimate and the RWE/IWE.} {p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{opt GSSUgetrdone: } {cmd:y} {cmd:Tr} {cmd:FEg} [{varlist}] {if in} 
   [{cmd:,} {it:options}]
   
{synoptset 20 tabbed}{...}
{p2col 5 20 24 2:Where:}{p_end}
{synopt:{cmd:y}}dependent variable{p_end}
{synopt:{cmd:Tr}}independent variable of interest (e.g., treatment){p_end}
{synopt:{cmd:Feg}}categorical variable indexing the fixed effect group{p_end}
{synopt:{cmd:varlist}}additional control variables.{p_end}

{p2col 5 20 24 2: {cmd:Required Package: This command requires installing the Estout package. To do so, type}}{p_end}
{synopt: {stata ssc install estout, replace:ssc install estout, replace} }{p_end}


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}} for heteroskedastic-robust standard errors, use the option vce(robust) {p_end}

{synopt :{opth cluster(cluster)}} for cluster-robust standard errors, specify cluster(clustervar) {p_end}

{synopt :{opth file(name)}} stores the results of the estimations and test to a file named name.csv {p_end}

{synoptline}
	

{marker syntax}{...}
{title:Description}  
   
{pstd}
{stata help GSSUgetrdone:GSSUgetrdone} runs the commands {stata help GSSUtest:GSSUtest}, {stata help GSSUwtest:GSSUwtest}, and {stata help intscoretest: intscoretest} and displays the results. {stata help GSSUgetrdone:GSSUgetrdone} automatically uses robust standard errors in its calculations. 

{marker options}{...}
{title:Options}

{dlgtab:SE/Robust}

{phang}
For homoskedastic errors, ignore the {it:vce()}and {it:cluster()} options. For heteroskedastic-robust standard errors, use the option {it:vce(robust)} and for cluster-robust standard errors, specify {it:cluster(clustervar)}.; see
{helpb vce_option:[R] {it:vce_option}}.


{marker examples}{...}
{title:Example 1:} Estimating the RWE and IWE using {stata help GSSUgetrdone:GSSUgetrdone}.

{pstd}Open example data set.{p_end}
{phang2}{stata adopath ++ "CensusData.dta": sysuse} {stata sysuse  censusdata.dta, clear : CensusData}{p_end}

{pstd}Estimate the IWE and the RWE, run Wald and Score tests, and run specification tests: {p_end}
{phang2}{stata GSSUgetrdone lnww educ age_dum: GSSUgetrdone lnww educ age_dum}{p_end}

{title:Example 2:} Saving results to file. 

{pstd}The option file() lets the user store the results to a .csv file: {p_end}
{phang2}{stata GSSUgetrdone lnww educ age_dum, file(example) : GSSUgetrdone lnww educ age_dum, file(example)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{stata help GSSUgetrdone:GSSUgetrdone} stores the following in {cmd:e()}: {p_end}
		
{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars} {p_end}
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
Gibbons, Charles E., Suarez Serrato, Juan Carlos, & Urbancic, Michael B. 2014. "Broken or Fixed Effects?"
{p_end}
