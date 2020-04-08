DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4 (
    site_id INT,
    highest_price FLOAT,
    lowest_price FLOAT,
	avg_price FLOAT
);

--Assumptions
--Bookings can only occur at the beginning of the time slot 
--all our tables' information are correct
--average fee is per person without including the monitor
--output will not include sites without any bookings as it would be useless information

DROP VIEW IF EXISTS diverFees CASCADE;
CREATE VIEW diverFees AS
SELECT booking.site_id, 
	booking.timeSlot_of_dive,
	booking.date_of_dive, 
	booking.type_of_dive, 
	booking.num_divers AS capacity,
	site.site_fee, 
	monitor.price_morning_open, 
	monitor.price_morning_cave, 
	monitor.price_morning_deep, 
	monitor.price_afternoon_open, 
	monitor.price_afternoon_cave, 
	monitor.price_afternoon_deep, 
	monitor.price_night_open, 
	monitor.price_night_cave, 
	monitor.price_night_deep
FROM booking, site, monitor
WHERE booking.site_id = site.s_id
	AND booking.monitor_id = monitor.m_id;


DROP VIEW IF EXISTS MorningOpenAndPricePerDiver CASCADE;
CREATE VIEW MorningOpenAndPricePerDiver AS
SELECT (price_morning_open + site_fee)/(capacity-1) AS price_per_Diver, 
	site_id
FROM diverFees
WHERE type_of_dive = 'open'
	AND timeSlot_of_dive = 'morning';

SELECT * FROM MorningOpenAndPricePerDiver;

DROP VIEW IF EXISTS MorningCaveAndPricePerDiver CASCADE;
CREATE VIEW MorningCaveAndPricePerDiver AS
SELECT (price_morning_cave + site_fee)/(capacity-1) AS price_per_Diver, 
	site_id
FROM diverFees
WHERE type_of_dive = 'cave'
	AND timeSlot_of_dive = 'morning';
	
SELECT * FROM MorningCaveAndPricePerDiver;

DROP VIEW IF EXISTS MorningDeepAndPricePerDiver CASCADE;
CREATE VIEW MorningDeepAndPricePerDiver AS
SELECT (price_morning_deep + site_fee)/(capacity-1) AS price_per_Diver, 
	site_id
FROM diverFees
WHERE type_of_dive = 'deep'
	AND timeSlot_of_dive = 'morning';
	
SELECT * FROM MorningDeepAndPricePerDiver;

DROP VIEW IF EXISTS AfternoonOpenAndPricePerDiver CASCADE;
CREATE VIEW AfternoonOpenAndPricePerDiver AS
SELECT (price_afternoon_open + site_fee)/(capacity-1) AS price_per_Diver, 
	site_id
FROM diverFees
WHERE type_of_dive = 'open'
	AND timeSlot_of_dive = 'afternoon';
	
SELECT * FROM AfternoonOpenAndPricePerDiver;

DROP VIEW IF EXISTS AfternoonCaveAndPricePerDiver CASCADE;
CREATE VIEW AfternoonCaveAndPricePerDiver AS
SELECT (price_afternoon_cave + site_fee)/(capacity-1) AS price_per_Diver, 
	site_id
FROM diverFees
WHERE type_of_dive = 'cave'
	AND timeSlot_of_dive = 'afternoon';
	
SELECT * FROM AfternoonCaveAndPricePerDiver;
	
DROP VIEW IF EXISTS AfternoonDeepAndPricePerDiver CASCADE;
CREATE VIEW AfternoonDeepAndPricePerDiver AS
SELECT (price_afternoon_deep + site_fee)/(capacity-1) AS price_per_Diver, 
	site_id
FROM diverFees
WHERE type_of_dive = 'deep'
	AND timeSlot_of_dive = 'afternoon';
	
SELECT * FROM AfternoonDeepAndPricePerDiver;
	
DROP VIEW IF EXISTS NightOpenAndPricePerDiver CASCADE;
CREATE VIEW NightOpenAndPricePerDiver AS
SELECT (price_night_open + site_fee)/(capacity-1) AS price_per_Diver, 
	site_id
FROM diverFees
WHERE type_of_dive = 'open'
	AND timeSlot_of_dive = 'night';
	
SELECT * FROM NightOpenAndPricePerDiver;

DROP VIEW IF EXISTS NightCaveAndPricePerDiver CASCADE;
CREATE VIEW NightCaveAndPricePerDiver AS
SELECT (price_night_cave + site_fee)/(capacity-1) AS price_per_Diver, 
	site_id
FROM diverFees
WHERE type_of_dive = 'cave'
	AND timeSlot_of_dive = 'night';
	
SELECT * FROM NightCaveAndPricePerDiver;

DROP VIEW IF EXISTS NightDeepAndPricePerDiver CASCADE;
CREATE VIEW NightDeepAndPricePerDiver AS
SELECT (price_night_deep + site_fee)/(capacity-1) AS price_per_Diver, 
	site_id
FROM diverFees
WHERE type_of_dive = 'deep'
	AND timeSlot_of_dive = 'night';
	
SELECT * FROM NightDeepAndPricePerDiver;
	
DROP VIEW IF EXISTS AllCapacityAndPrice CASCADE;
CREATE VIEW AllCapacityAndPrice AS
(SELECT * FROM MorningOpenAndPricePerDiver)
	UNION All
(SELECT * FROM MorningCaveAndPricePerDiver)
	UNION All
(SELECT * FROM MorningDeepAndPricePerDiver)
	UNION All
(SELECT * FROM AfternoonOpenAndPricePerDiver)
	UNION All
(SELECT * FROM AfternoonCaveAndPricePerDiver)
	UNION All
(SELECT * FROM AfternoonDeepAndPricePerDiver)
	UNION All
(SELECT * FROM NightOpenAndPricePerDiver)
	UNION All
(SELECT * FROM NightCaveAndPricePerDiver)
	UNION All
(SELECT * FROM NightDeepAndPricePerDiver);

SELECT * FROM AllCapacityAndPrice;

insert into q4 
SELECT site_id, MAX(price_per_diver) AS highest_price,
    MIN(price_per_diver) AS lowest_price,
    AVG(price_per_diver) AS avg_price
FROM AllCapacityAndPrice
GROUP BY site_id;










