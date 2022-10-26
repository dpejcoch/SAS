%macro Jaccard(refSize,inSize,cutoff,maxobs,rel=N);
array JacRef[&refSize] $1;
array JacIn[&inSize] $1;
do m = 1 to length(i);
	JacIn[m] = substr(i,m,1);
end;
do n = 1 to length(r);
	JacRef[n] = substr(r,n,1);
end;
do w = 1 to length(i);
	do v = 1 to length(i);
		if w ^= v and JacIn[w] = JacIn[v] and JacIn[v] ^= '#' then JacIn[v] = '#';
	end;
end;
do x = 1 to length(r);
	do y = 1 to length(r);
		if x ^= y and JacRef[x] = JacRef[y] and JacRef[y] ^= '#' then JacRef[y] = '#';
	end;
end;
prunik = 0;
sjednoceni = 0;
/* spočtení průniku a sjednocení porovnávaného a referenčního řetězce */
do t = 1 to max(length(i),length(r));
	do u = 1 to max(length(i),length(r));
		if JacIn[t] ^= '#' or JacRef[u] ^= '#' then do;
			if JacIn[t] = JacRef[u] then do; 
				prunik = prunik + 1; 
				JacRef[u] = '#'; 
			end;
		end;
	end;
end;
do p = 1 to max(length(i),length(r));
	if missing(JacIn[p]) = 0 and JacIn[p] not in ('#',' ') then sjednoceni = sjednoceni + 1;
	if missing(JacRef[p]) = 0 and JacRef[p] not in ('#',' ') then sjednoceni = sjednoceni + 1;
end;
/* výpočet vlastního skóre Jaccardova koeficientu */
JacScore= prunik / sjednoceni;
/* smazání pomocných proměnných */
drop p t u x y m n v w prunik sjednoceni;
%do n = 1 %to &refSize;
	drop JacRef&n JacIn&n;
%end;
/* výpočet matice záměn */
%if &rel ^= "N" %then %do;
	%put tohle je klic: &rel;
	%ConfMatrix(JAC,rel=&rel);
%end;
/* porovnání skóre s prahovou hodnotou */
if JacScore >= &cutoff then JacFlag = 1; else JacFlag = 0;
attrib 
JacFlag label = "Jaccardův koeficient - příznak podobnosti"
JacScore label = "Jaccardův koeficient - kalkulované skóre"
;
%mend Jaccard;