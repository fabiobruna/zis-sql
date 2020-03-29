# @Source opnames-bedden.sql

Minimale set informatie over bedden

```sql

set nocount on -- Stop de melding over aantal regels
set ansi_warnings on -- ISO foutmeldingen(NULL in aggregraat bv)
set ansi_nulls on -- ISO NULLL gedrag(field = null returns null, ook als field null is)

/** 
 *   @Source opnames-bedden.sql
 *   @Description 
 */

	SELECT  
        t20.afdeling+'|'+t20.kamer+'|'+cast(t20.bednr as varchar(12)) BedKey,
		t00.locatie,
		t00.CODE AFDELING, 
		t20.kamer,
		t20.bednr,
		case when t25.bednr is null then 'Nee' else 'Ja' end as [Geblokkeerd bed],
		cast(t25.[EINDDAT] as date) [EindDatum blokkade],
		cast(t25.[INGDAT] as date) [IngangsDatum blokkade],
		isnull(t26.[Omschrijving], '') [Reden blokkade]
	FROM [dbo].OPNAME_AFDELING t00
	  JOIN [dbo].OPNAME_KAMER t10
	    on t10.AFDELING = t00.CODE
	  JOIN [dbo].OPNAME_BEDDEN t20 
		ON t20.AFDELING = t10.afdeling 
	    and t20.kamer = t10.kamer
	  left join [dbo].[OPNAME_OPNBLOKBED] t25
		on t20.afdeling+'|'+t20.kamer+'|'+cast(t20.bednr as varchar(12)) = t25.AFDELING+'|'+t25.kamer+'|'+cast(t25.bednr as varchar(12))
		and getdate() BETWEEN t25.[INGDAT]+ISNULL(NULLIF(t25.[INGTIJD],''), '00:00') AND t25.[EINDDAT]+t25.[EINDTIJD]
	   left join [dbo].[OPNAME_BLOKBEDREDE] t26
		on t25.BlokReden = t26.Code
	 where t00.ACTIEF = 1
		and t10.ACTIEF = 1
		and t20.ACTIEF = 1
```