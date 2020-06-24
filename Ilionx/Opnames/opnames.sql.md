@Source opnames.sql

```sql
/** 
 *   @Source opnames.sql
 *   @Description basis selecie opnames op de Ilionx database
 *   @Mutaties: https://vm-dwhdevops-p1.mchaaglanden.local/DefaultCollection/
 */

set nocount on -- Stop de melding over aantal regels
set ansi_warnings on -- ISO foutmeldingen(NULL in aggregraat bv)
set ansi_nulls on -- ISO NULLL gedrag(field = null returns null, ook als field null is)

/** 
    [nt-vm-dwh-p3].dwh_ezis.dbo.
    [vm-dwhsql-t1].hmcbi
    [vm-dwhsql-t1].curedwh
    [HIXR.mchbrv.nl].[HIX_PRODUCTIE].[dbo].
*/

  use curedwh;

	select
		t00.PatientKey patientnr,
		t20.OpnametypeOmschrijving,
		t00.Opnamenummer,
		t00.Opnamedatum,
		t30.AfdelingCode,
		t30.AfdelingOmschrijving
	from CureDWH.dmtm.Opnames_FactOpnames t00
	 join CureDWH.dmtm.Opnames_DimOpnametype t20
	  on t00.OpnametypeKey = t20.OpnametypeKey
	 join CureDWH.dmtm.Opnames_DimAfdeling t30
	  on t00.OpnameAfdelingKey = t30.AfdelingKey
where 1=1
```