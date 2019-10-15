# @Source verrichtingen.sql

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
), 
cte_artsen as (
    select
        t00.artscode,
        case when isnull(t00.sigcode+''+t00.liszcode, '') = ''
        then null
        else t00.sigcode+''+t00.liszcode end as artscode_landelijk,
        ltrim(case when isnull(achternaam,'') = '' then '' else ltrim(achternaam)  COLLATE database_default + ' ' end
           +
           case when isnull(achternaam,'') <> '' and isnull(meisjesnaa,'') <> '' then ' - ' else '' end
           +
           case when isnull(meisjesnaa,'') = '' then '' else ltrim(meisjesnaa) + ' ' end
           +
           case when isnull(voorvoegm,'') = '' then '' else lower(voorvoegm)  end
            +
           case when isnull(voorvoega,'') = '' then '' else lower(voorvoega) + ' ' end
           +
           case when isnull(voorletter,'') = '' then '' else voorletter end) specialist_naam,
        case
        when isnull(t00.Specialism, '') = ''
        then null
        else t00.Specialism end specialisme_code,
        t10.omschr specialisme,
        t10.cotgcode agb_specialisme_nr,
        t00.geslacht,
        cast(t00.gebdat as date) geboortedatum,
        cast(t00.begindat as date) begindatum,
        cast(t00.eindedat as date) einddatum,
        case
        when isnull(t00.trajspec, '') = ''
        then null else
        t00.trajspec end trajectspecialisme,
        t00.artstype,
        t20.omschr artstype_oms,
        t00.zorgvsoort,
        case t00.zorgvsoort
            when '00' then 'n.v.t.'
            when '01' then 'Huisarts'
            when '02' then 'Apotheker'
            when '03' then 'Medisch specialist'
            when '04' then 'Fysiotherapeut'
            when '05' then 'Logopedist'
            when '06' then 'Ziekenhuis'
            when '08' then 'Verloskundige'
            when '11' then 'Tandarts specialist mondziekten en kaakchirurgie'
            when '12' then 'Tandarts algemeen practicus'
            when '13' then 'Tandartsspecialist dentomaxillaire orthopedie'
            when '14' then 'Bedrijfsarts'
            when '18' then 'Dialysecentrum'
            when '20' then 'Radiotherapeutisch centrum'
            when '22' then 'Zelfstandig behandelcentrum'
            when '24' then 'Diëtist'
            when '30' then 'Verstandelijk gehandicapten'
            when '32' then 'GGD'
            when '37' then 'Gezondheidscentrum'
            when '38' then 'Tandheelkundig centurm'
            when '39' then 'Regionale instelling voor jeugdtandzorg'
            when '41' then 'Beheerstichtingen verpleeghuizen, verzorgingsh. en thuiszorg'
            when '42' then 'Verzorgingstehuis'
            when '44' then 'Optometrist'
            when '45' then 'Verpleeginrichting somatische ziekten'
            when '46' then 'Verpleeginrichtingen psychogeriatrische patiënten'
            when '47' then 'Gecombineerde verpleeginrichting'
            when '50' then 'Laboratoria'
            when '57' then 'Physician assistant'
            when '66' then 'Beheerstichtingen gezinsvervangende tehuizen, dagv. en zwakzinnigeninst.'
            when '73' then 'AWBZ-gecombineerd'
            when '74' then 'ARBO-diensten'
            when '84' then 'Overige arts'
            when '87' then 'Mondhygiënist'
            when '88' then 'Ergotherapeut'
            when '90' then 'Genezer'
            when '91' then 'Verpleegkundige en kraamverzorgers A'
            when '94' then 'Psycholoog'
            when '98' then 'Declarant'
            else null end zorgvsoort_oms,
        case
            when isnull(t00.tbicode, '') = '' then null
            else t00.tbicode end as tbicode,
        t30.tbitype,
        t30.naam tbinaam,
        t00.postcode,
        t00.adres,
        case when t00.artstype = 'E' and t00.FACTTBI = 1 and t30.TBITYPE = 'W' then 'Ja' else 'Nee' end [wds]
    from CSZISLIB_ARTS t00
     left join CSZISLIB_SPEC t10
      on t00.specialism =  t10.speccode
     left join CSZISLIB_ARTSTYPE t20
      on t00.artstype =  t20.code
      left join CSZISLIB_TBI  t30
      on  t00.tbicode = t30.tbicode
       and getdate() between isnull(t30.begindat, '19000101') and isnull(t30.eindedat, '29991213')
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
      cast(null as nvarchar(10)) rekcode,
      cast(null as nvarchar(10)) zorgprofielklasse,
      t00.uitvoerder as uitvoerder_code,
      t25.specialist_naam as specialist_naam_uitvoerder,
      t25.specialisme_code as specialisme_code_uitvoerder,
      t00.aanvrager as aanvrager_code,
      t20.specialist_naam as specialist_naam_aanv,
      t20.specialisme_code as specialisme_code_aanvrager,
      t10.kostplaats as kostenplaats,
      t00.faktuurnum,
      cast(t00.faktuurdat as date) as faktuurdatum,
      case t10.FAKTURATIESTATUS
           when 'PRKA' then 'Parkeren automatisch'
           when 'PRKH' then 'Parkeren handmatig'
           when 'PEND' then 'Declaratie verzonden'
           when 'APPR' then 'Declaratie goedgekeurd'
           when 'DECL' then 'Declaratie afgekeurd'
           when 'DONE' then 'Declaratie afgekeurd (afgehandeld)'
      else t10.FAKTURATIESTATUS end fakturatiestatus,
      t00.verzekerin as instantie,
      t00.casenr dbcnummer,
      t00.opnamenr opnamenummer,
      t00.refnummer referentie,
      t00.bron,
      t00.afdeling,
      t00.locatie,
--      case when substring(isnull(t10.correctie,'      '),4,1) <> '1' then 'Nee' else 'Ja' end as correctie,
      t10.bronstatus,
      case when t10.bronstatus  = 'P' then 'Gepland'
           when t10.bronstatus  = 'A' then 'Geaccodeerd'
           when t10.bronstatus  = 'V' then 'Voorlopig'
           else 'Geaccodeerd' end [status oms],
      t10.bedragspec,
      t10.bedragziek,
      t10.aantal as aantal_uitgevoerd,
      case 
      when case when isnull(t10.ctgcode, '') = '' then t40.codedecl else t10.ctgcode end in ( '191117', '993010' ) then 'Ja'
      when t20.specialisme in ( 'XNOK', 'XHAAG' ) then 'Ja'
      else t20.wds end as [wds],
      FORMAT(getdate(), N'yyyy-MM-dd hh:mm') as draaimoment
    from [dbo].faktuur_verricht t00
     join [dbo].faktuur_verrsec  t10
      on t00.id = t10.id
     left join cte_artsen t20 -- aanvrager
      on t00.aanvrager = t20.ARTSCODE
     left join cte_artsen t25 -- uitvoerder
      on t00.uitvoerder = t25.ARTSCODE
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
      and substring(isnull(t10.correctie,'      '),4,1) <> '1'
--      and t25.SPECIALISM in ( 'CAR', 'HEE', 'APO' )
      -- and coalesce(t10.ctgcode, t40.codedecl) = #filter op declaratiecode
) t1

