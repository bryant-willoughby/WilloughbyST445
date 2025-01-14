*/ 

Programmed by: Bryant Willoughby 
Course: ST 445 (002)
Last Edited on: 11/27/22
Program Purpose: Final Project Section 1 

*create the InputDS libref and InputRaw fileref; 
x 'cd L:\st445\Data\BookData\BeverageCompanyCaseStudy'; 
libname InputDS '.'; 
filename InputRaw '.'; 

*Use ACCESS keyword in LIBNAME statement to access this Microsoft Access database; 
libname counties access "2016Data.accdb"; 

*associate a libref named Results for my class' results folder; 
x 'cd L:\st445\Results\FinalProjectPhase1'; 
libname Results '.';  

*associate a libref named Data for my class' Data folder (mainly to access provided formats); 
x 'cd L:\st445\Data'; 
libname Data '.'; 

*create a libref and fileref - both named Exam associated with my Exam storage location; 
*note: all data, formats, files, or other objects I store must be saved in this library; 
*this is my working directory; 
x 'cd S:\st445_code\Final_Exam_1_datasets'; 
libname Exam '.';
filename Exam '.'; 

*Store the County table from this file into a SAS data set named Counties (in my Exam library); 
*Here, I am creating my own local copy to work with; 
data Exam.counties; 
  set counties.counties (rename = (state = stateFips county = countyFips));    /*counties is the name of the particular table I want to retrieve*/ 
run; 


*Clear the library for this file as soon as you read in the necessary information from it; 
libname counties clear; 

*create remaining formats not provided from Duggins for ProductName; 
*note: provided $prodnames format applies to Sodas (Cola/Non-Cola); 
proc format library = Exam; 
  value energy (fuzz=0)   1 =  "Zip-Orange"                   /*refers to energy drink data sets*/ 
                          2 =  "Zip-Berry" 
                          3 =  "Zip-Grape" 
                          4 =  "Diet Zip-Orange" 
                          5 =  "Diet Zip-Berry" 
                          6 =  "Diet Zip-Grape" 
                          7 =  "Big Zip-Berry" 
                          8 =  "Big Zip-Grape" 
                          9 =  "Diet Big Zip-Berry" 
                          10 = "Diet Big Zip-Grape" 
                          11 = "Mega Zip-Orange" 
                          12 = "Mega Zip-Berry" 
                          13 = "Diet Mega Zip-Orange" 
                          14 = "Diet Mega Zip-Berry" 
  ; 
  value other (fuzz=0)    1 =  "Non-Soda Ades-Lemonade"                   /*refers to other drink data sets*/ 
                          2 =  "Non-Soda Ades-Diet Lemonade" 
                          3 =  "Non-Soda Ades-Orangeade" 
                          4 =  "Non-Soda Ades-Diet Orangeade" 
                          5 =  "Nutritional Water-Orange" 
                          6 =  "Nutritional Water-Grape" 
                          7 =  "Diet Nutritional Water-Orange" 
                          8 =  "Diet Nutritional Water-Grape" 
  ; 
run; 


*Read in non-cola South region dataset with mostly column input and formatted input to read in date value; 
data Exam.NonColaSouth; 
  attrib productname length = $ 50
         size        length = $ 200
  ; 
  infile InputRaw ("Non-Cola--NC,SC,GA.dat") firstobs = 7; 
  input stateFips 1-2 
        countyFips 3-5 
        productname $ 6-25 
        size $ 26-35
        unitSize  36-38
        date mmddyy10.    /*use mmddyy. informat to read in numeric date values*/ 
        unitssold 49-55
  ;                       
run; 


*read in South-region energy dataset only using list-based input styles; 
data Exam.EnergySouth;
  infile InputRaw("Energy--NC,SC,GA.txt") dlm = '09'x firstobs = 2; 
  input stateFips 
        countyFips 
        productname : $50.
        size :  $200.
        unitSize 
        date : date9.     /*modified list input reads delimited fields that require informats (using DATE informat here)*/ 
        unitssold 
  ;                    
run; 


*read in the South-region dataset for 'Other' drinks only using list-based input styles; 
data Exam.OtherSouth; 
  infile InputRaw("Other--NC,SC,GA.csv") dsd firstobs = 2; /*using dsd as a defensive programming practice (while still setting delimiter to comma)*/ 
  input stateFips
        countyFips
        productname : $50.
        size : $200. 
        unitSize 
        date : date9.
        unitssold
  ; 
