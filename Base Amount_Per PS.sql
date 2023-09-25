(SELECT distinct ph.RequestNumber,
	  sum(pl.BaseAmounProcurement) BaseAmounProcurement,
	  isnull(po.purchasenumber,'-') purchasenumber,isnull(so.salenumber,'-') salenumber,ph.CreatedDate,u.FullName tm,um.FullName sm,ms.StageName,
      right(ProcIdUsers, len(ProcIdUsers) - charindex(',', ProcIdUsers) + 0) Seperated_Proc_Ids from PRRequestLines pl
      left join PRRequestHeaders ph on pl.RequestId=ph.RequestId
      left join ModuleTypes mt on mt.Id=ph.TypeId
      left join ModuleTypeStages mts on mts.Id=ph.TypeStageId
      left join ModuleStages ms on ms.Id=mts.StageId
      left join SaleOrders so on so.RequestId=ph.RequestId
      left join Users u on pl.ProcIdUsers=u.userid
      left join users um on ph.ResponsiblePersonId=um.userid
      left join one_bid.BidLines b on b.RequestLineId = pl.RequestLineId
      left join PurchaseOrderLines pol on pol.RequestLineId = pl.RequestLineId
      left join PurchaseOrders po on po.PurchaseOrderId = pol.PurchaseOrderId
      WHERE ph.[Description] NOT LIKE '%test%' and ph.StatusId='1' and 
      ph.CreatedDate between '2022-06-01 00:00:00' and '2022-07-07 00:00:00' and ProcIdUsers is not null  
      group by ph.RequestNumber,po.purchasenumber,so.salenumber,PH.CreatedDate, ph.[Description],u.FullName,ms.StageName,pl.ProcIdUsers,um.FullName
union all
      select distinct a.RequestNumber,
	  sum(a.BaseAmounProcurement) BaseAmounProcurement,
	  isnull(a.purchasenumber,'-'),isnull(a.salenumber,'-'),a.CreatedDate,a.tm ,a.sm sm,a.StageName,
      Seperated_Proc_Ids from 
      (select ph.RequestNumber,
	  sum(pl.BaseAmounProcurement) BaseAmounProcurement,
	  isnull(po.purchasenumber,'-') purchasenumber,isnull(so.salenumber,'-') salenumber,ph.CreatedDate,u.FullName tm,um.FullName sm,ms.StageName, 
      case when charindex(',',ProcIdUsers) > 0 then left(ProcIdUsers, charindex(',', ProcIdUsers) - 1) end Seperated_Proc_Ids  FROM PRRequestLines pl
      left join PRRequestHeaders ph on pl.RequestId=ph.RequestId
      left join ModuleTypes mt on mt.Id=ph.TypeId
      left join ModuleTypeStages mts on mts.Id=ph.TypeStageId
      left join ModuleStages ms on ms.Id=mts.StageId
      left join SaleOrders so on so.RequestId=ph.RequestId
      left join Users u on pl.ProcIdUsers=u.userid
	  left join users um on ph.ResponsiblePersonId=um.userid
	  left join one_bid.BidLines b on b.RequestLineId = pl.RequestLineId
	  left join PurchaseOrderLines pol on pol.RequestLineId = pl.RequestLineId
	  left join PurchaseOrders po on po.PurchaseOrderId = pol.PurchaseOrderId
      WHERE ph.[Description] NOT LIKE '%test%' and ph.StatusId='1' and 
      ph.CreatedDate between '2022-06-01 00:00:00' and '2022-07-07 00:00:00' and ProcIdUsers is not null 
      group by ph.RequestNumber,po.purchasenumber,so.salenumber,PH.CreatedDate, ph.[Description],u.FullName,ms.StageName,um.FullName,pl.ProcIdUsers,ph.CreatedDate
	  ) a 
	  where a.Seperated_Proc_Ids is not null
	  group by a.RequestNumber,a.purchasenumber,a.salenumber,a.tm,a.StageName,a.sm,a.Seperated_Proc_Ids,a.CreatedDate) ) 


