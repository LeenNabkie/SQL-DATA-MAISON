
/*****************************************************************************************************
******************************************************************************************************
                          Math30602 Logiciels statistiques en gestion
                          S�ance1_exercies_solutions                                                                                                             *;

******************************************************************************************************
******************************************************************************************************
*****************************************************************************************************/

/*
Chaque question est repondue de deux mani�res diff�rentes. D'abord en utilisant le langage SQL, puis
en utilisant le langage SAS.
*/


/****************************************************************************************************
******************************************  Question 1	*********************************************
Veuillez cr�er une nouvelle table de donn�es (que  vous nommerez ��data_subset��) dans laquelle vous 
aurez seulement les variables "numero_id", "prix ", "jardin", "date_poste" et "code_postal" . 
Cette table doit �tre cr��e � partir de la table de donn�es ��data_maisons_vendre��.
 
*****************************************************************************************************
*****************************************************************************************************/

/*Importer des donn�es EXCEL dans SAS et les stocker dans la librairie WORK*/
PROC IMPORT OUT= data_maisons_vendre
DATAFILE= "C:\Votre chemin complet\data_maisons_vendre.xlsx"
DBMS=EXCEL REPLACE;
RANGE="Feuil1$";
GETNAMES=YES;
RUN;

*SQL;
proc sql;
create table data_subset_SQL  as 
select numero_id,prix, jardin,date_poste,code_postal
from data_maisons_vendre;
quit;

*SAS;
data data_subset_SAS (keep=numero_id prix jardin date_poste code_postal);
	set data_maisons_vendre;
run;

/****************************************************************************************************
******************************************  Question 2	*********************************************
Veuillez cr�er deux nouvelles tables de donn�es � partir de la table de donn�es ��data_subset�.

1)La premi�re contiendra toutes les propri�t�s qui poss�dent un jardin. Pour cette table,
veuillez extraire seulement les colonnes suivantes:
"numero_id", "prix" et "date_poste".Elle se nommera ��data_sub_jard1��.

2)La deuxi�me table contiendra toutes les propri�t�s qui ne poss�dent pas de jardin. 
Veuillez extraire les colones "numero_id", "prix", "date_poste" et "code_postal". 
Elle se nommera ��data_sub_jard0��.

 
*****************************************************************************************************
*****************************************************************************************************/
*SQL;

proc sql;
create table data_sub_jard1_SQL  as 
select numero_id,prix,date_poste
from data_subset_SQL
where  jardin=1;
quit;

proc sql;
create table data_sub_jard0_SQL  as 
select numero_id,prix, date_poste, code_postal
from data_subset_SQL
where  jardin=0;
quit;


*SAS;
data data_sub_jard1_SAS (keep=numero_id prix date_poste);
	set data_subset_SAS;
	where jardin=1;
run;

data data_sub_jard0_SAS (drop=jardin);
	set data_subset_SAS;
	where jardin=0;
run;

/****************************************************************************************************
******************************************  Question 3	*********************************************

En prenant la table de donn�es ��data_sub_jard0��
1)veuillez d�terminer la date d'affichage la plus ancienne qui soit en utilisant la clause ORDER BY. 
2)Combien  y a-t-il d�observations?

*****************************************************************************************************
*****************************************************************************************************/
*SQL;
proc sql NUMBER;
select 
		date_poste
from data_sub_jard0_SQL
order by date_poste;
quit;

proc sql;
		select count(*) as nb_ligne
		from  data_sub_jard0_SQL;
quit;



* il y a 689 observations;

* ou bien ;
proc sql;
select monotonic() as row
from data_sub_jard0_SQL
order by monotonic();
quit;


*SAS;
proc sort data=data_sub_jard0_SAS (keep=date_poste) out=data_sub_jard0_date_ancienne_SAS;by date_poste;run;

* il y a 689 observations;

/****************************************************************************************************
******************************************  Question 4	*********************************************

En prenant la table de donn�es ��data_sub_jard0��, veuillez cr�er une table de donn�es qui comprendra
toutes les propri�t�s poss�dant r�pondant � un des crit�res suivants:
Soit les 3 derniers caract�res sont le 4B1
Soit les 3 premiers caract�res sont le H1M
De plus la maison doit couter entre 600 000$ et 850 000$.

Combien d'observations obtenez-vous dans cette nouvelle table de donn�es (que vous nommerez)?
Veuillez ordonner cette table par prix (de fa�on croissante).


*****************************************************************************************************
*****************************************************************************************************/

