--QUERY 2
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2(
    monitor_id INT, 
    avg_booking_fee FLOAT, 
    email VARCHAR(50)
);
    

--Average rating of each monitor
DROP VIEW IF EXISTS AverageMonitorRatings CASCADE;
CREATE OR REPLACE VIEW AverageMonitorRatings AS 
SELECT monitor_id_of_rating, avg(MonitorRating) AS avg_MonitorRating
FROM MonitorRating
GROUP BY monitor_id_of_rating;

--Average rating of each site
DROP VIEW IF EXISTS AverageSiteRatings CASCADE;
CREATE OR REPLACE VIEW AverageSiteRatings AS
SELECT site_id, avg(SiteRating) AS avg_SiteRating
FROM SiteRating  
GROUP BY site_id;


--Monitors paired with the sites they have privileges at, and average ratings of both
DROP VIEW IF EXISTS AllInfo CASCADE;
CREATE OR REPLACE VIEW AllInfo AS
SELECT *
FROM AverageMonitorRatings, AverageSiteRatings, MonitorPrivilege
WHERE monitor_id_with_privileges = monitor_id_of_rating
AND site_id_of_privilege = site_id;

--Monitors which have a lower or equal to average rating than at least one of the sites they work at
--(or who have no ratings)
DROP VIEW IF EXISTS HasLower CASCADE;
CREATE OR REPLACE VIEW HasLower AS
SELECT DISTINCT monitor_id_of_rating FROM AllInfo
WHERE avg_MonitorRating <= avg_SiteRating;

--Monitors that have a higher average rating than every site they work at,
--paired with all their bookings
DROP VIEW IF EXISTS RelevantMonitors CASCADE;
CREATE OR REPLACE VIEW RelevantMonitors AS
SELECT * FROM 
Monitor, Booking
WHERE 
monitor_id = m_id AND
m_id NOT IN (SELECT * FROM HasLower);


--Sums of every type of fee by monitor
DROP VIEW IF EXISTS MonitorMorningOpenFees CASCADE;
CREATE OR REPLACE VIEW MonitorMorningOpenFees AS
SELECT sum(price_morning_open)  filter (WHERE timeSlot_of_dive='morning' AND type_of_dive='open') AS MonitorMorningOpenFees, m_id AS m_o_id FROM
Monitor LEFT JOIN Booking
ON timeSlot_of_dive='morning' AND type_of_dive='open'
AND m_id = monitor_id
GROUP BY m_id;

DROP VIEW IF EXISTS MonitorMorningCaveFees CASCADE;
CREATE OR REPLACE VIEW MonitorMorningCaveFees AS
SELECT sum(price_morning_cave) filter (WHERE timeSlot_of_dive='morning' AND type_of_dive='cave') AS MonitorMorningCaveFees,m_id AS m_c_id FROM
Monitor LEFT JOIN Booking
ON timeSlot_of_dive='morning' AND type_of_dive='cave'
AND m_id = monitor_id
GROUP BY m_id;

DROP VIEW IF EXISTS MonitorMorningDeepFees CASCADE;
CREATE OR REPLACE VIEW MonitorMorningDeepFees AS
SELECT sum(price_morning_deep) filter (WHERE timeSlot_of_dive='morning' AND type_of_dive='deep') AS MonitorMorningDeepFees,m_id AS m_d_id FROM
Monitor LEFT JOIN Booking
ON timeSlot_of_dive='morning' AND type_of_dive='deep'
AND m_id = monitor_id
GROUP BY m_id;
--------------------------------------------------------

DROP VIEW IF EXISTS MonitorAfternoonOpenFees CASCADE;
CREATE OR REPLACE VIEW MonitorAfternoonOpenFees AS
SELECT sum(price_afternoon_open) filter (WHERE timeSlot_of_dive='afternoon' AND type_of_dive='open') AS MonitorAfternoonOpenFees, m_id AS a_o_id FROM
Monitor LEFT JOIN Booking
ON timeSlot_of_dive='afternoon' AND type_of_dive='open'
AND m_id = monitor_id
GROUP BY m_id;

DROP VIEW IF EXISTS MonitorAfternoonCaveFees CASCADE;
CREATE OR REPLACE VIEW MonitorAfternoonCaveFees AS
SELECT sum(price_afternoon_cave) filter (WHERE timeSlot_of_dive='afternoon' AND type_of_dive='cave') AS MonitorAfternoonCaveFees, m_id AS a_c_id FROM
Monitor LEFT JOIN Booking
ON timeSlot_of_dive='afternoon' AND type_of_dive='cave'
AND m_id = monitor_id
GROUP BY m_id;

