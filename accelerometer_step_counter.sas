
/* Accelerometer / Step Counter */
/* Writer: Hajin Jang */
/* Date: 9/4/2024 */

/*********************************************************************************/
/* 
This analysis evaluates the level of agreement between an activity diary, a thigh-worn step counter, and a waist-worn accelerometer in classifying time spent in different physical activity intensities and in determining whether an individual meets WHO/CDC moderate-to-vigorous physical activity recommendations. 
*/

/*
The dataset consists of one full day of minute-level physical activity data from a single participant, derived from three measurement methods: a self-reported activity diary recorded in 15-minute blocks and two device-based measures (a thigh-worn step counter and a waist-worn accelerometer) that capture activity in 1-minute epochs. Diary data were converted to minute-level observations to align with device data, and all observations outside the diary recording window were excluded to ensure comparability across methods. Activity intensity was categorized into sedentary, light, moderate-to-vigorous, and exploratory non-ambulant behaviors.
*/
/*********************************************************************************/


libname assign "C:\Users\HAJ90\OneDrive - University of Pittsburgh\Document\PA\reliability"; run;


* Create copy of data;

data mets;
set assign.mets;
run;

data activity;
set assign.activity;
run;

proc contents data=mets;      
run;						 

proc print data=mets;
run;

proc contents data= activity;
run;

 proc print data=activity (obs=10);
 run;


* Assigning intensity levels to variables;

Proc sort data=activity;
by activity;
run;

proc sort data=mets;
by activity;
run;

data activity_2;      
merge activity mets;
by activity;
run;


* Assigning intensity levels to diary activity based on accepted met value cutpoints;

data activity_2;  
set activity_2;
if met <1.5 then d_intensity=1;
else if 1.5<= met <3.0 then d_intensity=2;
else if  3.0<= met then d_intensity=3;
label d_intensity= 'diary intensity level 1=sedentary 2=light 3=moderate-vigorous';
run;


* Assigning intensity levels to step counts based on step cutpoints;

data activity_2;  
set activity_2;
if steps =0 then s_intensity=1;
else if 1<= steps <100 then s_intensity=2;
else if 100<= steps then s_intensity=3;
label s_intensity= 'steps intensity level 1=non=ambulation 2=light 3=moderate-vigorous'; 
run;


* Assigning intensity levels to accelerometer counts based on Freedson VM cutpoints;

data activity_2; 
set activity_2;
if ac_counts < 100 then a_intensity=1;
else if 100<= ac_counts <2690 then a_intensity=2;
else if 2690<= ac_counts then a_intensity=3;
label a_intensity= 'accelerometer intensity level 1=sedentary 2=light 3=moderate-vigorous';
run;


* Output descriptive statistics on amount of time in each activity level;

proc freq data=activity_2;
tables (d_intensity s_intensity a_intensity) * count; 
title 'Descriptive stats: number of minutes and % of time in each intensity level';
run;

proc means data=activity_2 sum; /* total steps for this day */
var steps;
title 'Total step counts for the day';
run;


* Creating a pie graph for each measurement method showing the % of time spent in each activity level;
* Creating dichotomous variables for each intensity level;

data activity_2;			
set activity_2;
if d_intensity=1 then Sed_D=1;
else Sed_D=0;
run;

data activity_2;
set activity_2;
if d_intensity=2 then Light_D=1;
else Light_D=0;
run;

data activity_2;
set activity_2;
if d_intensity=3 then Modvig_D=1;
else Modvig_D=0;
run;


/*********************************************/

data activity_2;					
set activity_2;
if s_intensity=1 then Sed_S=1;   /* non-ambulation variable, not exact equivalent to SED*/
else Sed_S=0;
run;

data activity_2;
set activity_2;
if s_intensity=2 then Light_S=1;
else Light_S=0;
run;

data activity_2;
set activity_2;
if s_intensity=3 then Modvig_S=1;
else Modvig_S=0;
run;

/********************************************/

data activity_2;					
set activity_2;
if a_intensity=1 then Sed_A=1;
else Sed_A=0;
run;

data activity_2;
set activity_2;
if a_intensity=2 then Light_A=1;
else Light_A=0;
run;

data activity_2;
set activity_2;
if a_intensity=3 then Modvig_A=1;
else Modvig_A=0;
run;


