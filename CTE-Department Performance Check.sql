use OneData_Universal
go
with Omt as(
   select ph.RequestNumber,pl.LineNumber,plsi.ApproveDate,pl.RequestLineId,ph.StatusId
   from PRRequestHeaders ph
   left join PRRequestLines pl on ph.RequestId=pl.RequestId
   left join PRRequestLineStageInfoes plsi on plsi.RequestLineId=pl.RequestLineId
   left join ModuleTypeStages mts on mts.Id=pl.DocumentTypeStageId
   left join ModuleActions ma on ma.FromTypeStageId=mts.Id
   where plsi.actionid=2148 and
   pl.StatusId=1 and ph.CreatedUserId!=2 and ph.StatusId=1
   group by ph.RequestNumber,pl.LineNumber,plsi.ApproveDate,pl.RequestLineId,ph.StatusId),
Delegation as
   (select ph.RequestNumber,pl.LineNumber,plsi.ApproveDate,pl.RequestLineId,ph.StatusId
   from PRRequestHeaders ph
   left join PRRequestLines pl on ph.RequestId=pl.RequestId
   left join PRRequestLineStageInfoes plsi on plsi.RequestLineId=pl.RequestLineId
   left join ModuleTypeStages mts on mts.Id=pl.DocumentTypeStageId
   left join ModuleActions ma on ma.FromTypeStageId=mts.Id
   where plsi.actionid=90258 and
   pl.StatusId=1 and ph.CreatedUserId!=2 and ph.StatusId=1
   group by ph.RequestNumber,pl.LineNumber,plsi.ApproveDate,pl.RequestLineId,ph.StatusId),
bazar_qiym_secilmesi as
   (select ph.RequestNumber,pl.LineNumber,plsi.ApproveDate,pl.RequestLineId,ph.StatusId
   from PRRequestHeaders ph
   left join PRRequestLines pl on ph.RequestId=pl.RequestId
   left join PRRequestLineStageInfoes plsi on plsi.RequestLineId=pl.RequestLineId
   left join ModuleTypeStages mts on mts.Id=pl.DocumentTypeStageId
   left join ModuleActions ma on ma.FromTypeStageId=mts.Id
   where plsi.actionid=90338 and
   pl.StatusId=1 and ph.CreatedUserId!=2 and ph.StatusId=1
   group by ph.RequestNumber,pl.LineNumber,plsi.ApproveDate,pl.RequestLineId,ph.StatusId),
alis_icra as
   (select ph.RequestNumber,pl.LineNumber,plsi.ApproveDate,pl.RequestLineId,ph.StatusId
   from PRRequestHeaders ph
   left join PRRequestLines pl on ph.RequestId=pl.RequestId
   left join PRRequestLineStageInfoes plsi on plsi.RequestLineId=pl.RequestLineId
   left join ModuleTypeStages mts on mts.Id=pl.DocumentTypeStageId
   left join ModuleActions ma on ma.FromTypeStageId=mts.Id
   where plsi.actionid=90385 and
   pl.StatusId=1 and ph.CreatedUserId!=2 and ph.StatusId=1
   group by ph.RequestNumber,pl.LineNumber,plsi.ApproveDate,pl.RequestLineId,ph.StatusId)
select distinct(f.RequestNumber),f.LineNumber,
CAST(f.OMT_Delegation_minute / 1440 AS VARCHAR(8)) + 'd ' +
CAST((f.OMT_Delegation_minute % 1440) / 60 AS VARCHAR(8)) + 'h ' +
FORMAT(f.OMT_Delegation_minute % 60, 'D2') + 'min' AS OMT_Delegation,
CAST(f.Delegation_Bazar_minute / 1440 AS VARCHAR(8)) + 'd ' +
CAST((f.Delegation_Bazar_minute % 1440) / 60 AS VARCHAR(8)) + 'h ' +
FORMAT(f.Delegation_Bazar_minute % 60, 'D2') + 'min' AS Delegation_Bazar,
CAST(f.Bazar_Alis_minute / 1440 AS VARCHAR(8)) + 'd ' +
CAST((f.Bazar_Alis_minute % 1440) / 60 AS VARCHAR(8)) + 'h ' +
FORMAT(f.Bazar_Alis_minute % 60, 'D2') + 'min' AS Bazar_Alis
from
(select distinct(Omt.RequestNumber),Omt.LineNumber,omt.StatusId,
DATEDIFF(day, omt.ApproveDate,Delegation.ApproveDate) as OMT_Delegation_day,
DATEDIFF(hour, omt.ApproveDate,Delegation.ApproveDate) as OMT_Delegation_hour,
DATEDIFF(minute,omt.ApproveDate,Delegation.ApproveDate) as OMT_Delegation_minute,
DATEDIFF(day, Delegation.ApproveDate,bazar_qiym_secilmesi.ApproveDate) as Delegation_Bazar_day,
DATEDIFF(hour, Delegation.ApproveDate,bazar_qiym_secilmesi.ApproveDate) as Delegation_Bazar_hour,
DATEDIFF(minute, Delegation.ApproveDate,bazar_qiym_secilmesi.ApproveDate) as Delegation_Bazar_minute,
DATEDIFF(DAY, bazar_qiym_secilmesi.ApproveDate,alis_icra.ApproveDate) as Bazar_Alis_day,
DATEDIFF(HOUR,bazar_qiym_secilmesi.ApproveDate,alis_icra.ApproveDate) as Bazar_Alis_hour,
DATEDIFF(minute,bazar_qiym_secilmesi.ApproveDate,alis_icra.ApproveDate) as Bazar_Alis_minute
from Omt
left join Delegation on Delegation.RequestLineId=Omt.RequestLineId
left join bazar_qiym_secilmesi on bazar_qiym_secilmesi.RequestLineId=Omt.RequestLineId
left join alis_icra on alis_icra.RequestLineId=Omt.RequestLineId
where omt.StatusId=1 and omt.ApproveDate>'2023-01-05'
group by omt.RequestNumber,omt.LineNumber,omt.ApproveDate,Delegation.ApproveDate,bazar_qiym_secilmesi.ApproveDate,
alis_icra.ApproveDate,Omt.StatusId) as f
group by f.RequestNumber,f.LineNumber,f.OMT_Delegation_minute,Delegation_Bazar_minute,f.Bazar_Alis_minute