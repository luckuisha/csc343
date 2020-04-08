--QUERY 1
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1 (
  open_count INT NOT NULL,
  cave_count INT NOT NULL,
  deep_count INT NOT NULL
  );

--Sites paired with bookings at that site
DROP VIEW IF EXISTS SiteAndBooking CASCADE;
CREATE OR REPLACE VIEW SiteAndBooking AS SELECT * 
FROM Site, Booking
WHERE s_id = site_id;

--Sites with a cave dives AND a monitor available at some time for cave dives there
DROP VIEW IF EXISTS HasCave CASCADE;
CREATE OR REPLACE VIEW HasCave AS SELECT *
FROM SiteANDBooking, Monitor, MonitorPrivilege
WHERE
--Monitor offers cave
max_cave > 0 
AND MonitorPrivilege.site_id_of_privilege = SiteANDBooking.s_id
AND Monitor.m_id = MonitorPrivilege.monitor_id_with_privileges
--Site offers cave
AND (max_daylight_cave> 0 OR max_night_cave > 0);


--Sites with open dives AND a monitor available at some time for open dives there
DROP VIEW IF EXISTS HasOpen CASCADE;
CREATE OR REPLACE VIEW HasOpen AS SELECT *
FROM SiteANDBooking, Monitor, MonitorPrivilege
WHERE 
--Monitor offers open
max_open > 0 
AND MonitorPrivilege.site_id_of_privilege = SiteANDBooking.site_id
AND Monitor.m_id = MonitorPrivilege.monitor_id_with_privileges
--Site offers open
AND (max_daylight_open >0 OR max_night_open > 0);

--Sites with deep dives AND a monitor available at some time for deep dives there
DROP VIEW IF EXISTS HasDeep CASCADE;
CREATE OR REPLACE VIEW HasDeep AS SELECT *
FROM SiteANDBooking, Monitor, MonitorPrivilege
WHERE
--Monitor offers deep
max_deep > 0
AND MonitorPrivilege.site_id_of_privilege = SiteANDBooking.site_id
AND Monitor.m_id = MonitorPrivilege.monitor_id_with_privileges
--Site offers deep
AND (max_daylight >0 OR max_night_deep > 0);

DROP VIEW IF EXISTS Answer CASCADE;
CREATE OR REPLACE VIEW Answer AS SELECT 
(SELECT count(DISTINCT site_id) FROM HasOpen) AS open_count,
(SELECT count(DISTINCT site_id) FROM HasCave) AS cave_count,
(SELECT count(DISTINCT site_id) FROM HasDeep) AS deep_count;

INSERT INTO q1 (SELECT * FROM Answer);