* Comparisons by groups;
* BY using Cochran Q to test if the probability of all three groups positivily identifying minutes as a given intensity level is the same;

proc freq data=activity_2;
   tables Light_D Light_S Light_A / nocum;
   tables Light_D*Light_S*Light_A / agree noprint;  
   format Light_D Light_S Light_A;
   /* weight Count */                          
   title 'Study of Three Activity Mesurement Methods for Assessing Light Activity';
run;

proc freq data=activity_2;
   tables Modvig_D Modvig_S Modvig_A / nocum;
   tables Modvig_D*Modvig_S*Modvig_A / agree noprint;  
   /* weight Count */                        
   title 'Study of Three Activity Mesurement Methods for Assessing Moderate-Vigorous Activity';
run;


* Comparison across the Sedentary group as an exploratory analyses;
 
 proc freq data=activity_2;
   tables Sed_D Sed_S Sed_A / nocum;
   tables Sed_D*Sed_S*Sed_A / agree noprint;  
   /* weight Count; */                       
   title 'Exploratory Study of Three Activity Mesurement Methods for Assessing Sedentary and Non-Ambulation';
run;


* Pairwise comparison for sets where there was a difference;

* Light;

proc freq data=activity_2;
		title "McNemar's test for Paired Samples";
		tables Light_D*Light_S /agree expected norow nocol nopercent; 
		run;
proc freq data=activity_2;
		title "McNemar's test for Paired Samples";
		tables Light_D*Light_A /agree expected norow nocol nopercent; 
		run;
proc freq data=activity_2;
		title "McNemar's test for Paired Samples";
		tables Light_S*Light_A /agree expected norow nocol nopercent; 
		run;

* Experimental Sedentary, non-ambulation;

proc freq data=activity_2;
		title "McNemar's test for Paired Samples";
		tables SED_D*SED_S /agree expected norow nocol nopercent; 
		run;
proc freq data=activity_2;
		title "McNemar's test for Paired Samples";
		tables SED_D*SED_A /agree expected norow nocol nopercent; 
		run;
proc freq data=activity_2;
		title "McNemar's test for Paired Samples";
		tables SED_S*SED_A /agree expected norow nocol nopercent; 
		run;


* Multiple testing correction;

* Light;

data pv;
         input Test $ raw_p;   
         datalines;
      testds .0001
      testda .0001
      tessa .5994
      ;
run;

proc multtest inpvalues=pv bon holm hoc fdr;  
         run;								  

* Exploratory sedentary / non-ambulation;

data pv;
         input Test $ raw_p;    
         datalines;
      testds .0001
      testda .0001
      testsa .8907
      ;
run;

proc multtest inpvalues=pv bon holm hoc fdr; 
         run;			


/*********************************************************************************/
/*********************************************************************************/

/* Summary and Conclusion of the Code */
/*
Overall agreement between the three methods varied by activity intensity. Agreement was strongest for moderate-to-vigorous physical activity, with a high overall Kappa coefficient and no significant differences across methods, indicating consistent classification of higher-intensity activities. In contrast, agreement for light activity and sedentary behavior was weaker, particularly between the activity diary and the device-based measures, while agreement between the step counter and accelerometer remained relatively high.

The poorer agreement involving the diary likely reflects its subjective nature. Participants may misclassify activities, especially those near intensity cutpoints, due to recall bias or difficulty perceiving exertion. Additionally, the diary’s use of 15-minute time blocks may obscure short bouts of activity or inactivity that are captured more precisely by device-based measures operating at 1-minute resolution.

The exploratory distinction between non-ambulant and sedentary behavior offers potential value by providing more nuanced insight into passive sitting versus low-intensity standing or minimal movement. However, this comparison has limitations, as borderline activities such as very slow walking or subtle movements may be inconsistently classified across methods, reducing interpretability.

Finally, all three methods identified the participant as meeting WHO/CDC physical activity guidelines, whether assessed using minutes of moderate-to-vigorous activity or a daily step count threshold. While the step count approach yielded the same conclusion in this case, it does not capture activity intensity and may misclassify light walking as moderate activity. Using both step-based and intensity-based metrics together may therefore provide a more comprehensive assessment of physical activity behavior.
*/
