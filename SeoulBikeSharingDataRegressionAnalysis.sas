title "Seoul Bike Sharing Dataset";
data SeoulBikeSharing;
    infile "C:\Users\KMEHDI\Downloads\SeoulBikeSharing.csv" delimiter=',' firstobs=2 missover dsd truncover;
    input Date : mmddyy10. Rented_Bike_Count Hour Temperature Humidity Wind_speed Visibility Dew_point_temperature Solar_Radiation Rainfall Snowfall Seasons : $6. Holiday : $11. Functioning_Day : $3.;
run;
proc print data=SeoulBikeSharing (obs=5);
run;
data SeoulBikeSharing_dummies;
    set SeoulBikeSharing;


    dummy_Spring = (Seasons = 'Spring');
    dummy_Summer = (Seasons = 'Summer');
    dummy_Autumn = (Seasons = 'Autumn');

    
    dummy_Holiday = (Holiday = 'Holiday');
    dummy_FunctioningDay = (Functioning_Day = 'Yes');
run;

title "Seoul Bike Sharing Dataset - Descriptive Statistics and Visualizations";
proc means data=SeoulBikeSharing N mean std min max;
    var Rented_Bike_Count Hour Temperature Humidity Wind_speed Visibility Dew_point_temperature Solar_Radiation Rainfall Snowfall;
run;
title "Boxplot for Rented Bike Count and Seasons";
proc boxplot data=SeoulBikeSharing;
    plot Rented_Bike_Count*Seasons;
run;
title "Scatter Plot for Rented Bike Count and Temperature";
proc sgscatter data=SeoulBikeSharing;
    plot Rented_Bike_Count*Temperature;
run;
title "Histogram for Rented Bike Count";
proc univariate data=SeoulBikeSharing;
    var Rented_Bike_Count;
    histogram Rented_Bike_Count / normal;
run;
title "Full Linear Regression Model for Seoul Bike Sharing";
proc reg data=SeoulBikeSharing_dummies;
    model Rented_Bike_Count = Hour Temperature Dew_point_temperature Humidity Wind_speed Visibility Solar_Radiation Rainfall Snowfall dummy_Spring dummy_Summer dummy_Autumn dummy_Holiday dummy_FunctioningDay / r influence vif stb;
    output out=RegStats p=predicted_values r=residuals;
run;
title "Full Linear Regression Model for Seoul Bike Sharing taking out Dew Point Temperature";
proc reg data=SeoulBikeSharing_dummies;
    model Rented_Bike_Count = Hour Temperature Humidity Wind_speed Visibility Solar_Radiation Rainfall Snowfall dummy_Spring dummy_Summer dummy_Autumn dummy_Holiday dummy_FunctioningDay / r influence vif stb;
    output out=RegStats p=predicted_values r=residuals;
run;
proc corr data=SeoulBikeSharing_dummies nosimple;
    var Hour Temperature Humidity Wind_speed Visibility Dew_point_temperature Solar_Radiation Rainfall Snowfall;
    title "Correlation Matrix to Check for Multicollinearity";
run;
proc sgplot data=RegStats;
    title "Residuals vs Predicted Plot";
    scatter x=predicted_values y=residuals;
run;
proc sgplot data=RegStats;
    title "Residuals Histogram";
    histogram residuals;
