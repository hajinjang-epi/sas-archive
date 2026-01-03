
/* NHANES Surveillance Analysis */
/* Author: Hajin Jang */
/* Date: 10/6/2024 */


/*********************************************************************************/

/* 
This analysis uses population-weighted NHANES survey data to describe physical activity and sedentary behaviors among U.S. adults aged 20 years and older, comparing activity patterns across sex, race and ethnicity, and age groups while appropriately accounting for the complex survey design. 
*/

/*
Data were drawn from the 2003–2004 and 2005–2006 cycles of the National Health and Nutrition Examination Survey (NHANES), restricted to adults aged 20 years and older. Physical activity outcomes were derived from household survey questions assessing participation in biking or walking, household tasks, moderate and vigorous activity, strength training, and time spent on the computer and watching television. All analyses incorporated NHANES sampling weights, strata, and clustering to generate population-representative estimates, and results were stratified by sex, race and ethnicity, and age group. 
*/

/*********************************************************************************/


* Read the data;

* Macro using PROC COPY and the XPORT engine for reading transport files;

%macro drive(dir,ext,out);                                                                                                                  
                                                                                                                                        
  %let filrf=mydir;                                                                                                                      
                                                                                                                                        
  /* Assigns the fileref of mydir to the directory and opens the directory */                                                                    
  %let rc=%sysfunc(filename(filrf,&dir));                                                                                                
  %let did=%sysfunc(dopen(&filrf));                                                                                                      
                                                                                                                                        
  /* Returns the number of members in the directory */                                                                   
  %let memcnt=%sysfunc(dnum(&did));                                                                                                      
                                                                                                                                        
   /* Loops through entire directory */                                                                                                  
   %do i = 1 %to &memcnt;                                                                                                                
    
     /* Returns the extension from each file */                                                                                                                                    
     %let name=%qscan(%qsysfunc(dread(&did,&i)),-1,.);                                                                                   
                                                                                                                                        
     /* Checks to see if file contains an extension */                                                                                     
     %if %qupcase(%qsysfunc(dread(&did,&i))) ne %qupcase(&ext) %then %do;                                                                  
                                                                                                                                        
     /* Checks to see if the extension matches the parameter value */                                                                      
     /* If condition is true, submit PROC COPY statement  */                                                                      
     %if (%superq(ext) ne and %qupcase(&name) = %qupcase(&ext)) or                                                                       
         (%superq(ext) = and %superq(name) ne) %then %do;    
                                                                         
     	    libname old xport "&dir.\%qsysfunc(dread(&did,&i))"; 
		libname new "&out";
		proc copy in=old out=new;
		run;
     %end;                                                                                                                               
   %end; 
  %end; 
                                                                                                                                        
  /* Close the directory */                                                                                                            
  %let rc=%sysfunc(dclose(&did));                                                                                                        
/* END MACRO */                                                                                                                                           
%mend drive;   


* Macro call;

%drive(C:\Users\HAJ90\OneDrive - University of Pittsburgh\Document\PA\surveillance\xpt,xpt,C:\Users\HAJ90\OneDrive - University of Pittsburgh\Document\PA\surveillance\xpt\converted);  

libname NHANES 'C:\Users\HAJ90\OneDrive - University of Pittsburgh\Document\PA\surveillance\xpt\converted';

proc contents data=NHANES.demo_c;
run;


* Reweighting and add datasets together;

* Append demo data from 2003-04 and 2005-06;

data NHANES.demog;
set NHANES.demo_c NHANES.demo_d;
run;

* Reweighting the new dataset to account for the additional years of data;

data NHANES.demog;
set NHANES.demog;
if sddsrvyr in (3) then WTINT4YR = 2/4 * WTINT2YR;
run;

data NHANES.demog;
set NHANES.demog;
if sddsrvyr in (4) then WTINT4YR = 2/4 * WTINT2YR;
run;


* Merging two PA files and adding them to the demographic data;

proc sort data=NHANES.paq_c;  
by SEQN;
run;

proc sort data=NHANES.paq_d;
by SEQN;
run;

data NHANES.activity;
merge NHANES.paq_c NHANES.paq_d;  
by SEQN;
run;


/*********** Adding the physical activity data to the other data **************************/

proc sort data=NHANES.demog;
by SEQN;
run;

proc sort data=NHANES.activity;
by SEQN;
run;

data NHANES.NHANES_combo;
merge NHANES.demog NHANES.activity;  
by SEQN;
run;


/************** Examining the completeness of the data ********************/

proc contents data=NHANES.NHANES_combo;
run;

data NHANES_combo;
set NHANES.NHANES_combo;
run;


* Creating additional categorical groups;

proc format;
value fsex 1='M' 2='F';
value race5f
1= 'Mexican Am'
2= 'Other Hispanic' 
3=  'NH White'
4 = 'NH Black'
5 = 'Other Race';
value age5f
1='6-19 years'
2='20-39 years'
3='40-59 years'
4='60-69 years'
5='70+ years';
value age2f
        1='<19 yrs'
        2='20+yrs'
        ;
value dichotf
	    1='yes'
		0='no';
value sedf
	   1='less than 1 hour/day'
	   2='1-3 hours/day'
	   3='>3 hours/day';

run;


* Creating categorical data;

