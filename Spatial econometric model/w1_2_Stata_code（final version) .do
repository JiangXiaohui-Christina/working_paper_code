
**Date: 2020/05/21
**Purpose: replicate the spatial model in codes_w1-2.R
**please install splavar, spatwmat, spmat, xsmle, spc2xt, logout at first
clear all
set more off
set memory 100m

*注意变量名称大小写
*change working dictionary
*cd "/Users/jiang/Desktop/Analysis(20140322onward)/w1-2"
cd "/Users/tinchan/Desktop/AIT Research/天/Philippines/Analysis(20140322onward)/w1-2"
*import the spatial matrix
import delimited w1-2_matrix.csv, clear
drop v1
drop in 1
save w1-2_matrix.dta, replace
forvalues i = 2(1)141 {
  replace v`i'=1 if v`i'>0
          }
save w1-2_original_matrix.dta, replace
mkmat v2-v141,matrix(W1)  //using mkmat to create matrix for durbin model
spatwmat using w1-2_original_matrix.dta, name(W2) standardize //using spmatwmat to create a matrix
 

*import data
import excel "Bohol_Game_demog_DB_w1-2.xlsx", sheet("IR") firstrow clear


*irrigated sample 


*Spatial Durbin Model(SEM): OLS estimation 
*ols1<- lm(di2~Wvolume+WAge+WGender+WEducation+Wln_as+WFA2+Whhsize+Wfemale_ratio+volume+Age+Gender+Education+ln_as+FA2+hhsize+female_ratio, data=data)

*create Wvolume WAge WGender WEducation Wln_as WFA2 Whhsize Wfemale_ratio
mkmat volume Age Gender Education ln_as FA2 hhsize female_ratio //convert variable to matrix 
mat Wvolume = W1*volume 

//注意前后顺序，矩阵乘法定义前一个矩阵的列数必须等于后一个矩阵的行数，W：140*140，volume:140*1
svmat Wvolume , names(Wvolume) //Create variables from matrix
rename Wvolume1 Wvolume


mat WAge = W1*Age
svmat WAge, names(WAge)
rename WAge1 WAge

mat WGender = W1*Gender
svmat WGender, names(WGender)
rename WGender1 WGender

mat WEducation = W1*Education
svmat WEducation, names(WEducation)
rename WEducation1 WEducation

mat Wln_as = W1*ln_as
svmat Wln_as, names(Wln_as)
rename Wln_as1 Wln_as

mat WFA2 = W1*FA2
svmat WFA2, names(WFA2)
rename WFA21 WFA2

mat Whhsize = W1*hhsize
svmat Whhsize, names(Whhsize)
rename Whhsize1 Whhsize

mat Wfemale_ratio = W1*female_ratio
svmat Wfemale_ratio, names(Wfemale_ratio)
rename Wfemale_ratio1 Wfemale_ratio
*run regression 
reg di2 Wvolume WAge WGender WEducation Wln_as WFA2 Whhsize Wfemale_ratio volume Age Gender Education ln_as FA2 hhsize female_ratio, robust
spatdiag, weights(W2)
*test for spatial dependence 
reg di2 volume Age Gender Education ln_as FA2 hhsize female_ratio, robust
spatdiag, weights(W2)

*ols2a<-lm(pgp1r2~Wvolume+WAge+WGender+WEducation+Wln_as+WFA2+Whhsize+Wfemale_ratio+volume+Age+Gender+Education+ln_as+FA2+hhsize+female_ratio+ri0)
reg pgp1r2 Wvolume WAge WGender WEducation Wln_as WFA2 Whhsize Wfemale_ratio volume Age Gender Education ln_as FA2 hhsize female_ratio ri0, robust
spatdiag, weights(W2)
*test for spatial dependence 
reg pgp1r2 volume Age Gender Education ln_as FA2 hhsize female_ratio ri0, robust
spatdiag, weights(W2)

*ols2b<-lm(pgp2r2~Wvolume+WAge+WGender+WEducation+Wln_as+WFA2+Whhsize+Wfemale_ratio+volume+Age+Gender+Education+ln_as+FA2+hhsize+female_ratio+ri0+pgp1rrd+pgp1_fr1+frxrr1d+pgp1r2)
reg pgp2r2 Wvolume WAge WGender WEducation Wln_as WFA2 Whhsize Wfemale_ratio volume Age Gender Education ln_as FA2 hhsize female_ratio ri0 pgp1rrd pgp1_fr1 frxrr1d pgp1r2, robust
spatdiag, weights(W2)
*test for spatial dependence 
reg pgp2r2 volume Age Gender Education ln_as FA2 hhsize female_ratio ri0, robust
spatdiag, weights(W2)




*for spatial regression 
clear all
set more off
set memory 100m

*注意变量名称大小写
*change working dictionary
*cd "/Users/jiang/Desktop/Analysis(20140322onward)/w1-2
*cd "/Users/jiang/Desktop/Analysis(20140322onward)/w1-2"
*import the spatial matrix
import delimited w1-2_matrix.csv, clear
drop v1
drop in 1
save w1-2_matrix.dta, replace
mkmat v2-v141,matrix(W1)  //using mkmat to create matrix for durbin model
*w1-2_matrix_1.csv is the csv files based on w1-2_matrix.csv but the first rows are the number of rows in order to be identified by spmatrix.
*this code download from https://www.statalist.org/forums/forum/general-stata-discussion/general/1379989-spmat-import-csv-files?_=1490372754709 to deal with the error occuring when running spmat 
import delimited w1-2_matrix.csv, clear
drop in 1
count
local N = r(N)
insobs 1, before(1)
replace v1 = `N' in 1
count
local N = r(N)
forvalues i=2/`N' {
    qui replace v`i' = 0 in `i'
}
export delimited w1-2_matrix_1.csv, replace novarnames delimit(" ")
clear all