run; 


*Read in the Non-cola dataset for the North region only using formatted input; 
data Exam.NonColaNorth; 
  attrib productcode length = $ 200; 
  infile InputRaw("Non-Cola--DC-MD-VA.dat") firstobs = 5; 
  input stateFips 2.
        countyFips 3.
        productcode $25.
        date anydtdte10.     /*different styles of dates used in raw file can all be interpreted using an informat called ANYDTDTE*/ 
        unitssold 7.
  ; 
run; 
        

*Read in Energy datset for the North region only using list-based input styles; 
data Exam.EnergyNorth; 
  infile InputRaw("Energy--DC-MD-VA.txt") dlm = '09'x firstobs = 2; 
  input stateFips 
        countyFips 
        productcode : $200.
        date : anydtdte10.   
        unitssold 
  ; 
run; 


*read in Other dataset for North region using only list-based input styles; 
data Exam.OtherNorth; 
  infile InputRaw("Other--DC-MD-VA.csv") dsd firstobs = 2; 
  input stateFips 
        countyFips 
        productcode : $200.
        date : anydtdte10.
        unitssold 
  ; 
run; 



*Produce AllDrinks data set that contains all records from Cola, Non-Cola, Energy, and Other for both the North and South regions (concatenation); 
options fmtsearch = (Data Exam); /*access formats from both libraries where they are stored*/ 
data Exam.AllDrinks (drop = _: productcode); 
  attrib 
          stateFips                                                                  label = "State FIPS"
          countyFips                                                                 label = "County FIPS" 
          region             length = $ 8       format = $8.     informat = $8.      label = "Region" /*Do I need to specify the informat in the attrib statement?*/ 
                                                                                                               /*Is there somewhere else wher I could have putten it?*/ 
          productname        length = $ 50                                           label = "Beverage Name"
          type               length = $ 8                                            label = "Beverage Type" 
          flavor             length = $ 30                                           label = "Beverage Flavor"
          productCategory    length = $ 30                                           label = "Beverage Category" 
          productSubCategory length = $ 30                                           label = "Beverage Sub-Category"
          size               length = $ 200                                          label = "Beverage Volume"
          unitSize                              format =  best12.                    label = "Beverage Quantity" 
          container          length = $ 6                                            label = "Beverage Container"
          date                            format = date9.                            label = "Sale Date" 
          unitssold                       format = comma7.                           label = "Units Sold" 
          productcode                                                                label = ""           /*drop once I have derived variables from productcode*/ 
  ;
  set InputDS.ColaNCSCGA (in = SouthCola)                                  
      InputDS.ColaDCMDVA (in = NorthCola rename = (code = productcode)) 
      Exam.NonColaSouth  (in = SouthNonCola)
      Exam.NonColaNorth  (in = NorthNonCola)
      Exam.EnergySouth   (in = SouthEnergy)
      Exam.EnergyNorth   (in = NorthEnergy)
      Exam.OtherSouth    (in = SouthOther)
      Exam.OtherNorth    (in = NorthOther)
  ; 

  _datasettracker = 1*SouthCola + 2*NorthCola + 3*SouthNonCola + 4*NorthNonCola + 5*SouthEnergy + 6*NorthEnergy + 7*SouthOther + 8*NorthOther; /*Use this to derive Region below*/

  productname = propcase(productname); /*productname should always appear with proper casing*/ 

  select (_datasettracker);        
    when(1) do; 
        Region = "South";                                     /*Region is either North or South based on which file provided the data*/ 
        productcategory = "Soda: Cola";                         /*Productcategory is based on the categorization of the product for all data sets except Other*/ 
        flavor = strip(tranwrd(productname,'Diet',''));             /*Flavor is derived from the name of product*/ 
      end; 
    when(3) do; 
        Region = "South"; 
        productcategory = "Soda: Non-Cola"; 
        flavor = strip(tranwrd(productname,'Diet',''));
      end; 
    when(5) do; 
        Region = "South"; 
        productcategory = "Energy";
        productsubcategory = strip(scan(tranwrd(productname,'Diet',''),1,'-')); /*productsubcategory only applies to energy drinks; derived from the productname*/ 
        flavor = strip(scan(tranwrd(productname,'Diet',''),2,'-'));      
      end; 
    when(7) Region = "South";
    when(2) do;                         /*productname only provided directly in the South data sets - not North - thus, must be derived using product codes for North data sets*/ 
       Region = "North";
       _productname = input(scan(productcode,2,'-'), 8.); 
       productname = put(_productname, prodnames.); 
       productcategory = "Soda: Cola"; 
       flavor = strip(tranwrd(productname,'Diet',''));
       _unitsize = strip(scan(productcode,4,'-'));             /*UnitSize is only provided in the South Data sets but can be derived from productcode for North data sets*/ 
       unitsize = input(_unitsize,8.);
       size = strip(scan(productcode,3,'-'));    /*size should always provided - needs to be extracted from productcode for North data sets*/ */;
     end; 
    when(4) do; 
       Region = "North"; 
       _productname = input(scan(productcode,2,'-'), 8.); 
       productname = put(_productname, prodnames.);
       productcategory = "Soda: Non-Cola"; 
       flavor = strip(tranwrd(productname,'Diet',''));
       _unitsize = strip(scan(productcode,4,'-'));             
       unitsize = input(_unitsize,8.);
       size = strip(scan(productcode,3,'-'));
      end; 
    when(6) do; 
       Region = "North"; 
       _productname = input(scan(productcode,2,'-'), 8.); 
       productname = put(_productname, energy.);
       productcategory = "Energy"; 
       productsubcategory = strip(scan(tranwrd(productname,'Diet',''),1,'-')); /*STRIP gets rid of all leading/trailing spaces*/ 
       flavor = strip(scan(tranwrd(productname,'Diet',''),2,'-'));
       _unitsize = strip(scan(productcode,4,'-'));             
       unitsize = input(_unitsize,8.);
       size = scan(productcode,3,'-');
      end; 
    when(8) do; 
       Region = "North"; 
       _productname = input(scan(productcode,2,'-'), 8.); 
       productname = put(_productname, other.);
       _unitsize = strip(scan(productcode,4,'-'));             
       unitsize = input(_unitsize,8.);
       size = scan(productcode,3,'-');
      end;  
  end; 

  _typetracker = index(productname, "Diet");    /*Type is either Diet or Non-Diet based on the name of the product*/ 

  select(_typetracker); 
    when(0)    type = "Non-Diet"; 
    otherwise  type = "Diet";           /*any string that contains Diet found from INDEX function is type: Diet*/ 
  end; 

  _nonsodaadestracker = index(productname, "Non-Soda Ades");   /*INDEX function finds the first instance of a string within a larger string*/ 
 
  _nutritionalwatertracker = index(productname, "Nutritional Water"); 

  if  _nonsodaadestracker ne 0 then do; 
          productcategory = "Non-Soda Ades";         /*ProductCategory is based on more specific values rather than merely the categorization of the product for the Other data set*/
          flavor = strip(scan(tranwrd(productname,'Diet',''),3,'-'));
        end; 
    else if _nutritionalwatertracker ne 0 then do;  /*Using IF-THEN/ELSE for dependent checks to derive productcategory and flavor variable for Other data sets*/  
                productcategory = "Nutritional Water";
                flavor = scan(productname,2,'-');
              end; 
              
  size = lowcase(size);         /*Units of size are always lowercase*/

  _ouncestracker = index(scan(size,2),'o'); /*one of default delimiters for scan function is space*/

  _ltracker = index(scan(size,2),'l'); 

  _lunits = scan(size,2); 

  if _ouncestracker ne 0 then size = tranwrd(size,'ounces','oz');     /*the only acceptable units are "oz" and "liter"*/ 
    else if _ltracker ne 0 and _lunits eq 'liters' then size = tranwrd(size,'liters','liter'); 
      else if _ltracker ne 0 and _lunits eq 'l' then size = tranwrd(size,'l','liter'); 

  select(size); /*Container is derived from Size*/ 
    when('8 oz')    container = 'Can'; 
    when('12 oz')   container = 'Can'; 
    when('16 oz')   container = 'Can'; 
    when('20 oz')   container = 'Bottle'; 
    when('1 liter') container = 'Bottle'; 
    when('2 liter') container = 'Bottle'; 
  end;

