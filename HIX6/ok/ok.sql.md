# @source: ok.sql

Let op: deze selectie bevat de hoofdverrichting, en verder alleen informatie over de totale OK

```sql
if object_id('tempdb..#operaties') is not null drop table #operaties;
select * into #operaties
from (
   select
      t00.operatienr,
      t00.STATUS,
      t00.zkh_nr as patientnummer,
      t00.specialism as [specialisme code],
      t20.OMSCHR as [specialisme oms],
      cast(t00.operatie_d as date) as operatiedatum,
      cast(t00.aanvraag_d as date) aanvraagdatum,
      t00.typeverric as [soort opname],
      t60.VER_CODE hoofdverrichting, -- Eerste verrichting?
      t00.okkamer,
      t10.omschr,
      t00.gp_okkamer,
      cast(t00.gp_datum as date) gp_datum,
      t00.gp_sessienr,
      t00.gp_van,
      t00.gp_duur,
      dateadd(mi, t00.gp_van, t00.gp_datum) [Geplande starttijd],
      dateadd(mi, t00.gp_van+t00.gp_duur, t00.gp_datum) [Geplande eindtijd],
      dateadd(mi, t00.t_bellen,   t00.operatie_d) Gebeld,
      dateadd(mi, t00.t_okcomplx, t00.operatie_d) [Op complex],
      dateadd(mi ,t00.bt_ok, t00.operatie_d) [Aankomst Operatiekamer],
      dateadd(mi, t00.bt_anaest,  t00.operatie_d) [Start inleiding],
      dateadd(mi, t00.et_inleidi, t00.operatie_d) [Eind inleiding],
      dateadd(mi, t00.bt_operati, t00.operatie_d) [Start operateur],
      dateadd(mi, case when t00.et_ok = 0 then t00.t_naarafd else t00.et_ok end,  t00.operatie_d) [Eind uitleiding/vertrek OK],
      dateadd(mi, t00.t_naarafd,  t00.operatie_d) [Vertrek Verkoever],
      dateadd(mi, t00.t_voorber,  t00.operatie_d) tijd_voorber,
      dateadd(mi, t00.et_anaest,  t00.operatie_d) eindtijd_anaest,
      dateadd(mi, t00.et_operati, t00.operatie_d) eindtijd_operati,
      dateadd(mi, t00.bt_uitleid, t00.operatie_d) begintijd_uitleid,
      dateadd(mi, t00.t_recovery, t00.operatie_d) tijd_recovery,
      datediff(mi, dateadd(mi, case when isnull(t00.bt_ok, 0) = 0 then t00.BT_OPERATI else t00.bt_ok end, t00.operatie_d),
          dateadd(mi, case when t00.et_ok = 0 then t00.ET_OPERATI else t00.ET_OK end, t00.operatie_d)) [ok duur],
      t00.verw_duur [verwachte duur],
      cast(t00.aanmaak_d as date) as [op wachtlijst],
      t00.prioriteit,
      t00.anaesttech,
      t40.omschr Anesthesietechniek_oms,
      case when t00.prioriteit = 's' then 'ja' else 'nee' end as [spoed?]
   from ok_okinfo t00
    left join ok_okkamers t10
     on t10.code =  t00.okkamer
    left join CSZISLIB_SPEC t20
     on t00.SPECIALISM = t20.SPECCODE
    left join OK_ANATECH t40
     on t00.anaesttech = t40.code
    left join  [dbo].ok_okclustr t50
     on t00.OPERATIENR = t50.OPERATIENR
    left join [dbo].ok_okver t60 
     on t60.okid = t50.hoofdver
   where t00.STATUS = 'P'
    and t00.operatie_d between '..' AND '..'
) t1

select *
from #operaties
order by operatiedatum
```