run;
data SeoulBikeSharing_Cleaned;
 set SeoulBikeSharing_dummies;
  if _n_ in (3283, 3297, 3499, 3513, 3523, 3537, 3547, 3619, 3681, 3705, 3715, 3825, 3835, 3873, 3883, 3928, 3929, 3930, 3931, 3945, 3955, 3969, 3979, 3997, 4051, 4123, 4161, 4171, 4185, 4195, 4219, 4281, 4291, 4305, 4339, 4240, 4353, 4363, 4377, 4387, 4449, 4459, 4460, 4473, 4483, 4521, 4531, 4532, 4545, 4555, 4556, 4617, 4641, 4651, 4652, 4653, 4654, 4674, 4699, 4713, 4723, 4724, 4785, 4809, 4819, 4820, 4833, 4843, 4844, 4857, 4867, 4868, 4881, 4891, 4953, 4963, 5001, 5011, 5025, 5049, 5059, 5060, 5145, 5155, 5169, 5179, 5203, 5217, 5227, 5313, 5347, 5371, 5395, 5491, 6331, 6571, 6657, 6667, 6681, 6691, 6705, 6729, 6739, 6811, 6825, 6835, 6849, 6859, 6873, 6883, 6907, 6969, 6979, 7219, 7315, 7473, 7483, 7521, 7569, 7579, 7641, 7651, 7665, 7675, 7689, 7713, 7737, 7809, 7843, 7857, 7867, 7881, 7977, 8001, 8025, 8049, 8073, 8145, 8233, 8337, 8361) then delete;
proc print;
run;
proc reg data=SeoulBikeSharing_Cleaned;
    model Rented_Bike_Count = Hour Temperature Humidity Wind_speed Visibility Solar_Radiation Rainfall Snowfall dummy_Spring dummy_Summer dummy_Autumn dummy_Holiday dummy_FunctioningDay / r influence vif stb;
    output out=RegStats p=predicted_values r=residuals;
run;
title "Test and Train Sets for Seoul Bike Sharing";
proc surveyselect data=SeoulBikeSharing_Cleaned out=SeoulBikeSharing_split seed=563423
    samprate=0.80 outall;
run;
data SeoulBikeSharing_split;
set SeoulBikeSharing_split;
if Selected then new_y = Rented_Bike_Count;
run;
proc print data=SeoulBikeSharing_split;
run;
* Model 1 Stepwise;
proc reg data=SeoulBikeSharing_split;
    model new_y = Hour Temperature Humidity Wind_speed Visibility Solar_Radiation Rainfall
                  Snowfall dummy_Spring dummy_Summer dummy_Autumn dummy_Holiday dummy_FunctioningDay /
                  selection = stepwise;
run;
* Model 2 Cp;
proc reg data=SeoulBikeSharing_split;
    model new_y = Hour Temperature Humidity Wind_speed Visibility Solar_Radiation Rainfall Snowfall dummy_Spring dummy_Summer dummy_Autumn dummy_Holiday dummy_FunctioningDay / selection = cp;
run;
* Model 3 Backward;
proc reg data=SeoulBikeSharing_split;
    model new_y = Hour Temperature Humidity Wind_speed Visibility Solar_Radiation Rainfall Snowfall dummy_Spring dummy_Summer dummy_Autumn dummy_Holiday dummy_FunctioningDay / selection = backward;
run;
* Model 4 Forward;
proc reg data=SeoulBikeSharing_split;
    model new_y = Hour Temperature Humidity Wind_speed Visibility Solar_Radiation Rainfall Snowfall dummy_Spring dummy_Summer dummy_Autumn dummy_Holiday dummy_FunctioningDay / selection = forward;
run;
* Model 5 Adj-R2;
proc reg data=SeoulBikeSharing_split;
    model new_y = Hour Temperature Humidity Wind_speed Visibility Solar_Radiation Rainfall Snowfall dummy_Spring dummy_Summer dummy_Autumn dummy_Holiday dummy_FunctioningDay / selection = adjrsq;
run;

title “Final Model w/ options taking out Visibility”;
proc reg data=SeoulBikeSharing_split;
    model new_y = Hour Temperature Humidity Wind_speed Solar_Radiation Rainfall Snowfall dummy_Spring dummy_Summer dummy_Autumn dummy_Holiday dummy_FunctioningDay;
