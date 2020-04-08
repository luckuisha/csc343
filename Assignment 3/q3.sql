DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3 (
    avg_price_more_than_half_full FLOAT,
	avg_price_less_than_equal_half_full FLOAT
);

--Asumptions
--Bookings can only occur at the beginning of the time slot 
--Bookings must end at the end of the time slot (important for calculating percentage capacity)
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
	site.max_daylight_open, 
	site.max_night_open, 
	site.max_daylight_cave, 
	site.max_night_cave, 
	site.max_daylight_deep, 
	site.max_night_deep, 
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


DROP VIEW IF EXISTS capacityPercentageMorningOpenAndPricePerDiver CASCADE;
CREATE VIEW capacityPercentageMorningOpenAndPricePerDiver AS
SELECT (capacity-1)/max_daylight_open::FLOAT AS percentage, 
	(price_morning_open + site_fee)/(capacity-1) AS price_per_Diver, 
	site_id, date_of_dive
FROM diverFees
WHERE type_of_dive = 'open'
	AND timeSlot_of_dive = 'morning';

SELECT * FROM capacityPercentageMorningOpenAndPricePerDiver;

DROP VIEW IF EXISTS OpenMorningTotalCapacityAndPricePerDiver CASCADE;
CREATE VIEW OpenMorningTotalCapacityAndPricePerDiver AS
SELECT SUM(percentage) AS percentage, 
    AVG(price_per_diver) AS price_per_diver, 
    site_id
FROM capacityPercentageMorningOpenAndPricePerDiver
GROUP BY date_of_dive, site_id;

SELECT * FROM OpenMorningTotalCapacityAndPricePerDiver;

DROP VIEW IF EXISTS capacityPercentageMorningCaveAndPricePerDiver CASCADE;
CREATE VIEW capacityPercentageMorningCaveAndPricePerDiver AS
SELECT (capacity-1)/max_daylight_open::FLOAT AS percentage, 
	(price_morning_cave + site_fee)/(capacity-1) AS price_per_Diver, 
	site_id, date_of_dive
FROM diverFees
WHERE type_of_dive = 'cave'
	AND timeSlot_of_dive = 'morning';
	
SELECT * FROM capacityPercentageMorningCaveAndPricePerDiver;

DROP VIEW IF EXISTS CaveMorningTotalCapacityAndPricePerDiver CASCADE;
CREATE VIEW CaveMorningTotalCapacityAndPricePerDiver AS
SELECT SUM(percentage) AS percentage, 
    AVG(price_per_diver) AS price_per_diver, 
    site_id
FROM capacityPercentageMorningCaveAndPricePerDiver
GROUP BY date_of_dive, site_id;

SELECT * FROM CaveMorningTotalCapacityAndPricePerDiver;

DROP VIEW IF EXISTS capacityPercentageMorningDeepAndPricePerDiver CASCADE;
CREATE VIEW capacityPercentageMorningDeepAndPricePerDiver AS
SELECT (capacity-1)/max_daylight_open::FLOAT AS percentage, 
	(price_morning_deep + site_fee)/(capacity-1) AS price_per_Diver, 
	site_id, date_of_dive
FROM diverFees
WHERE type_of_dive = 'deep'
	AND timeSlot_of_dive = 'morning';
	
SELECT * FROM capacityPercentageMorningDeepAndPricePerDiver;

DROP VIEW IF EXISTS DeepMorningTotalCapacityAndPricePerDiver CASCADE;
CREATE VIEW DeepMorningTotalCapacityAndPricePerDiver AS
SELECT SUM(percentage) AS percentage, 
    AVG(price_per_diver) AS price_per_diver, 
    site_id
FROM capacityPercentageMorningDeepAndPricePerDiver
GROUP BY date_of_dive, site_id;

SELECT * FROM DeepMorningTotalCapacityAndPricePerDiver;

DROP VIEW IF EXISTS capacityPercentageAfternoonOpenAndPricePerDiver CASCADE;
CREATE VIEW capacityPercentageAfternoonOpenAndPricePerDiver AS
SELECT (capacity-1)/max_daylight_open::FLOAT AS percentage, 
	(price_afternoon_open + site_fee)/(capacity-1) AS price_per_Diver, 
	site_id, date_of_dive
