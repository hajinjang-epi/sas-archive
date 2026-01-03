
/* Ordinal Categorical Data Analysis */
/* Writer: Hajin Jang */
/* Date: 10/5/2024 */


/*********************************************************************************/

/* 
This analysis evaluates whether response categories on an 11-point confidence scale (0–10) used to measure self-efficacy for physical activity provide sufficient informational value, and assesses empirical support for collapsing lower-end categories using frequency distributions and point-biserial correlations. 
*/

/*
The dataset consists of responses from a 13-item physical activity confidence questionnaire administered to a cohort of middle-aged women, with each item scored on an 11-point ordinal scale ranging from 0 to 10. Item scores are summed to generate a total confidence score. Analyses focused on evaluating the distribution of responses across scale points and the contribution of each response category to the overall scale using frequency distributions and point-biserial correlations. 
*/

/*********************************************************************************/



* Read the data;

libname Conf "H:\Document\PA\5_OrdinalCat";
run;

data confidence;
set conf.confidence;
run;

data frequency ;
set conf.frequency;
run;

proc contents data=confidence;
run;

proc contents data=frequency;
run;


* Output frequencies of answers to each question;

data conf.frequency;
set conf;
run;

proc freq data=conf.frequency;
Tables A B C D E F G H I J K L M;
run;


* Calculating point biseral correlations for each score for each question;

* Create individual data sets for each question;

/******** Question A *********/

data confidence_a;
set confidence;
where question='A';
run;

/******** Question B *********/

data confidence_b;
set confidence;
where question='B';
run;

/******** Question C *********/

data confidence_c;
set confidence;
where question='C';
run;

/******** Question D *********/

data confidence_d;
set confidence;
where question='D';
run;

/******** Question E *********/

data confidence_e;
set confidence;
where question='E';
run;

/******** Question F *********/

data confidence_f;
set confidence;
where question='F';
run;

/******** Question G *********/

data confidence_g;
set confidence;
where question='G';
run;

/******** Question H *********/

data confidence_h;
set confidence;
where question='H';
run;

/******** Question I *********/

data confidence_i;
set confidence;
where question='I';
run;

/******** Question J *********/

data confidence_j;
set confidence;
where question='J';
run;

/******** Question K *********/

data confidence_k;
set confidence;
where question='K';
run;

/******** Question L *********/

data confidence_l;
set confidence;
where question='L';
run;

/******** Question M *********/

data confidence_m;
set confidence;
where question='M';
run;


* Macro for point biseral correlations;

%macro biserial(version, data= ,contin= ,binary= ,out=);

%if &version ne %then %put BISERIAL macro Version 2.2;

options nonotes;
* exclude observations with missing variables *;
data &out;
 set &data;
 where &contin>.;
 if &binary>.;
 run;

* compute the ranks for the continuous variable *;
proc rank data=&out out=&out ;
 var &contin;
 ranks r_contin;
 run;

* compute proportion of binary, std of contin, and n *;
proc means data=&out noprint;
 var &binary &contin;
 output out=_temp_(keep=p stdy n) mean=p std=stdx stdy n=n;
 run;

* sort by the binary variable *;
proc sort data=&out;
 by descending &binary;
 run;

* compute mean of contin and rank of contin var *;
proc means data=&out noprint;
 by notsorted &binary;
 var &contin r_contin;
 output out=&out mean=my r_contin;
 run;

* restructure the means computed in the step above *;
proc transpose data=&out out=&out(rename=(col1=my1 col2=my0));
 var r_contin my;
 run;

* combine the data needed to compute biserial correlation *;
data &out;
 set &out(drop= _name_ _label_);
 retain r1 r0 ;
 if _n_=1 then do;
  r1=my1;
  r0=my0;
 end;
 else do;
  set _temp_;
  output;
 end;
 run;

* compute point biserial correlation *;
proc corr data=&data  noprint outp=_temp_;
 var &binary &contin;
 run;



* extract the point biserial correlation from the matrix *;
data _temp_(keep=pntbisrl);
 set _temp_(rename=(&contin=pntbisrl));
 if _TYPE_='CORR' and &binary<>1 then output;

 run;

options notes;
* compute biserial and rank biserial *;
data &out;
 merge _temp_  &out;
 if pntbisrl=1 then delete;
 h=probit(1-p);
 u=exp(-h*h/2)/sqrt(2*arcos(-1));
 biserial=p*(1-p)*(my1-my0)/stdy/u;
 rnkbisrl=2*(r1-r0)/n;

 keep biserial pntbisrl rnkbisrl;
 label biserial='Biserial Corr'
       pntbisrl='Point Biserial Corr'
       rnkbisrl='Rank Biserial Corr';
 run;