run;
title "Validation - Test Set";
proc reg data=SeoulBikeSharing_split;
model new_y = Hour Temperature Humidity Wind_speed Solar_Radiation Rainfall Snowfall dummy_Spring dummy_Summer dummy_Autumn dummy_Holiday dummy_FunctioningDay;
output out = outm1(where=(new_y=.)) p=yhat;
run;
title "Difference between Observed and Predicted in Test Set";
data outm1_sum;
    set outm1;
    Diff = Rented_Bike_Count - yhat; 
 absd = abs(Diff);
run;

proc summary data=outm1_sum;
    var Diff absd;
    output out=outm1_stats std(Diff)=rmse mean(absd)=mae;
run;
title "Validation Statistics for Model";
proc print data=outm1_stats;
run;
proc corr data=outm1;
    var Rented_Bike_Count yhat;
run;
proc glmselect data=SeoulBikeSharing_split;
    model Rented_Bike_Count = Hour Temperature Humidity Wind_speed
                              Dew_point_temperature Solar_Radiation Rainfall Snowfall
                              dummy_Spring dummy_Summer dummy_Autumn 
                              dummy_Holiday dummy_FunctioningDay
    / selection=stepwise cvMethod=split(5) cvDetails=all;
run;
title "Predictions with made up values";
data prediction;
    Hour = 10; Temperature = 22; Humidity = 60; Wind_speed = 5; Solar_Radiation = 1; Rainfall = 5; Snowfall = 0; 
    dummy_Spring = 1; dummy_Summer = 0; dummy_Autumn = 0; dummy_Holiday = 0; dummy_FunctioningDay = 1;
    new_y = -512.75865 
            + 26.33330 * Hour 
            + 25.60766 * Temperature 
            - 8.20552 * Humidity 
            + 15.75782 * Wind_speed 
            - 77.05616 * Solar_Radiation 
            - 55.28560 * Rainfall 
            + 30.15287 * Snowfall 
            + 214.67249 * dummy_Spring 
            + 192.17746 * dummy_Summer 
            + 351.45104 * dummy_Autumn 
            - 87.53055 * dummy_Holiday 
            + 902.81028 * dummy_FunctioningDay;
    output; 

    Hour = 15; Temperature = 18; Humidity = 45; Wind_speed = 3; Solar_Radiation = 0.5; Rainfall = 0; Snowfall = 0; 
    dummy_Spring = 0; dummy_Summer = 1; dummy_Autumn = 0; dummy_Holiday = 1; dummy_FunctioningDay = 1;
    new_y = -512.75865 
            + 26.33330 * Hour 
            + 25.60766 * Temperature 
            - 8.20552 * Humidity 
            + 15.75782 * Wind_speed 
            - 77.05616 * Solar_Radiation 
            - 55.28560 * Rainfall 
            + 30.15287 * Snowfall 
            + 214.67249 * dummy_Spring 
            + 192.17746 * dummy_Summer 
            + 351.45104 * dummy_Autumn 
            - 87.53055 * dummy_Holiday 
            + 902.81028 * dummy_FunctioningDay;
    output;

    Hour = 20; Temperature = 15; Humidity = 70; Wind_speed = 4; Solar_Radiation = 0; Rainfall = 10; Snowfall = 2; 
    dummy_Spring = 0; dummy_Summer = 0; dummy_Autumn = 1; dummy_Holiday = 0; dummy_FunctioningDay = 1;
    new_y = -512.75865 
            + 26.33330 * Hour 
            + 25.60766 * Temperature 
            - 8.20552 * Humidity 
            + 15.75782 * Wind_speed 
            - 77.05616 * Solar_Radiation 
            - 55.28560 * Rainfall 
            + 30.15287 * Snowfall 
            + 214.67249 * dummy_Spring 
            + 192.17746 * dummy_Summer 
            + 351.45104 * dummy_Autumn 
            - 87.53055 * dummy_Holiday 
            + 902.81028 * dummy_FunctioningDay;
    output;
run;
proc print data=prediction;
run;

