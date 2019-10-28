
```sql
/** 
 *   @Source episode-verwijzer.sql.md
 *   @Description 
 *   @Mutaties: https://vm-dwhdevops-p1.mchaaglanden.local/DefaultCollection/vault-snippets
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

select 
	typeverw,
	case typeverw
		when '01' then  'Zelfverwijzer SEH (een patient die zich meldt bij de SEH zonder verwijzing.'
		when '02' then  'Zelfverwijzer niet-SEH (bijvoorbeeld een patient die zich meldt bij de polikliniek zonder verwijzing).'
		when '03' then  'Verwezen patient SEH (Een patient die zich meldt bij de SEH met een verwijzing).'
		when '04' then  'Verwezen patient niet-SEH vanuit eerstelijn (bijvoorbeeld een patient die zich meldt bij de polikliniek met een verwijzing vanuit de eerstelijn).'
		when '05' then  'Verwezen patient niet-SEH vanuit ander specialisme binnen dezelfde instelling (bijvoorbeeld een patient die zich meldt bij de polikliniek met een verwijzing van een ander medisch specialisme binnen dezelfde instelling'
		when '06' then  'Verwezen patient niet-SEH vanuit andere instelling (bijvoorbeeld een patiënt die zich meldt bij de polikliniek met een verwijzing van andere instelling).'
		when '07' then  'Eigen patient (bijvoorbeeld ingeval vervolgtraject of nieuwe zorgvraag van eigen patient).'
		when '08' then  'Verwezen patient niet-SEH vanuit eerstelijn, maar verwijzer heeft geen AGB-code (bijvoorbeeld ingeval van optometristen).'
		when '09' then  'Patient welke gebruik maakt van directe toegang tot paramedisch hulp (bijvoorbeeld directe toegang tot fysiotherapie).'
		else null end [type verwijzer]
from episode_epiverw
```