/*********** AGE **********/
data NHANES_combo;                             
set NHANES_combo;
if ridageyr<20 then agegrp2=1;					
else if 20<=ridageyr then agegrp2=2;
format agegrp age2f.;							
run;

data NHANES_combo;
set NHANES_combo;
if ridageyr <20 then agegrp5=1;
else if 20<=ridageyr <40 then agegrp5=2;
else if 40<=ridageyr <60 then agegrp5=3;
else if 60<=ridageyr <70 then agegrp5=4;
else if 70<=ridageyr <80 then agegrp5=5;
format agegrp5 age5f.;
run;

data NHANES_combo;
set NHANES_combo;
format RIAGENDR fsex.;
format  RIDRETH1 race5f.;
run;


* Calculating activity variabes;

data NHANES_combo;                        
set NHANES_combo;
if PAD020=1 then walk_bike=1;
else if PAD020>1 then walk_bike=0;
else walk_bike=.;
format walk_bike dichotf.;
run;

data NHANES_combo;
set NHANES_combo;
if PAD200=1 then vig=1;
else if PAD200>1 then vig=0;
else vig=.;
format vig dichotf.;
run;

data NHANES_combo;
set NHANES_combo;
if PAD320=1 then mod=1;
else if PAD320>1 then mod=0;
else mod=.;
format mod dichotf.;
run;

data NHANES_combo;
set NHANES_combo;
if PAD440=1 then strength=1;
else if PAD440>1 then strength=0;
else strength=.;
format strength dichotf.;
run;

data NHANES_combo;
set NHANES_combo;
if PAQ100=1 then tasks=1;
else if PAQ100>1 then tasks=0;
else tasks=.;
format tasks dichotf.;
run;


* TV and computer collapsed to 3 categories;

data NHANES_combo;
set NHANES_combo;
if PAD590=0 then tv=1;
else if PAD590=1 then tv=1;
else if PAD590=6 then tv=1;
else if PAD590=2 then tv=2;
else if PAD590=3 then tv=2;
else if PAD590=4 then tv=3;
else if PAD590=5 then tv=3;
else tv=.;
format tv sedf.;
run;

data NHANES_combo;
set NHANES_combo;
if PAD600=0 then comp=1;
else if PAD600=1 then comp=1;
else if PAD600=6 then comp=1;
else if PAD600=2 then comp=2;
else if PAD600=3 then comp=2;
else if PAD600=4 then comp=3;
else if PAD600=5 then comp=3;
else comp=.;
format comp sedf.;
run;


* Output by demographic subgroups;

* Calculating frequencies and running Chi-square for comparisons across subgroups;

/************* Gender Groups *************/

proc sort data=NHANES_combo;
by agegrp2;
run;

proc surveyfreq data=NHANES_combo;
by agegrp2;										
strata SDMVSTRA;								
cluster SDMVPSU;			
tables RIAGENDR*(tv comp walk_bike tasks mod vig strength)/ wchisq wllchisq nostd chisq chisq1;
weight WTINT4YR; 
run;


/************* Race/Ethnicity Groups ******/

proc surveyfreq data=NHANES_combo;
by agegrp2;										
strata SDMVSTRA;							
cluster SDMVPSU;								
tables ridreth1*(tv comp walk_bike tasks mod vig strength)/ wchisq wllchisq nostd chisq chisq1 ;
weight WTINT4YR; 
run;


/***************** Age *************/;

proc surveyfreq data=NHANES_combo;
strata SDMVSTRA;
cluster SDMVPSU;
tables agegrp5*(tv comp walk_bike tasks mod vig strength) / wchisq wllchisq nostd chisq chisq1;
weight WTINT4YR;
where agegrp2=2;                                  
run;



/*********************************************************************************/
/*********************************************************************************/
	
/* Summary and Conclusion of the Code */
/*
Sex-stratified analyses showed statistically significant differences for most physical activity and sedentary behavior outcomes. Men reported higher participation in biking or walking, vigorous activity, and strength training, while women reported slightly higher participation in household tasks and greater time spent watching television. In contrast, participation in moderate activity did not differ significantly by sex. Notably, several statistically significant differences were small in magnitude, reflecting the influence of large sample sizes in population-weighted survey data.

Clear disparities were observed across racial and ethnic groups. White adults consistently reported higher participation in all forms of physical activity, including moderate and vigorous activity and strength training, compared with Black, Mexican American, Other Hispanic, and Other race groups. Sedentary behaviors, such as time spent on the computer and watching television, also varied significantly by race and ethnicity, highlighting substantial heterogeneity in activity patterns across population subgroups.

Strong age-related gradients were evident across all outcomes. Participation in biking or walking, moderate activity, vigorous activity, and strength training declined sharply with increasing age, particularly among adults aged 60 years and older. Conversely, younger adults reported higher levels of screen-based sedentary behaviors, while older adults showed lower engagement in both high-intensity activity and prolonged screen time. All age-based comparisons were highly statistically significant.

Despite many highly significant p-values, the observed differences across groups were often modest, underscoring the importance of focusing on the magnitude and practical relevance of estimated differences rather than statistical significance alone. Variation in chi-square values across outcomes suggests that some activity measures may be more sensitive to subgroup differences than others, reinforcing the need to assess potential bias and consider reweighting when subgroup distributions or missing data patterns differ substantially.
*/
												
