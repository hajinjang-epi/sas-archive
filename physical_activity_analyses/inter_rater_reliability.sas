
/* Inter Rator Reliability */
/* Writer: Hajin Jang */
/* Date: 9/9/2024 */


/*********************************************************************************/

/* 
This analysis evaluates inter-rater reliability among three trained reviewers assessing park use by comparing their agreement on counts of individuals and categorical characteristics, including age group, device use, and activity intensity, using percent agreement, Kappa statistics, and Intraclass Correlation Coefficients (ICC). 
*/

/*
The data consist of observations from three trained reviewers who independently assessed the same video-recorded park areas during identical 30-minute time blocks. Reviewers recorded the number of individuals entering each area and classified each individual by age group, assisted walking device use, wheeled device use, and activity intensity. Because all reviewers evaluated the same recordings under standardized conditions, the dataset supports direct comparison of agreement across reviewers for both categorical variables and continuous counts. 
*/

/*********************************************************************************/


libname Obs "H:\Document\PA\2_1_Observation"; 
run;


* Create copy;

data counts;
set obs.counts;
run;

data individuals;
set obs.individuals;
run;

proc contents data=counts;     
run;						 

proc print data=counts;
run;

proc contents data= individuals;
run;

 proc print data=individuals (obs=10);
 run;


* Transpose to wide format;

proc sort data= individuals;
by id;
run;

/* Age */

proc transpose data = individuals out=age prefix=rater_; 
by id; 
id rater; 
var age; 
run;

proc print data=age;
run;

proc contents data=age;
run;

/* assist */

proc transpose data = individuals out=assist prefix=rater_; 
by id; 
id rater; 
var assist; 
run;

proc print data=assist;
run;

proc contents data=assist;
run;

/* wheels */

proc transpose data = individuals out=wheels prefix=rater_; 
by id; 
id rater; 
var wheels; 
run;

proc print data=wheels;
run;

proc contents data=wheels;
run;

/* intensity */

proc transpose data = individuals out=intensity prefix=rater_; 
by id; 
id rater; 
var intensity; 
run;

proc print data=intensity;
run;

proc contents data=intensity;
run;


* Output matching numbers;
* number matching across all categories and between individual pairs;

/* Age */

proc print data=age;
title "Age matching across all 3 ";
where rater_1=rater_2 and rater_2=rater_3;
run;

proc print data=age;
title "Age matching 1 to 2 ";
where rater_1=rater_2;
run;

proc print data=age;
title "Age matching 1 to 3 ";
where rater_1=rater_3;
run;

proc print data=age;
title "Age matching 2 to 3 ";
where rater_2=rater_3;
run;

/* assist */

proc print data=assist;
title "Assist matching across all 3 ";
where rater_1=rater_2 and rater_2=rater_3;
run;

proc print data=assist;
title "assist matching 1 to 2 ";
where rater_1=rater_2;
run;

proc print data=assist;
title "assist matching 1 to 3 ";
where rater_1=rater_3;
run;

proc print data=assist;
title "assist matching 2 to 3 ";
where rater_2=rater_3;
run;

/* Wheels */

proc print data=Wheels;
title "Wheels matching across all 3 ";
where rater_1=rater_2 and rater_2=rater_3;
run;

proc print data=Wheels;
title "wheels matching 1 to 2 ";
where rater_1=rater_2;
run;

proc print data=Wheels;
title "wheels matching 1 to 3 ";
where rater_1=rater_3;
run;

proc print data=Wheels;
title "wheels matching 2 to 3 ";
where rater_2=rater_3;
run;

/* Intensity */

proc print data=Intensity;
title "Intensity matching across all 3 ";
where rater_1=rater_2 and rater_2=rater_3;
run;

proc print data=Intensity;
title "intensity matching 1 to 2 ";
where rater_1=rater_2;
run;

proc print data=Intensity;
title "intensity matching 1 to 3 ";
where rater_1=rater_3;
run;

proc print data=Intensity;
title "intensity matching 2 to 3 ";
where rater_2=rater_3;
run;


* Calculating the ICC for the ordinal and continuous variables;

data individuals;
set obs.individuals;
title " ";
run;

%macro intracc(data=_LAST_,target=TARGET???,rater=RATER???,
               depvar=DEPVAR???,nrater=0,out=_DATA_,print=1);

title2 'Intraclass Correlations for Inter-Rater Reliability';
proc glm data=&data outstat=_stats_
  %if &print<3 %then noprint; ;
  * glm: sums of squares in reliability calculation;
  class &target &rater;
  model &depvar = &target &rater ;
  run;

proc sort data=_stats_;
  by _name_ _SOURCE_;
  run;

%if &print>=2 %then %do;
proc print data=_stats_;
  title3 'Statistics from 2-way ANOVA w/o Interaction';
  run;
%end;