%mend;


* Call macro for each sub-analyses;

/************ QUESTION A **************/

%biserial(data=confidence_a, contin=total, binary=score_0, out=questA_0);

    proc print data=questA_0 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for A_0';
     run;

%biserial(data=confidence_a, contin=total, binary=score_1, out=questA_1);

    proc print data=questA_1 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for A_1';
     run;

%biserial(data=confidence_a, contin=total, binary=score_2, out=questA_2);

    proc print data=questA_2 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for A_2';
     run;

%biserial(data=confidence_a, contin=total, binary=score_3, out=questA_3);

    proc print data=questA_3 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for A_3';
     run;

%biserial(data=confidence_a, contin=total, binary=score_4, out=questA_4);

    proc print data=questA_4 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for A_4';
     run;

%biserial(data=confidence_a, contin=total, binary=score_5, out=questA_5);

    proc print data=questA_5 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for A_5';
     run;

%biserial(data=confidence_a, contin=total, binary=score_6, out=questA_6);

    proc print data=questA_6 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for A_6';
     run;

%biserial(data=confidence_a, contin=total, binary=score_7, out=questA_7);

    proc print data=questA_7 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for A_7';
     run;

%biserial(data=confidence_a, contin=total, binary=score_8, out=questA_8);

    proc print data=questA_8 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for A_8';
     run;


%biserial(data=confidence_a, contin=total, binary=score_9, out=questA_9);

    proc print data=questA_9 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for A_9';
     run;
	
%biserial(data=confidence_a, contin=total, binary=score_10, out=questA_10);

    proc print data=questA_10 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for A_10';
     run;


/************ QUESTION B **************/

%biserial(data=confidence_b, contin=total, binary=score_0, out=questB_0);

    proc print data=questB_0 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for B_0';
     run;

%biserial(data=confidence_b, contin=total, binary=score_1, out=questB_1);

    proc print data=questB_1 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for B_1';
     run;

%biserial(data=confidence_b, contin=total, binary=score_2, out=questB_2);

    proc print data=questB_2 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for B_2';
     run;

%biserial(data=confidence_b, contin=total, binary=score_3, out=questB_3);

    proc print data=questB_3 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for B_3';
     run;

%biserial(data=confidence_b, contin=total, binary=score_4, out=questB_4);

    proc print data=questB_4 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for B_4';
     run;

%biserial(data=confidence_b, contin=total, binary=score_5, out=questB_5);

    proc print data=questB_5 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for B_5';
     run;

%biserial(data=confidence_b, contin=total, binary=score_6, out=questB_6);

    proc print data=questB_6 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for B_6';
     run;

%biserial(data=confidence_b, contin=total, binary=score_7, out=questB_7);

    proc print data=questB_7 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for B_7';
     run;

%biserial(data=confidence_b, contin=total, binary=score_8, out=questB_8);

    proc print data=questB_8 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for B_8';
     run;


%biserial(data=confidence_b, contin=total, binary=score_9, out=questB_9);

    proc print data=questB_9 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for B_9';
     run;
	
%biserial(data=confidence_b, contin=total, binary=score_10, out=questB_10);

    proc print data=questB_10 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for B_10';
     run;


/************ QUESTION C **************/

%biserial(data=confidence_c, contin=total, binary=score_0, out=questC_0);

    proc print data=questC_0 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for C_0';
     run;

%biserial(data=confidence_c, contin=total, binary=score_1, out=questC_1);

    proc print data=questC_1 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for C_1';
     run;

%biserial(data=confidence_c, contin=total, binary=score_2, out=questC_2);

    proc print data=questC_2 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for C_2';
     run;

%biserial(data=confidence_c, contin=total, binary=score_3, out=questC_3);

    proc print data=questC_3 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for C_3';
     run;

%biserial(data=confidence_c, contin=total, binary=score_4, out=questC_4);

    proc print data=questC_4 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for C_4';
     run;

%biserial(data=confidence_c, contin=total, binary=score_5, out=questC_5);

    proc print data=questC_5 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for C_5';
     run;

%biserial(data=confidence_c, contin=total, binary=score_6, out=questC_6);

    proc print data=questC_6 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for C_6';
     run;

