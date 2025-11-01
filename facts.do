/// facts and tables
/// 
clear
cd  "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\22"
use "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\20_reg&synthetic control\import_m_90.dta"


/// The total value in rials and dollars, as well as the weight, is calculated for each tariff code and month, with no duplicate tariff codes within the same month.

collapse (sum) rialvalue dolarvalue weight, by( month_year year month tariff )

/// Complete panel structure
/// Generate all possible combinations of tariff, year, and month
/// If data for a tariff code is missing in a given month, we replace it with 0.
fillin tariff year month 

/// month_yris like 139504
gen month_yr = year * 100 + month
drop month_year


drop _fillin
/// exchange rate group 
/// Merge the data with the exchange rate group information to identify which goods fall under the preferential, NIMA, or personal import groups.
merge m:m tariff month_yr using  "E:\Dropbox\Shojaei's Thesis Project\Data\Eligible Products\Maps\HS_dta\HS_1390_1402.dta", keep(match master) nogen

gen month_year=ym(year,month)
format month_year %tm

/// In the `data.dta` file, I have saved the monthly exchange rate premium for preferential and Nima data, along with the monthly CPI data for Iran and the US, to calculate the real value.

merge m:1 month_year using "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\20_reg&synthetic control\data_EX.dta", keep(match master) nogen

replace rialvalue = 0 if rialvalue == .
/// To calculate the real rial value, divide the nominal rial value by the CPI_Iran 
gen realvalue_rial= (rialvalue/cpi_iran_m) *100
replace rialvalue = 0 if rialvalue == .
replace realvalue_rial = 0 if realvalue_rial == .
///
keep if year>= 1397
collapse gap weight realvalue_rial realvalue_million rialvalue cpi_iran_m , by(tariff month_year month_yr group)
gen preferential = 0
replace preferential = 1 if group == 1 & month_yr>= 139702
gen nima = 0
replace nima = 1 if  (group == 2 | group == 21 | group == 22 | group == 23 ) & month_yr >= 139702 & month_yr < 139907
replace nima = 1 if (group == 21 | group == 2) & month_yr >= 139907
gen nima_t_n = 0
replace nima_t_n = 1 if (group == 22 | group == 23 | group == 24 | group == 25 | group == 26) &  month_yr >= 139907
replace nima_t_n = 1 if ( group == 24 | group == 25 | group == 26 ) & month_yr >= 139702 & month_yr < 139907

/// calculate the number of tariff codes eligible for the preferential subsidy by month
egen tariff_count_preferential = count(tariff) if preferential == 1, by(month_year)
/// calculate the number of tariff codes non-eligible for the preferential subsidy by month
egen tariff_count_nima = count(tariff) if nima == 1, by(month_year)

egen tariff_count_nima_t_n = count(tariff) if nima_t_n == 1, by(month_year)


egen tariff_count_personal = count(tariff) if nima_t_n == 0 & nima == 0 & preferential == 0, by(month_year)

/// total import dolarvalue monthly eligible for the preferential subsidy and non-eligible by month
/// billion
gen billion_realvalue = realvalue_million/1000
egen import_preferential_month_dolar = total(billion_realvalue*preferential) , by(month_year)
egen import_nima_month_dolar = total(billion_realvalue*nima), by(month_year)

egen import_nima_t_n_month_dolar = total(billion_realvalue*nima_t_n), by(month_year)

egen import_personal_month_dolar = total(billion_realvalue) if group == 3 | group ==27, by(month_year)

/// total import weight eligible for the preferential subsidy and non-eligible by month
/// weight/1000000 is thousand tons
 gen thousand_ton_w = weight/1000000000
 
egen import_preferential_month_w = total(thousand_ton_w*preferential), by(month_year)

egen import_nima_monthـw = total(thousand_ton_w*nima), by(month_year)

egen import_nima_t_n_month_w = total(thousand_ton_w*nima_t_n), by(month_year)


egen import_personal_month_w = total(thousand_ton_w) if group == 3 | group ==27, by(month_year)

