# Mumbai-PPIA-AYUSH
#Replication files

Construct.do
It cleans the preliminary datasets and creates various datasets which are used for analysis in the other do files.

Table1B.do
This file creates tables reporting the number of time each case scenario was presented to each of the provider groups (control, treatment, PPIA and non-PPIA) in baseline and in endline. These tables were separately edited in google sheets to create one compact table.

Table2.do
This file runs linear regression models to estimate the differences in quality of care outcomes between endline and baseline for the Observational Cohort. These results are reported in a table.

Table3.do
This file runs linear regression models to check if the control and treatment groups are statistically indistinguishable in baseline across a list of balance, process and quality of care indicators. For each family of indicators, a table and figure is generated. The 3 tables were separately edited in google sheets to create one compact table.

Table4A.do
This file runs difference in differences models to estimate the effect (both ITT and TOT) of the PPIA program on quality of care indicators for the Experimental Cohort. Only TB case scenarios are included as the asthma case was not presented in baseline. Results are saved in a table and a figure.

Table4B.do
This file runs a linear regression to estimate the effect(both ITT and TOT) of the PPIA program on quality of care indicators of the asthma case for the Experimental Cohort. Results are saved in a table and a figure.

Fig1.do
This file creates a figure that compares the mean of correct management, referral and chest x-ray for the 4 groups of the Observational Cohort (remained out of PPIA, exited PPIA in endline, entered PPIA in baseline, remained in PPIA) across baseline and endline.

TableA1.do
This file creates tables that report the number of providers within each group that belong to one of the 4 groups for each case scenario: presented the case in both the rounds, presented the case only in baseline, presented the case only in endline, not presented the case in either of the rounds. These tables were separately edited in google sheets to create one compact table.
