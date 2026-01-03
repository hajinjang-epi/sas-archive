
/* PA Monitor Validity and Reliability */
/* Author: Hajin Jang */
/* Date: 9/24/2024 */


/*********************************************************************************/

/* 
This analysis evaluates the reliability, concurrent validity, and external validity of physical activity monitor measures by examining test-retest reliability across days, agreement between different activity metrics and devices, and comparability of activity levels with NHANES population data. 
*/
/*
The dataset includes multi-day physical activity monitor data from adults aged 20–69 years, with activity measured using waist-worn and wrist-worn accelerometers over up to 10 days. Measures include daily step counts, vector magnitude counts, and minutes of moderate-to-vigorous physical activity. The data allow assessment of within-person reliability across days, concurrent validity between different metrics and devices, and external validity through comparison with nationally representative NHANES estimates. 
*/

/*********************************************************************************/


* Validity;

libname Reli "C:\Users\HAJ90\OneDrive - University of Pittsburgh\Document\PA\pa_monitor";
run;

data accel;
set reli.accel;
run;

data fitbit;
set reli.fitbit;
run;

proc contents data=accel; 							
run;


* Get average per day and merge;

* Changing scale of VM counts to be more in line with the steps;

proc means data= accel mean median range p25 p75;
var steps_counts vector_magnitude_counts;
run;

data accel;
set accel;
vector_magnitude_ct_2=vector_magnitude_counts/100;
run;


* Get average per day for the accel data for the steps, VM counts;

proc means data=accel noprint;
var subject steps_counts vector_magnitude_ct_2;  
by subject;
output out=accel_av
mean(steps_counts)= steps 
mean(vector_magnitude_ct_2)=vector;
run;

proc means data= accel_av mean median range p25 p75;
var steps vector;
run;


* Individuals with less than 4 valid days (accepted minimum);

data accel_av_2;
set accel_av;
where _freq_ ge 4;
run;

proc print data=accel_av_2;
run;


* Merging in Fitbit data;

data fitbit;
set fitbit;
fitbit_steps= steps;
drop steps;
run;

proc sort data=fitbit;
by subject;
run;

data accel_av_2;
set accel_av_2;
accel_steps=steps;
drop steps;
run;

proc sort data=accel_av_2;
by subject;
run;

data accel_fitbit;
merge accel_av_2 fitbit;
by subject;
run;


* Running statistical tests;

* Spearman (continuous activity data still typically requires Spearman not Pearson);

* Steps to VM from the same monitor - ActiGraph;

proc corr data=accel_fitbit spearman;
 var vector accel_steps;
   run;


* Steps to steps across the ActiGraph and Fitbit monitor;

proc corr data=accel_fitbit spearman;
 var fitbit_steps accel_steps;
   run;


* Basic Bland Altman with representation of regression line;

* Creating Bland Altmand for steps vs. VM counts from the ActiGraph;

data datafile;
 set accel_fitbit;
 diffaccel_stepsvector=accel_steps-vector;
 meanaccel_stepsvector=mean(accel_steps,vector);
run;
************************************************
** Mean and standard deviation of the **
** difference accel_steps-vector **
************************************************;
proc means data=datafile mean std noprint;
 var diffaccel_stepsvector;
 output out=mdiff mean=mdiffaccel_stepsvector
 std=sddiffaccel_stepsvector;
run;
*************************************************
** Merging the mean and stadard deviation of the **
** difference with each observation in the **
** original data file **
*************************************************;
data datafile2;
 if _n_=1 then set mdiff;
 set datafile;
 lldiffaccel_stepsvector2=mdiffaccel_stepsvector-(2*sddiffaccel_stepsvector);
 uldiffaccel_stepsvector2=mdiffaccel_stepsvector+(2*sddiffaccel_stepsvector);
 lldiffaccel_stepsvector3=mdiffaccel_stepsvector-(3*sddiffaccel_stepsvector);
 uldiffaccel_stepsvector3=mdiffaccel_stepsvector+(3*sddiffaccel_stepsvector);
 drop _freq_ _type_;
