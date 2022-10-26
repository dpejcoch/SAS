%macro Levenshtein(refSize,inSize,cutoff,maxobs,rel=N);
/* definice polí pro jednotlivé znaky porovnávaných řetězců */
array LevRef[&refSize] $1;
array LevIn[&inSize] $1;
/* definice matice pro výpočet transformace vstupního řetězce na výstupní */
array LevMatrix[&refSize,&inSize] 8;
/* naplnění pole pro porovnávaný řetězec */
do m = 1 to length(i) + 1;
	LevMatrix[m,1] = m - 1;
	if m <= length(i) then LevIn[m] = substr(i,m,1);
end;
/* naplnění pole pro referenční řetězec */
do n = 1 to length(r) + 1;
	LevMatrix[1,n] = n - 1;
	if n <= length(r) then LevRef[n] = substr(r,n,1);
end;
drop m n;
/* vlastní výpočet nákladů transformace porovnávaného řetězce na referenční řetězec */
do z = 2 to length(i) + 1;
	do x = 2 to length(r) + 1;
		if LevRef[z-1] = LevIn[x-1] then cost = 0; else cost = 1;
		LevMatrix[z,x] = min(
					LevMatrix[z-1,x]+1,
					LevMatrix[z,x-1]+1,
					LevMatrix[z-1,x-1] + cost
					);
		LevCosts = LevMatrix[z,x];
	end;
end;
drop z x cost;
/* nápočet skóre určující náklady transformace */
LevScore = 1 - LevCosts / max(length(i),length(r));
/* pokud je skóre vyšší než prahová hodnota, je dosaženo shody */
if LevScore >= &cutoff then LevFlag = 1; else LevFlag = 0;
/* vymazání pracovních proměnných */
%do n = 1 %to &refSize;
	drop LevRef&n LevIn&n;
%end;
%do m = 1 %to %eval(&refSize * &inSize);
	drop LevMatrix&m;
%end;
/* pokud je specifikovan klic, provadi se napocet matice zamen */
%if &rel ^= "N" %then %do;
	%put tohle je klic: &rel;
	%ConfMatrix(Lev,rel=&rel);
%end;
/* přidání labelu pro cílové atributy */
attrib 
LevFlag label = "Levenshteinova vzdálenost - příznak podobnosti"
LevCosts label = "Levenshteinova vzdálenost - kalkulované náklady"
LevScore label = "Levenshteinova vzdálenost - kalkulované skóre"
;
%mend Levenshtein;