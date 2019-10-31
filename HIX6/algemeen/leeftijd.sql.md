# @Source leeftijd.sql

Dit is een voorbeeld met een dbc datum. Vervang door iedere andere datum to van welke de datum berekend moet worden

```sql
datediff (yy, t10.gebdat, cast(t00.[dbc begindatum] as date)) +
			case 
              when dateadd(yy, datediff(yy, t10.gebdat, cast(t00.[dbc begindatum] as date)),  t10.gebdat) > cast (t00.[dbc begindatum] as date)
			  then -1
			  else 0
end leeftijd
```