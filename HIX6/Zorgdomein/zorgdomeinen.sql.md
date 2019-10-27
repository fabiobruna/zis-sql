@Source zorgdomeinen.sql

```sql
/** 
 *   @Source zorgdomeinen.sql
 *   @Description Snippet zorgdomein
 *   @Mutaties: http://dwh.mchaaglanden.local/gitphp/?sort=age
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

    exec tempdb..sp_columns '#';

    datediff(yy, @geboortedatum, @rekendatum) +
    case when dateadd(yy, datediff(yy, @geboortedatum, @rekendatum),  @geboortedatum) > @rekendatum
       then -1
       else 0
       end age

    [nt-vm-dwh-p3].dwh_ezis.dbo.
    [vm-dwhsql-t1].hmcbi
    [vm-dwhsql-t1].curedwh
    [HIXR.mchbrv.nl].[HIX_PRODUCTIE].[dbo].
*/


select
  t00.id, 
  cast(t00.[verwdate] as date) verwijsdatum, 
  charindex('Code:', t00.verwtext),
  substring(t00.verwtext, 10, charindex('Code:', t00.verwtext)-10) locatie,
  substring(t00.verwtext, charindex('Code:', t00.verwtext)+6, cast(charindex('Product:', t00.verwtext) as int) - cast(charindex('Code:', t00.verwtext)+6 as int)) Code,
  case when charindex('Productcode:', t00.verwtext) = 0 
	   then null 
	   else substring(t00.verwtext, charindex('Productcode:', t00.verwtext)+13, cast(charindex('Reden:', t00.verwtext) as int) - cast(charindex('Productcode:', t00.verwtext)+13 as int)) end Productcode,
  case when charindex('Reden:', t00.verwtext) = 0 
	   then null 
	   else substring(t00.verwtext, charindex('Reden:', t00.verwtext)+7, cast(charindex('Type:', t00.verwtext) as int) - cast(charindex('Reden:', t00.verwtext)+7 as int)) end Reden,
  case when charindex('Type:', t00.verwtext) = 0 
	   then null 
	   else substring(t00.verwtext, charindex('Type:', t00.verwtext)+6, cast(charindex('Toegangstijd:', t00.verwtext) as int) - cast(charindex('Type:', t00.verwtext)+6 as int)) end Type,
  case when charindex('Toegangstijd:', t00.verwtext) = 0 
	   then null 
	   else substring(t00.verwtext, charindex('Toegangstijd:', t00.verwtext)+13, len(t00.verwtext) - cast(charindex('Toegangstijd:', t00.verwtext)+13 as int)) end Type,
  t30.zoekcode, 
--  t00.verwtext, 
  cast('' as varchar(255)) afgeleidtype, 
  t00.statusid, 
  t00.patientid
FROM [dbo].[webagen_verwijs] t00
  left join [dbo].[webagen_agvrwvrg] t10 
	on t10.id = t00.verwvrg    
  left join [dbo].[webagen_agvrwtyp] t20
	on t20.id = t10.typid
  left join [dbo].[webagen_agvrwcat] t30 
  on t30.id = t20.catid
where LEFT(t00.EXTID,2) = 'ZD' 
--  and exists (select '' from #HiXzorgproducten s00 where s00.PATIENTNR = t00.PATIENTID)
--  and t30.ZOEKCODE = 'MDL'
order by verwijsdatum desc
```