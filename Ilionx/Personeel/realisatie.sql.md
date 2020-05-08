@Source relisatie.sql

```sql
/** 
 *   @Source relisatie.sql
 *   @Description basis selecie realisatie op de Ilionx personeel datamart
 *   @Mutaties: https://vm-dwhdevops-p1.mchaaglanden.local/DefaultCollection/
 */

set nocount on -- Stop de melding over aantal regels
set ansi_warnings on -- ISO foutmeldingen(NULL in aggregraat bv)
set ansi_nulls on -- ISO NULLL gedrag(field = null returns null, ook als field null is)

/** 
    [vm-dwhsql-t1].hmcbi
    [vm-dwhsql-t1].curedwh
    [HIXR.mchbrv.nl].[HIX_PRODUCTIE].[dbo].
*/

  use curedwh;

select top 100
    t00.Boekdatum,
    t70.Personeelsnummer,
    t20.WerkgeverOmschrijving,
    t30.ArbeidsrelatieOmschrijving,
    t40.CAOOmschrijving,
    t60.FunctieOmschrijving,
    t50.ClusterOmschrijving,
    t10.ContracturenPerWeek,
    t00.WerkgeverFulltimeUren,
    t10.Ancienniteit,
    t00.FTEVerloond,
    t00.FTEMeerwerk,
    t00.FTEMeerwerk,
    t00.FTEOverwerk,
    t00.FTEOnbetaaldverlof,
    t00.FTEOuderschapsverlof,
    t00.FTEZwangerschapsverlof
from curedwh.DMTm.Personeel_FactFormatieInzet t00
 left join curedwh.DMTm.Personeel_DimDienstverband t10
  on t00.DienstverbandKey = t10.DienstverbandKey
 left join curedwh.DMTm.Personeel_DimWerkgever t20
  on t00.WerkgeverKey = t20.WerkgeverKey
 left join curedwh.DMTm.Personeel_DimArbeidsrelatie t30
  on t00.ArbeidsrelatieKey = t30.ArbeidsrelatieKey
 left join curedwh.DMTm.Personeel_DimCAO t40
  on t00.CAOKey = t40.CAOKey
 left join curedwh.DMTm.Algemeen_DimKostenplaats t50
  on t00.KostenplaatsKey = t50.KostenplaatsKey
 left join curedwh.DMTm.Personeel_DimFunctie t60
  on t00.FunctieKey = t60.FunctieKey
 left join curedwh.DMTm.Personeel_DimMedewerker t70
  on t00.MedewerkerKey = t70.MedewerkerKey
where 1=1
order by t00.Boekdatum
```