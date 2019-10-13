#  @Source episode-dbcs.sql

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

declare @start date;
set @start = '20190101';

if object_id('tempdb..#HiXzorgproducten') is not null drop table #HiXzorgproducten;
select * into #HiXzorgproducten
from (
    select  distinct
        t00.patientnr,
        t00.episode,
        t00.verwijsnr,
        t00.specialism [episode spec],
        t40.omschr [episode spec oms],
        cast(t00.begindat as date) [episode beginddatum],
        cast(isnull(t00.einddat, '29991231') as date) [episode einddatum],
        case when isnull(t00.hoofddiag, '') = '' then t05.hoofddiag else t00.hoofddiag end [episode diagnose],
        t00.locatie [episode locatie],
        t05.dbcnummer,
        cast(t05.begindat as date) [dbc begindatum],
        cast(isnull(t05.einddat, '29991231') as date) [dbc einddatum],
        t05.uitvoerder,
        t05.hoofddiag [dbc diagnose],
        t30.omschrijv [dbc diagnose oms],
        t05.zorgtype,
        t70.omschrijv [zorgtype oms],
        t05.zorgvraag,
        t60.omschrijv [zorgvraag oms],
        t05.dbctyperin,
        t05.specialism [dbc specialisme],
        t05.locatie [dbc locatie],
        t50.omschr [dbc specialisme oms],
        t05.icd10,
        t05.zorgprod,
        t05.hoofddbc,
        1 as [dbc aantal],
        cast(t05.faktuurdat as date) faktuurdatum,
        t05.declcode,
        t05.verzekerin,
        t80.foutstatus,
        t80.foutcode,
        cast(t80.omschrijv as nvarchar(max)) [foutcode oms],
        t10.verwijzer,
        t10.typeverw,
        case when t10.bronid = '' then null else t10.bronid end bronid ,
        case when t10.bron = '' then null else t10.bron end bron,
        t05.vervallen,
        t05.KLEUR,
        case
            when t05.KLEUR = 'G' then 'Groen'
            when t05.KLEUR = 'R' then 'Rood. Machtiging vereist.'
            when t05.KLEUR = 'O' then 'Oranje. Aanspraak ZVW.'
            else t05.KLEUR end as [kleur oms],
        t05.STATUS,
        case
            when t05.status = 'X' then 'Niet gefactureerd'
            when t05.status = 'D' then 'Aangeleverd'
            when t05.status = 'N' then 'Niet declarabel'
            when t05.einddat is null then 'Openstaand'
            else t05.status end [status oms]
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
     left join EPISODE_ZORGVRAA t60
      on t05.SPECIALISM = t60.SPECIALISM
       and t05.ZORGVRAAG = t60.CODE
       and cast(t05.BEGINDAT as date) > isnull(t60.DATUM, '19000101')
       and cast(t05.BEGINDAT as date) < isnull(t60.EINDDATUM, '29991231')
     left join EPISODE_ZORGTYPE t70
      on t05.ZORGTYPE = t70.CODE
       and cast(t05.BEGINDAT as date) > isnull(t70.BEGINDAT, '19000101')
       and cast(t05.BEGINDAT as date) < isnull(t70.EINDDAT, '29991231')
     left join EPISODE_DBCFLOG t80
      on t05.DBCNUMMER = t80.DBCNUMMER
    where t05.vervallen = 0
     and cast(t05.BEGINDAT as date) >= @start
) t1

delete from #HiXzorgproducten where not exists ( select '' from FAKTUUR_VERRICHT s00 where s00.CASENR = #HiXzorgproducten.DBCNUMMER );
```