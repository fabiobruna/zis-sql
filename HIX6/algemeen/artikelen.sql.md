# @Source artikelen.sql

```sql
if object_id('tempdb..#artikelen') is not null drop table #artikelen;
select *
into #artikelen 
from (
    select 
        t00.artcode, 
        t00.arcode atc_code,
        substring(t00.arcode, 1, 3) as atc_code_rekening,
        cast(null as nvarchar(12)) rekening,
        t00.artbroncod,
        t00.omschr,
        t00.langomschr,
        t00.zinummer,
        t10.HPKODE [zindex artikelobject HPKODE],
        t10.NMETIK [zindex artikelobject NMETIK],
        t10.NMNM40 [zindex artikelobject NMNM40],
        t10.NMNAAM [zindex artikelobject NMNAAM],
        t20.NMETIK [Handelsproduct NMETIK],
        t20.NMNM40 [Handelsproduct NMNM40],
        t20.NMNAAM [Handelsproduct NMNAAM],
        t20.MSNAAM [Handelsproduct MSNAAM],
        t20.PRKODE [Handelsproduct PRKODE],
        t30.NMETIK [Voorschrijfproducten NMETIK],
        t30.NMNM40 [Voorschrijfproducten NMNM40],
        t30.NMNAAM [Voorschrijfproducten NMNAAM],
        t30.GPKODE [Voorschrijfproducten GPKODE],
        t40.NMETIK [Generiek product NMETIK],
        t40.NMNM40 [Generiek product NMNM40],
        t40.NMNAAM [Generiek product NMNAAM]
    from LOGISTK_ARTIKEL t00
     left join ZINDEX_004 t10 -- zindex artikelobject
      on t00.ARTCODE = t10.ATKODE
     left join ZINDEX_031 t20 -- Handelsproduct
      on t10.HPKODE = t20.HPKODE
     left join ZINDEX_050 t30 -- Voorschrijfproducten
      on t20.PRKODE = t30.PRKODE
     left join ZINDEX_711 t40
      on t30.GPKODE = t40.GPKODE
) t1

update t00
set t00.zinummer = '-'
from #artikelen t00
where isnull(ZINUMMER, '') = '';
```