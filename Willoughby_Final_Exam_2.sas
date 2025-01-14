*/ 

Programmed by: Bryant Willoughby 
Course: ST 445 (002)
Last Edited on: 12/3/22
Program Purpose: Final Project Section 2

*create the InputDS libref and InputRaw fileref; 
x 'cd L:\st445\Data\BookData\BeverageCompanyCaseStudy'; 
libname InputDS '.'; 
filename InputRaw '.'; 

*associate a libref named Results for my class' results folder; 
x 'cd L:\st445\Results\FinalProjectPhase1'; 
libname Results '.';  

*associate a libref named Data for my class' Data folder (mainly to access provided formats); 
x 'cd L:\st445\Data'; 
libname Data '.'; 

*create a libref and fileref - both named Exam associated with my Exam storage location; 
*note: all data, formats, files, or other objects I store must be saved in this library; 
*this is my working directory; 
x 'cd S:\st445_code\Final_Exam_2_datasets'; 
libname Exam '.';
filename Exam '.'; 


*This is my attempt at the data step for Sodas 
*note: I recognize it is not working correctly but I wanted to provide what I was able to complete in hopes of some partial credit - thanks!; 
data Exam.Sodas (keep = number productname size quantity); 
  infile InputRaw("Sodas.csv") firstobs = 6 dsd truncover; 
  input number : productname : $20.  _sizequantity:  $25. @;
  do i = 1 to 100 until(missing(_sizequantity));
    size = scan(_sizequantity,1,'(');
    do k = 2 to 5 until(missing(quantity)); 
      quantity = scan(_sizequantity,k,'(,)'); 
      output; 
    end; 
    input _sizequantity $ @; 
  end;
run; 

*Set options; 
options nodate; 
ods noproctitle;  

*set up output; 
ods _all_ close; 
ods pdf dpi = 300 file = "WilloughbyFinalReport.pdf";
ods listing image_dpi = 300; 


*Output #3 (Activity2.1);   
title1 j = c 'Activity 2.1'; 
title2 j = c 'Summary of Units Sold'; 
title3 j = c 'Single Unit Packages'; 
footnote h = 7 pt j = c 'Minimum and maximum Sales are within any county for any week'; 
proc means data = Results.AllData nonobs sum min max nolabels;  
  where statefips in (13,37,45) and productname in ("Cherry Cola" "Cola" "Diet Cherry Cola" "Diet Cola" "Diet Vanilla Cola" "Vanilla Cola") and unitsize = 1 ;
  class statefips productname size unitsize; 
  var unitssold;
  attrib statefips    label = "StateFIPS"
         productname  label = "productName" 
         size         label = "Container Size"
         unitsize     label = "Containers Per Unit"
  ; 
run; 
footnote; 



*Output #5 (Activity2.3) - only include Table 1 and Table 2 regardless of the values of ProductName; 
title1 j = c 'Activity 2.3'; 
title2 j = c 'Cross Tabulation of Single Unit Product Sales in Various States'; 
ods select Freq.Table1of1.CrossTabFreqs   
           Freq.Table2of1.CrossTabFreqs;
proc freq data = Results.AllData; 
  table productname*statefips*size / format = comma10.; /*A*B*C in the TABLE statement creates the B*C table for each level of A*/ 
  weight unitssold;   /*count based on a quantitative variable using the WEIGHT statement*/ 
                      /*using WEIGHT statement to summarize unitssold for combinations of stateFips and size controlling for productname*/ 
  where statefips in (13,37,45) and productname in ("Cherry Cola","Cola","Diet Cherry Cola","Diet Cola","Diet Vanilla Cola", "Vanilla Cola") and unitsize = 1; 
run; 


*Output #12 (Activity 3.1) - Restructure the legend to be a 3x2 set of names that lists Citrus, Grape and Lemon-Lime in the first column then Orange and Zesty in the second column;
ods graphics / reset imagename = 'Activity3_1' width = 6 in; 
title j = c 'Activity 3.1'; 
title2 j = c 'Single-Unit 12 oz Sales'; 
title3 j = c 'Regular, Non-Cola Sodas'; 
proc sgplot data = Results.AllData; 
  hbar statename / response = unitssold 
                   group = productname 
                   groupdisplay = cluster; 
  where unitsize eq 1 and size eq '12 oz' and productcategory eq 'Soda: Non-Cola' and type ne 'Diet' and statename in ('Georgia','North Carolina','South Carolina'); 
  keylegend / location = inside
              position = bottomright 
              title = ''
              down = 3;  
  yaxis display = (nolabel); 
  xaxis label = "Total Sold"; 
run; 


