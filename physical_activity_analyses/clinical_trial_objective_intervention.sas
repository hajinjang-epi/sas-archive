
/* Clinical Trial Objective Intervention via Actigraphy */
/* Writer: Hajin Jang */
/* Date: 11/21/2024 */


/*********************************************************************************/

/* 
This analysis evaluates changes in objectively measured physical activity and sedentary behavior over a 12-month lifestyle intervention using mixed-effects models, assessing overall time trends and differences by intervention assignment. 
*/

/*
Data come from a randomized lifestyle intervention study in which participants were assigned to one of two activity-focused programs with slightly different goals. Activity outcomes included average daily step counts, moderate-to-vigorous physical activity minutes, and sedentary minutes measured at baseline, 6 months, and 12 months. Although all participants had baseline measurements, follow-up data were incomplete at later time points, resulting in an unbalanced longitudinal dataset. Mixed-effects models were used to assess changes over time and to account for repeated measures and missing observations. 
*/

/*********************************************************************************/


libname clinic "C:\Users\HAJ90\OneDrive - University of Pittsburgh\Document\PA\7_Clinical trial data"; run;


* Add formats;

proc format;
value fgen 1='M' 2='F';
value fassign 1='Goal 1' 2='Goal 2';
value ftime 0='baseline' 1='6 months' 2= '12 months';
value age6f
1= '<50 years'
2= '50 to <55 years' 
3=  '55 to <60 years'
4 = '60 to <65 years'
5 = '65 to <70 years'
6= '70+ years';
run;


* Read the data;

data interven;
set clinic.interven;
run;

proc contents data= interven;
run;


* Checking missing values;

proc sql;
    create table count as
    select id, count(time)
    from interven
    group by id;
quit;


proc freq data=count;         
table _TEMG001;       
run;                  


* Evidence for change over time;

* Pre-post values at baseline and 6 and 12 months;

proc sort data= interven;
by time;
run;
title1 'Mean average steps by time';
proc summary data=interven;
var avsteps;
output out=summrystep_all n=number mean=average std=std_deviation;
by time;
run;

proc print data=summrystep_all;
run;

/********************************************/

title1 'Mean average moderate-vigorous PA by time';
proc summary data=interven;
var avmv;
output out=summrymvpa_all n=number mean=average std=std_deviation;
by time;
run;

proc print data=summrymvpa_all;
run;

/*************************************************/

title1 'Mean average sedentary by time';
proc summary data=interven;
var avsed;
output out=summrysed_all n=number mean=average std=std_deviation;
by time;
run;

proc print data=summrysed_all;
run;

/******************************************/

proc sort data= interven;
by assign time;
run;

title1 'Mean average steps by treatment and time';
proc summary data=interven;
var avsteps;
output out=summrystep n=number mean=average std=std_deviation;
by assign time;
run;

proc print data=summrystep;
run;

/***********************************/

title1 'Mean average moderate-vigorous by treatment and time';
proc summary data=interven;
var avmv;
output out=summrymv n=number mean=average std=std_deviation;
by assign time;
run;

proc print data=summrymv;
run;

/******************************/

title1 'Mean average steps by treatment and time';
proc summary data=interven;
var avsed;
output out=summrysed n=number mean=average std=std_deviation;
by assign time;
run;

proc print data=summrysed;
run;


* Mixed models;

PROC MIXED data=interven;  
class id time;  
model avsteps=time / ddfm=kenwardroger;  
repeated / subject=id type=un r rcorr;  
lsmeans time / pdiff; title 'Repeated Measures ANOVA of Time on Steps';
run;

PROC MIXED data=interven;  
class id time;  
model avmv=time / ddfm=kenwardroger;  
repeated / subject=id type=un r rcorr;  
lsmeans time / pdiff; title 'Repeated Measures ANOVA of Time on Moderate-vigorous activity';
run;

PROC MIXED data=interven;  
class id time;  
model avsed=time / ddfm=kenwardroger;  
repeated / subject=id type=un r rcorr;  
lsmeans time / pdiff; title 'Repeated Measures ANOVA of Time on sedentary';
run;


* Mixed models ANOVA for differences in the two interventions over time;

PROC MIXED data=interven;  
class id assign time;  
model avsteps=assign|time / ddfm=kenwardroger;  
repeated / subject=id type=un r rcorr;  
lsmeans assign|time / pdiff; title 'Repeated Measures ANOVA of Group and Time on Steps';
run;

PROC MIXED data=interven;  
class id assign time;  
model avmv=assign|time / ddfm=kenwardroger;  
repeated / subject=id type=un r rcorr;  
lsmeans assign|time / pdiff; title 'Repeated Measures ANOVA of Group and Time on Moderate-Vogirous Activity';
run;

PROC MIXED data=interven;  
class id assign time;  
model avsed=assign|time / ddfm=kenwardroger;  
repeated / subject=id type=un r rcorr;  
lsmeans assign|time / pdiff; title 'Repeated Measures ANOVA of Group and Time on Sedentary time';
run;



/*********************************************************************************/
/*********************************************************************************/

/* Summary and Conclusion of the Code */
/*
Descriptive results indicated modest short-term improvements in physical activity. Mean step counts and moderate-to-vigorous physical activity increased from baseline to 6 months, followed by declines at 12 months that approached or returned to baseline levels. This general pattern was observed both overall and within each intervention group. In contrast, sedentary time remained relatively stable across all time points, suggesting little impact of the intervention on sedentary behavior.

Attrition over time may affect how well the descriptive table reflects true changes in activity. Approximately one-quarter of participants had only two measurements and about 10% had only one measurement, raising concern for potential bias if participants who dropped out differed systematically from those who completed follow-up assessments. As a result, simple comparisons of means at each time point may not fully represent longitudinal change in the full study population.

Mixed-effects models examining change over time among all participants showed significant increases in step counts and moderate-to-vigorous activity at 6 months compared to baseline, followed by significant declines between 6 and 12 months. No significant differences were observed between baseline and 12 months for either outcome, indicating that early gains were not sustained. Sedentary time did not change significantly across any time comparisons.

When controlling for intervention assignment, time remained a significant predictor of changes in step counts and moderate-to-vigorous activity, but not sedentary time. Importantly, there was no evidence of significant assignment-by-time interactions for any outcome, suggesting that changes in activity over time did not differ meaningfully between the two intervention programs. Overall, the intervention appeared to produce short-term improvements in physical activity that were not maintained over 12 months, with no clear differences between program goals.
*/


