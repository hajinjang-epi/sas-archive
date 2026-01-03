
/* Intensive Longitudinal Data (ILD) analysis and Mulilevel Structure */
/* Writer: Hajin Jang */
/* Date: 12/24/2024 */


/*********************************************************************************/

/* 
This analysis introduces intensive longitudinal data (ILD) analysis by explaining its multilevel structure, the role of time in modeling dynamic processes, and its application to studying physical activity patterns over time. 
*/

/*
This analysis is conceptual rather than data-driven and focuses on the methodological framework of intensive longitudinal data analysis. ILD typically involves repeated measurements of behaviors or outcomes, such as physical activity, collected at frequent and regular intervals within individuals. These data structures allow researchers to simultaneously examine within-person changes over time and between-person differences in behavioral patterns. 
*/

/*********************************************************************************/


options nodate nonumber ; 
run; 

libname ch4 "C:\Users\HAJ90\OneDrive - University of Pittsburgh\Document\PA\9_Intensive longitudinal data"; run;


*CONTROL GROUP;

data timec;
set ch4.time;
if treatment = 0;
run;

ods graphics on/antialiasmax=40200 height=9in width=9in;
ods pdf style=journal dpi=300 file="H:\Document\PA\9_ILD\raw-ctl.pdf";
run;
title1 "Control Group";
proc sgpanel data=timec CYCLEATTRS noautolegend;
 panelby id/columns=5 rows=5 novarname;
 series x=time y=intimacy /LINEATTRS = (pattern = 1 color = black thickness=1);
 scatter x=time y=intimacy /MARKERATTRS = (symbol=x color = black);
 rowaxis min=0 max=8 label='Intimacy';
 colaxis label='Time in Weeks';
run;
ods pdf close;
ods graphics off;
run;


*TREATMENT GROUP;

data timet;
set ch4.time;
if treatment = 1;
run;

ods graphics on/antialiasmax=40200 height=9in width=9in;
ods pdf style=journal dpi=300 file="H:\Document\PA\9_ILD\raw-trt.pdf";
run;
title1 "Treatment Group";
proc sgpanel data=timet CYCLEATTRS noautolegend;
 panelby id/columns=5 rows=5 novarname;
 series x=time y=intimacy /LINEATTRS = (pattern = 1 color = black thickness=1);
 scatter x=time y=intimacy /MARKERATTRS = (symbol=x color = black);
 rowaxis min=0 max=8 label='Intimacy';
 colaxis label='Time in Weeks';
run;
ods pdf close;
ods graphics off;
run;


proc mixed covtest data=ch4.time method=reml cl;
class id time;
model intimacy=time01 treatment time01*treatment/solution cl ddf=48,48,48,48 outp=tpred outpm=tpredm residual;
random int time01/subject=id type=un s g gcorr;
repeated time/subject=id type=ar(1);
ods exclude SolutionR;
ods output SolutionR = randpred;
run;


* Comparing intimacy model to same model using Mplus;
proc mixed covtest data=ch4.intimacy method=ml cl;
class id time;
model intimacy=time01 treatment time01*treatment/solution cl ddf=48,48,48,48 outp=intp outpm=intpm residual;
random int time01/subject=id type=un s g gcorr;
repeated time/subject=id; *type=ar(1);
ods exclude SolutionR;
run; 


*Predicted values for control group;

data tpredc;
set tpred;
if treatment=0;
run;

ods graphics on/antialiasmax=40200 height=9in width=9in;
ods pdf style=journal dpi=300 file="H:\Document\PA\9_ILD\tpred-c.pdf";
run;
title1 "Control Group";
proc sgpanel data=tpredc CYCLEATTRS noautolegend;
 panelby id/columns=5 rows=5 novarname;
 series x=time y=pred /LINEATTRS = (pattern = 1 color = black thickness=3);
 series x=time y=intimacy /LINEATTRS = (pattern = 1 color = black thickness=1);
 scatter x=time y=intimacy /MARKERATTRS = (symbol=x color = black);
 rowaxis min=0 max=8 label='Intimacy';
 colaxis label='Time in Weeks';
run;
ods pdf close;
run;
ods graphics off;
run;


*Predicted values for treatment group;

data tpredt;
set tpred;
if treatment=1;
run;

ods graphics on/antialiasmax=40200 height=9in width=9in;
ods pdf style=journal dpi=300 file="H:\Document\PA\9_ILD\tpred-t.pdf";
run;
title1 "Treatment Group";
proc sgpanel data=tpredt CYCLEATTRS noautolegend;
 panelby id/columns=5 rows=5 novarname;
 series x=time y=pred /LINEATTRS = (pattern = 1 color = black thickness=3);
 series x=time y=intimacy /LINEATTRS = (pattern = 1 color = black thickness=1);
 scatter x=time y=intimacy /MARKERATTRS = (symbol=x color = black);
 rowaxis min=0 max=8 label='Intimacy';
 colaxis label='Time in Weeks';
run;
ods pdf close;
run;
ods graphics off;
run;


* Spaghetti plots;

data tpredm1;
set tpredm;
predm=pred;
keep id time predm;
run;
 