/// I changed its unit to Hemat (thousand Billion Toman).
gen realvalue_rial_hemat= realvalue_rial/10000000000000

/// total import real rial value eligible for the preferential subsidy and non-eligible by month
egen import_preferential_rial = total(realvalue_rial_hemat*preferential), by(month_year)
egen import_nima_rial = total(realvalue_rial_hemat*nima), by(month_year)

egen import_nima_t_n_rial = total(realvalue_rial_hemat*nima_t_n) , by(month_year)


egen import_personal_rial = total(realvalue_rial_hemat) if group == 3 | group ==27 , by(month_year)
/// total monthly imports dolar and rial alues and weight.

egen total_import_dolar = total(billion_realvalue), by(month_year)
egen total_import_rial = total(realvalue_rial_hemat), by(month_year)
egen total_import_weght = total(thousand_ton_w), by(month_year)

collapse tariff_count_preferential tariff_count_nima tariff_count_nima_t_n tariff_count_personal import_preferential_month_dolar import_nima_month_dolar import_nima_t_n_month_dolar import_personal_month_dolar import_preferential_month_w import_nima_monthـw import_nima_t_n_month_w import_personal_month_w import_preferential_rial import_nima_rial import_nima_t_n_rial import_personal_rial total_import_dolar total_import_rial total_import_weght,by(month_yr month_year)
 /// monthly table in excel

export excel month_yr month_year tariff_count_preferential tariff_count_nima tariff_count_nima_t_n tariff_count_personal import_preferential_month_dolar import_nima_month_dolar import_nima_t_n_month_dolar import_personal_month_dolar import_preferential_month_w import_nima_monthـw import_nima_t_n_month_w import_personal_month_w import_preferential_rial import_nima_rial import_nima_t_n_rial import_personal_rial total_import_dolar total_import_rial total_import_weght using "Import_monthly_from1397_12.xlsx", firstrow(variables) replace

////
 replace import_preferential_month_dolar=0 if import_preferential_month_dolar==.

replace import_nima_t_n_month_dolar = 0 if import_nima_t_n_month_dolar == .
. replace import_nima_month_dolar=0 if import_nima_month_dolar==.
//// calculate which currency share

 gen preferential_share = (import_preferential_month_dolar/ total_import_dolar)*100

. gen nima_share = (import_nima_month_dolar /total_import_dolar)*100 + preferential_share
gen nima_t_n_share = (import_nima_t_n_month_dolar/total_import_dolar)* 100 + nima_share

. gen personal_share = (import_personal_month_dolar /total_import_dolar )*100 + nima_t_n_share

/// graph

gen year_m = year + 621
gen month_m = month + 3
//////////////////Gregorian Year
gen month_year_m=ym(year_m,month_m)
format month_year_m %tm
keep if year_m >= 2018
collapse nima_share preferential_share nima_t_n_share personal_share, by( month_year_m)

graph set window fontface "Times New Roman"

