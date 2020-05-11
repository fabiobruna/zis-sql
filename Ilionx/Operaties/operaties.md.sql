@Source operaties.sql

```sql
/**
 *   @Source operaties.sql
 *   @Description basis selecie operaties op de Ilionx database
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
    t00.PatientKey,
    t00.Operatienummer,
    t00.Operatiedatum,
    t00.AantalGerealiseerdeOperaties,
    t01.VerrichtingcodeKey,
    t02.VerrichtingOmschrijving,
    t01.AantalVerrichtingen,
    t01.SnijdendSpecialistKey,
    t01.AssistentKey,
    t01.UitvoerderKey,
    t03.DBCNummer,
    t04.DiagnoseCode,
    t04.DiagnoseOmschrijving
from
    [DMTm].[OK_FactOperaties] t00
    left join [DMTm].[OK_FactOperatieveVerrichtingen] t01
     on t00.operatienummer = t01.Operatienummer
    left join [DMTm].[OK_DimVerrichtingcode] t02
     on t01.VerrichtingcodeKey = t02.VerrichtingcodeKey
    left join [DMTm].[Productie_FactZorgactiviteiten] t03
     on t00.Operatienummer = t03.Referentienummer
        and t01.VerrichtingcodeKey = t03.Invoercode
        and t03.AantalProductie = '1' -- er is ook een ANA regel en daar is Aantalproductie 0
    left join [DMTm].[Productie_DimZorgtrajecten] t04
    on t03.dbcnummer = t04.[DBCNummer]
where t00.Operatiedatum between '20190101' and '20191231'
--    and (t01.SnijdendSpecialistKey in ('HEEPEE','HEEHOL','HEEMAD', 'HEEHAG','58472', '58476')
--    or t01.AssistentKey in ('HEEPEE','HEEHOL','HEEMAD', 'HEEHAG','58472', '58476')
--    or t01.UitvoerderKey in  ('HEEPEE','HEEHOL','HEEMAD', 'HEEHAG','58472', '58476'))
    and t00.IsVervallen  <> '0'
--    and t00.operatienummer =  '0002030580'
order by t00.Operatienummer
```