update t00
set t00.zorgprofielklasse = t10.zorgklasse
from #ezisfakt t00
 join episode_dbcverro t10
  on t00.declaratiecode = t10.code
where t10.begindatum is not null
  and t10.einddatum is null
  and isnull(t10.zorgklasse, '') <> ''

 /*
 || Rekcode is relevant voor dure geneesmiddelen, maar wie weet voor nog meer?
 */

if object_id('tempdb..#faktuur_vercode') is not null drop table #faktuur_vercode;
select *
into #faktuur_vercode
from (
    select
        code,
        cast(isnull(begindatum, '19000101') as date) begindatum,
        cast(isnull(blokvanaf, '29990101') as date) blokvanaf,
        AFDELING,
        rekcode,
        row_number() over(partition by code, afdeling, isnull(blokvanaf, '29990101') order by isnull(begindatum, '19000101') desc) as teller
    from FAKTUUR_VERCODE
    where AFDELING <> 'CBVO'
     and isnull(rekcode, '') <> ''
) t1


update t00
set t00.rekcode = t70.rekcode
from #ezisfakt t00
 join #faktuur_vercode t70
      on t00.AFDELING = t70.AFDELING
       and t00.invoercode = t70.CODE
       and t00.verrichtingsdatum < t70.BLOKVANAF
       and t00.verrichtingsdatum > t70.begindatum
where isnull(t00.rekcode, '') = ''
 and t70.teller =  1

/*
|| Medicatie dingen. Aantal is anders of zo.
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

/*
|| Check of er een WDS DBC is
*/

if object_id('tempdb..#HiXzorgproductenWDS') is not null drop table #HiXzorgproductenWDS;
select * into #HiXzorgproductenWDS
from (
    select  distinct
        t05.dbcnummer
    from [dbo].episode_episode t00
     join [dbo].episode_dbcper t05
      on t00.episode = t05.episode
     join #ezisfakt t10
      on t05.DBCNUMMER = t10.dbcnummer
     where t05.vervallen = 0
       and t05.ZORGTYPE = 'W'
) t1

update t00
set t00.wds = 'Ja'
from #ezisfakt t00
 join #HiXzorgproductenWDS t10
  on t00.dbcnummer = t10.DBCNUMMER
where t00.wds = 'Nee';

select *
from #ezisfakt
-- where correctie = 'nee'
order by verrichtingsdatum
```