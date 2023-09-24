SELECT
    he."id",
    CONCAT(he."FirstName", ' ', he."LastName") AS Employees,
    hc."CompanyName",
    hd."DepartmentName",
    httt.InDate0 AS TimeTable,
    TO_CHAR(httt.InDate0::time(0), 'HH24:MI:SS') AS InTime,
    TO_CHAR(httt.OutDate0::time(0), 'HH24:MI:SS') AS OutTime,
    hs."ScheduleName",
    c."year",
    c."month",
    TO_CHAR(to_timestamp(c."month"::text, 'MM'), 'TMmon') AS Month_Name,
    c."week",
    c."day",
    CASE WHEN httt.InDate0::time(0) < hs."InDate" AND hr."ReasonName" IS NULL THEN 0 ELSE 1 END AS Late,
    hr."ReasonName",
    dt."TypeName" AS ReasonName1,
    CASE WHEN hr."ReasonName" IS NOT NULL THEN
        (CONCAT(EXTRACT(DAY FROM (hat."ToDate" - hat."FromDate")), ' days ', EXTRACT(HOUR FROM (hat."ToDate" - hat."FromDate")), ' hours ',
        EXTRACT(MINUTE FROM (hat."ToDate" - hat."FromDate")), ' minutes'))
    ELSE NULL END AS AbsenceDuration,
    round(EXTRACT(EPOCH FROM (hat."ToDate" - hat."FromDate")::interval) / 60) AS MinutesAbsence,
    CASE WHEN httt.OutDate0::time(0) > hs."OutDate" THEN
        concat(to_char((httt.OutDate0::time(0) - hs."OutDate"), 'HH24 hrs MI "minutes" SS "seconds"'), ' <span style="color: #08BCB0; font-weight: bold;">' || 'late' || '</span>')
    WHEN httt.OutDate0 IS NULL THEN NULL
    ELSE concat(to_char((hs."OutDate" - httt.OutDate0::time(0)), 'HH24 hrs MI "minutes" SS "seconds"'), ' <span style="color: #E56B70; font-weight: bold;">' || 'early' || '</span>') END AS Exit_Duration,
    CASE WHEN httt.InDate0::time(0) > hs."InDate" THEN
        concat(to_char((httt.InDate0::time(0) - hs."InDate"), 'HH24 hrs MI "minutes" SS "seconds"'), ' <span style="color: #08BCB0; font-weight: bold;">' || 'late' || '</span>')
    WHEN httt.InDate0 IS NULL THEN NULL
    ELSE concat(to_char((hs."InDate" - httt.InDate0::time(0)), 'HH24 hrs MI "minutes" SS "seconds"'), ' <span style="color: #E56B70; font-weight: bold;">' || 'early' || '</span>') END AS Enterance_Duration,
    CASE WHEN httt.OutDate0::time(0) > hs."OutDate" THEN 1
    WHEN httt.OutDate0::time(0) < hs."OutDate" THEN 0
    ELSE NULL END AS OutCondition,
    CASE WHEN httt.InDate0::time(0) > hs."InDate" THEN 1
    WHEN httt.InDate0::time(0) < hs."InDate" THEN 0
    ELSE NULL END AS InCondition,
    hs."InDate"
FROM calendar c
LEFT JOIN hrapp_transactions ht ON ht."Day" = c."day" AND ht."Year" = c."year" AND ht."Month" = c."month"
left join (SELECT htt."ProgramID",htt."Day",htt."Month",htt."Year",min(htt."InDate") InDate0,max(htt."OutDate") OutDate0 FROM hrapp_transactions htt
group by htt."ProgramID",htt."Day",htt."Month",htt."Year") httt on httt."Day"=c."day" and httt."Year"=c."year" and httt."Month"=c."month" and httt."ProgramID"=ht."ProgramID"
left join hrapp_programemployees pgp on ht."ProgramID"=pgp."ProgramID"
left join hrapp_employees he on pgp."Emp_id"=he."id"
left join hrapp_scheduletypes hs on he."ScheduleType_id"=hs.id 
left join hrapp_companies hc on hc."id"=he."CompanyId_id"
LEFT JOIN hrapp_departments hd on hd."id"=he."Department_id"
left join hrapp_absencetransactions hat on hat."Emp_id"=he."id" and ((c."date"::timestamp::date) between (hat."FromDate"::timestamp::date) and ((hat."ToDate"::timestamp::date)))
left join hrapp_documenttypes dt on dt."id"=hat."DocumentType_id"
left join hrapp_documentstages dts on dts."id"=hat."DocumentTypeStage_id" and dts."id"=4
left join hrapp_reasons hr on hat."Reason_id"=hr."id"
where he."FirstName" is not NULL 
GROUP BY
    he."id",he."FirstName",he."LastName",hc."CompanyName",hd."DepartmentName",httt.InDate0,httt.OutDate0,hs."ScheduleName",c."year",
    c."month",c."week", c."day",hs."InDate",hr."ReasonName",dt."TypeName",hat."ToDate",hat."FromDate",hs."OutDate"