data &out;
  title3 'Calculate all reliabilities in one fell swoop';
  retain msw msb wms ems edf bms bdf jms jdf k;
  set _stats_;
  by _name_;
  if upcase(_type_)='SS1' then delete;
  if upcase(_source_)='ERROR' then do;
     ems=ss/df;
     edf=df;
  end;
  if upcase(_source_)="%upcase(&target)" then do;
     bms=ss/df;
     msb=bms;
     bdf=df;
  end;
  if upcase(_source_)="%upcase(&rater)" then do;
     jms=ss/df;
     jdf=df;
     k=df+1;
  end;
  if last._name_ then do;
    msw=((ems*edf)+(jms*jdf))/(edf+jdf);
    wms=msw;
    n=bdf+1;
    theta=(msb-msw)/(k*msw);                   * Winer formulae;
    wsingle=theta/(1+theta);                   * Winer ICC(1,1);
    wk=(k*theta)/(1+k*theta);                  * Winer ICC(1,k);
    %if &nrater %then %do;
    wnrater=(&nrater*theta)/(1+&nrater*theta); * Winer reliability
                                                 if mean of nraters;
    %end;
    sfsingle=(bms-wms)/(bms+(k-1)*wms);        * ICC(1,1);
    sfrandom=(bms-ems)/
        ((bms)+((k-1)*ems)+((k*(jms-ems))/n)); * ICC(2,1);
    sffixed=(bms-ems)/(bms+((k-1)*ems));       * ICC(3,1);
    sfk=(bms-wms)/bms;                         * ICC(1,k);
    sfrandk=(bms-ems)/(bms+((jms-ems)/n));     * ICC(2,k);
    sffixedk=(bms-ems)/bms;                    * ICC(3,k) with no
                                                 interaction assumption;
    output;
  end;
  label wsingle="Winer reliability: single score"
        wk="Winer reliability: mean of k scores"
        %if &nrater %then %do;
        wnrater="Winer reliability: mean of &nrater scores"
        %end;
        sfsingle="Shrout-Fleiss reliability: single score"
        sfrandom="Shrout-Fleiss reliability: random set"
        sffixed="Shrout-Fleiss reliability: fixed set"
        sfk="Shrout-Fleiss reliability: mean k scores"
        sfrandk="Shrout-Fleiss rel: rand set mean k scrs"
        sffixedk="Shrout-Fleiss rel: fxd set mean k scrs";
run;

%if &print %then %do;
proc print label;
  id _name_;
  var msw msb wms ems edf bms bdf jms jdf k theta
      wsingle wk %if &nrater %then wnrater;
      sfsingle sfrandom sffixed sfk sfrandk sffixedk;
run;
%end;

%mend intracc;


* Call macro;

/* Age */

data individuals;   
set individuals;
run;
%intracc(depvar=age, target=id, rater=rater, nrater=3);

/* Intensity */

data individuals;   
set individuals;
run;

%intracc(depvar=intensity, target=id, rater=rater, nrater=3);

/* Count */

proc transpose data=counts  /* Transpose wide data to long form */
   out=counts_2 (rename=(col1=counts _name_=reviewer));
   var reviewer_1-reviewer_3;
   by time_period;
run;

proc contents data=counts_2;
run;

data counts_2;   
set counts_2;
run;

%intracc(depvar=counts, target=time_period, rater=reviewer, nrater=3);


* Calculating the Kappa Coefficients for the binary variables of Assist and Wheels;

* Paired Kappas;

proc freq data = assist;
      tables Rater_1 * Rater_2 /agree;
test kappa;
title "Assist Kappa 1 to 2";
   run;

proc freq data = assist;
      tables Rater_2 * Rater_3 /agree;
test kappa ;
title "Assist Kappa 2 to 3";
   run;

proc freq data = assist;
      tables Rater_1 * Rater_3 /agree;
test kappa ;
title "Assist Kappa 1 to 3";
   run;


* Running Kappa statistics across pairs for the Wheels data;

proc freq data = wheels;
      tables Rater_1 * Rater_2 /agree;
test kappa;
title "wheels Kappa 1 to 2";
   run;

proc freq data = wheels;
      tables Rater_2 * Rater_3 /agree;
test kappa ;
title "wheels Kappa 2 to 3";
   run;

proc freq data = wheels;
      tables Rater_1 * Rater_3 /agree;
test kappa ;
title "wheels Kappa 1 to 3";
   run;


* Kappa across all 3 raters;

data obs.assist;
set assist;
rater1=rater_1;
rater2=rater_2;
rater3=rater_3;
drop _LABEL_ _NAME_ rater_1 rater_2 rater_3;

run;

proc contents data=obs.assist;
run;


data obs.wheels;
set wheels;
drop _LABEL_ _NAME_;
run;

proc contents data=obs.wheels;
run;



/*********************************************************************************/
/*********************************************************************************/

/* Summary and Conclusion of the Code */
/*
Overall percent agreement across reviewers was generally high, though it varied by variable. Agreement was strongest for assisted device use, which showed very high consistency across all reviewers, and for activity intensity, which also demonstrated strong agreement. In contrast, wheeled device use showed moderate agreement, and age group classification had the lowest overall agreement, suggesting greater difficulty in consistently classifying age from observational data.

Patterns of disagreement differed by reviewer pair. Reviewers 1 and 3 showed the lowest agreement for age group, assisted device use, and wheeled device use, while reviewers 2 and 3 had the lowest agreement for activity intensity. These differences likely reflect variability in subjective judgment, particularly for characteristics that require visual estimation, such as age category or borderline activity intensity.

Reliability assessed using ICC showed good to excellent agreement across all outcomes. The Shrout-Fleiss fixed-effects ICC, which was the primary measure given the fixed set of trained reviewers, demonstrated strong reliability for age, intensity, and counts. ICC values from the random-effects model were slightly higher, reflecting the assumption of greater variability across a broader reviewer population. The fixed-effects mean k scores ICC showed the highest agreement, as averaging across reviewers reduces individual-level variability and enhances reliability.

Kappa statistics supported these findings for binary variables. Assisted device use demonstrated substantial agreement well beyond chance across all reviewers and reviewer pairs, while wheeled device use showed only moderate agreement with notable variability across pairs. Together, the ICC and Kappa results indicate that reviewer agreement was strongest for clearly observable characteristics and weakest for variables requiring subjective interpretation, reinforcing the value of multi-metric reliability assessment in observational studies.
*/
