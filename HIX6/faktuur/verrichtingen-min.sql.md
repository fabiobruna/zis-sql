# @Source verrichtingen-min.sql

Minimale set verrichtingen, alleen omschrijvingen voor de invoer en declaratiecode.

```sql
set nocount on -- Stop de melding over aantal regels
set ansi_warnings on -- ISO foutmeldingen(NULL in aggregraat bv)
set ansi_nulls on -- ISO NULLL gedrag(field = null returns null, ook als field null is)

/** 
 *   @Source verrichtingen-min.sql
 *   @Description 
 */

declare @start date;
declare @eind date;
set @start = '20190101';
set @eind = '20191231';

if object_id('tempdb..#ezisfakt') is not null drop table #ezisfakt;

with cte_declaratiecode as (
    select
        code,
        afdeling,
        cast(isnull(begindatum, '19000101') as date) begindatum,
        isnull(cast(case
          when lead (begindatum) over (partition by code, afdeling order by begindatum) < isnull(cast(blokvanaf as date), '29991231')
          then dateadd(dd, -1, lead (begindatum) over (partition by code, afdeling order by begindatum)) 
          else blokvanaf end as date), '29991231') blokvanaf,
        codedecl,
        row_number() over(partition by code, afdeling, isnull(blokvanaf, '29991231') order by isnull(begindatum, '19000101') desc) as teller
    from [dbo].faktuur_ververz
    where AFDELING <> 'CBVO'
)
select IDENTITY(INT, 1, 1) AS id, * into #ezisfakt
from (
    select
      t00.patientnr as patientnummer,
      cast(t00.datum as date) as verrichtingsdatum,
      t10.code as invoercode,
      t30.OMSCHRIJV [invoercode oms],
      coalesce(case when isnull(t10.ctgcode, '') = '' then null else t10.ctgcode end, t40.codedecl) declaratiecode,
      cast (null as nvarchar(300)) [declaratiecode oms],
      t00.uitvoerder as uitvoerder_code,
      t00.aanvrager as aanvrager_code,
      t10.kostplaats as kostenplaats,
      t00.verzekerin as instantie,
      t00.casenr dbcnummer,
      t00.opnamenr opnamenummer,
      t00.refnummer referentie,
      t00.bron,
      t00.afdeling,
      t00.locatie,
      t10.bronstatus,
      t10.bedragspec,
      t10.bedragziek,
      case when and substring(isnull(t10.correctie,'      '),4,1) <> '1' then t10.aantal else 0 end as aantal_uitgevoerd
      FORMAT(getdate(), N'yyyy-MM-dd hh:mm') as draaimoment
    from [dbo].faktuur_verricht t00
     join [dbo].faktuur_verrsec  t10
      on t00.id = t10.id
     left join faktuur_veromsch t30
      on t00.AFDELING = t30.AFDELING
       and t10.code = t30.code
     left join cte_declaratiecode t40
      on t00.AFDELING = t40.AFDELING
       and t10.CODE = t40.CODE
       and t00.DATUM < t40.BLOKVANAF
       and t00.DATUM > t40.begindatum
       and t40.teller = 1
    where not (substring(t10.code,1,2) in ('14','15','16','17') and t00.afdeling <> 'WAPO')
      and t10.CODE <> 'UNK'
      and t00.datum between @start and @eind
) t1

/*
|| Medicatie dingen. Aantal is anders.
*/

update t00
set t00.aantal_uitgevoerd = t10.medaantal
from #ezisfakt t00
 join faktuur_verrmed t10
  on t00.id = t10.id

/*
|| Toevoegen omschrijvingen (declaratiecode doen we achteraf ivm de codes die we hierboven afleiden)
*/

update t00
set t00.[declaratiecode oms] = t20.omschrijv
from #ezisfakt t00
  join faktuur_veromsch t20
   on t00.AFDELING = t20.AFDELING
   and t00.declaratiecode = t20.code

select *
from #ezisfakt
-- where correctie = 'nee'
order by verrichtingsdatum
```