# @Source document.sql

```sql
set nocount on -- Stop de melding over aantal regels
set ansi_warnings on -- ISO foutmeldingen(NULL in aggregraat bv)
set ansi_nulls on -- ISO NULLL gedrag(field = null returns null, ook als field null is)

/** 
 *   @Source document.sql
 *   @Description 
 */

declare @start date;
declare @eind date;
set @start = '20190101';
set @eind = '20190701';

if object_id('tempdb..#HiXzorgproducten') is not null drop table #HiXzorgproducten;
select * into #HiXzorgproducten
from (
    select  
        t00.patientnr,
        t00.episode,
        t00.verwijsnr,
        t05.dbcnummer,
        cast(t05.begindat as date) [dbc begindatum],
        cast(isnull(t05.einddat, '29991231') as date) [dbc einddatum],
        t05.uitvoerder,
        t05.hoofddiag [dbc diagnose],
        t30.omschrijv [dbc diagnose oms],
        t05.zorgtype,
        t70.omschrijv [zorgtype oms],
        t05.dbctyperin,
        t05.specialism [dbc specialisme],
        t05.locatie [dbc locatie],
        t50.omschr [dbc specialisme oms],
        1 as [dbc aantal],
        t10.verwijzer,
        t10.typeverw
    from [dbo].episode_episode t00
     join [dbo].episode_dbcper t05
      on t00.episode = t05.episode
     left join [dbo].episode_epiverw t10
      on t00.verwijsnr = t10.verwijsnr
     left join EPISODE_DIAG t30
      on case when isnull(t00.HOOFDDIAG, '') = '' then t05.HOOFDDIAG else t00.HOOFDDIAG end = t30.CODE
       and t00.SPECIALISM = t30.SPECIALISM
       and cast(t00.BEGINDAT as date) > isnull(t30.DATUM, '19000101')
       and cast(t00.BEGINDAT as date) < isnull(t30.EINDDATUM, '29991231')
     left join EPISODE_DIAG t35
      on t05.HOOFDDIAG = t35.CODE
       and t05.SPECIALISM = t35.SPECIALISM
       and cast(t05.BEGINDAT as date) > isnull(t35.DATUM, '19000101')
       and cast(t05.BEGINDAT as date) < isnull(t35.EINDDATUM, '29991231')
     left join CSZISLIB_SPEC t40
      on t00.SPECIALISM = t40.SPECCODE
     left join CSZISLIB_SPEC t50
      on t05.SPECIALISM = t50.SPECCODE
     left join EPISODE_ZORGTYPE t70
      on t05.ZORGTYPE = t70.CODE
       and cast(t05.BEGINDAT as date) > isnull(t70.BEGINDAT, '19000101')
       and cast(t05.BEGINDAT as date) < isnull(t70.EINDDAT, '29991231')
    where t05.vervallen = 0
     and cast(t05.BEGINDAT as date) between @start and @eind
	 and t05.zorgtype = 'R'
) t1
delete from #HiXzorgproducten where not exists ( select '' from FAKTUUR_VERRICHT s00 where s00.CASENR = #HiXzorgproducten.DBCNUMMER );

select *
from #HiXzorgproducten

select top 100 
	t20.DBCNUMMER ,
	t00.PATIENTNR,
	t00.SPECIALISM,
	t00.KENMERK,
	t10.sjabnaam,
    t00.accdatum+t00.acctijd as accdatumtijd,
	row_number() over(partition by t20.DBCNUMMER order by t00.accdatum+t00.acctijd) as teller
from [dbo].wi_document t00
 left join [dbo].wi_sjabloon t10
   on t00.sjab_id = t10.id
 join #HiXzorgproducten t20
  on t00.PATIENTNR = t20.PATIENTNR
   and t00.SPECIALISM = t20.[dbc specialisme] -- brief van het DBC specialisme
   and cast(t00.ACCDATUM as date) between t20.[dbc begindatum] and t20.[dbc einddatum] -- brief TIJDENS DBC

