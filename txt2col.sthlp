{smcl}
{* *! version 1.0  April2017}{...}
{vieweralsosee "matchit (if installed)" "help matchit"}{...}
{vieweralsosee "freqindex (if installed)" "help freqindex"}{...}
{vieweralsosee "cleanchars (if installed)" "help cleanchars"}{...}
{viewerjumpto "Syntax" "txt2col##syntax"}{...}
{viewerjumpto "Description" "txt2col##description"}{...}
{viewerjumpto "Options" "txt2col##options"}{...}
{viewerjumpto "Examples" "txt2col##examples"}{...}
{marker Top}{...}
{title:Title}

{p2colset 2 18 20 2}{...}
{p2col :txt2col {hline 1}} 
Splits one or more variables into several columns (new variables)
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 5 15}
{cmd:txt2col} {it: {help varlist}} {it:[{help if}]} {it:[{help in}]} [, {opt d:elim(string)} {opt r:egexout(string)} {opt v:ardelim(string)} ]
{p_end}


{marker examples}{...}
{title:Examples:}

{phang2}{cmd:. txt2col} {it:mytxtvar}, d(",") {p_end}
{phang2}{cmd:. txt2col} {it:mytxtvar}, r("[^,;|]") {p_end}
