select FullName,case when c.ForeignLocalId=2 then 'Foreign' else 'Local' end as Types,
Count(distinct RequestId) TotalRFQ,Count(distinct Requestlinelineid)  TotalLines,Count( distinct BidLineId) HasOffer,
Count(SaleNumber) HasSo,Count(PurchaseNumber) HasPo,Count(RequestLineId) CancelledLines,Month, sum(returnid) ReturnId
from 
	(select case when (bidlineid is null and RequestLineId is not null) or (returnid=0 and ForeignLocalId=1 and Status=23099) then null                        -- bid yaranmamis cancel edilen sorgular nezere alinmir;daxili bazarin legv edilmis sorgularini cixiriq
 				 else RequestId end RequestId,	Month,u.FullName,Requestlineid ,case when (BidLineId is not null and RequestLineId is not null) or             --bid yaranmamis cancel edilen sorgular nezere alinmir
				 (returnid=1) then null else SaleNumber end SaleNumber,case when returnid=1 then null else PurchaseNumber end PurchaseNumber,			       --deaktiv sorgularin elaqeli senedlerini goturmuruk 
				 case when BidLineId is  null and RequestLineId is not null then null else Requestlinelineid end Requestlinelineid,u.UserId,returnid,
				 Status,case when returnid=1 then null else BidLineId end BidLineid,ForeignLocalId,supforeign
	from Users u 
			 left join
			(select distinct prl.RequestId,MONTH(prl.CreatedDate) Month ,prloh.UserId,prloh.Status,prlx.RequestLineId,so.SaleNumber,po.PurchaseNumber,
				prl.RequestLineId Requestlinelineid,bl.requestlineid BidLineId,s.ForeignLocalId supforeign,pt.ForeignLocalId,
				 case when pt.ForeignLocalId=1							  --ancaq local userleri filterlesin 
					   and s.ForeignLocalId=1							  --ancaq daxili supplierleri filterlesin
			           and Status=23099									  --bize daxilin qiymet vere bilmediyi case-ye baxmaq lazimdir, odur ki statusu legvde olsun
			           and b.CreatedUserId!=prloh.UserId			      --eger daxili bazar ozu evvel bid yaradibsa onu goturme
			           and bod.isselected=1							      --bid ancaq secildiyi muddetde kecerlidir
			           and b.CreatedUserId  in						      --xarici bazar userlerinin yaratdigi bidleri gotur imenni
					   (901050,901006,901069,901074,15,901075,
					   901073,1059,901085,901071,901070,901007) 
					   and s.SupplierCode not in ('V-000104','V-000313')   --Lalenin jotunlarini nezere almaq lazimdir
					   then 1 else 0 end as returnid			           --daxilin qiymet vere bilmediyi ama xaricin daxilden qiymet tapa bildiyini gosterir; per line isleyir
					   ,b.CreatedUserId
							from  PRRequestLineOfferHeaders prloh  
							left join PRRequestLines prl on prloh.RequestLineId = prl.RequestLineId
							left join PRRequestHeaders prh on prh.RequestId = prl.RequestId
							left join one_bid.BidLines bl on bl.RequestLineId = prl.RequestLineId
							left join one_bid.Bids b on b.bidid = bl.bidid
							left join PRRequestLines prlx on prlx.RequestLineId = prl.RequestLineId and 
							prlx.DocumentTypeStageId in (20015,311052,3020015,3311052,4020015,4311052,8120015,8411052)
							left join ModuleTypeStages mts on mts.Id=prl.DocumentTypeStageId
							left join ModuleStages ms on ms.Id=mts.StageId
							left join SaleOrderLines sol on sol.RequestLineId = prl.RequestLineId
							left join SaleOrders so on so.SaleOrderId = sol.SaleOrderId and so.TypeStageId not in 
							(90027,90028,90029  ,310111 ,310118 ,310124 ,3090027,3090028,3090029,4090027,4090028,4090029,8190027,8190028,8190029)
							left join PurchaseOrderLines pol on pol.RequestLineId = sol.RequestLineId
							left join PurchaseOrders po on pol.PurchaseOrderId = po.PurchaseOrderId  and po.StatusId = 1 and po.TypeStageId not in 
							(50024,50025,50026,260035,260045,260053,310092,310098,310105,310024,320024,3050024,3050025,3050026,4050024,4050025,4050026,8150024,8150025,8150026)
							left join Suppliers s on s.SupplierCode = prl.SupplierCode
							left join ProcurementTeam pt on pt.userid = prloh.UserId      --aktiv userler ucun
							left outer join one_bid.BidStageInfos bsi on bsi.BidId = bl.BidId and  bsi.ActionId in 
							(90248  ,90734  ,90848  ,90908  ,90974  ,3090248,4091042,3090734,4091025,3090908,3090974,4090248,4090734,4090908,4090974)
							left join one_bid.BidOfferDetails bod on bod.bidlineid=bl.Id
							where prl.CreatedDate >'2023-02-28'	and prh.StatusId = 1 and prh.CreatedUserId != 2 and prl.StatusId = 1 and prloh.UserId != 2                                                            
							and  (prl.SupplierCode not in (N'V-000220',N'V-000621',N'V-000012','V-000211') or prl.SupplierCode is null) and prh.ModuleEntryDestinationId <> 6 
							group by  prl.RequestId, prloh.UserId,prlx.RequestLineId,so.SaleNumber,po.PurchaseNumber,prl.RequestLineId,
							bl.RequestLineId,prl.CreatedDate,prloh.Status,s.ForeignLocalId,pt.ForeignLocalId,b.CreatedUserId,bod.IsSelected,s.SupplierCode
							having case when pt.ForeignLocalId=1 and isnull(s.ForeignLocalId,0)=2 and Status=23099 then 1 else 0 end !=1									--daxili userin yarada bilmediyi bide xarici user xaricden qiymet verib
							and case when pt.ForeignLocalId=1 and isnull(s.ForeignLocalId,0)=1 and Status=23099 and prloh.UserId=b.CreatedUserId then 1 else 0 end !=1      --daxili userler arasinda sorgu gedib gelib+evvelki user bid yaradib,legv edilmisleri cixiriQ
							and case when pt.ForeignLocalId=2 and Status=23099  then 1 else 0 end != 1)																        --xarici userin legv edilmis sorgularini goturmuruk
			dataset on dataset.UserId = u.UserId
			where u.UserId in (901050,901006,901069,901074,19,15,901075,901073,1059,901014,901085,49,900003,17,901070,1080,901007,1099,901071) 
	) c
	where requestid is not null
group by FullName,c.UserId,Month,RequestId,c.ForeignLocalId



