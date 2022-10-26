%macro NeedleWunschDist(refSize,inSize,cutoff,maxobs,G,rel=N);
array NWRef[&refSize] $1;
array NWIn[&inSize] $1;
array NWMatrix[&refSize,&inSize] 8;
do m = 1 to length(i) + 1;
	NWMatrix[m,1] = m - 1;
	if m <= length(i) then NWIn[m] = substr(i,m,1);
end;
do n = 1 to length(r) + 1;
	NWMatrix[1,n] = n - 1;
	if n <= length(r) then NWRef[n] = substr(r,n,1);
end;
drop m n;
do z = 2 to length(i) + 1;
	do x = 2 to length(r) + 1;	
		if NWRef[z-1] = NWIn[x-1] then cost = 0; else cost = 1;
		NWMatrix[z,x] = min(
					NWMatrix[z-1,x]+&G,
					NWMatrix[z,x-1]+&G,
					NWMatrix[z-1,x-1] + cost
					);
		NWCosts = NWMatrix[z,x];
	end;
end;
drop z x cost;
NWScore = 1 - NWCosts / max(length(i),length(r));
if NWScore >= &cutoff then NWFlag = 1; else NWFlag = 0;
%do n = 1 %to &refSize;
	drop NWRef&n NWIn&n;
%end;
%do m = 1 %to %eval(&refSize * &inSize);
	drop NWMatrix&m;
%end;
%if &rel ^= "N" %then %do;
	%put tohle je klic: &rel;
	%ConfMatrix(NW,rel=&rel);
%end;
attrib 
NWFlag label = "Needleman-Wunschova vzdálenost - pøíznak podobnosti"
NWCosts label = "Needleman-Wunschova vzdálenost - kalkulované náklady"
NWScore label = "Needleman-Wunschova vzdálenost - kalkulované skóre"
;
%mend NeedleWunschDist;