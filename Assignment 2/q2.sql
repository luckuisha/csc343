-- Q2. Refunds!

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2 (
    airline CHAR(2),
    name VARCHAR(50),
    year CHAR(4),
    seat_class seat_class,
    refund REAL
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
-- DROP VIEW IF EXISTS intermediate_step CASCADE;


-- Define views for your intermediate steps here:




DROP VIEW IF EXISTS inboundairports CASCADE;
CREATE OR REPLACE VIEW inboundairports AS 
SELECT * FROM flight,airport 
WHERE flight.inbound=airport.code;

DROP VIEW IF EXISTS outboundairports CASCADE;
CREATE OR REPLACE VIEW outboundairports AS 
SELECT * FROM flight, airport 
WHERE flight.outbound=airport.code;

DROP VIEW IF EXISTS domesticflights CASCADE;
CREATE OR REPLACE VIEW domesticflights AS
SELECT inboundairports.s_dep, inboundairports.s_arv, 
	inboundairports.id, inboundairports.airline
FROM inboundairports, outboundairports 
WHERE inboundairports.id = outboundairports.id 
	and inboundairports.country = outboundairports.country;

DROP VIEW IF EXISTS internationalflights CASCADE;
CREATE OR REPLACE VIEW internationalflights AS
SELECT inboundairports.s_dep, inboundairports.s_arv, 
	inboundairports.id, inboundairports.airline
FROM inboundairports, outboundairports 
WHERE inboundairports.id=outboundairports.id 
	and inboundairports.country<>outboundairports.country;

DROP VIEW IF EXISTS domesticrefund4 CASCADE;
CREATE OR REPLACE VIEW domesticrefund4 as
SELECT s_dep, s_arv, booking.flight_id as id,
	(departure.datetime-domesticflights.s_dep) as depdelay,
	0.35*booking.price as refund, 
	domesticflights.airline as airline, 
	airline.name as name,
	booking.seat_class as seat_class,
	EXTRACT(year FROM departure.datetime) as year
FROM domesticflights, departure, arrival, booking, airline
WHERE departure.flight_id=arrival.flight_id 
	and domesticflights.id=departure.flight_id 
	and departure.flight_id=booking.flight_id
	and (departure.datetime-domesticflights.s_dep) >= '04:00:00' 
	and(departure.datetime-domesticflights.s_dep) < '10:00:00'
   and extract(hour from (arrival.datetime-domesticflights.s_arv))>extract(hour from(departure.datetime-domesticflights.s_dep))*0.5
   and airline.code = domesticflights.airline;

DROP VIEW IF EXISTS internationalrefund7 CASCADE;
CREATE OR REPLACE VIEW internationalrefund7 as
SELECT s_dep, s_arv, booking.flight_id as id, 
	(departure.datetime-internationalflights.s_dep) as depdelay, 
	0.35*booking.price as refund, 
	internationalflights.airline as airline,
	airline.name as name, 
	booking.seat_class as seat_class, 
	EXTRACT(year FROM departure.datetime) as year
FROM internationalflights, departure, arrival, booking, airline
WHERE departure.flight_id=arrival.flight_id 
	and internationalflights.id=departure.flight_id 
	and departure.flight_id=booking.flight_id	
	and (departure.datetime-internationalflights.s_dep) >= '07:00:00' 
	and (departure.datetime-internationalflights.s_dep) < '12:00:00'
	and extract(hour from (arrival.datetime-internationalflights.s_arv))>extract(hour from (departure.datetime-internationalflights.s_dep))*0.5
	and airline.code = internationalflights.airline;

DROP VIEW IF EXISTS domesticrefund10 CASCADE;
CREATE OR REPLACE VIEW domesticrefund10 as
SELECT s_dep, s_arv, booking.flight_id as id,
	(departure.datetime-domesticflights.s_dep) as depdelay,
	0.5*booking.price as refund, 
	domesticflights.airline as airline, 
	airline.name as name,
	booking.seat_class as seat_class,
	EXTRACT(year FROM departure.datetime) as year
FROM domesticflights, departure, arrival, booking, airline
WHERE departure.flight_id=arrival.flight_id 
	and domesticflights.id=departure.flight_id 
	and departure.flight_id=booking.flight_id
	and (departure.datetime-domesticflights.s_dep) >= '10:00:00' 
   and extract(hour from (arrival.datetime-domesticflights.s_arv))>extract(hour from (departure.datetime-domesticflights.s_dep))*0.5
   and airline.code = domesticflights.airline;

DROP VIEW IF EXISTS internationalrefund12 CASCADE;
CREATE OR REPLACE VIEW internationalrefund12 as
SELECT s_dep, s_arv, booking.flight_id as id, 
	(departure.datetime-internationalflights.s_dep) as depdelay, 
	0.5*booking.price as refund, 
	internationalflights.airline as airline,
	airline.name as name, 
	booking.seat_class as seat_class, 
	EXTRACT(year FROM departure.datetime) as year
FROM internationalflights, departure, arrival, booking, airline
WHERE departure.flight_id=arrival.flight_id 
	and internationalflights.id=departure.flight_id 
	and departure.flight_id=booking.flight_id	
	and (departure.datetime-internationalflights.s_dep) >= '12:00:00'
	and extract(hour from (arrival.datetime-internationalflights.s_arv))>extract(hour from (departure.datetime-internationalflights.s_dep))*0.5
	and airline.code = internationalflights.airline;

DROP VIEW IF EXISTS everything CASCADE;
CREATE OR REPLACE VIEW everything AS
(select airline, name, year, seat_class, sum(refund) as refund
from domesticrefund4
GROUP BY seat_class, airline, year, name, refund)
	UNION(
select airline, name, year, seat_class, sum(refund) as refund
from internationalrefund7
GROUP BY seat_class, airline, year, name, refund) 
	UNION(
select airline, name, year, seat_class, sum(refund) as refund
from internationalrefund12
GROUP BY seat_class, airline, year, name, refund)
	UNION(
select airline, name, year, seat_class, sum(refund) as refund
from domesticrefund10
GROUP BY seat_class, airline, year, name, refund);

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2

SELECT airline as airline, name as name, year as year, seat_class as seat_class, sum(refund) as refund
FROM everything
GROUP BY seat_class, airline, year, name
ORDER BY airline, seat_class;

