

```sql
WITH lijst_van_vragen(childid, lijstid, treelayid, volgnr, rlevel)
AS
(
 SELECT t00.childid, t00.lijstid, t00.treelayid, t00.volgnr, 0 AS rlevel
  FROM vrlijst_treelay t00
 WHERE t00.lijstid = '#########'              -- AAN TE PASSEN ID
UNION ALL
 SELECT a.childid, a.lijstid, l.treelayid, l.volgnr, l.rlevel + 1
 FROM lijst_van_vragen l
 JOIN vrlijst_treelay a
  ON l.childid = a.lijstid
)

SELECT t00.lijstid, t00.volgnr, t10.vraagid, t10.stelling, t00.rlevel
FROM lijst_van_vragen t00
 JOIN vrlijst_vragen t10
  ON t00.childid = t10.vraagid
  ORDER BY t00.volgnr
```  