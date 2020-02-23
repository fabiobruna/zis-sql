# @Source DAX/percentage-from-total.md

In DAX kun je niet het totaal van een kolom of rij bepalen. Met deze formule kun wel het totaal van de tabel gebruiken. Mits je de kubus of je rapport goed opzet werkt dit hetzelfde.
Voorbeeld, aantal verzuimmeldingen percentage t.o.v. een totaal.

```dax
% Verzuimmeldingen:= 
    'Σ Verzuim'[# Verzuimmeldingen] /
    Calculate(
        SUM(Verzuim[AantalEindigendeVerzuimgevallen]);
        'Σ Verzuim';
        ALLSELECTED()
    )
```