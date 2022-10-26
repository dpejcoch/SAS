%macro DamLevDist(refSize,inSize,cutoff,maxobs,rel=N);
array DLRef[&refSize] $1;
array DLIn[&inSize] $1;
array DLMatrix[&refSize,&inSize] 8;
do m = 1 to length(i) + 1;
	DLMatrix[m,1] = m - 1;
	if m <= length(i) then DLIn[m] = substr(i,m,1);
end;
do n = 1 to length(r) + 1;
	DLMatrix[1,n] = n - 1;
	if n <= length(r) then DLRef[n] = substr(r,n,1);
end;
drop m n;
do z = 2 to length(i) + 1;
	do x = 2 to length(r) + 1;	
		if DLRef[z-1] = DLIn[x-1] then cost = 0; else cost = 1;
		DLMatrix[z,x] = min(
					DLMatrix[z-1,x]+1,
					DLMatrix[z,x-1]+1,
					DLMatrix[z-1,x-1] + cost
					);
	/* specificka forma zohledneni preklepu */	
		if(z > 2 and x > 2 and DLRef[z] = DLIn[x-1] and DLRef[z-1] = DLIn[x]) then
               DLMatrix[z,x] = min(
                                DLMatrix[z,x],
                                DLMatrix[z-2, x-2] + cost
                             );
		DLCosts = DLMatrix[z,x];
	end;
end;
drop z x cost;
DLScore = 1 - DLCosts / max(length(i),length(r));
if DLScore >= &cutoff then DLFlag = 1; else DLFlag = 0;
%do n = 1 %to &refSize;
	drop DLRef&n DLIn&n;
%end;
%do m = 1 %to %eval(&refSize * &inSize);
	drop DLMatrix&m;
%end;
%if &rel ^= "N" %then %do;
	%ConfMatrix(DL,rel=&rel);
%end;
attrib 
DLFlag label = "Damerau-Lavenshteinova vzdálenost - pøíznak podobnosti"
DLCosts label = "Damerau-Lavenshteinova vzdálenost - kalkulované náklady"
DLScore label = "Damerau-Lavenshteinova vzdálenost - kalkulované skóre"
;
%mend DamLevDist;