FROM diverFees
WHERE type_of_dive = 'open'
	AND timeSlot_of_dive = 'afternoon';
	
SELECT * FROM capacityPercentageAfternoonOpenAndPricePerDiver;
	
DROP VIEW IF EXISTS OpenAfternoonTotalCapacityAndPricePerDiver CASCADE;
CREATE VIEW OpenAfternoonTotalCapacityAndPricePerDiver AS
SELECT SUM(percentage) AS percentage, 
    AVG(price_per_diver) AS price_per_diver, 
    site_id
FROM capacityPercentageAfternoonOpenAndPricePerDiver
GROUP BY date_of_dive, site_id;

SELECT * FROM OpenAfternoonTotalCapacityAndPricePerDiver;

DROP VIEW IF EXISTS capacityPercentageAfternoonCaveAndPricePerDiver CASCADE;
CREATE VIEW capacityPercentageAfternoonCaveAndPricePerDiver AS
SELECT (capacity-1)/max_daylight_open::FLOAT AS percentage, 
	(price_afternoon_cave + site_fee)/(capacity-1) AS price_per_Diver,
	site_id, date_of_dive
FROM diverFees
WHERE type_of_dive = 'cave'
	AND timeSlot_of_dive = 'afternoon';
	
SELECT * FROM capacityPercentageAfternoonCaveAndPricePerDiver;

DROP VIEW IF EXISTS CaveAfternoonTotalCapacityAndPricePerDiver CASCADE;
CREATE VIEW CaveAfternoonTotalCapacityAndPricePerDiver AS
SELECT SUM(percentage) AS percentage, 
    AVG(price_per_diver) AS price_per_diver, 
    site_id
FROM capacityPercentageAfternoonCaveAndPricePerDiver
GROUP BY date_of_dive, site_id;

SELECT * FROM CaveAfternoonTotalCapacityAndPricePerDiver;
	
DROP VIEW IF EXISTS capacityPercentageAfternoonDeepAndPricePerDiver CASCADE;
CREATE VIEW capacityPercentageAfternoonDeepAndPricePerDiver AS
SELECT (capacity-1)/max_daylight_open::FLOAT AS percentage, 
	(price_afternoon_deep + site_fee)/(capacity-1) AS price_per_Diver, 
	site_id, date_of_dive
FROM diverFees
WHERE type_of_dive = 'deep'
	AND timeSlot_of_dive = 'afternoon';
	
SELECT * FROM capacityPercentageAfternoonDeepAndPricePerDiver;
	
DROP VIEW IF EXISTS DeepAfternoonTotalCapacityAndPricePerDiver CASCADE;
CREATE VIEW DeepAfternoonTotalCapacityAndPricePerDiver AS
SELECT SUM(percentage) AS percentage, 
    AVG(price_per_diver) AS price_per_diver, 
    site_id
FROM capacityPercentageAfternoonDeepAndPricePerDiver
GROUP BY date_of_dive, site_id;

SELECT * FROM DeepAfternoonTotalCapacityAndPricePerDiver;

DROP VIEW IF EXISTS capacityPercentageNightOpenAndPricePerDiver CASCADE;
CREATE VIEW capacityPercentageNightOpenAndPricePerDiver AS
SELECT (capacity-1)/max_daylight_open::FLOAT AS percentage, 
	(price_night_open + site_fee)/(capacity-1) AS price_per_Diver, 
	site_id, date_of_dive
FROM diverFees
WHERE type_of_dive = 'open'
	AND timeSlot_of_dive = 'night';
	
SELECT * FROM capacityPercentageNightOpenAndPricePerDiver;
	
DROP VIEW IF EXISTS OpenNightTotalCapacityAndPricePerDiver CASCADE;
CREATE VIEW OpenNightTotalCapacityAndPricePerDiver AS
SELECT SUM(percentage) AS percentage, 
    AVG(price_per_diver) AS price_per_diver, 
    site_id
FROM capacityPercentageNightOpenAndPricePerDiver
GROUP BY date_of_dive, site_id;

SELECT * FROM OpenNightTotalCapacityAndPricePerDiver;