%biserial(data=confidence_c, contin=total, binary=score_7, out=questC_7);

    proc print data=questC_7 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for C_7';
     run;

%biserial(data=confidence_c, contin=total, binary=score_8, out=questC_8);

    proc print data=questC_8 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for C_8';
     run;


%biserial(data=confidence_c, contin=total, binary=score_9, out=questC_9);

    proc print data=questC_9 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for C_9';
     run;
	
%biserial(data=confidence_c, contin=total, binary=score_10, out=questC_10);

    proc print data=questC_10 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for C_10';
     run;


/************ QUESTION D **************/

%biserial(data=confidence_d, contin=total, binary=score_0, out=questd_0);

    proc print data=questd_0 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for d_0';
     run;

%biserial(data=confidence_d, contin=total, binary=score_1, out=questd_1);

    proc print data=questd_1 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for d_1';
     run;

%biserial(data=confidence_d, contin=total, binary=score_2, out=questd_2);

    proc print data=questd_2 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for d_2';
     run;

%biserial(data=confidence_d, contin=total, binary=score_3, out=questd_3);

    proc print data=questd_3 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for d_3';
     run;

%biserial(data=confidence_d, contin=total, binary=score_4, out=questd_4);

    proc print data=questd_4 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for d_4';
     run;

%biserial(data=confidence_d, contin=total, binary=score_5, out=questd_5);

    proc print data=questd_5 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for d_5';
     run;

%biserial(data=confidence_d, contin=total, binary=score_6, out=questd_6);

    proc print data=questd_6 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for d_6';
     run;

%biserial(data=confidence_d, contin=total, binary=score_7, out=questd_7);

    proc print data=questd_7 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for d_7';
     run;

%biserial(data=confidence_d, contin=total, binary=score_8, out=questd_8);

    proc print data=questd_8 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for d_8';
     run;


%biserial(data=confidence_d, contin=total, binary=score_9, out=questd_9);

    proc print data=questd_9 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for d_9';
     run;
	
%biserial(data=confidence_d, contin=total, binary=score_10, out=questd_10);

    proc print data=questd_10 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for d_10';
     run;


/************ QUESTION E **************/

%biserial(data=confidence_e, contin=total, binary=score_0, out=queste_0);

    proc print data=queste_0 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for e_0';
     run;

%biserial(data=confidence_e, contin=total, binary=score_1, out=queste_1);

    proc print data=queste_1 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for e_1';
     run;

%biserial(data=confidence_e, contin=total, binary=score_2, out=queste_2);

    proc print data=queste_2 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for e_2';
     run;

%biserial(data=confidence_e, contin=total, binary=score_3, out=queste_3);

    proc print data=queste_3 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for e_3';
     run;

%biserial(data=confidence_e, contin=total, binary=score_4, out=queste_4);

    proc print data=queste_4 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for e_4';
     run;

%biserial(data=confidence_e, contin=total, binary=score_5, out=queste_5);

    proc print data=queste_5 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for e_5';
     run;

%biserial(data=confidence_e, contin=total, binary=score_6, out=queste_6);

    proc print data=queste_6 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for e_6';
     run;

%biserial(data=confidence_e, contin=total, binary=score_7, out=queste_7);

    proc print data=queste_7 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for e_7';
     run;

%biserial(data=confidence_e, contin=total, binary=score_8, out=queste_8);

    proc print data=queste_8 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for e_8';
     run;


%biserial(data=confidence_e, contin=total, binary=score_9, out=queste_9);

    proc print data=queste_9 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for e_9';
     run;
	
%biserial(data=confidence_e, contin=total, binary=score_10, out=queste_10);

    proc print data=queste_10 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for e_10';
     run;


/************ QUESTION F **************/

%biserial(data=confidence_f, contin=total, binary=score_0, out=questf_0);

    proc print data=questf_0 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for f_0';
     run;

%biserial(data=confidence_f, contin=total, binary=score_1, out=questf_1);

    proc print data=questf_1 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for f_1';
     run;

%biserial(data=confidence_f, contin=total, binary=score_2, out=questf_2);

    proc print data=questf_2 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for f_2';
     run;

%biserial(data=confidence_f, contin=total, binary=score_3, out=questf_3);

    proc print data=questf_3 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for f_3';
     run;

%biserial(data=confidence_f, contin=total, binary=score_4, out=questf_4);

    proc print data=questf_4 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for f_4';
     run;