run;
********************************************************************
** Creating the Bland Altman Plot with **
** scatter of the difference vs. the mean for each observation **
** a reference line at 0 in solid blue **
** a reference line at the mean of the difference in solid red **
** a reference line at +/- 2SD of the mean of the difference in **
** dashed red **
** a reference line at +/-3SD of the mean of the differences in **
** dashed green **
********************************************************************;
proc sgplot data=datafile2;
 scatter x=meanaccel_stepsvector y=diffaccel_stepsvector;
 refline lldiffaccel_stepsvector3/ axis=y lineattrs=(color=green pattern=2
 thickness=2pt);
 refline lldiffaccel_stepsvector2/ axis=y lineattrs=(color=red pattern=4
 thickness=2pt);
 refline mdiffaccel_stepsvector/ axis=y lineattrs=(color=red thickness=2pt);
 refline uldiffaccel_stepsvector2/ axis=y lineattrs=(color=red pattern=4
 thickness=2pt);
 refline uldiffaccel_stepsvector3/ axis=y lineattrs=(color=green pattern=2
 thickness=2pt);
 refline 0 / axis=y lineattrs=(color=blue thickness=2pt);
 yaxis label='Difference (accel_steps-vector)';
 xaxis label='Mean - (accel_steps+vector)/2';
 Yaxis values=(-4000 to 6000 by 500);
title 'Bland-Altman Plot of Difference (accel_steps-vector magnitude) vs Mean';
run;


* Creating Bland Altman for actigraph Steps versus Fitbit steps;

data datafile;
 set accel_fitbit;
 diffaccel_stepsfitbit_steps=accel_steps-fitbit_steps;
 meanaccel_stepsfitbit_steps=mean(accel_steps,fitbit_steps);
run;
************************************************
** Mean and standard deviation of the **
** difference accel_steps-fitbit_steps **
************************************************;
proc means data=datafile mean std noprint;
 var diffaccel_stepsfitbit_steps;
 output out=mdiff mean=mdiffaccel_stepsfitbit_steps
 std=sddiffaccel_stepsfitbit_steps;
run;
*************************************************
** Merging the mean and stadard deviation of the **
** difference with each observation in the **
** original data file **
*************************************************;
data datafile2;
 if _n_=1 then set mdiff;
 set datafile;
 lldiffaccel_stepsfitbit_steps2=mdiffaccel_stepsfitbit_steps-(2*sddiffaccel_stepsfitbit_steps);
 uldiffaccel_stepsfitbit_steps2=mdiffaccel_stepsfitbit_steps+(2*sddiffaccel_stepsfitbit_steps);
 lldiffaccel_stepsfitbit_steps3=mdiffaccel_stepsfitbit_steps-(3*sddiffaccel_stepsfitbit_steps);
 uldiffaccel_stepsfitbit_steps3=mdiffaccel_stepsfitbit_steps+(3*sddiffaccel_stepsfitbit_steps);
 drop _freq_ _type_;
run;
********************************************************************
** Creating the Bland Altman Plot with **
** scatter of the difference vs the mean for each observation **
** a reference line at 0 in solid blue **
** a reference line at the mean of the difference in solid red **
** a reference line at +/- 2SD of the mean of the difference in **
** dashed red **
** a reference line at +/-3SD of the mean of the differences in **
** dashed green **
********************************************************************;
proc sgplot data=datafile2;
 scatter x=meanaccel_stepsfitbit_steps y=diffaccel_stepsfitbit_steps;
 refline lldiffaccel_stepsfitbit_steps3/ axis=y lineattrs=(color=green pattern=2
 thickness=2pt);
 refline lldiffaccel_stepsfitbit_steps2/ axis=y lineattrs=(color=red pattern=4
 thickness=2pt);
 refline mdiffaccel_stepsfitbit_steps/ axis=y lineattrs=(color=red thickness=2pt);
 refline uldiffaccel_stepsfitbit_steps2/ axis=y lineattrs=(color=red pattern=4
 thickness=2pt);
 refline uldiffaccel_stepsfitbit_steps3/ axis=y lineattrs=(color=green pattern=2
 thickness=2pt);
 refline 0 / axis=y lineattrs=(color=blue thickness=2pt);
 yaxis label='Difference (accel_steps-fitbit_steps)';
 xaxis label='Mean - (accel_steps+fitbit_steps)/2';
 Yaxis values=(-2500 to 1000 by 500);