DROP VIEW IF EXISTS MonitorAfternoonDeepFees CASCADE;
CREATE OR REPLACE VIEW MonitorAfternoonDeepFees AS
SELECT sum(price_afternoon_deep) filter (WHERE timeSlot_of_dive='afternoon' AND type_of_dive='deep') AS MonitorAfternoonDeepFees, m_id AS a_d_id FROM
Monitor LEFT JOIN Booking
ON timeSlot_of_dive='afternoon' AND type_of_dive='deep'
AND m_id = monitor_id
GROUP BY m_id;
--------------------------------------------------------------

DROP VIEW IF EXISTS MonitorNightOpenFees CASCADE;
CREATE OR REPLACE VIEW MonitorNightOpenFees AS
SELECT sum(price_night_open) filter (WHERE timeSlot_of_dive='night' AND type_of_dive='open') AS MonitorNightOpenFees, m_id AS n_o_id FROM
Monitor LEFT JOIN Booking
ON timeSlot_of_dive='night' AND type_of_dive='open'
AND m_id = monitor_id
GROUP BY m_id;

DROP VIEW IF EXISTS MonitorNightCaveFees CASCADE;
CREATE OR REPLACE VIEW MonitorNightCaveFees AS
SELECT sum(price_night_cave) filter (WHERE timeSlot_of_dive='night' AND type_of_dive='cave') AS MonitorNightCaveFees, m_id AS n_c_id FROM
Monitor LEFT JOIN Booking
ON timeSlot_of_dive='night' AND type_of_dive='cave'
AND m_id = monitor_id
GROUP BY m_id;

DROP VIEW IF EXISTS MonitorNightDeepFees CASCADE;
CREATE OR REPLACE VIEW MonitorNightDeepFees AS
SELECT sum(price_night_deep) filter (WHERE timeSlot_of_dive='night' AND type_of_dive='deep') AS MonitorNightDeepFees, m_id AS n_d_id FROM
Monitor LEFT JOIN Booking
ON timeSlot_of_dive='night' AND type_of_dive='deep'
AND m_id = monitor_id
GROUP BY m_id;

--Monitors paired with the total sum of fees they have ever collected
DROP VIEW IF EXISTS TotalMonitorFees CASCADE;
CREATE OR REPLACE VIEW TotalMonitorFees AS
SELECT (COALESCE (MonitorMorningOpenFees, 0) + COALESCE (MonitorMorningCaveFees, 0) + COALESCE(MonitorMorningDeepFees,0) 
+ COALESCE(MonitorAfternoonOpenFees, 0) + COALESCE(MonitorAfternoonCaveFees, 0) + COALESCE(MonitorAfternoonDeepFees, 0) 
+ COALESCE(MonitorNightOpenFees, 0) + COALESCE(MonitorNightCaveFees, 0) + COALESCE(MonitorNightDeepFees, 0)  ) AS sum_of_fees, m_o_id AS mo_id 

FROM MonitorMorningOpenFees, MonitorMorningCaveFees, MonitorMorningDeepFees, 

MonitorAfternoonOpenFees, MonitorAfternoonCaveFees, MonitorAfternoonDeepFees,

MonitorNightOpenFees, MonitorNightCaveFees, MonitorNightDeepFees

WHERE m_o_id= m_c_id
AND m_o_id= m_d_id

AND m_o_id= a_o_id
AND m_o_id= a_c_id
AND m_o_id= a_d_id

AND m_o_id= n_o_id
AND m_o_id= n_c_id
AND m_o_id= n_d_id;

--Total number of bookings each monitor has or will supervise
DROP VIEW IF EXISTS NumBookings CASCADE;
CREATE OR REPLACE VIEW NumBookings AS 
 SELECT count(monitor_id) AS numbookings, monitor_id AS mon_id
 FROM Booking
 GROUP BY monitor_id;

--Monitors paired with their average fees and emails (final answer)
DROP VIEW IF EXISTS AverageMonitorFees CASCADE;
CREATE OR REPLACE VIEW AverageMonitorFees AS
SELECT
DISTINCT m_id, ( (sum_of_fees)/(numbookings) ) AS avg_booking_fee, email

FROM NumBookings, TotalMonitorFees, RelevantMonitors
WHERE m_id = mon_id
AND mon_id = mo_id
AND m_id IN (SELECT m_id FROM RelevantMonitors);



INSERT INTO q2
SELECT * FROM AverageMonitorFees; 


