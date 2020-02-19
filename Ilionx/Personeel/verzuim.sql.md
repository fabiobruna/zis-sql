@Source verzuim.sql

```sql
/** 
 *   @Source verzuim.sql
 *   @Description basis selecie verzuim op de Ilionx personeel datamart
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

with cte_start as (
select ZiektegevalKey, DatumVerzuim
from curedwh.DMTm.Personeel_FactVerzuim
where AantalStartendeVerzuimgevallen = 1
),
cte_eind as (
select ZiektegevalKey, DatumVerzuim
from curedwh.DMTm.Personeel_FactVerzuim
where AantalEindigendeVerzuimgevallen = 1
)
  select distinct
    t00.ZiektegevalKey,
	t30.Personeelsnummer,
	t30.Medewerkernaam,
	t20.AfdelingOmschrijving,
	t20.ClusterOmschrijving,
	case 
		when ziektedag-1 between 1 and 14 then 'Kort'
		when ziektedag-1 between 15 and  91 then 'Middellang'
		when ziektedag-1 between 92 and 365 then 'Lang verzuim'
		when ziektedag-1 > 365 then 'Tweede ziektjaar'
		else 'Onbekend' end categorie,
	 t40.DatumVerzuim [start verzuim],
	 t50.DatumVerzuim [eind verzuim]
from curedwh.DMTm.Personeel_FactVerzuim t00
 left join curedwh.DMTm.Personeel_DimDienstverband t10
  on t00.DienstverbandKey = t10.DienstverbandKey
 left join curedwh.DMTm.Algemeen_DimKostenplaats t20
  on t00.KostenplaatsKey = t20.KostenplaatsKey
 left join curedwh.DMTm.Personeel_DimMedewerker t30
  on t00.MedewerkerKey = t30.MedewerkerKey
 left join cte_start t40
  on t00.ZiektegevalKey = t40.ZiektegevalKey
 left join cte_start t50
  on t00.ZiektegevalKey = t50.ZiektegevalKey
order by [start verzuim]

```