run; 


*match-merging the AllDrinks data set with Counties data set by stateFips and countyFips; 
/*must sort both data sets before merging*/ 
/*note: each record in the Counties data set identified by the combination of stateFips and countyFips is unique - thus, this is a one-to-many match-merge*/ 
proc sort data = Exam.AllDrinks out = Exam.SortedAllDrinks; 
  by stateFips countyFips; 
run; 

proc sort data = Exam.Counties out = Exam.SortedCounties; 
  by stateFips countyFips; 
run; 


data Exam.AllData(drop = _average); 
  attrib 
          stateName          length = $ 50      format = $50.    informat = $50.     label = "State Name"
          stateFips                                                                  label = "State FIPS"
          countyName         length = $ 50      format = $50.    informat = $50.     label = "County Name"
          countyFips                                                                 label = "County FIPS" 
          region             length = $ 8       format = $8.     informat = $8.      label = "Region" /*Do I need to specify the informat in the attrib statement?*/ 
                                                                                                                      /*Is there somewhere else wher I could have putten it?*/ 
          popestimate2016                      format = comma10.                     label = "Estimated Population in 2016"
          popestimate2017                      format = comma10.                     label = "Estimated Population in 2017"
          productname        length = $ 50                                           label = "Beverage Name"
          type               length = $ 8                                            label = "Beverage Type" 
          flavor             length = $ 30                                           label = "Beverage Flavor"
          productCategory    length = $ 30                                           label = "Beverage Category" 
          productSubCategory length = $ 30                                           label = "Beverage Sub-Category"
          size               length = $ 200                                          label = "Beverage Volume"
          unitSize                              format =  best12.                    label = "Beverage Quantity" 
          container          length = $ 6                                            label = "Beverage Container"
          date                                  format = date9.                      label = "Sale Date" 
          unitssold                             format = comma7.                     label = "Units Sold" 
          salesPerThousand                      format = 7.4                         label = "Sales per 1,000"
  ;   
  
  merge Exam.SortedAllDrinks 
        Exam.SortedCounties; 

  by stateFips countyFips; 
  
  _average = (popestimate2016 + popestimate2017)/2;

  salesperthousand = 1000*(unitssold/_average); /*ratio of unitssold to the average population from 2016 and 2017 (scale by 1000)*/