*SQL;
proc sql;
create table data_jard0_H1M_4B1_600_850_SQL as 
select *
from data_sub_jard0_SQL
where (substr(code_postal,4,3)="4B1" or substr(code_postal,1,3)="H1M" ) 
and prix>=600000 and  prix<=850000 /* ou bien and prix between 600000 and 850000*/
order by prix;
quit;


proc sql;
select count(*) label='Nombre de lignes'
from data_jard0_H1M_4B1_600_850_SQL
;
quit;

* SAS;
Data data_jard0_H1M_4B1_600_850_SAS;
	set data_sub_jard0_SAS;
	where (substr(code_postal,1,3)="H1M" or substr(code_postal,4,3)="4B1") 
	and prix>=600000 and  prix<=850000; /* ou bien: and prix between 600000 and 850000*/;
run;

proc sort data=data_jard0_H1M_4B1_600_850_SAS  ;by prix;run;
/*On peut calculer diff�rentes statistiques en fonction d�une ou de plusieurs variables*/
proc summary data=data_jard0_H1M_4B1_600_850_SAS nway missing;
var prix;
output out = Sommaire_util1 (drop = _type_ _freq_)
;
run;


/****************************************************************************************************
******************************************  Question 5	*********************************************

� l'aide la table de donn�es ��data_maisons_vendre��, veuillez cr�er une nouvelle variable que vous 
nommerez prix_700k.
Cette variable prendra la valeur de 1 lorsque le prix est au moins de  700 000$ et 0 sinon.



*****************************************************************************************************
*****************************************************************************************************/
*SQL;
proc sql;
	create table data_maisons_vendre_700K_SQL as 
		select 
				*, 
				case 
					when prix>=700000 then 1 
					else 0 
				end as prix_700k
		from data_maisons_vendre; 
quit;

*SAS;
data data_maisons_vendre_700K_SAS;
	set data_maisons_vendre;
	if prix>=700000 then prix_700k=1; 
	else prix_700k=0;
run; 


/****************************************************************************************************
******************************************  Question 6	*********************************************
Nous allons maintenant cr�er une nouvelle variable qui se nommera "satisfaction" dans notre table
de donn�es ��data_maisons_vendre��.

Cette variable sera une variable cat�gorique � 3 modalit�s:
Elle prendra la valeur "OUI" lorsque si: 
la propri�t� est  un duplex ou un triplex et que le montant est inf�rieur � 500 000$
la propri�t� est une maison, qu'il y ait un jardin, qu'elle soit dans le H2E, H3E OU H3R, et qu'elle coute au plus 450 000 $
la propri�t� est une maison en dessous de 300 000$, elle ne se trouve pas dans H3X ou le H2Z et qu'elle poss�de un jardin.

Elle prendra la valeur de "NON" si:
-la propri�t� coute plus de 650 000$
-la propri�t� se trouve dans le H1Y ou le H1P

Dans tous les autres cas, la variable prendra la valeur de "NA"
De plus, nous nous int�resserons seulement aux maisons qui ont au minimum 3 pi�ces;


*****************************************************************************************************
*****************************************************************************************************/

* sql;
proc sql;
create table data_maisons_vendre_3P_SQL as 
select *,
case when 
(substr(numero_id,1,2) in ("tr","du") and prix<500000) or 
(substr(numero_id,1,2)="ma" and jardin=1 and substr(code_postal,1,3) in ("H2E","H3E","H3R") and prix<=450000) or 
(substr(numero_id,1,2)="ma" and prix <300000 and substr(code_postal,1,3) not in ("H3X","H2Z") and jardin=1)
then "OUI"
when 
(prix>650000) or 
(substr(code_postal,1,3)  in ("H1Y","H1P"))
then "NON"
else "NA" end as satisfaction

from data_maisons_vendre
where nbr_pieces>=3;
quit;


*SAS;
data data_maisons_vendre_3P_SAS;
	set data_maisons_vendre;
	if  (substr(numero_id,1,2) in ("tr","du") and prix<500000) or 
		(substr(numero_id,1,2)="ma" and jardin=1 and substr(code_postal,1,3) in ("H2E","H3E","H3R") and prix<=450000) or 
		(substr(numero_id,1,2)="ma" and prix <300000 and substr(code_postal,1,3) not in ("H3X","H2Z") and jardin=1)
	then satisfaction= "OUI";
	else if (prix>650000) or 
			(substr(code_postal,1,3)  in ("H1Y","H1P"))
	then satisfaction= "NON";
	else satisfaction= "NA";
	where nbr_pieces>=3;
run;




*******************************************************************************************************************************;
*******************************************************************************************************************************;
*******************************************************************************************************************************;
*******************************************************************************************************************************;