title 'Bland-Altman Plot of Difference (accel_steps-fitbit_steps) vs Mean';
run;


* Bland Altman to discuss the bias in more detail;

* Bland Altman for steps to steps across monitors;

data diffs ;
set accel_fitbit ;
/* calculate the difference */
diff = accel_steps-vector ;
/* calculate the average */
mean = (accel_steps+vector)/2 ;
run ;
proc print data = diffs;
run;

proc sql noprint ;
select mean(diff)-2*std(diff),  mean(diff)+2*std(diff)
into   :lower,  :upper 
from diffs ;
quit;
proc sgplot data = diffs ;
reg x = accel_steps y = diff/clm clmtransparency = .5;
needle x = Accel_steps y = diff/baseline = 0;
refline 0 / LABEL = ('No diff line');
TITLE 'Bland-Altman Plot ActiGraph Steps versus Vector Magnitude Counts/100';
footnote 'Accurate prediction with 10% homogeneous error'; 
run ;
quit ;


data diffs ;
set accel_fitbit ;
/* calculate the difference */
diff = accel_steps-fitbit_steps ;
/* calculate the average */
mean = (accel_steps+fitbit_steps)/2 ;
run ;
proc print data = diffs;
run;

proc sql noprint ;
select mean(diff)-2*std(diff),  mean(diff)+2*std(diff)
into   :lower,  :upper 
from diffs ;
quit;
proc sgplot data = diffs ;
reg x = accel_steps y = diff/clm clmtransparency = .5;
needle x = Accel_steps y = diff/baseline = 0;
refline 0 / LABEL = ('No diff line');
TITLE 'Bland-Altman Plot ActiGraph Steps versus Fitbit Steps';
footnote 'Accurate prediction with 10% homogeneous error'; 
run ;
quit ;


* Output descriptive statistics for comparison to other populations;

proc means data=accel noprint;
var subject steps_counts mod_vig;  
by subject;
output out=accel_av
mean(steps_counts)= steps 
mean(mod_vig)=moderatevig;
run;

data accel_av_2;
set accel_av;
where _freq_ ge 4;
run;


* Adults aged 20-69 years with a mean BMI of 26.8;

proc means data= accel_av_2 mean std median min p25 p75 max;
var steps moderatevig;
run;



/*********************************************************************************/
/*********************************************************************************/

/* Summary and Conclusion of the Code */
/*
Test-retest reliability analyses showed moderate reliability between Day 1 and Day 2 and between Day 1 and Day 8 for steps, vector magnitude, and moderate-to-vigorous activity minutes, suggesting some day-to-day variability in physical activity. Reliability estimates were generally lower when comparing Day 1 to Day 8, particularly for moderate-to-vigorous activity, which may reflect both natural fluctuations in behavior and potential reactivity on the first day of monitor wear. In contrast, reliability between averaged weekday and weekend measures was good, indicating relatively stable activity patterns across different types of days in this cohort.

Concurrent validity analyses demonstrated strong associations between different measures of physical activity. Step counts and vector magnitude counts from the same monitor were strongly correlated, indicating that both metrics capture similar underlying movement patterns despite measuring different aspects of activity. Comparisons between waist-worn and wrist-worn step counts also showed very high correlations; however, Bland–Altman analyses revealed systematic bias, with wrist-worn devices consistently overestimating step counts, particularly at higher activity levels.

Bland–Altman plots further illustrated that agreement between measures was not uniform across the range of activity. While average differences between ActiGraph step counts and vector magnitude counts were small, variability increased at higher activity levels, indicating reduced agreement as movement intensity increased. Similarly, wrist-worn devices showed increasing overestimation of steps with greater activity, likely due to arm movements being misclassified as steps.

External validity comparisons suggested that this cohort’s average step counts were lower than those typically reported in NHANES, while time spent in moderate-to-vigorous physical activity was comparable. This discrepancy highlights how different activity metrics can lead to different conclusions about population activity levels and underscores the importance of considering measurement methods and cohort characteristics when generalizing findings to broader populations.
*/




