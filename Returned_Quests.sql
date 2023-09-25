with Local_Foreign as
(select ploh.requestid,ploh.RequestLineId,u.UserId UserId1,u.FullName Procurement_Specialist,ploh1.UserId,u1.FullName Procurement_Specialist1
--,count(distinct ploh.RequestId) Total_Returned_PR, count(distinct ploh.RequestLineId) Total_Returned_Line_Count
,pl.CreatedDate
from 
PRRequestHeaders ph
left join PRRequestLines pl on pl.RequestId=ph.RequestId
left join PrRequestLineOfferHeaders ploh on ploh.RequestLineId=pl.RequestLineId and ploh.[Status]=2301
 and ploh.UserId not in(901050,901006,901069,901074,15,901075,901073,1059,901085,901071,901070,901007)
left join PrRequestLineOfferHeaders ploh1 on ploh1.RequestLineId=pl.RequestLineId and ploh1.[Status]=23099
and ploh1.UserId not in(901050,901006,901069,901074,15,901075,901073,1059,901085,901071,901070,901007)
left join Users u on u.UserId=ploh.UserId
left join Users u1 on u1.UserId=ploh1.UserId
where pl.CreatedDate>'2023-02-28' and pl.StatusId=1 and pl.createduserid!=2 and ph.TypeId = 20001 and ph.ModuleEntryDestinationId = 2
and ploh.UserId=ploh1.UserId),
Foreign_Local as
(select ploh.requestid,ploh.RequestLineId,ploh1.UserId UserId2,u1.FullName Procurement_Specialist2,u.UserId,u.FullName Procurement_Specialist,
pl.CreatedDate
--,count(distinct ploh.RequestId) Total_Returned_PR, count(distinct ploh.RequestLineId) Total_Returned_Line_Count
from 
PRRequestHeaders ph
left join PRRequestLines pl on pl.RequestId=ph.RequestId
left join PrRequestLineOfferHeaders ploh on ploh.RequestLineId=pl.RequestLineId and ploh.[Status]=23099
 and ploh.UserId not in(901050,901006,901069,901074,15,901075,901073,1059,901085,901071,901070,901007)
left join PrRequestLineOfferHeaders ploh1 on ploh1.RequestLineId=pl.RequestLineId and ploh1.[Status]=23099
and ploh1.UserId in(901050,901006,901069,901074,15,901075,901073,1059,901085,901071,901070,901007)
left join Users u on u.UserId=ploh.UserId
left join Users u1 on u1.UserId=ploh1.UserId
where pl.CreatedDate>'2023-02-28' and pl.StatusId=1 and pl.createduserid!=2  and ph.ModuleEntryDestinationId <> 6
and ploh.UserId!=ploh1.UserId
group by ploh.RequestId,ploh.RequestLineId,u.UserId,u.FullName,ploh1.UserId,u1.FullName,pl.CreatedDate
)
select distinct Local_Foreign.Procurement_Specialist,count(distinct Local_Foreign.RequestId) Total_Returned_PR,
count(distinct Local_Foreign.RequestLineId)
Total_Returned_Line_Count,Month(Local_Foreign.createddate) Month
from Local_Foreign 
left join Foreign_Local on Foreign_Local.RequestId=Local_Foreign.RequestId
where Local_Foreign.RequestLineId=Foreign_Local.RequestLineId
group by Local_Foreign.Procurement_Specialist,Local_Foreign.CreatedDate



