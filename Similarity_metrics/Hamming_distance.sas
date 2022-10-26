/*
refSize = velikost referenčního řetězce
inSize = velikost porovnávaného řetězce
cutoff = prahová hodnota
*/
%macro HammingDist(refSize,inSize,cutoff,maxobs,rel=N);
if length(i) = length(r) then do;
	array HDRef[&refSize] $1;
	array HDIn[&inSize] $1;

	HDCosts = 0;
	do z = 1 to max(length(i),length(r));
		if z <= length(r) then HDRef[z] = substr(r,z,1);
		if z <= length(i) then HDIn[z] = substr(i,z,1);
		if missing(HDRef[z]) = 1 and missing(HDIn[z]) = 1 then HDCosts = HDCosts + 0;
		else if HDRef[z] = HDIn[z] then HDCosts = HDCosts + 0;
		else HDCosts = HDCosts + 1;
	end;
	HDScore = 1 - (HDCosts / length(i));
	if HDScore >= &cutoff then HDFlag = 1; else HDFlag = 0;
end; else HDFlag = 0;
drop z;
%do n = 1 %to &refSize;
	drop HDRef&n HDIn&n;
%end;
%if &rel ^= "N" %then %do;
	%ConfMatrix(HD,rel=&rel);
%end;
attrib 
HDFlag label = "Hammingova vzdálenost - příznak podobnosti"
HDCosts label = "Hammingova vzdálenost - kalkulované náklady"
HDScore label = "Hammingova vzdálenost - kalkulované skóre"
;
%mend HammingDist;