run; 


/*Create appropriate data set from AllData file to produce Activity 3.6*/ 
proc means data = Exam.AllData mean median nonobs;
  class productname;
  var unitssold; /*sales pertains to unitssold variable*/ 
  where productcategory = 'Nutritional Water' and unitsize eq 1;
  ods output summary = Exam.Activity36; 
run; 


*Create appropriate data set from AllData file to produce Activity 4.4; 
proc means data = Exam.AllData q1 q3 nonobs;  
  class region type date; 
  var unitssold; 
  where flavor = 'Cola' and size = '20 oz' and unitsize eq 1; 
  ods output summary = Exam.Activity44; 
run; 


*Create appropriate data set from AllDrinks file to produce the Optional Activity; 
*note: sort order for this new data set is correct (position of variables displayed can be changed in a later PROC (print) without changing underlying structure of data); 
proc sort data = Exam.AllDrinks(keep = productcategory productsubcategory productname type container flavor size)
          out = Exam.OptionalActivity
          nodupkey; 
    by productcategory productsubcategory productname type container flavor size; 
run;


*Create appropriate data set from AllData file to produce Activity 5.5; 
proc means data = Exam.AllData sum nonobs;
  class date type statename; 
  var unitssold; 
  where (statename = 'North Carolina' or statename = 'South Carolina') and month(date) = 8 and size = '12 oz' and unitsize = 1 and flavor = 'Cola';  
                                                                           /*MONTH function recognizes numeric value 8 to represent the month of August*/ 
  ods output summary = Exam.intermediateActivity55; 
run; 

proc transpose data = Exam.intermediateActivity55 out = Exam.Activity55 (drop = _NAME_ _LABEL_);
  var unitssold_sum; 
  id statename;  /*ID statement uses values of a variable in DATA= to name columns in OUT=; 
                 thus, new columns are NC/SC that contain respective sums like we need for subsequent graph*/ 
  by date type; 
run; 


*use a macro variable named CompOpts to apply all the settings that are common across the COMPARE steps; 
/*%let CompOpts = outbase outcompare outdiff outnoequal noprint method = absolute criterion = 1E-15;*/
/**/
/* proc compare base = Results.AllDrinks*/
/*              compare = Exam.Alldrinks*/
/*              out = work.DiffsB */
/*              &CompOpts;*/
/* run;  */
/**/
/*  proc compare base = Results.AllData*/
/*              compare = Exam.AllData*/
/*              out = work.DiffsA */
/*              &CompOpts;*/
/* run;  */



quit; 
