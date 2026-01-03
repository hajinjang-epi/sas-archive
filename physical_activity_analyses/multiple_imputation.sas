
/* Multiple Imputation */
/* Writer: Hajin Jang */
/* Date: 12/05/2024 */


/*********************************************************************************/

/* 
This analysis evaluates the feasibility and limitations of using multiple imputation for missing physical activity data by assessing correlations among candidate predictors, relationships with missingness, and comparing imputed results to complete-case analyses. 
*/

/*
Data were drawn from a longitudinal lifestyle intervention study with objectively measured physical activity outcomes, including average daily steps, moderate-to-vigorous physical activity minutes, and sedentary time. Several demographic and study-related variables (age, age category, sex, intervention assignment, and intervention-related indicators) were examined for their associations with activity outcomes and with missingness. These variables were evaluated to determine whether they were sufficiently correlated with outcomes and missingness to support valid multiple imputation. 
*/

/*********************************************************************************/


libname clinic "C:\Users\HAJ90\OneDrive - University of Pittsburgh\Document\PA\8_Missing data"; run;


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
set clinic.interven2;
run;

data cov;
set clinic.cov;
run;

proc contents data= cov;
run;

proc contents data=interven;
run;

proc freq data=interven;
tables id*time;
run;

data missing;
input id time;
datalines;
1011	1
1014	2
1024	2
1035	1
1043	1
1079	1
1079	2
1086	2
1093	1
1093	2
2010	2
2043	1
2043	2
2056	2
2070	1
2070	2
3034	2
3042	1
3042	2
3047	1
3047	2
3051	2
3052	1
3071	1
3071	2
3073	2
3094	2
3099	1
3099	2
5004	2
5009	1
5009	2
5015	2
5035	2
5036	1
5036	2
5039	2
5045	2
5049	1
5049	2
5058	2
5060	2
5072	2
5073	1
5073	2
5083	2
5090	2
5098	2
5101	2
5104	2
5111	1
5111	2
5120	2
5122	2
6005	2
6010	1
6010	2
6017	2
6021	2
6035	2
6040	2
6042	1
6047	2
6051 	1
6051	2
6053	2
6058	2
6059	2
6060	2
6062	2
6068	2
6078	2
6083	2
6085	2
6086	2
6091	1
6101	1
6101	2
6108	2
6110	1
6110	2
6111	2
6112	2
6118	2
6119	2
6121	1
6123	2
6124	2
7002	2
7003	1
7003	2
7008	2
7009	2
7019	1
7019	2
7020	2
7025	2
7030	1
7030	2
7032	1
7032	2
7037	2
7043	1
7043	2
7050	1
7050	2
7052	1
7052	2
7063	2
7067	1
7067	2
7072	1
7072	2
7077	1
7078	2
7085	1
7085	2
7092	2
7096	2
7099	2
7100	1
7100	2
7103	2
7106	2
7115	2
7122	2
7134	2
7135	2
;
run;

data interven2;
set interven missing;run;

PRoc freq data=interven2;
tables ID*Time;
run;

proc sort data=interven2;
by id;run;

proc sort data=cov;
by id; run;

* Add covariates;

data all;
merge interven2 (in=a) cov;
by id;
if a;
run;


* Variables used for imputation;

* Identifying missing values;

proc means data=all nmiss; 
run;

proc corr data=all;				
var avsteps age agecat;	
where avsteps ne .;
run;

proc corr data=all;				
var avmv age agecat ;	
where avmv ne .;
run;

proc corr data=all;				
var avsed age agecat ;	
where avsed ne .;
run;


* t-tests;

proc ttest data=all;
var avsteps avsed avmv;
class IMM;
run;

proc ttest data=all;
var avsteps avsed avmv;
class Assign;
run;

proc ttest data=all;
var avsteps avsed avmv;
class gender;
run;


/************************************************************************************************************************************/;

* Relationship with potential variables for imputation and missingness;

* Flags for missing;

    data hsb_flag;												
    set all;
    if avsteps =.  then activity_flag =1; else activity_flag =0;
    run;

    proc freq data=hsb_flag;										
    tables activity_flag;
    run;


* Identifying patterns of missingness;

proc mi data=HSB_flag nimpute=0 ;
ods select misspattern;
run;

proc ttest data=hsb_flag;
var Age agecat;
class activity_flag;
run;

proc freq data=hsb_flag;
tables activity_flag* (gender imm assign)/ chisq;
run;



* Imputation procedures;

* Imputation phase;

proc mi data= all nimpute=10 out=mi_mvn seed=54321
minimum=40 0 0	0 150 150
maximum=80 1 1	50 12000 950;
var age gender imm avmv avsteps avsed;	
run;


* Analyses phase;

/*************MVPA *******************/

TITLE " MULTIPLE IMPUTATION REGRESSION MVPA";
proc glm data = mi_mvn ;							
model avmv = assign|time;							
by _imputation_;									
ods output ParameterEstimates=a_mv;			       
run;
quit;

* Pooling data;

proc mianalyze parms=a_mv;
modeleffects intercept assign time assign*time;
run;


/*************Steps *******************/

TITLE " MULTIPLE IMPUTATION REGRESSION Steps";
proc glm data = mi_mvn ;
model avsteps = assign|time;
by _imputation_;
ods output ParameterEstimates=a_step;
run;
quit;

* Pooling data;

proc mianalyze parms=a_step;
modeleffects intercept assign time assign*time;
run;


/*************SED *******************/

TITLE " MULTIPLE IMPUTATION REGRESSION Sed";
proc glm data = mi_mvn ;
model avsed = assign|time;
by _imputation_;
ods output ParameterEstimates=a_sed;
run;
quit;

* Pooling data;

proc mianalyze parms=a_sed;
modeleffects intercept assign time assign*time;
run;



/*********************************************************************************/
/*********************************************************************************/

/* Summary and Conclusion of the Code */
/*
Correlation analyses showed that age and age category were significantly associated with step counts and moderate-to-vigorous physical activity, although the strength of these correlations was modest (all correlations <0.4). Intervention-related variables, including assignment and IMM, were significantly associated with steps and moderate-to-vigorous activity, while sedentary time showed weaker or inconsistent associations with the tested variables. Overall, IMM emerged as the variable most strongly related to activity outcomes and thus the most promising candidate for inclusion in imputation models, with age, sex, and assignment providing secondary support.

Assessment of missingness indicated that missing data were not completely at random. Age and IMM were significantly related to missingness, suggesting that certain subgroups were more likely to have incomplete activity data. This pattern highlights a limitation of the study design, as missingness related to variables that are also associated with the outcomes of interest can introduce bias and threaten the validity and generalizability of complete-case analyses.

Despite some significant associations, the dataset did not meet recommended criteria for robust multiple imputation, which typically require several predictors with moderate to strong correlations (=0.4) with both the outcome and missingness. As a result, imputation models in this study were limited in their ability to accurately recover missing activity data. Comparisons with results from the previous analysis showed that imputed analyses did not materially change the overall conclusions: short-term increases in physical activity were observed, but no sustained improvements were evident over the intervention period, and sedentary time remained largely unchanged.

Finally, reliance on baseline or prior time-point variables for imputing later activity measures may introduce bias in intervention studies. Because participants were actively encouraged to change their behavior, imputing missing follow-up data based primarily on pre-intervention values may underestimate true intervention effects or misrepresent individual trajectories. These findings underscore the importance of planning for missing data a priori by collecting additional behavioral, health, and contextual variables that are meaningfully related to physical activity and sedentary behavior to support more valid imputation.
*/
