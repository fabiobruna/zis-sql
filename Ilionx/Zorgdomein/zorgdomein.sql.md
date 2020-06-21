@Source zorgdomein.sql

```sql
/** 
 *   @Source zorgdomein.sql
 *   @Description:  Ontsluiten zorgdomein data
 *   @Mutaties: https://vm-dwhdevops-p1.mchaaglanden.local/DefaultCollection/
 *
 *		Change		Name		Date		Description 
-----------------------------------------------------------------------------------------------------------------
 *		1			Fabio		2020-06-21	Create
 */

set nocount on
set ansi_warnings on
set ansi_nulls on

  use curedwh;

select top 100 
  t00.id, 
  cast(t00.[verwdate] as date) verwijsdatum, 
  charindex('Code:', t00.verwtext),
  substring(t00.verwtext, 10, charindex('Code:', t00.verwtext)-10) locatie,
  substring(t00.verwtext, charindex('Code:', t00.verwtext)+6, cast(charindex('Product:', t00.verwtext) as int) - cast(charindex('Code:', t00.verwtext)+6 as int)) Code,
  case when charindex('Productcode:', t00.verwtext) = 0 
	   then null 
	   else substring(t00.verwtext, charindex('Productcode:', t00.verwtext)+13, cast(charindex('Reden:', t00.verwtext) as int) - cast(charindex('Productcode:', t00.verwtext)+13 as int)) end Productcode,
  case when charindex('Reden:', t00.verwtext) = 0 
	   then null 
	   else substring(t00.verwtext, charindex('Reden:', t00.verwtext)+7, cast(charindex('Type:', t00.verwtext) as int) - cast(charindex('Reden:', t00.verwtext)+7 as int)) end Reden,
  case when charindex('Type:', t00.verwtext) = 0 
	   then null 
	   else substring(t00.verwtext, charindex('Type:', t00.verwtext)+6, cast(charindex('Toegangstijd:', t00.verwtext) as int) - cast(charindex('Type:', t00.verwtext)+6 as int)) end Type,
  case when charindex('Toegangstijd:', t00.verwtext) = 0 
	   then null 
	   else substring(t00.verwtext, charindex('Toegangstijd:', t00.verwtext)+13, len(t00.verwtext) - cast(charindex('Toegangstijd:', t00.verwtext)+13 as int)) end Type,
  t30.zoekcode, 
--  t00.verwtext, 
  cast('' as varchar(255)) afgeleidtype, 
  t00.statusid, 
  t00.patientid
FROM hism.vhix_WEBAGEN_VERWIJS t00
LEFT JOIN hism.vhix_WEBAGEN_AGVRWVRG t10
 on t10.ID = t00.VERWVRG
LEFT JOIN hism.vhix_WEBAGEN_AGVRWTYP t20
 on t20.ID = t10.TYPID
LEFT JOIN hism.vhix_WEBAGEN_AGVRWCAT t30
 on t30.ID = t20.CATID
where 1=1
 and isnull(t00.EXTID, '') <> ''
 and t00.[VERWDATE] BETWEEN '20190101' and '20190301'
-- AND LEFT(a.EXTID,2) = 'ZD'
```