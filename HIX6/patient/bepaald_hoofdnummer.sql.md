# @Source bepaald_hoofdnummer.sql

```sql
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

    exec tempdb..sp_columns '#';

    datediff(yy, @geboortedatum, @rekendatum) +
    case when dateadd(yy, datediff(yy, @geboortedatum, @rekendatum),  @geboortedatum) > @rekendatum
       then -1
       else 0
       end age

    [nt-vm-dwh-p3].dwh_ezis.dbo.
    [HIXR.mchbrv.nl].[HIX_PRODUCTIE].[dbo].
*/

if object_id('tempdb..#patientenreeks') is not null drop table #patientenreeks;
with Hierarchy (patientnr, ParentId, preverent, Level)
 AS
 (
    -- anchor
     SELECT 
        patientnr,
        KOPPELNR,
        case isnull(koppelstat, '')
                     when '>' then cast(0 as bit) 
                     else cast(1 as bit) 
                   end preverent,
        0 AS Level   
     FROM dbo.PATIENT_PATIENT
     where case isnull(koppelstat, '')
                     when '>' then cast(0 as bit) 
                     else cast(1 as bit) 
                   end = 1
     UNION ALL
     -- recurse
     SELECT su.patientnr,
        su.KOPPELNR,
        case isnull(su.koppelstat, '')
                     when '>' then cast(0 as bit) 
                     else cast(1 as bit) 
                   end preverent,
        Level + 1 AS Level   
     FROM dbo.PATIENT_PATIENT AS su
     join hierarchy 
       on hierarchy.patientnr = su.KOPPELNR  
       and case isnull(su.koppelstat, '')
                     when '>' then cast(0 as bit) 
                     else cast(1 as bit) 
                   end = 0
 )
 SELECT 
    patientnr,
    cast(null as varchar(32)) hpatientnr,
    parentid,
    level,
    row_number() over(partition by level order by level) as teller
into #patientenreeks
FROM Hierarchy
order by teller, level

update t00
set t00.hpatientnr =  t10.patientnr
from #patientenreeks t00
 join #patientenreeks t10
  on t00.teller = t10.teller
   and t10.Level = 0

```