*output #15 (Activity 3.3) - the bars have the SHEEN dataskin; 
*note: my legend will show up with the label "Containers per Unit" instead of the variable name - that is OK - MY LABEL SHOWS UP AS 'BEVERAGE QUANTITY'; 
ods graphics / reset imagename = 'Activity3_3' width = 6 in;
title j = c 'Activity 3.3'; 
title2 j = c 'Average Weekly Sales, Non-Diet Energy Drinks'; 
title3 j = c 'For 8 oz Cans in Georgia'; 
proc sgplot data = Results.AllData; 
  vbar productname / response = unitssold 
                     stat = mean 
                     group = unitsize 
                     groupdisplay = cluster
                     dataskin = sheen;  
  where productcategory eq 'Energy' and type eq 'Non-Diet' and size eq '8 oz' and statename eq 'Georgia'; 
  yaxis label = "Weekly Average Sales"; 
  xaxis display = (nolabel); 
run; 


*Output #19 (Activity 3.6) - the narrower bar is 60% of the wider bar and the front bar has 40% transparency; 
ods graphics / reset imagename = 'Activity3_6' width = 6 in;
title j = c 'Activity 3.6'; 
title2 j = c 'Weekly Average Sales, Nutritional Water'; 
title3 j = c 'Single-Unit Packages'; 
proc sgplot data = Results.Act3_6results; 
  hbar productname / response = unitssold_mean 
                     barwidth = 0.42  ; 
  hbar productname / response = unitssold_median
                     barwidth = 0.7
                     fillattrs = (transparency = 0.4); 

  xaxis label = 'Georgia, North Carolina, and South Carolina'; 
  yaxis display = (nolabel); 
  keylegend / location = inside
              position = topright 
              title = 'Weekly Sales' 
              noborder
              across = 1;  
run; 


*Output #22 (Activity 4.1);
options nolabel; 
title j = c 'Activity 4.1'; 
title2 j = c 'Weekly Sales Summaries'; 
title3 j = c 'Cola Products, 20 oz Bottles, Individual Units'; 
footnote h = 7 pt j = c 'All States'; 
proc means data = Results.AllData nonobs mean median q1 q3 maxdec = 0;
  where flavor in ("Cherry Cola", "Cola", "Vanilla Cola") and size = '20 oz' and unitsize = 1;  
  class region type flavor; 
  var unitssold;
run; 
options label;


*Output #23 (Activity 4.2);
ods graphics / reset imagename = 'Activity4_2' width = 6 in;
title j = c 'Activity 4.2'; 
title2 j = c 'Weekly Sales Distributions'; 
title3 j = c 'Cola Products, 12 Packs of 20 oz Bottles'; 
footnote h = 7 pt j = c 'All States'; 
proc sgpanel data = Results.AllData; 
  panelby region type / novarname;
  histogram unitssold / binstart = 125 binwidth = 250
                        scale = proportion; 
  colaxis label = 'Units Sold';
  rowaxis display = (nolabel) valuesformat = percent8.; 
  where flavor eq 'Cola' and unitsize eq 12 and size eq '20 oz'; 
run; 


*Output #25 (Activity 4.4); 
ods graphics / reset imagename = 'Activity4_4' width = 6 in;
title j = c 'Activity 4.4'; 
title2 j = c 'Sales Inter-Quartile Ranges'; 
title3 j = c 'Cola: 20 oz Bottles, Individual Units'; 
footnote h = 7 pt j = c 'All States'; 
proc sgpanel data = Results.Act4_4results; 
  panelby region type / novarname; 
  format date monyy7.; 
  highlow x = date low = unitssold_Q1 high = unitssold_Q3 / lineattrs = (color=darkblue); /*choosing an X= variable provides a vertical axis for the high-low range*/ 
  rowaxis label = 'Q1-Q3'; 
  colaxis label = 'Date' interval = month;  
run; 
footnote; 

*Output #28 (No activity number); 
title j = c 'Optional Activity'; 
title2 j = c 'Product Information and Categorization'; 
proc print data = Results.Classification noobs; 
  var productname type productcategory productsubcategory flavor size container; 
run; 


*Output #33 (Activity 5.5); 
ods graphics / reset imagename = '5_5 Activity' width = 6 in;
title j = c 'Activity 5.5'; 
title2 j = c 'North and South Carolina Sales in August'; 
title3 j = c '12 oz, Single-Unit, Cola Flavor';  
proc sgpanel data = Results.Act5_5trans; 
  attrib North_Carolina label = 'North Carolina'
         South_Carolina label = 'South Carolina'; 
  panelby type / columns = 1 novarname; 
  format date mmddyy8.;
  hbar date / response = North_Carolina
              barwidth = 0.42;
  hbar date / response = South_Carolina
              barwidth = 0.7
              transparency = 0.3;
  rowaxis display = (nolabel); 
  colaxis label = 'Sales' valuesformat = comma8. type = linear; 
run;


