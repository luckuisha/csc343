-- Q4. Plane Capacity Histogram

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4 (
	airline CHAR(2),
	tail_number CHAR(5),
	very_low INT,
	low INT,
	fair INT,
	normal INT,
	high INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
-- DROP VIEW IF EXISTS intermediate_step CASCADE;


-- Define views for your intermediate steps here:
DROP VIEW IF EXISTS depSeats CASCADE;
CREATE OR REPLACE VIEW depSeats as
select departure.flight_id as flight_num, 
	coalesce (count(booking.flight_id), 0) as seats, 
	plane.airline, (capacity_economy+capacity_business+capacity_first) as capacity, 
	tail_number
from flight, plane, booking right join departure
on booking.flight_id = departure.flight_id
where flight.id = departure.flight_id
	and plane.tail_number = flight.plane
group by booking.flight_id, departure.flight_id, tail_number
order by departure.flight_id;

DROP VIEW IF EXISTS depFlightPercent CASCADE;
CREATE OR REPLACE VIEW depFlightPercent as 
SELECT tail_number, count(flight_num) as numflights, (seats::decimal/capacity) as percent, airline
FROM depSeats
GROUP BY tail_number, flight_num, capacity, airline, seats;

DROP VIEW IF EXISTS planeCombos CASCADE;
CREATE OR REPLACE VIEW planeCombos as 
SELECT tail_number, airline
FROM plane;

DROP VIEW IF EXISTS allflightsandcapacity CASCADE;
CREATE OR REPLACE VIEW allflightsandcapacity as 
SELECT planecombos.tail_number as tail_number, coalesce(numflights, 0) as numflights, percent, planecombos.airline
from depFlightPercent right join planecombos
	on planecombos.tail_number = depFlightPercent.tail_number;


DROP VIEW IF EXISTS upto20 CASCADE;
CREATE OR REPLACE VIEW upto20 as
SELECT tail_number, airline, COALESCE(sum(numflights) filter (where percent<0.2), 0) as numflights
FROM allflightsandcapacity
GROUP BY tail_number, airline;

DROP VIEW IF EXISTS twentytoforty CASCADE;
CREATE OR REPLACE VIEW twentytoforty as
SELECT tail_number, airline, COALESCE(sum(numflights) filter (where percent>=0.2 and percent<0.4), 0) as numflights
FROM allflightsandcapacity
GROUP BY tail_number, airline;

DROP VIEW IF EXISTS fortytosixty CASCADE;
CREATE OR REPLACE VIEW fortytosixty as
SELECT tail_number, airline, COALESCE(sum(numflights) filter (where percent>=0.4 and percent<0.6), 0) as numflights
FROM allflightsandcapacity
GROUP BY tail_number, airline;

DROP VIEW IF EXISTS sixtytoeighty CASCADE;
CREATE OR REPLACE VIEW sixtytoeighty as
SELECT tail_number, airline, COALESCE(sum(numflights) filter (where percent>=0.6 and percent<0.8), 0) as numflights
FROM allflightsandcapacity
GROUP BY tail_number, airline;

DROP VIEW IF EXISTS over80 CASCADE;
CREATE OR REPLACE VIEW over80 as
SELECT tail_number, airline, COALESCE(sum(numflights) filter (where percent>=0.8), 0) as numflights
FROM allflightsandcapacity
GROUP BY tail_number, airline;

DROP VIEW IF EXISTS histogramdata CASCADE;
CREATE OR REPLACE VIEW histogramdata AS 
SELECT upto20.airline, 
upto20.tail_number, upto20.numflights as very_low, 
twentytoforty.numflights as low, 
fortytosixty.numflights as fair, 
sixtytoeighty.numflights as normal,
over80.numflights as high 
FROM upto20, twentytoforty,fortytosixty,sixtytoeighty,over80 
WHERE upto20.tail_number= twentytoforty.tail_number 
and upto20.tail_number= fortytosixty.tail_number
and upto20.tail_number=sixtytoeighty.tail_number 
and upto20.tail_number=over80.tail_number
ORDER BY upto20.airline, upto20.tail_number;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q4
SELECT * from histogramdata;


