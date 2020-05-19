*! version 0.2111 J.D. Raffo August 2018
cap program drop txt2col
program txt2col
 version 14
 syntax varlist(string min=1) [if] [in] [, Delim(string) Regexout(string) Vardelim(varname string) NOREPlace Bundle(integer 1)]
 marksample touse , novarlist strok
 qui count if `touse'
 loc myN = `r(N)'
 if (`r(N)'==0){
  di "No observations to parse"
  error 2000
 }
 
 // setup //////////////////////////////////////
 preserve
 if (`bundle'<1) loc bundle=1
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
    else {
     if (ustrregexm(`"`delim'"',`"[`delim']"',1)!=1) gen `vardelim'=ustrregexra(`myvar', `"[^\\`delim']"',"",1) if `touse'
     else gen `vardelim'=ustrregexra(`myvar', `"[^`delim']"',"",1) if `touse'
    }
   }
   gen `tmpq'=ustrlen(`vardelim') if `touse'
   qui sum `tmpq' if `touse'
   loc mymax=`r(max)'
   if `mymax'>0 {
    gen `tmpl'=1 if `touse'
    gen `tmpu'=. if `touse'
    loc varnum = 1
		cap replace `myvar'_`varnum'="" if `tmpl'!=. & `touse'
    forv x = 1 (1) `mymax' {
     loc cur = `x'/`bundle'
     replace `tmpu' = ustrpos(`myvar',usubstr(`vardelim',`x',1),`tmpl')-`tmpl' if `touse'
     replace `tmpu' =. if `tmpu'<=0 & `touse'
     cap replace `myvar'_`varnum'=cond(`myvar'_`varnum'!="",`myvar'_`varnum' + usubstr(`myvar', `tmpl'-1, `tmpu'+1), usubstr(`myvar', `tmpl', `tmpu')) if `tmpl'!=. & `touse'
		 cap gen `myvar'_`varnum'=usubstr(`myvar', `tmpl', `tmpu') if `tmpl'!=. & `touse'
     replace `tmpl'=`tmpl'+`tmpu'+1 if `touse'      
     if (`cur'==int(`cur')) {
		  loc varnum = `varnum' + 1
      cap replace `myvar'_`varnum'="" if `tmpl'!=. & `touse'
		 }
		}
    // handles last bit
		loc cur = (`mymax'+1)/`bundle'
    if (`cur'==(int(`cur')+1/`bundle')) {
		 loc varnum = `varnum' + 1 
     cap replace `myvar'_`varnum'="" if `tmpl'!=. & `touse'
    }		
	  cap replace `myvar'_`varnum' = cond(`myvar'_`varnum'!="",`myvar'_`varnum' + usubstr(`myvar', `tmpl'-1, .), usubstr(`myvar', `tmpl', .)) if `tmpl'!=. & `touse'
		cap gen `myvar'_`varnum'=usubstr(`myvar', `tmpl',.) if `tmpl'!=. & `touse'    
   }
 }
restore, not 
di "(`myN' observations processed)"
end
 
