@Source agenda.sql

```sql
/**
 *   @Source agenda.sql
 *   @Description basis selecie agenda op de Ilionx database
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
	t00.Afspraakdatum,
	t20.Preferentnummer PatientNummer,
	t10.AgendaNaam,
	t10.AgendaOmschrijving,
	t10.SubagendaNaam,
	t10.SubagendaOmschrijving,
	t30.ConsulttypeOmschrijving,
	t40.AfspraaktypeOmschrijving,
	t40.AfspraaktypeGroep,
	t00.AantalAfspraken
from DMTm.Afspraken_FactAfspraken t00
 join DMTm.Afspraken_DimAgenda t10
  on t00.AgendaKey = t10.AgendaKey
 join DMTm.Algemeen_DimPatient t20
  on t00.PatientKey = t20.PatientKey
 left join DMTm.Afspraken_DimConsulttype t30
  on t00.ConsulttypeKey = t30.ConsulttypeKey
 left join DMTm.Afspraken_DimAfspraaktype t40
  on t00.AfspraaktypeKey = t40.AfspraaktypeKey
where 1=1
 and t00.IsVoldaan = 'Ja'
```