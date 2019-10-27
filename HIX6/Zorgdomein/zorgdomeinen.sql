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
  and exists (select '' from #HiXzorgproducten s00 where s00.PATIENTNR = t00.PATIENTID)
  and t30.ZOEKCODE = 'MDL'
order by verwijsdatum desc