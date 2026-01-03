
/* BOdy Worn Monitor */
/* Writer: Hajin Jang */
/* Date: 10/18/2024 */


/*********************************************************************************/

/* 
This analysis examines associations between BMI categories and objectively measured physical activity and sedentary behavior using NHANES 2003–2006 accelerometer data, stratified by age group and sex while accounting for survey design and reweighting for accelerometer nonwear. 
*/

/*
Data were drawn from NHANES 2003–2006 and included adults with valid accelerometer data, merged with demographic and BMI information. Accelerometer measures provided average daily minutes of moderate-to-vigorous physical activity, light activity, sedentary time, and average daily step counts. Data were processed to account for nonwear time and reweighted to address higher dropout related to invalid accelerometer data. Analyses were stratified by age (30 to <70 years and =70 years) and sex, with comparisons made across BMI categories using survey-weighted estimates. 
*/

/*********************************************************************************/



* Read Accelerometer data;

OPTIONS nofmterr;               

libname NHANES "C:\Users\HAJ90\OneDrive - University of Pittsburgh\Document\PA\6_Body worn monitor data";    
run;

data accel;					
set NHANES.accel2;
run;

proc contents data=accel;      /* wt_4 utilizes the weighting for those with 4+ valid days; wt_3 is for those with 3+ days */
run;						   
								 

* Importing demographic variables and BMI;

data demog;
set NHANES.demog;
run;

data bmi;                    
set NHANES.bmi;
run;

proc sort data=demog;
by seqn;
run;

proc sort data=bmi;
by seqn;
run;

proc sort data=accel;
by seqn;
run;

data accel_all;
merge accel (in=a) bmi demog;
by seqn;
if a;
run;


proc print data=accel_all (obs=100);
var seqn wt_4 wtint4yr;
run;


* Demographic formats;

proc format;
value fsex 1='M' 2='F';
value fbmi 1='BMI <25' 2='BMI 25 to <30' 3= 'BMI 30 to <35' 4= 'BMI 35+';
value fage 1='<30 years' 2= '30 to <70 years' 3= '70+ years';
run;


* Creating categorical BMI variables;

data accel_all;;
set accel_all;
if bmxbmi=. then bmi_cat=.;
else if bmxbmi <25 then bmi_cat=1;
else if 30 > bmxbmi => 25 then bmi_cat=2;
else if 35 > bmxbmi => 30 then bmi_cat=3;
else if bmxbmi => 35 then bmi_cat=4;
format bmi_cat fbmi.;
run;

data accel_all;;
set accel_all;
if ridageyr=. then age_cat=.;
else if ridageyr <30 then age_cat=1;
else if 70 > ridageyr => 30 then age_cat=2;
else if ridageyr=> 70 then age_cat=3;
format age_cat fage.;
format riagendr fsex.;
run;


* Means and ste for subgroups;

proc sort data=accel_all;
by age_cat riagendr bmi_cat;
run;

proc surveymeans  data=accel_all mean stderr;
title'Group means for activity variables 4 days by age*gender*bmi groups';
strata SDMVSTRA;
cluster SDMVPSU;
domain age_cat*riagendr*bmi_cat ; 
var  avlight avmv avsed AVtotstep;
weight wt_4; 
ods output statistics =NHANES_mean;
run;


* P-values for comparisons across groups;

proc surveymeans  data=accel_all mean stderr;
title'P-Values for differences for Average Light Activity';
strata SDMVSTRA;
cluster SDMVPSU;
domain age_cat*riagendr*bmi_cat/ diffmeans ; 
var  avlight;
weight wt_4; 
ods output statistics =NHANES_pdif_l;
run;

proc surveymeans  data=accel_all mean stderr;
title'P-Values for differences for Average Moderate -vigorous Activity';
strata SDMVSTRA;
cluster SDMVPSU;
domain age_cat*riagendr*bmi_cat/ diffmeans ; 
var  avmv;
weight wt_4; 
ods output statistics =NHANES_pdif_MV;
run;

proc surveymeans  data=accel_all mean stderr;
title'P-Values for differences for Average Sedentary Time';
strata SDMVSTRA;
cluster SDMVPSU;
domain age_cat*riagendr*bmi_cat/ diffmeans ; 
var avsed;
weight wt_4; 
ods output statistics =NHANES_pdif_s;
run;

proc surveymeans  data=accel_all mean stderr;
title'P-Values for differences for Average Steps';
strata SDMVSTRA;
cluster SDMVPSU;
domain age_cat*riagendr*bmi_cat/ diffmeans ; 
var  AVtotstep;
weight wt_4; 
ods output statistics =NHANES_pdif_stp;
run;



/*********************************************************************************/
/*********************************************************************************/

/* Summary and Conclusion of the Code */
/*
Among adults aged 30 to under 70 years, higher BMI was consistently associated with lower levels of physical activity, particularly for moderate-to-vigorous activity and step counts. In men, significant reductions in moderate-to-vigorous activity and step counts were most pronounced in the BMI 35+ group, while light activity showed a smaller but significant decrease only in the highest BMI category. Sedentary time varied little across BMI groups. In women, declines in moderate-to-vigorous activity and step counts were observed across multiple higher BMI categories, with the BMI 35+ group also exhibiting significantly higher sedentary time and lower light activity.

In adults aged 70 years and older, the inverse association between BMI and physical activity was even more pronounced. Both men and women in higher BMI categories engaged in substantially less moderate-to-vigorous activity and accumulated fewer daily steps compared to those with BMI under 25 kg/m². Light activity also declined significantly with increasing BMI in several groups, particularly among older men. Sedentary time tended to increase with BMI, although these differences were not consistently statistically significant.

Patterns differed by sex, with females generally showing steeper declines in moderate-to-vigorous activity and step counts as BMI increased, particularly in the younger age group. However, sex differences narrowed in the oldest age group, where overall activity levels were low across BMI categories. These findings suggest that higher BMI may have a stronger relative impact on physical activity behaviors among women, especially for more intense forms of activity.

Overall, moderate-to-vigorous physical activity and step counts were the activity measures most strongly affected by BMI across age and sex strata. Light activity showed more modest declines, and sedentary time increased only slightly with higher BMI. Together, these results indicate that higher BMI, especially BMI =35 kg/m², is associated with substantial reductions in objectively measured physical activity, with effects that are more pronounced in older adults and in women.
*/