DROP VIEW IF EXISTS capacityPercentageNightCaveAndPricePerDiver CASCADE;
CREATE VIEW capacityPercentageNightCaveAndPricePerDiver AS
SELECT (capacity-1)/max_daylight_open::FLOAT AS percentage, 
	(price_night_cave + site_fee)/(capacity-1) AS price_per_Diver, 
	site_id, date_of_dive
FROM diverFees
WHERE type_of_dive = 'cave'
	AND timeSlot_of_dive = 'night';
	
SELECT * FROM capacityPercentageNightCaveAndPricePerDiver;

DROP VIEW IF EXISTS CaveNightTotalCapacityAndPricePerDiver CASCADE;
CREATE VIEW CaveNightTotalCapacityAndPricePerDiver AS
SELECT SUM(percentage) AS percentage, 
    AVG(price_per_diver) AS price_per_diver, 
    site_id
FROM capacityPercentageNightCaveAndPricePerDiver
GROUP BY date_of_dive, site_id;

SELECT * FROM CaveNightTotalCapacityAndPricePerDiver;

DROP VIEW IF EXISTS capacityPercentageNightDeepAndPricePerDiver CASCADE;
CREATE VIEW capacityPercentageNightDeepAndPricePerDiver AS
SELECT (capacity-1)/max_daylight_open::FLOAT AS percentage, 
	(price_night_deep + site_fee)/(capacity-1) AS price_per_Diver, 
	site_id, date_of_dive
FROM diverFees
WHERE type_of_dive = 'deep'
	AND timeSlot_of_dive = 'night';
	
SELECT * FROM capacityPercentageNightDeepAndPricePerDiver;
	
DROP VIEW IF EXISTS DeepNightTotalCapacityAndPricePerDiver CASCADE;
CREATE VIEW DeepNightTotalCapacityAndPricePerDiver AS
SELECT SUM(percentage) AS percentage, 
    AVG(price_per_diver) AS price_per_diver, 
    site_id
FROM capacityPercentageNightDeepAndPricePerDiver
GROUP BY date_of_dive, site_id;

SELECT * FROM DeepNightTotalCapacityAndPricePerDiver;
	
DROP VIEW IF EXISTS AllCapacityAndPrice CASCADE;
CREATE VIEW AllCapacityAndPrice AS
(SELECT * FROM OpenMorningTotalCapacityAndPricePerDiver)
	Union All
(SELECT * FROM CaveMorningTotalCapacityAndPricePerDiver)
	Union All
(SELECT * FROM DeepMorningTotalCapacityAndPricePerDiver)
	Union All
(SELECT * FROM OpenAfternoonTotalCapacityAndPricePerDiver)
	Union All
(SELECT * FROM CaveAfternoonTotalCapacityAndPricePerDiver)
	Union All
(SELECT * FROM DeepAfternoonTotalCapacityAndPricePerDiver)
	Union All
(SELECT * FROM OpenNightTotalCapacityAndPricePerDiver)
	Union All
(SELECT * FROM CaveNightTotalCapacityAndPricePerDiver)
	Union All
(SELECT * FROM DeepNightTotalCapacityAndPricePerDiver);

DROP VIEW IF EXISTS AllAvgCapacityAndAvgPercentage CASCADE;
CREATE VIEW AllAvgCapacityAndAvgPercentage AS
SELECT AVG(percentage) AS avg_capacity_percentage, AVG(price_per_diver) AS avg_price_per_diver, site_id
FROM AllCapacityAndPrice
GROUP BY site_id;

DROP VIEW IF EXISTS greaterThanHalf CASCADE;
CREATE VIEW greaterThanHalf AS
SELECT AVG(avg_price_per_diver) AS avg_price_more_than_half_full
FROM AllAvgCapacityAndAvgPercentage
WHERE avg_capacity_percentage > 0.5;

DROP VIEW IF EXISTS lessThanEqualThanHalf CASCADE;
CREATE VIEW lessThanEqualThanHalf AS
SELECT AVG(avg_price_per_diver) AS avg_price_less_than_equal_half_full
FROM AllAvgCapacityAndAvgPercentage
WHERE avg_capacity_percentage <= 0.5;

INSERT INTO q3
SELECT avg_price_more_than_half_full, avg_price_less_than_equal_half_full
FROM lessThanEqualThanHalf, greaterThanHalf;










