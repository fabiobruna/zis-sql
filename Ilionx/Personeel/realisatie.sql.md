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

 select
	format(t00.BoekDatum, 'yyyyMM') periode,
	t20.ClusterOmschrijving,
	sum(t00.AantalDienstverbanddagen) dienstverbanddagen
from curedwh.DMTm.Personeel_FactFormatieDienstverband t00
 join curedwh.DMTm.Algemeen_DimKostenplaats t20
  on t00.KostenplaatsKey = t20.KostenplaatsKey
group by
	format(t00.BoekDatum, 'yyyyMM'),
	t20.ClusterOmschrijving
```