# @Source episode-verwijzer.sql

```sql
/** 
 *   @Source episode-verwijzer.sql
 *   @Description 
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
