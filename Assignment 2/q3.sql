-- Q3. North and South Connections

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3 (
    outbound VARCHAR(30),
    inbound VARCHAR(30),
    direct INT,
    one_con INT,
    two_con INT,
    earliest timestamp
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
-- DROP VIEW IF EXISTS intermediate_step CASCADE;


-- Define views for your intermediate steps here:

DROP VIEW IF EXISTS inboundFlights CASCADE;
CREATE OR REPLACE VIEW inboundFlights AS
SELECT * 
FROM flight, airport
WHERE flight.inbound = airport.code
	AND EXTRACT(year from flight.s_arv) = 2020
	AND EXTRACT(month from flight.s_arv) = 4
	AND EXTRACT(day from flight.s_arv) = 30
	AND EXTRACT(year from flight.s_dep) = 2020
	AND EXTRACT(month from flight.s_dep) = 4
	AND EXTRACT(day from flight.s_dep) = 30;

DROP VIEW IF EXISTS outboundFlights CASCADE;
CREATE OR REPLACE VIEW outboundFlights AS
SELECT * 
FROM flight, airport
WHERE flight.outbound = airport.code 
	AND EXTRACT(year from flight.s_arv) = 2020
	AND EXTRACT(month from flight.s_arv) = 4
	AND EXTRACT(day from flight.s_arv) = 30
	AND EXTRACT(year from flight.s_dep) = 2020
	AND EXTRACT(month from flight.s_dep) = 4
	AND EXTRACT(day from flight.s_dep) = 30;

DROP VIEW IF EXISTS USAorCanadaSameDayFlights CASCADE;
CREATE OR REPLACE VIEW USAorCanadaSameDayFlights AS
SELECT inboundFlights.id, 
	outboundFlights.country AS countryFrom, 
	inboundFlights.country AS countryTo, 
	outboundFlights.city AS cityFrom,
	inboundFlights.city AS cityTo, 
	outboundFlights.s_dep, outboundFlights.s_arv
FROM inboundFlights, outboundFlights
WHERE inboundFlights.id = outboundFlights.id
ORDER BY outboundFlights.s_dep, outboundFlights.s_arv;


DROP VIEW IF EXISTS directFlight CASCADE;
CREATE OR REPLACE VIEW directFlight AS
SELECT inboundFlights.id, 
	outboundFlights.country AS countryFrom, 
	inboundFlights.country AS countryTo, 
	outboundFlights.city AS cityFrom,
	inboundFlights.city AS cityTo, 
	outboundFlights.s_dep, outboundFlights.s_arv
FROM inboundFlights, outboundFlights
WHERE ((inboundFlights.country = 'Canada'
		AND outboundFlights.country = 'USA')
		OR (inboundFlights.country = 'USA'
		AND outboundFlights.country = 'Canada'))
	AND inboundFlights.id = outboundFlights.id

ORDER BY outboundFlights.s_dep, outboundFlights.s_arv;

DROP VIEW IF EXISTS oneConnectingFlight CASCADE;
CREATE OR REPLACE VIEW oneConnectingFlight AS
SELECT A.id, A.cityFrom as cityfromA, A.cityTo as citytoA, 
	B.cityFrom as cityfromB, B.cityTo as citytoB,
	A.s_dep as flightAdep, A.s_arv as flightAarv,
	B.s_dep as flightBdep, B.s_arv as flightBarv
FROM USAorCanadaSameDayFlights as A, 
	USAorCanadaSameDayFlights as B
WHERE A.id <> B.id 
	AND A.cityTo = B.cityFrom
	AND ((A.countryFrom = 'Canada'
		AND B.countryTo = 'USA')
		OR (A.countryFrom = 'USA'
		AND B.countryTo = 'Canada'))
	AND (EXTRACT(hour FROM (B.s_dep - A.s_arv))*60 + EXTRACT(minute FROM (B.s_dep - A.s_arv))) >= 30;

DROP VIEW IF EXISTS twoConnectingFlight CASCADE;
CREATE OR REPLACE VIEW twoConnectingFlight AS
SELECT A.id as Aid, B.id as Bid, C.id as Cid,
	A.cityFrom as cityfromA, A.cityTo as citytoA, 
	B.cityFrom as cityfromB, B.cityTo as citytoB,
	C.cityFrom as cityfromC, C.cityTo as citytoC,
	A.s_dep as flightAdep, A.s_arv as flightAarv,
	B.s_dep as flightBdep, B.s_arv as flightBarv,
	C.s_dep as flightCdep, C.s_arv as flightCarv
FROM USAorCanadaSameDayFlights as A, 
	USAorCanadaSameDayFlights as B, 
	USAorCanadaSameDayFlights as C
WHERE A.id <> B.id
	AND B.id <> C.id
	AND A.cityTo = B.cityFrom
	AND B.cityTo = C.cityFrom
	AND ((A.countryFrom = 'Canada'
		AND C.countryTo = 'USA')
		OR (A.countryFrom = 'USA'
		AND C.countryTo = 'Canada'))
	AND (EXTRACT(hour FROM (B.s_dep - A.s_arv))*60 + EXTRACT(minute FROM (B.s_dep - A.s_arv))) >= 30
	AND (EXTRACT(hour FROM (C.s_dep - B.s_arv))*60 + EXTRACT(minute FROM (C.s_dep - B.s_arv))) >= 30;

DROP VIEW IF EXISTS cityCombos CASCADE;
CREATE OR REPLACE VIEW cityCombos AS
SELECT DISTINCT A.city AS outbound, B.city AS inbound
FROM airport AS A, airport AS B
WHERE (A.country = 'Canada'
		AND B.country = 'USA')
	OR (A.country = 'USA'
		AND B.country = 'Canada')
ORDER BY outbound, inbound;

DROP VIEW IF EXISTS directFlightInfo CASCADE;
CREATE OR REPLACE VIEW directFlightInfo AS
SELECT outbound, inbound,
	count(s_arv), 
	min(s_arv) as earliest
FROM directFlight RIGHT JOIN cityCombos
	ON outbound = cityFrom AND inbound = cityTo
GROUP BY outbound, inbound;


DROP VIEW IF EXISTS oneConnectingFlightInfo CASCADE;
CREATE OR REPLACE VIEW oneConnectingFlightInfo AS
SELECT outbound, inbound,
	count(flightBarv), 
	min(flightBarv) as earliest
FROM oneConnectingFlight RIGHT JOIN cityCombos
	ON outbound = cityFromA AND inbound = cityToB
GROUP BY outbound, inbound;

DROP VIEW IF EXISTS twoConnectingFlightInfo CASCADE;
CREATE OR REPLACE VIEW twoConnectingFlightInfo AS
SELECT outbound, inbound,
	count(flightCarv), 
	min(flightCarv) as earliest
FROM twoConnectingFlight RIGHT JOIN cityCombos
	ON outbound = cityFromA AND inbound = cityToC
GROUP BY outbound, inbound;

DROP VIEW IF EXISTS paths CASCADE;
CREATE OR REPLACE VIEW paths AS
(SELECT * FROM directFlightInfo)
	UNION
(SELECT * FROM oneConnectingFlightInfo)
	UNION
(SELECT * FROM twoConnectingFlightInfo);

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q3

SELECT directFlightInfo.outbound, 
	directFlightInfo.inbound, 
	directFlightInfo.count AS direct, 
	oneConnectingFlightInfo.count AS one_con, 
	twoConnectingFlightInfo.count AS two_con,
	min(paths.earliest) as earliest
FROM directFlightInfo, oneConnectingFlightInfo, twoConnectingFlightInfo, paths
WHERE directFlightInfo.outbound = oneConnectingFlightInfo.outbound
	AND oneConnectingFlightInfo.outbound = twoConnectingFlightInfo.outbound
	AND twoConnectingFlightInfo.outbound = paths.outbound
	AND directFlightInfo.inbound = oneConnectingFlightInfo.inbound
	AND oneConnectingFlightInfo.inbound = twoConnectingFlightInfo.inbound
	AND twoConnectingFlightInfo.inbound = paths.inbound
GROUP BY directFlightInfo.outbound, 
	directFlightInfo.inbound, directFlightInfo.count, oneConnectingFlightInfo.count, twoConnectingFlightInfo.count;