data tpred1;
merge tpred tpredm1;
by id time;
if treatment=0 then trtcat= "Control";
if treatment=1 then trtcat= "Treat";
run;

title1;
ods pdf style=journal dpi=300 file="H:\Document\PA\9_ILD\spag-time.pdf";
ods graphics on/antialiasmax=40200 height=8in width=10in;
run;


*Two-panel spaghetti plot;

proc sgpanel data=tpred1 noautolegend; *CYCLEATTRS ;
panelby trtcat/novarname;
series x=time y=pred/group=id LINEATTRS = (pattern = 1 color = black thickness=2);
series x=time y=predm/ LINEATTRS = (pattern = 1 color = black thickness=9);
rowaxis min=1 max=7 label='Intimacy';
colaxis label='Time in Weeks';
run;
ods pdf close;
run;
ods graphics off;
run;


*Selecting subjects based on their approximate control group slope percentiles (5, 25, 50, 75, 95);

data slopec5;
set randpred;
if effect = "time01";
if id = 4 or id = 8 or id = 12 or id = 15 or id = 22;
slope=estimate + 0.74;
keep id slope;
run;


*Selecting the same subjects from the predicted values dataset;

data tempc5;
set tpredc;
if id = 4 or id = 8 or id = 12 or id = 15 or id = 22;
run;


*Merging the two datasets;

data tpredc5;
merge tempc5 slopec5;
by id;
run;


*Sort by slope value;

proc sort data=tpredc5;
by slope;
run;

ods graphics on/antialiasmax=40200 height=2in width=9in;
ods pdf style=journal dpi=300 file="H:\Document\PA\9_ILD\tpredc5.pdf";
run;
title1 "Control Group";
proc sgpanel data=tpredc5 CYCLEATTRS noautolegend;
 panelby slope/columns=5 rows=1 novarname;
 series x=time y=pred /LINEATTRS = (pattern = 1 color = black thickness=3);
 series x=time y=intimacy /LINEATTRS = (pattern = 1 color = black thickness=1);
 scatter x=time y=intimacy /MARKERATTRS = (symbol=x color = black);
 rowaxis min=0 max=8 label='Intimacy';
 colaxis label='Time in Weeks';
run;
ods pdf close;
run;
ods graphics off;
run;


*Selecting subjects based on their approximate treatment group slope percentiles (5, 25, 50, 75, 95);

data slopet5;
set randpred;
if effect = "time01";
if id = 26 or id = 37 or id = 46 or id = 49 or id = 50;
slope=estimate +  0.74 + 0.9214;
keep id slope;
run;


*Selecting the same subjects from the predicted values dataset;

data tempt5;
set tpredt;
if id = 26 or id = 37 or id = 46 or id = 49 or id = 50;
run;


*Merging the two datasets;

data tpredt5;
merge tempt5 slopet5;
by id;
run;


*Sort by slope value;

proc sort data=tpredt5;
by slope;
run;


* Fitted data for five persons;

ods graphics on/antialiasmax=40200 height=2in width=9in;
ods pdf style=journal dpi=300 file="H:\Document\PA\9_ILD\tpredt5.pdf";
run;
title1 "Treatment Group";
proc sgpanel data=tpredt5 CYCLEATTRS noautolegend;
 panelby slope/columns=5 rows=1 novarname;
 series x=time y=pred /LINEATTRS = (pattern = 1 color = black thickness=3);
 series x=time y=intimacy /LINEATTRS = (pattern = 1 color = black thickness=1);
 scatter x=time y=intimacy /MARKERATTRS = (symbol=x color = black);
 rowaxis min=0 max=8 label='Intimacy';
 colaxis label='Time in Weeks';
run;
ods pdf close;
run;
ods graphics off;
run;



/*********************************************************************************/
/*********************************************************************************/

/* Summary and Conclusion of the Code */
/*
Intensive longitudinal data analyses explicitly account for two levels of variation: within-person (intra-individual) changes over time and between-person (inter-individual) differences. Considering both levels is critical because patterns observed across individuals do not necessarily reflect how a single individual’s behavior fluctuates over time. ILD approaches allow researchers to disentangle stable differences between people from dynamic, time-varying processes occurring within individuals.

Time must be included as a predictor in ILD models to capture temporal dynamics and behavioral trajectories. Many outcomes, including physical activity, change gradually, cyclically, or in response to interventions. Without explicitly modeling time, analyses may overlook important trends or misattribute temporal changes to other predictors. Including time enables the identification of short-term fluctuations, long-term trends, and responses to external influences.

Graphical examination of time-course data is an essential component of ILD analysis. Visualizing trajectories helps identify non-linear patterns, outliers, and heterogeneity in responses that may not be evident from model output alone. Graphs also aid in evaluating modeling assumptions and guide decisions about appropriate functional forms for time, ultimately improving model validity and interpretability.

An example hypothesis well suited for a time-course approach is that consistent physical activity over regular intervals leads to gradual improvements in physical function among older adults. This hypothesis could be tested using interval-contingent data collection, such as daily or weekly assessments of activity and functional outcomes. By examining how changes in activity precede or coincide with changes in function within individuals over time, ILD methods can provide insights into dynamic processes that are not observable in traditional cross-sectional or sparsely measured longitudinal studies.
*/


