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
    [nt-vm-dwh-p3].dwh_ezis.dbo.
    [vm-dwhsql-t1].hmcbi
    [vm-dwhsql-t1].curedwh
    [HIXR.mchbrv.nl].[HIX_PRODUCTIE].[dbo].
*/

  use curedwh;

  select
    t00.bronkey,
    t20.Preferentnummer patientnr,
    t00.Verrichtingdatum,
    t10.ArtsCode,
    t10.SpecialismeCode,
    t00.Invoercode,  
    t30.InvoerCodeOmschrijving,
    t30.Declaratiecode,
    t30.DeclaratieCodeOmschrijving,
    t00.ZorgactiviteitcodeKey,
    sum(t00.AantalProductie) aantal,
    sum(t00.Kostenbedrag) kostenbedrag, 
    sum(t00.Honorariumbedrag) Honorariumbedrag
  from DMTm.Productie_FactZorgactiviteiten t00
    join DMTm.Algemeen_DimArts t10
      on t00.UitvoerderKey = t10.ArtsKey
    join DMTm.Algemeen_DimPatient t20
       on t00.PatientKey = t20.PatientKey
    left join DMTm.[Productie_DimZorgactiviteitcode] t30
      on t00.ZorgactiviteitcodeKey = t30.ZorgactiviteitcodeKey 
    where year(t00.Verrichtingdatum) = 2018
   and not (substring(t00.ZorgactiviteitcodeKey,1,2) in ('14','15','16','17') and t00.Tariefafdeling <> 'WAPO' )
--   and t00.IsCreditregel = 'Nee'
--   and t00.IsGecrediteerd = 'Nee'
--   and t00.IsAddon = 'Nee'
  group by 
    t00.bronkey,
    t20.Preferentnummer,
    t00.Verrichtingdatum,
    t10.ArtsCode,
    t10.SpecialismeCode,
    t00.Invoercode,  
    t30.InvoerCodeOmschrijving,
    t30.Declaratiecode,
    t30.DeclaratieCodeOmschrijving,
    t00.ZorgactiviteitcodeKey
```