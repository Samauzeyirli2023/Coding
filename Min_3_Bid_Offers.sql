select u.FullName,case when u.UserId in (901050,901006,901069,901074,15,901075,901073,1059,901085,901071,901070,901007) then 'Foreign' else 'Local' end as Types,
ISNULL(sum(OneOffer)+sum(TwoOffer) +sum(ThreePlusOffer),0) Total_Offers
,ISNULL(sum(OneOffer),0) OneOffer,
ISNULL(sum(TwoOffer),0) TwoOffer,
ISNULL(sum(ThreePlusOffer),0) ThreePlusOffer,
Count(distinct RequestId) RFQ, Month
from (select b.BidNumber Bid_Number,bl.LineNumber Bid_Line_Number,count(bod.baseprice) Count_Offer,u.UserId,

case when count(bod.id)=1 then 1 else 0 end as 'OneOffer',
case when count(bod.id)=2 then 1 else 0 end as 'TwoOffer',
case when count(bod.id)>=3 then 1 else 0 end as 'ThreePlusOffer',
prl.RequestId,Month(prl.CreatedDate) Month
,u.FullName Procurement_Specialist
from one_bid.Bids b
left join one_bid.BidLines bl on bl.BidId=b.BidId
left join one_bid.BidOfferDetails bod on bl.Id=bod.bidlineid
left join one_bid.BidOffers bo on bod.BidOfferId=bo.Id
left join Users u on u.UserId=b.CreatedUserId
left join PRRequestLines prl on prl.RequestLineId = bl.RequestLineId
left join PRRequestHeaders prh on prh.RequestId = prl.RequestId
where bod.baseprice is not null and bod.baseprice!=0  and prh.ModuleEntryDestinationId <> 6
and b.StatusId=1 and b.CreatedUserId!=2 and prl.CreatedDate>'2023-02-28'
and b.TypeId not in
(300027,300031)
group by bl.LineNumber,b.BidNumber,u.FullName,u.UserId,prl.RequestId,prl.CreatedDate) c
right join Users u on u.UserId = c.UserId
where u.UserId in (
901050,901006,901069,901074,19,15,901075,901073,1059,901014,901085,49,900003,17,901070,1080,901007,1099)
group by u.FullName,u.UserId,Month;