%biserial(data=confidence_f, contin=total, binary=score_5, out=questf_5);

    proc print data=questf_5 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for f_5';
     run;

%biserial(data=confidence_f, contin=total, binary=score_6, out=questf_6);

    proc print data=questf_6 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for f_6';
     run;

%biserial(data=confidence_f, contin=total, binary=score_7, out=questf_7);

    proc print data=questf_7 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for f_7';
     run;

%biserial(data=confidence_f, contin=total, binary=score_8, out=questf_8);

    proc print data=questf_8 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for f_8';
     run;


%biserial(data=confidence_f, contin=total, binary=score_9, out=questf_9);

    proc print data=questf_9 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for f_9';
     run;
	
%biserial(data=confidence_f, contin=total, binary=score_10, out=questf_10);

    proc print data=questf_10 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for f_10';
     run;


/************ QUESTION G **************/

%biserial(data=confidence_g, contin=total, binary=score_0, out=questg_0);

    proc print data=questg_0 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for g_0';
     run;

%biserial(data=confidence_g, contin=total, binary=score_1, out=questg_1);

    proc print data=questg_1 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for g_1';
     run;

%biserial(data=confidence_g, contin=total, binary=score_2, out=questg_2);

    proc print data=questg_2 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for g_2';
     run;

%biserial(data=confidence_g, contin=total, binary=score_3, out=questg_3);

    proc print data=questg_3 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for g_3';
     run;

%biserial(data=confidence_g, contin=total, binary=score_4, out=questg_4);

    proc print data=questg_4 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for g_4';
     run;

%biserial(data=confidence_g, contin=total, binary=score_5, out=questg_5);

    proc print data=questg_5 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for g_5';
     run;

%biserial(data=confidence_g, contin=total, binary=score_6, out=questg_6);

    proc print data=questg_6 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for g_6';
     run;

%biserial(data=confidence_g, contin=total, binary=score_7, out=questg_7);

    proc print data=questg_7 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for g_7';
     run;

%biserial(data=confidence_g, contin=total, binary=score_8, out=questg_8);

    proc print data=questg_8 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for g_8';
     run;


%biserial(data=confidence_g, contin=total, binary=score_9, out=questg_9);

    proc print data=questg_9 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for g_9';
     run;
	
%biserial(data=confidence_g, contin=total, binary=score_10, out=questg_10);

    proc print data=questg_10 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for g_10';
     run;


/************ QUESTION H **************/

%biserial(data=confidence_h, contin=total, binary=score_0, out=questh_0);

    proc print data=questh_0 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for h_0';
     run;

%biserial(data=confidence_h, contin=total, binary=score_1, out=questh_1);

    proc print data=questh_1 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for h_1';
     run;

%biserial(data=confidence_h, contin=total, binary=score_2, out=questh_2);

    proc print data=questh_2 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for h_2';
     run;

%biserial(data=confidence_h, contin=total, binary=score_3, out=questh_3);

    proc print data=questh_3 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for h_3';
     run;

%biserial(data=confidence_h, contin=total, binary=score_4, out=questh_4);

    proc print data=questh_4 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for h_4';
     run;

%biserial(data=confidence_h, contin=total, binary=score_5, out=questh_5);

    proc print data=questh_5 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for h_5';
     run;

%biserial(data=confidence_h, contin=total, binary=score_6, out=questh_6);

    proc print data=questh_6 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for h_6';
     run;

%biserial(data=confidence_h, contin=total, binary=score_7, out=questh_7);

    proc print data=questh_7 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for h_7';
     run;

%biserial(data=confidence_h, contin=total, binary=score_8, out=questh_8);

    proc print data=questh_8 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for h_8';
     run;


%biserial(data=confidence_h, contin=total, binary=score_9, out=questh_9);

    proc print data=questh_9 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for h_9';
     run;
	
%biserial(data=confidence_h, contin=total, binary=score_10, out=questh_10);

    proc print data=questh_10 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for h_10';
     run;


/************ QUESTION I **************/

%biserial(data=confidence_i, contin=total, binary=score_0, out=questi_0);

    proc print data=questi_0 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for i_0';
     run;

%biserial(data=confidence_i, contin=total, binary=score_1, out=questi_1);

    proc print data=questi_1 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for i_1';
     run;

%biserial(data=confidence_i, contin=total, binary=score_2, out=questi_2);

    proc print data=questi_2 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for i_2';
     run;

