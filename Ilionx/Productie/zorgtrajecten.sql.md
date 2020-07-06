@Source zorgtrajecten.sql

```sql
/** 
 *   @Source zorgtrajecten.sql
 *   @Description basis selecie zorgtrajecten op de Ilionx database
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


  select top 100
    t20.Preferentnummer patientnr,
    t00.DBCNummer,
    t00.DBCBegindatum,
    t00.DBCEinddatum,
    t70.ZorgtypeCodeLandelijk,
    t70.ZorgtypeCode,
    t70.ZorgtypeOmschrijving,
    t10.ArtsCode,
	  t10.ArtsNaam,
    t10.SpecialismeCode,
	  t10.SpecialismeOmschrijving,
	  t80.DiagnoseCode,
	  t80.DiagnoseOmschrijving,
	  t30.Declaratiecode,
    sum(t00.Kostprijs) Kostprijs,
    sum(t00.Facturatiebedrag) Facturatiebedrag, 
    sum(t00.Aantal) Aantal
  from DMTm.Productie_FactZorgtrajecten t00
    join DMTm.Algemeen_DimArts t10
      on t00.UitvoerderKey = t10.ArtsKey
    join DMTm.Algemeen_DimPatient t20
      on t00.PatientKey = t20.PatientKey
	  left join dmtm.Productie_DimDBCDeclaratiecode t30
	    on t00.DeclaratiecodeKey = t30.DeclaratiecodeKey
    left join DMTm.Productie_DimZorgtype t70
      on t00.ZorgtypeKey = t70.ZorgtypeKey
    left join dmtm.Productie_DimDBCDiagnose t80
      on t00.DBCDiagnoseKey = t80.DBCDiagnoseKey
  where 1=1
   and t00.IsLeegTraject = 'Nee'
   and t00.IsDBCVervallen = 'Nee'
--   and t00.IsAddon = 'Nee'
  group by 
    t20.Preferentnummer patientnr,
    t00.DBCNummer,
    t00.DBCBegindatum,
    t00.DBCEinddatum,
    t70.ZorgtypeCodeLandelijk,
    t70.ZorgtypeCode,
    t70.ZorgtypeOmschrijving,
    t10.ArtsCode,
	  t10.ArtsNaam,
    t10.SpecialismeCode,
	  t10.SpecialismeOmschrijving,
	  t80.DiagnoseCode,
	  t80.DiagnoseOmschrijving,
	  t30.Declaratiecode
```