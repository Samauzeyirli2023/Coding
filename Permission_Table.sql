SELECT a.employees,
    a.timetable,
    a.timetable::date AS timetable0,
    concat(a.month_name, ' ', a.day) AS "time",
    a.year,
    a.month,
    a.day,
    a.absenceduration,
    COALESCE(a.minutesabsence, 0::numeric) AS minutesabsence,
    concat(a.fromdate0, '-', a.todate0) AS permission
   FROM ( SELECT he.id,
            concat(he."FirstName", ' ', he."LastName") AS employees,
            hc."CompanyName",
            hd."DepartmentName",
            httt.indate0 AS timetable,
            to_char(httt.indate0::time(0) without time zone::interval, 'HH24:MI:SS'::text) AS intime,
            to_char(httt.outdate0::time(0) without time zone::interval, 'HH24:MI:SS'::text) AS outtime,
            hs."ScheduleName",
            c.year,
            c.month,
            to_char(to_timestamp(c.month::text, 'MM'::text), 'TMmon'::text) AS month_name,
            (EXTRACT(hour FROM hat."ToDate")::text || ':'::text) || lpad(EXTRACT(minute FROM hat."ToDate")::text, 2, '0'::text) AS todate0,
            (EXTRACT(hour FROM hat."FromDate")::text || ':'::text) || lpad(EXTRACT(minute FROM hat."FromDate")::text, 2, '0'::text) AS fromdate0,
            c.week,
            c.day,
                CASE
                    WHEN httt.indate0::time(0) without time zone < hs."InDate" AND hr."ReasonName" IS NULL THEN 0
                    ELSE 1
                END AS late,
            hr."ReasonName",
                CASE
                    WHEN hr."ReasonName" IS NOT NULL THEN concat(EXTRACT(hour FROM hat."ToDate" - hat."FromDate"), ' hours ', EXTRACT(minute FROM hat."ToDate" - hat."FromDate"), ' minutes')
                    ELSE NULL::text
                END AS absenceduration,
            round(EXTRACT(epoch FROM hat."ToDate" - hat."FromDate") / 60::numeric) AS minutesabsence,
                CASE
                    WHEN httt.outdate0::time(0) without time zone > hs."OutDate" THEN concat(to_char(httt.outdate0::time(0) without time zone - hs."OutDate", 'HH24 hrs MI "minutes" SS "seconds"'::text), ' late')
                    WHEN httt.outdate0 IS NULL THEN NULL::text
                    WHEN httt.outdate0::time(0) without time zone < hs."OutDate" THEN concat(to_char(hs."OutDate" - httt.outdate0::time(0) without time zone, 'HH24 hrs MI "minutes" SS "seconds"'::text), ' early')
                    WHEN httt.outdate0::time(0) without time zone = hs."OutDate" THEN 'On Time'::text
                    ELSE NULL::text
                END AS exit_duration,
                CASE
                    WHEN httt.indate0::time(0) without time zone > hs."InDate" THEN concat(to_char(httt.indate0::time(0) without time zone - hs."InDate", 'HH24 hrs MI "minutes" SS "seconds"'::text), ' late')
                    WHEN httt.indate0 IS NULL THEN NULL::text
                    WHEN httt.indate0::time(0) without time zone < hs."InDate" THEN concat(to_char(hs."InDate" - httt.indate0::time(0) without time zone, 'HH24 hrs MI "minutes" SS "seconds"'::text), ' early')
                    WHEN httt.indate0::time(0) without time zone = hs."InDate" THEN 'On Time'::text
                    ELSE NULL::text
                END AS enterance_duration,
                CASE
                    WHEN httt.outdate0::time(0) without time zone > hs."OutDate" THEN 1
                    WHEN httt.outdate0::time(0) without time zone < hs."OutDate" THEN 0
                    WHEN httt.outdate0::time(0) without time zone IS NULL THEN NULL::integer
                    ELSE NULL::integer
                END AS outcondition,
                CASE
                    WHEN httt.indate0::time(0) without time zone > hs."InDate" THEN 1
                    WHEN httt.indate0::time(0) without time zone < hs."InDate" THEN 0
                    WHEN httt.indate0::time(0) without time zone IS NULL THEN NULL::integer
                    ELSE NULL::integer
                END AS incondition
           FROM calendar c
             LEFT JOIN hrapp_transactions ht ON ht."Day" = c.day AND ht."Year" = c.year AND ht."Month" = c.month
             LEFT JOIN ( SELECT htt."ProgramID",
                    htt."Day",
                    htt."Month",
                    htt."Year",
                    min(htt."InDate") AS indate0,
                    max(htt."OutDate") AS outdate0
                   FROM hrapp_transactions htt
                  GROUP BY htt."ProgramID", htt."Day", htt."Month", htt."Year") httt ON httt."Day" = c.day AND httt."Year" = c.year AND httt."Month" = c.month AND httt."ProgramID" = ht."ProgramID"
             LEFT JOIN hrapp_programemployees pgp ON ht."ProgramID" = pgp."ProgramID"
             LEFT JOIN hrapp_employees he ON pgp."Emp_id" = he.id
             LEFT JOIN hrapp_scheduletypes hs ON he."ScheduleType_id" = hs.id
             LEFT JOIN hrapp_companies hc ON hc.id = he."CompanyId_id"
             LEFT JOIN hrapp_departments hd ON hd.id = he."Department_id"
             LEFT JOIN hrapp_absencetransactions hat ON hat."Emp_id" = he.id AND c.date::date >= hat."FromDate"::date AND c.date::date <= hat."ToDate"::date
             LEFT JOIN hrapp_reasons hr ON hat."Reason_id" = hr.id
          WHERE he."FirstName" IS NOT NULL) a
  GROUP BY a.employees, a.id, a."CompanyName", a."DepartmentName", a.timetable, a.intime, a.outtime, a."ScheduleName", a.year, a.month, a.month_name, a.week, a.day, a.late, a."ReasonName", a.absenceduration, a.minutesabsence, a.enterance_duration, a.exit_duration, a.todate0, a.fromdate0
  ORDER BY a.month;