%biserial(data=confidence_i, contin=total, binary=score_3, out=questi_3);

    proc print data=questi_3 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for i_3';
     run;

%biserial(data=confidence_i, contin=total, binary=score_4, out=questi_4);

    proc print data=questi_4 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for i_4';
     run;

%biserial(data=confidence_i, contin=total, binary=score_5, out=questi_5);

    proc print data=questi_5 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for i_5';
     run;

%biserial(data=confidence_i, contin=total, binary=score_6, out=questi_6);

    proc print data=questi_6 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for i_6';
     run;

%biserial(data=confidence_i, contin=total, binary=score_7, out=questi_7);

    proc print data=questi_7 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for i_7';
     run;

%biserial(data=confidence_i, contin=total, binary=score_8, out=questi_8);

    proc print data=questi_8 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for i_8';
     run;


%biserial(data=confidence_i, contin=total, binary=score_9, out=questi_9);

    proc print data=questi_9 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for i_9';
     run;
	
%biserial(data=confidence_i, contin=total, binary=score_10, out=questi_10);

    proc print data=questi_10 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for i_10';
     run;


/************ QUESTION J **************/

%biserial(data=confidence_j, contin=total, binary=score_0, out=questj_0);

    proc print data=questj_0 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for j_0';
     run;

%biserial(data=confidence_j, contin=total, binary=score_1, out=questj_1);

    proc print data=questj_1 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for j_1';
     run;

%biserial(data=confidence_j, contin=total, binary=score_2, out=questj_2);

    proc print data=questj_2 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for j_2';
     run;

%biserial(data=confidence_j, contin=total, binary=score_3, out=questj_3);

    proc print data=questj_3 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for j_3';
     run;

%biserial(data=confidence_j, contin=total, binary=score_4, out=questj_4);

    proc print data=questj_4 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for j_4';
     run;

%biserial(data=confidence_j, contin=total, binary=score_5, out=questj_5);

    proc print data=questj_5 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for j_5';
     run;

%biserial(data=confidence_j, contin=total, binary=score_6, out=questj_6);

    proc print data=questj_6 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for j_6';
     run;

%biserial(data=confidence_j, contin=total, binary=score_7, out=questj_7);

    proc print data=questj_7 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for j_7';
     run;

%biserial(data=confidence_j, contin=total, binary=score_8, out=questj_8);

    proc print data=questj_8 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for j_8';
     run;


%biserial(data=confidence_j, contin=total, binary=score_9, out=questB_9);

    proc print data=questB_9 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for B_9';
     run;
	
%biserial(data=confidence_j, contin=total, binary=score_10, out=questB_10);

    proc print data=questB_10 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for B_10';
     run;


/************ QUESTION K **************/

%biserial(data=confidence_k, contin=total, binary=score_0, out=questk_0);

    proc print data=questk_0 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for k_0';
     run;

%biserial(data=confidence_k, contin=total, binary=score_1, out=questk_1);

    proc print data=questk_1 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for k_1';
     run;

%biserial(data=confidence_k, contin=total, binary=score_2, out=questk_2);

    proc print data=questk_2 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for k_2';
     run;

%biserial(data=confidence_k, contin=total, binary=score_3, out=questk_3);

    proc print data=questk_3 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for k_3';
     run;

%biserial(data=confidence_k, contin=total, binary=score_4, out=questk_4);

    proc print data=questk_4 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for k_4';
     run;

%biserial(data=confidence_k, contin=total, binary=score_5, out=questk_5);

    proc print data=questk_5 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for k_5';
     run;

%biserial(data=confidence_k, contin=total, binary=score_6, out=questk_6);

    proc print data=questk_6 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for k_6';
     run;

%biserial(data=confidence_k, contin=total, binary=score_7, out=questk_7);

    proc print data=questk_7 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for k_7';
     run;

%biserial(data=confidence_k, contin=total, binary=score_8, out=questk_8);

    proc print data=questk_8 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for k_8';
     run;


%biserial(data=confidence_k, contin=total, binary=score_9, out=questk_9);

    proc print data=questk_9 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for k_9';
     run;
	
%biserial(data=confidence_k, contin=total, binary=score_10, out=questk_10);

    proc print data=questk_10 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for k_10';
     run;


/************ QUESTION L **************/

%biserial(data=confidence_l, contin=total, binary=score_0, out=questl_0);

    proc print data=questl_0 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for l_0';
     run;

%biserial(data=confidence_l, contin=total, binary=score_1, out=questl_1);

    proc print data=questl_1 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for l_1';
     run;

