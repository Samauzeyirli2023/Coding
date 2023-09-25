select FullName,RFQ,userid,
case when UserId in (901050,901006,901069,901074,15,901075,901073,1059,901085,901071,901070,901007) then 'Foreign' else 'Local' end as Types ,
Count(distinct RFQ) TotalRFQ,
Count( distinct HasOfferId) HasOffer,Count(distinct HasSoId) HasSo,Count(distinct HasPoId) HasPo,Count(distinct Cancel) Cancelled, Month
from
				(select case when (HasOfferId is null and Cancel is not null) or (returnid=0 and ForeignLocalId=1 and Status=23099) then null                  
 					else RequestId end RequestId,	Month,u.FullName,RequestId RFQ,case when (HasOfferId is not null and Cancel is not null) or         
					(returnid=1) then null else HasSoId end HasSoId,case when returnid=1 then null else HasPoId end HasPoId,			        
					case when HasOfferId is  null and Cancel is not null then null else Cancel end Cancel,u.UserId,returnid,
					Status,case when returnid=1 then null else HasOfferId end HasOfferId,ForeignLocalId,supforeign
from Users u
left join
				(select prl.RequestId,Month(prl.createddate) Month,plof.UserId,plof.Status, prlx.RequestId Cancel,hasso.HasSoId,haspo.HasPoId,bidoffer.HasOfferId,
					   s.ForeignLocalId supforeign,pt.ForeignLocalId,
					   case when pt.ForeignLocalId=1							
					   and s.ForeignLocalId=1						
			           and Status=23099									  
			           and b.CreatedUserId!=plof.UserId			     
			           and bod.isselected=1							     
			           and b.CreatedUserId  in						      
					   (901050,901006,901069,901074,15,901075,
					   901073,1059,901085,901071,901070,901007) 
					   and s.SupplierCode not in ('V-000104','V-000313')   
					   then 1 else 0 end as returnid			           
					   ,b.CreatedUserId
							from   PRRequestLineOfferHeaders plof 
							left outer join PRRequestLines prl on prl.RequestLineId = plof.RequestLineId and prl.CreatedDate >'2023-03-01' and prl.StatusId = 1 
							left outer join PRRequestHeaders prh on prh.RequestId = prl.RequestId and  prh.StatusId = 1  
							left outer join one_bid.BidLines bl on bl.RequestLineId = prl.RequestLineId
							left outer join one_bid.Bids b on b.bidid = bl.bidid
							left outer join one_bid.BidOfferDetails bod on bod.bidlineid=bl.Id
							left outer join one_bid.BidOffers bo on bo.Id=bod.BidOfferId
							left outer join PRRequestLines prlx on prlx.RequestLineId = prl.RequestLineId and prlx.DocumentTypeStageId in (
							20015,311052,3020015,3311052,4020015,4311052,8120015,8411052
							) and prlx.PriceProcurement is null
							left outer join ModuleTypeStages mts on mts.Id=prl.DocumentTypeStageId
							left outer join ModuleStages ms on ms.Id=mts.StageId
							left outer join Suppliers s on s.SupplierCode = prl.SupplierCode
							left outer join ProcurementTeam pt on pt.userid = plof.UserId  
							left outer join (
										select distinct prl.RequestId as HasOfferId from PRRequestLines prl 
										inner join one_bid.BidLines bl on bl.RequestLineId = prl.RequestLineId
										where prl.CreatedDate >'2023-03-01' and prl.StatusId = 1 and bl.StatusId=1 and bl.CreatedUserId!=2 and prl.CreatedUserId!=2
							) bidoffer on bidoffer.HasOfferId = prl.RequestId and b.CreatedUserId=plof.UserId
							left outer join (
										select distinct prl.RequestId HasPoId  from PRRequestLines prl 
										inner join PurchaseOrderLines pol on pol.RequestLineId = prl.RequestLineId
										inner join PurchaseOrders po on pol.PurchaseOrderId = po.PurchaseOrderId 
										where prl.CreatedDate >'2023-03-01' and prl.StatusId = 1  and po.TypeStageId not in 
										(50024,50025,50026,260035,260045,260053,310092,310098,310105,310024,320024,3050024,
										3050025,3050026,4050024,4050025,4050026,8150024,8150025,8150026) and po.StatusId = 1
							) haspo on haspo.HasPoId = prl.RequestId
							left outer join (
										select distinct prl.RequestId HasSoId  from PRRequestLines prl 
										inner join SaleOrderLines sol on sol.RequestLineId = prl.RequestLineId
										inner join SaleOrders so on sol.SaleOrderId = so.SaleOrderId 
										where prl.CreatedDate >'2023-03-01' and prl.StatusId = 1 and so.TypeStageId not in
										(90027,90028,90029  ,310111 ,310118 ,310124 ,3090027,3090028,3090029,4090027
										,4090028,4090029,8190027,8190028,8190029) and so.StatusId = 1
							) hasso on hasso.HasSoId = prl.RequestId
							where prl.CreatedDate >'2023-03-01' and prh.StatusId = 1 and prh.CreatedUserId != 2 and prl.StatusId = 1 and plof.UserId != 2                                                            
							and  (prl.SupplierCode not in (N'V-000220',N'V-000621',N'V-000012','V-000211'
							) or prl.SupplierCode is null) and prh.ModuleEntryDestinationId <> 6			
							group by  prl.RequestId, plof.UserId,prlx.RequestId,hasso.HasSoId,haspo.HasPoId,bidoffer.HasOfferId
							,prl.CreatedDate,s.ForeignLocalId,pt.ForeignLocalId,plof.Status,b.CreatedUserId,bod.IsSelected,s.SupplierCode
							having case when pt.ForeignLocalId=1 and isnull(s.ForeignLocalId,0)=2 and Status=23099 then 1 else 0 end !=1								
							and case when pt.ForeignLocalId=1 and isnull(s.ForeignLocalId,0)=1 and Status=23099 and 
							plof.UserId=b.CreatedUserId then 1 else 0 end !=1      
							and case when pt.ForeignLocalId=2 and Status=23099  then 1 else 0 end != 1
							) dataset on dataset.UserId = u.UserId
where  u.UserId in (
901050,901006,901069,901074,19,15,901075,901073,1059,901014,901085,49,900003,17,901070,1080,901007,1099,901071)) c
where requestid is not null 
group by FullName,UserId,Month,RFQ,userid    
