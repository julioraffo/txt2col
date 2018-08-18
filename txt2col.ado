*! version 0.1 J.D. Raffo April 2017
cap program drop txt2col
program txt2col
 version 14
 syntax varlist(string min=1)[, Delim(string) Regexout(string) Vardelim(varname string)]

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
	 cap drop `myvar'_*
	 if (`varflag'==0) {
	  cap drop `vardelim' 
	  if (`regexflag'==1) gen `vardelim'=ustrregexra(`myvar', `"`regexout'"',"",1)
		else gen `vardelim'=ustrregexra(`myvar', `"[^`delim']"',"",1)
	 }
	 gen `tmpq'=ustrlen(`vardelim')
	 qui sum `tmpq'
	 loc mymax=`r(max)'
	 if `mymax'>0 {
 	  gen `tmpl'=1
	  gen `tmpu'=.
		forv x = 1 (1) `mymax' {
		 replace `tmpu' = ustrpos(`myvar',usubstr(`vardelim',`x',1),`tmpl')-`tmpl'
		 replace `tmpu' =. if `tmpu'<=0
		 gen `myvar'_`x'=usubstr(`myvar', `tmpl', `tmpu') if `tmpl'!=.
		 replace `tmpl'=`tmpl'+`tmpu'+1 		 
		}
		loc mymax=`mymax'+1
		gen `myvar'_`mymax'=usubstr(`myvar', `tmpl',.) if `tmpl'!=.
	 }
 }
restore, not 
end
 