spmatrix import W3 using  w1-2_matrix_1.csv


*import data
import excel "Bohol_Game_demog_DB_w1-2.xlsx", sheet("IR") firstrow clear


*Spatial Error and Spatial lag (ML)
spset POLY_ID
spregress di2 volume Age Gender Education ln_as FA2 hhsize female_ratio, ml dvarlag(W3) ivarlag(W3:volume Age Gender Education ln_as FA2 hhsize female_ratio) vce(robust)
*errmd1<-errorsarlm(di2~Wvolume+WAge+WGender+WEducation+Wln_as+WFA2+Whhsize+Wfemale_ratio+volume+Age+Gender+Education+ln_as+FA2+hhsize+female_ratio, data=data, spmatrix, method="eigen", zero.policy=TRUE)
spregress di2 volume Age Gender Education ln_as FA2 hhsize female_ratio, ml errorlag(W3) ivarlag(W3:volume Age Gender Education ln_as FA2 hhsize female_ratio) vce(robust)
*ARAR1<-sacsarlm(di2~Wvolume+WAge+WGender+WEducation+Wln_as+WFA2+Whhsize+Wfemale_ratio+volume+Age+Gender+Education+ln_as+FA2+hhsize+female_ratio,data=data,spmatrix, 
spregress di2 volume Age Gender Education ln_as FA2 hhsize female_ratio, ml dvarlag(W3) errorlag(W3) ivarlag(W3:volume Age Gender Education ln_as FA2 hhsize female_ratio) vce(robust)
*Model without WX variables
spregress di2 volume Age Gender Education ln_as FA2 hhsize female_ratio, ml dvarlag(W3) errorlag(W3) vce(robust)




*Spatial Error and Spatial lag (gs2sls)


//gs2sls with first order instrumental variable (WX)
spregress di2 volume Age Gender Education ln_as FA2 hhsize female_ratio, gs2sls dvarlag(W3) ivarlag(W3:volume Age Gender Education ln_as FA2 hhsize female_ratio) impower(1)
*errmd1<-errorsarlm(di2~Wvolume+WAge+WGender+WEducation+Wln_as+WFA2+Whhsize+Wfemale_ratio+volume+Age+Gender+Education+ln_as+FA2+hhsize+female_ratio, data=data, spmatrix, method="eigen", zero.policy=TRUE)
spregress di2 volume Age Gender Education ln_as FA2 hhsize female_ratio, gs2sls errorlag(W3) ivarlag(W3:volume Age Gender Education ln_as FA2 hhsize female_ratio) impower(1)
*ARAR1<-sacsarlm(di2~Wvolume+WAge+WGender+WEducation+Wln_as+WFA2+Whhsize+Wfemale_ratio+volume+Age+Gender+Education+ln_as+FA2+hhsize+female_ratio,data=data,spmatrix, 
spregress di2 volume Age Gender Education ln_as FA2 hhsize female_ratio, gs2sls dvarlag(W3) errorlag(W3) ivarlag(W3:volume Age Gender Education ln_as FA2 hhsize female_ratio) impower(1)
*Model without WX variables
spregress di2 volume Age Gender Education ln_as FA2 hhsize female_ratio, gs2sls dvarlag(W3) errorlag(W3) impower(1)




//gs2sls model with second order instrumental variable (W^2X)
spregress di2 volume Age Gender Education ln_as FA2 hhsize female_ratio, gs2sls dvarlag(W3) ivarlag(W3:volume Age Gender Education ln_as FA2 hhsize female_ratio) impower(2)
*errmd1<-errorsarlm(di2~Wvolume+WAge+WGender+WEducation+Wln_as+WFA2+Whhsize+Wfemale_ratio+volume+Age+Gender+Education+ln_as+FA2+hhsize+female_ratio, data=data, spmatrix, method="eigen", zero.policy=TRUE)
spregress di2 volume Age Gender Education ln_as FA2 hhsize female_ratio, gs2sls errorlag(W3) ivarlag(W3:volume Age Gender Education ln_as FA2 hhsize female_ratio) impower(2)
*ARAR1<-sacsarlm(di2~Wvolume+WAge+WGender+WEducation+Wln_as+WFA2+Whhsize+Wfemale_ratio+volume+Age+Gender+Education+ln_as+FA2+hhsize+female_ratio,data=data,spmatrix, 
spregress di2 volume Age Gender Education ln_as FA2 hhsize female_ratio, gs2sls dvarlag(W3) errorlag(W3) ivarlag(W3:volume Age Gender Education ln_as FA2 hhsize female_ratio) impower(2)
*Model without WX variables 
spregress di2 volume Age Gender Education ln_as FA2 hhsize female_ratio, gs2sls dvarlag(W3) errorlag(W3) impower(2)


