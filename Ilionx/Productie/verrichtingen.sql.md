@Source verrichtingen.sql

```sql
/** 
 *   @Source verrichtingen.sql
 *   @Description basis selecie verrichtingen op de Ilionx database
 *   @Mutaties: https://vm-dwhdevops-p1.mchaaglanden.local/DefaultCollection/
 */

set nocount on -- Stop de melding over aantal regels
set ansi_warnings on -- ISO foutmeldingen(NULL in aggregraat bv)
set ansi_nulls on -- ISO NULLL gedrag(field = null returns null, ook als field null is)

/** 
    select format ( getdate(), 'yyyy-MM-dd' ) AS FormattedDate;
    SELECT FORMAT(getdate(), N'yyyy-MM-dd HH:mm') AS FormattedDateTime;
    select format(xxx, 'C', 'nl-nl') as FormattedCurrency;
    select format(xxx, 'N0', 'nl-nl') as FormattedNumber;

    row_number() over(partition by xxx order by xxx) as teller,

    if object_id('tempdb..#naam') is not null drop table #naam;

    [nt-vm-dwh-p3].dwh_ezis.dbo.
    [vm-dwhsql-t1].hmcbi
    [vm-dwhsql-t1].curedwh
    [HIXR.mchbrv.nl].[HIX_PRODUCTIE].[dbo].
*/

  use curedwh;

  select
    t00.bronkey,
    t00.Preferentnummer patientnr,
    t00.Verrichtingdatum,
    t10.ArtsCode,
    t10.SpecialismeCode,
    t00.Invoercode,    -- invoerdecpde / CBV
	  t20.Declaratiecode, -- declaratie / CTG
    t00.ZorgactiviteitcodeKey,
    sum(t00.AantalProductie) aantal,
    sum(t00.Kostenbedrag) kostenbedrag, 
    sum(t00.Honorariumbedrag) Honorariumbedrag
  from int.Productie_Zorgactiviteiten t00
    join int.Algemeen_Arts t10
      on t00.UitvoerderKey = t10.ArtsKey
    left join int.[Productie_DimZorgactiviteitcode] t20
	    on t00.ZorgactiviteitcodeKey = t20.ZorgactiviteitcodeKey 
    join int.Algemeen_Patient t30
      on t00.PatientKey = t30.PatientKey
  where year(t00.Verrichtingdatum) = 2017
   and not (substring(t00.ZorgactiviteitcodeKey,1,2) in ('14','15','16','17') and t00.Tariefafdeling <> 'WAPO' )
--   and t00.IsCreditregel = 'Nee'
--   and t00.IsGecrediteerd = 'Nee'
--   and t00.IsAddon = 'Nee'
  group by 
    t00.bronkey,
    t00.PatientKey,
    t00.Verrichtingdatum,
    t10.ArtsCode,
    t10.SpecialismeCode,
    t00.Invoercode,
	  t20.Declaratiecode,
    t00.ZorgactiviteitcodeKey
```