twoway ///
    (area personal_share month_year_m, fcolor(ltblue) lcolor(navy%10)) ///
    (area nima_t_n_share month_year_m, fcolor(gs8) lpattern(O) lcolor(black%50)) ///
    (area nima_share month_year_m, fcolor(maroon%45) lpattern(O) lcolor(black%50)) ///
    (area preferential_share month_year_m, fcolor(navy) lcolor(maroon%20)), ///
    xlabel(`=tm(2018m4)'(3)`=tm(2023m12)', angle(75)) ///
    legend(order(1 "Free-market rate" 2 "NIMA negotiated rate" 3 "NIMA" 4 "Preferential rate") ///     
           position(6) ring(1) col(2) size(small)) ///
    ytitle("share of which exchange rate source in import(%)") /// 
    xtitle("")
   
graph export "preferential&nima&personal_nima_t_nshare_en.png", as(png) replace width(2000) height(1200)	  

////

//// some graphs
//////////////////////////yearly
clear
use "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\22\im_reg.dta"


keep if year>= 1397
gen subsidy  = 0
replace subsidy = 1 if group == 1 & month_yr >= 139702
/// total preferential import
egen preferential_im = total(subsidy*realvalue_million), by(year)


/// preferential intermediate & capital & consumption goods
egen im_inter_p = total(subsidy*realvalue_million*intermadiate), by(year)
egen im_cons_p = total(subsidy*realvalue_million*consumption), by(year)
egen im_capital_p = total(subsidy*realvalue_million*capital), by(year)
egen im_not_p = total(subsidy*realvalue_million*not_classified), by(year)

gen im_inter_p_s = (im_inter_p/preferential_im)*100
gen im_cons_p_s = (im_cons_p/preferential_im)*100
gen im_capital_p_s = (im_capital_p/preferential_im)*100
gen im_not_p_s = (im_not_p/preferential_im)*100

collapse preferential_im im_inter_p_s im_cons_p_s im_capital_p_s im_not_p_s, by(year tariff subsidy)

label variable im_inter_p_s   "intermadiate"
label variable im_cons_p_s    "consumption"
label variable im_capital_p_s "capital"
gen year_m = year + 621

graph set window fontface "Times New Roman"

graph bar im_inter_p_s im_cons_p_s im_capital_p_s, over(year_m) stack ///
    bar(1, color(ltblue)) ///
    bar(2, color(maroon%70)lpattern(dot) lwidth(medium)) ///
    bar(3, color(navy) lpattern(dash)) ///
    legend(order(1 "intermadiate" 2 "consumption" 3 "capital") rows(1) position(6)) /// 
    ytitle("Import share by commodity group under preferential rate (%)") ///  
    ylabel(0(10)100)

graph export "preferential_consumption_capital_ii.png", as(png) replace width(2000) height(1200)	

/// nima
clear
cd "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\22"
use "im_reg.dta"

gen nima = 0
replace nima = 1 if  (group == 2 | group == 21 | group == 22 | group == 23 ) & month_yr >= 139702 & month_yr < 139907
replace nima = 1 if (group == 21 | group == 2) & month_yr >= 139907
gen nima_t_n = 0
replace nima_t_n = 1 if (group == 22 | group == 23 | group == 24 | group == 25 | group == 26) &  month_yr >= 139907

keep if year>= 1397
/// nima 

/// nima import 
egen nima_im = total(nima*realvalue_million), by(year)

/// nima  intermediate & capital & consumption goods

egen im_inter_nima = total(nima*realvalue_million*intermadiate), by(year)
egen im_cons_nima = total(nima*realvalue_million*consumption), by(year)
egen im_capital_nima = total(nima*realvalue_million*capital), by(year)
egen im_not_nima = total(nima*realvalue_million*not_classified), by(year)

gen im_inter_nima_s = (im_inter_nima/nima_im)*100
gen im_cons_nima_s = (im_cons_nima/nima_im)*100
gen im_capital_nima_s = (im_capital_nima/nima_im)*100
gen im_not_nima_s = (im_not_nima/nima_im)*100

 collapse im_inter_nima_s im_cons_nima_s im_capital_nima_s im_not_nima_s, by(tariff nima year)
 

label variable im_inter_t_s   "intermadiate"
label variable im_cons_t_s    "consumption"
label variable im_capital_t_s "capital"
gen year_m = year + 621

graph set window fontface "Times New Roman"
//////////
gen year_m = year + 621
graph bar im_inter_nima_s im_cons_nima_s im_capital_nima_s, over(year_m) stack ///
    bar(1, color(ltblue)) ///
    bar(2, color(maroon%70)lpattern(dot) lwidth(medium)) ///
    bar(3, color(navy) lpattern(dash)) ///
    legend(order(1 "intermadiate" 2 "consumption" 3 "capital") rows(1) position(6)) /// 
    ytitle("Import share by commodity group under NIMA rate (%)") ///  
    ylabel(0(10)100)

graph export "NIMA_c_ii.png", as(png) replace width(2000) height(1200)	
	

///////////////////////////////////////////////////////////////////////////
///NIMA_negotiated rate

clear
cd "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\22"
use "im_reg.dta"

gen nima_t_n = 0
replace nima_t_n = 1 if (group == 22 | group == 23 | group == 24 | group == 25 | group == 26) &  month_yr >= 139907


keep if year >= 1399

/// nima_t_n

/// nima_t_n import 
egen nima_t_n_im = total(nima_t_n*realvalue_million), by(year)

///nima_t_n intermediate & capital & consumption goods
egen im_inter_nima_t_n  = total(nima_t_n*realvalue_million*intermadiate), by(year)
egen im_cons_nima_t_n   = total(nima_t_n*realvalue_million*consumption), by(year)
egen im_capital_nima_t_n = total(nima_t_n*realvalue_million*capital), by(year)
egen im_not_nima_t_n    = total(nima_t_n*realvalue_million*not_classified), by(year)

gen im_inter_nima_t_n_s   = (im_inter_nima_t_n/nima_t_n_im)*100
gen im_cons_nima_t_n_s    = (im_cons_nima_t_n/nima_t_n_im)*100
gen im_capital_nima_t_n_s = (im_capital_nima_t_n/nima_t_n_im)*100
gen im_not_nima_t_n_s     = (im_not_nima_t_n/nima_t_n_im)*100

collapse im_inter_nima_t_n_s im_cons_nima_t_n_s im_capital_nima_t_n_s im_not_nima_t_n_s, by(tariff nima_t_n year)

label variable im_inter_t_s   "intermadiate"
label variable im_cons_t_s    "consumption"
label variable im_capital_t_s "capital"
gen year_m = year + 621

graph set window fontface "Times New Roman"

graph bar im_inter_nima_t_n_s  im_cons_nima_t_n_s im_capital_nima_t_n_s, over(year_m) stack ///
    bar(1, color(ltblue)) ///
    bar(2, color(maroon%70)lpattern(dot) lwidth(medium)) ///
    bar(3, color(navy) lpattern(dash)) ///
    legend(order(1 "intermadiate" 2 "consumption" 3 "capital") rows(1) position(6)) /// 
    ytitle("Import share by commodity group under NIMA_negotiated rate (%)") ///  
    ylabel(0(10)100)

graph export "NIMA_negotiated_c_ii.png", as(png) replace width(2000) height(1200)	
	
/// total import is total import in intermadiate & capital & consumption goods
clear

cd "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\22"
use "im_reg.dta"

gen nima = 0
replace nima = 1 if  (group == 2 | group == 21 | group == 22 | group == 23 ) & month_yr >= 139702 & month_yr < 139907
replace nima = 1 if (group == 21 | group == 2) & month_yr >= 139907
gen nima_t_n = 0
replace nima_t_n = 1 if (group == 22 | group == 23 | group == 24 | group == 25 | group == 26) &  month_yr >= 139907
replace nima_t_n = 1 if ( group == 24 | group == 25 | group == 26 ) & month_yr >= 139702 & month_yr < 139907
keep if year>= 1397

/// personal_currency
gen person = 0
replace person = 1 if ( group == 27 | group == 3 | group == 0  & month_yr >= 139701)
gen subsidy = 0
replace subsidy = 1 if group == 1 & month_yr >= 139702
replace subsidy = 0 if month_yr >= 140105 & month_yr<= 140110
/// total import
egen inter_im = total(intermadiate*realvalue_million), by(month_yr)
egen cons_im = total(consumption*realvalue_million), by(month_yr)
egen capital_im = total(capital*realvalue_million), by(month_yr)

/// preferential intermediate & capital & consumption goods
egen im_inter_preferential = total(subsidy*realvalue_million*intermadiate), by(month_yr)
egen im_cons_preferential = total(subsidy*realvalue_million*consumption), by(month_yr)
egen im_capital_preferential = total(subsidy*realvalue_million*capital), by(month_yr)
egen im_not_preferential = total(subsidy*realvalue_million*not_classified), by(month_yr)

/// nima intermediate & capital & consumption goods
egen im_inter_nima = total(nima*realvalue_million*intermadiate), by(month_yr)
egen im_cons_nima = total(nima*realvalue_million*consumption), by(month_yr)
egen im_capital_nima = total(nima*realvalue_million*capital), by(month_yr)
egen im_not_nima = total(nima*realvalue_million*not_classified), by(month_yr)

/// personal intermediate & capital & consumption goods
egen im_inter_p = total(person*realvalue_million*intermadiate), by(month_yr)
egen im_cons_p = total(person*realvalue_million*consumption), by(month_yr)
egen im_capital_p = total(person*realvalue_million*capital), by(month_yr)
egen im_not_p = total(person*realvalue_million*not_classified), by(month_yr)


/// sana intermediate & capital & consumption goods
egen im_inter_nima_t_n = total(nima_t_n*realvalue_million*intermadiate), by(month_yr)
egen im_cons_nima_t_n = total(nima_t_n*realvalue_million*consumption), by(month_yr)
egen im_capital_nima_t_n = total(nima_t_n*realvalue_million*capital), by(month_yr)
egen im_not_nima_t_n = total(nima_t_n*realvalue_million*not_classified), by(month_yr)

/// share which currency from total import goods
gen im_inter_preferential_s = (im_inter_preferential/inter_im)*100
gen im_inter_nima_s = (im_inter_nima/inter_im)*100 + im_inter_preferential_s
gen im_inter_s_s =(im_inter_nima_t_n/inter_im)*100 + im_inter_nima_s
gen im_inter_p_s = (im_inter_p/inter_im)*100 + im_inter_s_s

gen im_cons_preferential_s = (im_cons_preferential/cons_im)*100
gen im_cons_nima_s =(im_cons_nima/cons_im)*100 + im_cons_preferential_s 
gen im_cons_s_s = (im_cons_nima_t_n/cons_im)*100 + im_cons_nima_s
gen im_cons_p_s = (im_cons_p/cons_im)*100 + im_cons_s_s

gen im_capital_preferential_s = (im_capital_preferential/capital_im)*100
gen im_capital_nima_s = (im_capital_nima/capital_im)*100 + im_capital_preferential_s
gen im_capital_s_s = (im_capital_nima_t_n/capital_im)*100 + im_capital_nima_s
gen im_capital_p_s = (im_capital_p/capital_im)*100 + im_capital_s_s


collapse im_inter_s_s im_capital_s_s im_cons_s_s im_inter_preferential_s im_inter_nima_s im_inter_p_s im_cons_preferential_s im_cons_nima_s im_cons_p_s im_capital_preferential_s im_capital_nima_s im_capital_p_s, by(month_year)

/// intermediate
twoway ///
    (area im_inter_p_s month_year, fcolor(ltblue) lcolor(navy%10)) ///
	(area im_inter_s_s month_year, fcolor(gs8) lpattern(O) lcolor(black%50)) ///
    (area im_inter_nima_s month_year, fcolor(maroon%60) lpattern(dot) lcolor(green%25)) ///
    (area im_inter_preferential_s month_year, fcolor(navy) lcolor(maroon%20)), ///
    xlabel(`=tm(1397m1)'(3)`=tm(1402m12)', angle(75)) ///
    legend(order(1 "Personal" 2 "NIMA_negotiated" 3 "NIMA" 4 "preferential") ///  
           position(6) ring(1) col(2) size(small)) ///
    ytitle("Currency share in intermediate goods imports (%)") ///    
    xtitle("")
graph export "intermediate.png", as(png) replace

/// consumption

twoway ///
    (area im_cons_p_s month_year, fcolor(ltblue) lcolor(navy%10)) ///
	(area im_cons_s_s month_year, fcolor(gs8) lpattern(O) lcolor(black%50)) ///
    (area im_cons_nima_s month_year, fcolor(maroon%60) lpattern(dot) lcolor(green%25)) ///
    (area im_cons_preferential_s month_year, fcolor(navy) lcolor(maroon%20)), ///
    xlabel(`=tm(1397m1)'(3)`=tm(1402m12)', angle(75)) ///
    legend(order(1 "Personal" 2 "NIMA_negotiated" 3 "NIMA" 4 "preferential") ///  
           position(6) ring(1) col(2) size(small)) ///
    ytitle("Currency share in consumption goods imports (%)") ///    
    xtitle("")
graph export "consumption.png", as(png) replace   	
	

/// capital
twoway ///
    (area im_capital_p_s month_year, fcolor(ltblue) lcolor(navy%10)) ///
	(area im_capital_s_s month_year, fcolor(gs8) lpattern(O) lcolor(black%50)) ///
    (area im_capital_nima_s month_year, fcolor(maroon%60) lpattern(dot) lcolor(green%25)) ///
    (area im_capital_preferential_s month_year, fcolor(navy) lcolor(maroon%20)), ///
    xlabel(`=tm(1397m1)'(3)`=tm(1402m12)', angle(75)) ///
	legend(order(1 "Personal" 2 "NIMA_negotiated" 3 "NIMA" 4 "preferential") ///  
           position(6) ring(1) col(2) size(small)) ///
    ytitle("Currency share in capital goods imports (%)") ///   
    xtitle("")
graph export "capital.png", as(png) replace    

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/// Exchange rate 
clear
cd "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\22\im_reg.dta"

use "data_EX.dta"

/// growth rate of which currency
. gen g_exchange_perf = ((exchangerate - exchangerate[_n-1])/ exchangerate[_n-1])*100

. gen g_exchange_nima = (( exchangeratenima - exchangeratenima[_n-1])/ exchangeratenima[_n-1])*100


. gen g_exchangerate_market  = (( exchangerate_m - exchangerate_m[_n-1])/ exchangerate_m[_n-1])*100
preserve
keep if year>= 1394


/// growth rate of which currency graph
twoway (line g_exchangerate_market g_exchange_nima month_year, lcolor(green%75 blue)) ///
       (scatter g_exchangerate_market month_year, msymbol(O) mcolor(green%25)), /// 
       ytitle("Currency growth rate (%)", axis(1)) /// 
       xlabel(`=tm(1394m1)'(12)`=tm(1402m12)', angle(75)) /// 
	   ylabel(-20(10)40) ///
       legend(order( 2 "NIMA currency" 3 "free-market currency") ///
              position(6) ring(1) col(1) size(small)) /// 
       xtitle("")
graph export "marketEXand nimaEX.png", as(png) replace width(2000) height(1200)	  
restore

//// graph
twoway (line premium_ex month_year, lcolor(green)) ///
    ,xline(`=ym(1391,3)', lcolor(blue) lpattern(dash)) ///
    text(95 `=ym(1391,3)' "Intensification of Sanctions", place(w) angle(30)) ///
    xline(`=ym(1397,2)', lcolor(blue) lpattern(dash)) ///
    text(95 `=ym(1397,2)' "Allocation of 4200 Toman Preferential Currency", place(w) angle(90)) ///
    xline(`=ym(1401,3)', lcolor(blue) lpattern(dash)) ///
    text(65 `=ym(1401,3)' "Removal of Preferential Currency", place(w) angle(90)) ///
    xline(`=ym(1401,11)', lcolor(blue) lpattern(dash)) ///
    text(95 `=ym(1401,11)' "Preferential Currency at 28,500 Toman", place(w) angle(90)) ///
    xlabel(`=tm(1390m1)'(12)`=tm(1402m12)', angle(75)) ///
    ytitle("Gap in Official Exchange Rate") /// 
    ylabel(0(10)100) ///
    xtitle("")

graph export "sanction and explain.png", as(png) replace width(2000) height(1200)	 

/////////////////////////////////////
clear
use "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\22\im_reg.dta"

gen year_m = year + 621
gen month_m = month + 3

gen month_year_m=ym(year_m,month_m)
format month_year_m %tm

collapse premium_ex realvalue_million, by( month_year group tariff year_m month)
gen group_s = substr(tariff, 1, 3)

destring group_s, replace
format group_s %03.0f


/// seasonal data to Reduced fluctuations
gen quarter = ceil(month / 3)


gen quarter_yr = year_m * 100 + quarter

gen quarter_year=yq(year_m,quarter)
format quarter_year %tq
//// total preferential and nima by group

egen im_g = total( realvalue_million ), by(quarter_year group_s )

egen im_tar = total( realvalue_million) if group ==1, by( quarter_year group_s)
egen im_nima = total( realvalue_million ) if group != 1, by( quarter_year group_s)

gen im_tar_g = im_tar/im_g * 100
gen im_nima_g = im_nima/im_g*100
egen premiun_ex_q = mean(premium_ex), by(quarter_year)
keep if year >= 1395
/// some graphs
twoway /// 
    (bar im_tar_g quarter_year if inlist(group_s, 230), /// 
        yaxis(1) barwidth(0.8) color(gs12)) /// 
    (line premiun_ex_q quarter_year, /// 
        lcolor(navy) lpattern(shortdash) lwidth(thick)), /// 
    ytitle("Feed Import Share & Gap (%)", axis(1)) /// 
    xlabel(#20, format(%tq) angle(45)) /// 
    legend(order(1 "Feed Import Share" /// 
                 2 "Exchange Rate Gap") /// 
           position(6) ring(1) col(2) size(small)) /// 
    xtitle("") 

graph export "feed_import.png", as(png) replace width(2000) height(1200) 

// Pharmaceuticals - Group 300
twoway /// 
    (bar im_tar_g quarter_year if group_s==300, yaxis(1) barwidth(0.8) color(gs12)) /// 
    (line premiun_ex_q quarter_year, lcolor(navy) lpattern(shortdash) lwidth(thick)), /// 
    ytitle("Pharma Import Share & Gap (%)", axis(1)) /// 
    xlabel(#20, format(%tq) angle(45)) /// 
    legend(order(1 "Pharma Import Share" 2 "Exchange Rate Gap") /// 
           position(6) ring(1) col(2) size(small)) /// 
    xtitle("") 

graph export "pharmaceuticals.png", as(png) replace width(2000) height(1200)

twoway /// 
    (bar im_tar_g quarter_year if inlist(group_s, 901,902), yaxis(1) barwidth(0.8) color(gs12)) /// 
    (line premiun_ex_q quarter_year, lcolor(navy) lpattern(shortdash) lwidth(thick)), /// 
    ytitle("Med. Equip. Import Share & Gap (%)", axis(1)) /// 
    xlabel(#20, format(%tq) angle(45)) /// 
    legend(order(1 "Med. Equip. Import Share" 2 "Exchange Rate Gap") /// 
           position(6) ring(1) col(2) size(small)) /// 
    xtitle("") 

graph export "medical_equipment.png", as(png) replace width(2000) height(1200)

/// Seeds
keep if year_m >= 2015
twoway /// 
    (bar im_tar_g quarter_year if inlist(group_s, 120), yaxis(1) barwidth(0.8) color(gs12)) /// 
    (line premiun_ex_q quarter_year, lcolor(navy) lpattern(shortdash) lwidth(thick)), /// 
    ytitle("Seed Import Share & Gap (%)", axis(1)) /// 
    xlabel(#20, format(%tq) angle(45)) /// 
    legend(order(1 "Seed Import Share" 2 "Exchange Rate Gap") /// 
           position(6) ring(2) col(1) size(small)) /// 
    xtitle("") 

graph export "seeds.png", as(png) replace width(2000) height(1200)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////****

***********************************************************************************

clear
use "E:\Signinid Dropbox\Mobina Shojaee\Shojaei's Thesis Project\Data\Do\22\im_reg.dta"

keep if year>= 1397
gen subsidy = 0
replace subsidy = 1 if group == 1 & month_yr >= 139702
/// nima import 
egen nima_im = total(nima*realvalue_million), by(year)
egen targihi_im = total(subsidy*realvalue_million),by(year)

//// calculate which goods share of preferential rate
egen oil_im_t = total(subsidy*realvalue_million) if substr(tariff,1,2) == "15",by(year)

gen oil_share = (oil_im_t/targihi_im)*100
///
egen drog_im_t = total(subsidy*realvalue_million) if substr(tariff,1,2) == "30",by(year)

gen drog_share = (drog_im_t/targihi_im)*100
///
egen animal_feed = total(subsidy*realvalue_million) if substr(tariff,1,2) == "23",by(year)
gen animal_feed_share = (animal_feed/targihi_im)*100
/////////////
egen medecine_eq = total(subsidy*realvalue_million) if (substr(tariff,1,3) == "901" | substr(tariff,1,3) == "902"),by(year)
gen medecine_eq_share =(medecine_eq/targihi_im)*100
////
egen barley = total(subsidy*realvalue_million) if substr(tariff,1,4) == "1003",by(year)
gen barley_share = (barley/targihi_im)*100
////
egen corn = total(subsidy*realvalue_million) if substr(tariff,1,4) == "1005",by(year)
gen corn_share = (corn/targihi_im)*100

egen seed = total(subsidy*realvalue_million) if substr(tariff,1,3) == "120",by(year)
gen seed_share = (seed/targihi_im)*100

egen pesticide= total(subsidy*realvalue_million) if substr(tariff,1,2) == "38",by(year)
gen pesticie_share = (pesticide/targihi_im)*100


egen rice = total(subsidy*realvalue_million) if substr(tariff,1,4) == "1006",by(year)
gen rice_share = (rice/targihi_im)*100

egen sheep = total(subsidy*realvalue_million) if substr(tariff,1,2) == "01",by(year)
gen sheep_share = (sheep/targihi_im)*100


egen chemical = total(subsidy*realvalue_million) if substr(tariff,1,2) == "29",by(year)
gen chemical_share = (chemical/targihi_im)*100


egen bean = total(subsidy*realvalue_million) if substr(tariff,1,2) == "07",by(year)
gen bean_share = (sheep/targihi_im)*100

egen meat = total(subsidy*realvalue_million) if substr(tariff,1,2) == "02",by(year)
gen meat_share = (meat/targihi_im)*100
egen other = total(subsidy*realvalue_million) if (substr(tariff,1,2) == "04" | substr(tariff,1,2) == "37" | substr(tariff,1,2) == "17" | substr(tariff,1,2) == "40" | substr(tariff,1,2) == "41" | substr(tariff,1,2) == "31" | substr(tariff,1,2) == "48" | substr(tariff,1,2) == "84" | substr(tariff,1,2) == "85" | substr(tariff,1,2) >= "50" & substr(tariff,1,2) < "84"), by(year)
gen other_share = (other/targihi_im)*100



collapse rice_share seed_share pesticie_share sheep_share meat_share chemical_share other_share bean_share oil_share barley_share medecine_eq_share corn_share animal_feed_share drog_share premium_ex,by(year)
//////////////////////////
///////////////////////////////////////////stack graph of some important eligible for preferential exchange rate goods
////////////////////////////////////
graph bar corn_share medecine_eq_share oil_share drug_share animal_feed_share barley_share seed_share pesticide_share other_share, over(year) stack /// 
    bar(1, color(ltblue)) /// 
    bar(2, color(maroon%70) lpattern(dot) lwidth(medium)) /// 
    bar(3, color(navy) lpattern(dash)) /// 
    bar(4, color(forest_green%60) lpattern(dot) lwidth(medium)) /// 
    bar(5, color(gray%50) lpattern(solid)) /// Feed & Animal Products
    bar(6, color(purple%60) lpattern(dash)) /// Barley
    bar(7, color(slateblue%60)) /// Seeds
    legend(order(1 "Corn" 2 "Medical Equipment" 3 "Oil" 4 "Drugs" 5 "Animal Feed" 6 "Barley" 7 "Seeds" 8 "Chemicals" 9 "Other Goods") rows(2) position(6)) ///
    ytitle("Share of Each Item in Total Preferential Currency Imports (%)") /// 
    ylabel(0(10)100)

	
graph export "share_m_o_Corn_drg_share_new.png", as(png) replace width(2000) height(1200)	