@Source budget.sql

```sql
/** 
 *   @Source budget.sql
 *   @Description basis selecie budget op de Ilionx personeel datamart
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


select 
	t10.ClusterOmschrijving,
	t10.KostenplaatsOmschrijving,
	t20.FunctieOmschrijving,
	t00.*
from dmtm.Personeel_FactFormatieBegroot t00
 join dmtm.Algemeen_DimKostenplaats t10
  on t00.KostenplaatsKey = t10.KostenplaatsKey
 join DMTm.Personeel_DimFunctie t20
  on t00.FunctieKey = t20.FunctieKey
where t10.ClusterOmschrijving = 'FINANCIEN'
 and year(t00.DatumBegroot) = 2019
 and t20.FunctieOmschrijving = 'controller'
```
 