%biserial(data=confidence_l, contin=total, binary=score_2, out=questl_2);

    proc print data=questl_2 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for l_2';
     run;

%biserial(data=confidence_l, contin=total, binary=score_3, out=questl_3);

    proc print data=questl_3 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for l_3';
     run;

%biserial(data=confidence_l, contin=total, binary=score_4, out=questl_4);

    proc print data=questl_4 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for l_4';
     run;

%biserial(data=confidence_l, contin=total, binary=score_5, out=questl_5);

    proc print data=questl_5 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for l_5';
     run;

%biserial(data=confidence_l, contin=total, binary=score_6, out=questl_6);

    proc print data=questl_6 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for l_6';
     run;

%biserial(data=confidence_l, contin=total, binary=score_7, out=questl_7);

    proc print data=questl_7 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for l_7';
     run;

%biserial(data=confidence_l, contin=total, binary=score_8, out=questl_8);

    proc print data=questl_8 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for l_8';
     run;


%biserial(data=confidence_l, contin=total, binary=score_9, out=questl_9);

    proc print data=questl_9 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for l_9';
     run;
	
%biserial(data=confidence_l, contin=total, binary=score_10, out=questl_10);

    proc print data=questl_10 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for l_10';
     run;


/************ QUESTION M **************/

%biserial(data=confidence_m, contin=total, binary=score_0, out=questm_0);

    proc print data=questm_0 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for m_0';
     run;

%biserial(data=confidence_m, contin=total, binary=score_1, out=questm_1);

    proc print data=questm_1 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for m_1';
     run;

%biserial(data=confidence_m, contin=total, binary=score_2, out=questm_2);

    proc print data=questm_2 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for m_2';
     run;

%biserial(data=confidence_m, contin=total, binary=score_3, out=questm_3);

    proc print data=questm_3 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for m_3';
     run;

%biserial(data=confidence_m, contin=total, binary=score_4, out=questm_4);

    proc print data=questm_4 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for m_4';
     run;

%biserial(data=confidence_m, contin=total, binary=score_5, out=questm_5);

    proc print data=questm_5 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for m_5';
     run;

%biserial(data=confidence_m, contin=total, binary=score_6, out=questm_6);

    proc print data=questm_6 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for m_6';
     run;

%biserial(data=confidence_m, contin=total, binary=score_7, out=questm_7);

    proc print data=questm_7 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for m_7';
     run;

%biserial(data=confidence_m, contin=total, binary=score_8, out=questm_8);

    proc print data=questm_8 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for m_8';
     run;


%biserial(data=confidence_m, contin=total, binary=score_9, out=questm_9);

    proc print data=questm_9 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for m_9';
     run;
	
%biserial(data=confidence_m, contin=total, binary=score_10, out=questm_10);

    proc print data=questm_10 label noobs;
     title 'Point Biserial, Biserial and Rank Biserial Correlations for m_10';
     run;



/*********************************************************************************/
/*********************************************************************************/

/* Summary and Conclusion of the Code */
/*
Frequency distribution analyses showed that lower response categories were used infrequently across items. Scores of 0 and 1 were rarely selected, and score 2 was also underutilized for many items, suggesting limited differentiation at the lower end of the scale. In contrast, mid-range and higher scores, particularly 5 through 10, were selected more consistently, with the highest usage observed for scores 9 and 10. This pattern indicates that respondents tended to express confidence toward the upper end of the scale.

Point-biserial correlation analyses reinforced these findings. Lower response categories exhibited weak or negative correlations with total confidence scores, indicating that these categories contributed little meaningful information to the overall measurement of self-efficacy. In contrast, higher response categories, especially scores of 9 and 10, showed strong positive correlations with the total score, suggesting that they effectively differentiated higher levels of confidence and aligned well with the construct being measured.

Together, the combined evidence from frequency of use and informational value supports consideration of collapsing lower-end categories. Response options that are both infrequently selected and weakly correlated with the total score provide minimal distinct information and may introduce unnecessary complexity. Based on these criteria, scores of 0, 1, and possibly 2 appear to be candidates for collapsing across all items in the instrument.

Overall, the results suggest that reducing the scale to fewer response categories at the lower end could simplify the questionnaire without compromising its ability to capture meaningful variation in physical activity confidence. A revised scale retaining the mid-to-upper range of responses may improve interpretability and efficiency while preserving the instrument’s measurement precision.
*/

