*! version 0.2 J.D. Raffo August 2018
cap program drop txt2col
program txt2col
 version 14
 syntax varlist(string min=1) [if] [in] [, Delim(string) Regexout(string) Vardelim(varname string) NOREPlace ]
 marksample touse , novarlist strok
 qui count if `touse'
 if (`r(N)'==0){
  di "No observations to parse"
  error 2000
 }
 
 // setup //////////////////////////////////////
 preserve
 if (`"`vardelim'"'!=`""') loc varflag=1
 else {
  loc varflag=0
	tempvar vardelim 
 }
 if (`"`regexout'"'!=`""') loc regexflag=1
 else loc regexflag=0
 if (`"`delim'"'==`""' & `regexflag'==0) loc delim=`","'
 tempvar tmpq tmpl tmpu 
 qui foreach myvar of loc varlist {
	 cap drop `tmpq' `tmpl' `tmpu' 
	 if ("`noreplace'"=="") cap drop `myvar'_*
	 if (`varflag'==0) {
	  cap drop `vardelim' 
	  if (`regexflag'==1) gen `vardelim'=ustrregexra(`myvar', `"`regexout'"',"",1) if `touse'
		else gen `vardelim'=ustrregexra(`myvar', `"[^`delim']"',"",1) if `touse'
	 }
	 gen `tmpq'=ustrlen(`vardelim') if `touse'
	 qui sum `tmpq' if `touse'
	 loc mymax=`r(max)'
	 if `mymax'>0 {
 	  gen `tmpl'=1 if `touse'
	  gen `tmpu'=. if `touse'
		forv x = 1 (1) `mymax' {
		 replace `tmpu' = ustrpos(`myvar',usubstr(`vardelim',`x',1),`tmpl')-`tmpl' if `touse'
		 replace `tmpu' =. if `tmpu'<=0 & `touse'
		 cap confirm variable `myvar'_`x'
		 if !_rc {
		  replace `myvar'_`x'=usubstr(`myvar', `tmpl', `tmpu') if `tmpl'!=. & `touse'
		 }
		 else {
		  gen `myvar'_`x'=usubstr(`myvar', `tmpl', `tmpu') if `tmpl'!=. & `touse'
		 }
		 replace `tmpl'=`tmpl'+`tmpu'+1 if `touse' 		 
		}
		loc mymax=`mymax'+1
        cap confirm variable `myvar'_`mymax'
		 if !_rc {
		  replace `myvar'_`mymax'=usubstr(`myvar', `tmpl',.) if `tmpl'!=. & `touse'
		 }
		 else {
		  gen `myvar'_`mymax'=usubstr(`myvar', `tmpl',.) if `tmpl'!=. & `touse'
		 }
	 }
 }
restore, not 
end
 
