%macro SmithWatermanDist(refSize,inSize,cutoff,maxobs,G,rel=N);
array SWRef[&refSize] $1;
array SWIn[&inSize] $1;
array SWMatrix[&refSize,&inSize] 8;
do m = 1 to length(i) + 1;
	SWMatrix[m,1] = m - 1;
	if m <= length(i) then SWIn[m] = substr(i,m,1);
end;
do n = 1 to length(r) + 1;
	SWMatrix[1,n] = n - 1;
	if n <= length(r) then SWRef[n] = substr(r,n,1);
end;
drop m n;
do z = 2 to length(i) + 1;
	do x = 2 to length(r) + 1;	
		if SWRef[z-1] = SWIn[x-1] then cost = 0; else cost = 1;
		SWMatrix[z,x] = min(
					SWMatrix[z-1,x]-&G,
					SWMatrix[z,x-1]-&G,
					SWMatrix[z-1,x-1] - cost
					);
		SWCosts = SWMatrix[z,x];
	end;
end;
drop z x cost;
SWScore = 1 - SWCosts / max(length(i),length(r));
if SWScore >= &cutoff then SWFlag = 1; else SWFlag = 0;
%do n = 1 %to &refSize;
	drop SWRef&n SWIn&n;
%end;
%do m = 1 %to %eval(&refSize * &inSize);
	drop SWMatrix&m;
%end;
%if &rel ^= "N" %then %do;
	%put tohle je klic: &rel;
	%ConfMatrix(SW,rel=&rel);
%end;
attrib 
SWFlag label = "Smith-Watermanova vzdálenost - příznak podobnosti"
SWCosts label = "Smith-Watermanova vzdálenost - kalkulované náklady"
SWScore label = "Smith-Watermanova vzdálenost - kalkulované skóre"
;
%mend SmithWatermanDist;