*Output #36 (Activity 6.2) - compute the required statistics using aliasing - for the dates, you must use the qtrr format; 
title j = c 'Activity 6.2'; 
title2 j = c 'Quarterly Sales Summaries for 12oz Single-Unit Products'; 
title3 j = c 'Maryland Only';
proc report data = Results.AllData nowd; 
  where size eq '12 oz' and unitsize eq 1 and statename eq 'Maryland'; 
  column type productname date unitssold = med unitssold = total unitssold = minimum unitssold = maximum; 
  define type / group 'Product Type'; 
  define productname / group 'Name'; 
  define date / group format = qtrr. order = internal 'Quarter'; 
  define med / median 'Median Weekly Sales'; 
    define total / sum  format = comma15. 'Total Sales';  
  define minimum / min 'Lowest Weekly Sales'; 
  define maximum / max 'Highest Weekly Sales'; 
  break after productname / summarize suppress; 
run; 


*Output #44 (Activity 7.1); 
*NOTE: unfortunately unable to read this data set in so not able to produce output; 


*Output #40 (Activity 7.4); 
title j = c 'Activity 7.4'; 
title2 j = c 'Quarterly Sales Summaries for 12oz Single-Unit Products'; 
title3 j = c 'Maryland Only';
proc report data = Results.AllData nowd out = report7_4
            style(header) = [backgroundcolor = cx969696
                             color = cx084594]
            style(summary) = [backgroundcolor = black 
                              color = white];
  where size eq '12 oz' and unitsize eq 1 and statename eq 'Maryland'; 
  column type productname date unitssold = med unitssold = total unitssold = minimum unitssold = maximum /*_date*/;  
  define type / group 'Product Type'; 
  define productname / group 'Name'; 
  define date / group format = qtrr. order = internal 'Quarter'; 
  define med / median 'Median Weekly Sales'; 
  define total / sum format = comma15. 'Total Sales';
  define minimum / min 'Lowest Weekly Sales'; 
  define maximum / max 'Highest Weekly Sales'; 
  break after productname / summarize suppress; 

  compute maximum; 
    if _break_ eq 'productname' then c = 0; 
      else if _break_ eq '' then do; 
        c+1;
        if mod(c,4) eq 1 then 
          call define(_row_,'style','style = [backgroundcolor = white]');
            else if mod(c,4) eq 2 then 
              call define(_row_,'style','style = [backgroundcolor = cxf0f0f0]'); 
                else if mod(c,4) eq 3 then 
                  call define(_row_,'style','style = [backgroundcolor = cxd9d9d9]'); 
                  else call define(_row_,'style','style = [backgroundcolor = cxbdbdbd]');
      end; 
  endcomp;
          
run; 


*Output #41 (Activity 7.5); 
title j = c 'Activity 7.5'; 
title2 j = c 'Quarterly Per-Capita Sales Summaries'; 
title3 j = c '12oz Single-Unit Lemonade'; 
title4 j = c 'Maryland Only'; 
footnote j = c h = 7 pt 'Flagged Rows: Sales Less Than 7.5 per 1000 for Diet, Less Than 30 per 1000 for Non-Diet'; 
proc report data = Results.AllData nowd out = report7_5
            style(header) = [backgroundcolor = cx969696
                             color = cx084594]
            style(summary) = [backgroundcolor = cx525252
                              color = white]; 
  where size eq '12 oz' and unitsize eq 1 and flavor eq 'Lemonade' and statename = 'Maryland'; 
  column countyname type date unitssold salesperthousand popestimate2016 = pop; 
  define countyname / group 'County'; 
  define type / group 'Product Type'; 
  define date / group format = qtrr. order = internal 'Quarter'; 
  define unitssold / analysis sum 'Total Sales'; 
  define salesperthousand / analysis sum format = 15.1  'Sales per 1000'; 
  define pop / analysis mean noprint;
  break after countyname / summarize suppress; 
  
  compute countyname; 
    countyname = strip(tranwrd(countyname,'County',''));
  endcomp; 


  compute after countyname / style = [backgroundcolor = black color = white just = right]; 
    line '2016 Population:' pop comma15.; 
  endcomp; 

  compute before type; 
    _tracker = substr(type,1,1); 
  endcomp; 

  compute pop; 
    if salesperthousand.sum lt 7.5 and missing(_break_) and _tracker eq 'D' then do; 
        call define(_row_,'style','style = [backgroundcolor = cxd9d9d9]'); 
        call define('salesperthousand.sum','style','style = [color = red]'); 
      end; 
          else if salesperthousand.sum lt 30 and missing(_break_) and _tracker eq 'N' then do; 
            call define(_row_,'style','style = [backgroundcolor = cxd9d9d9]'); 
            call define('salesperthousand.sum','style','style = [color = red]'); 
          end; 
  endcomp;

run; 
 
ods pdf close; 


quit; 
