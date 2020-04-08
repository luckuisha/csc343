-- Q1. Airlines

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1 (
    pass_id INT,
    name VARCHAR(100),
    airlines INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
-- DROP VIEW IF EXISTS intermediate_step CASCADE;


-- Define views for your intermediate steps here:

INSERT INTO q1
SELECT passenger.id as pass_id, firstname || ' ' || surname AS name, count(distinct flight.airline) as airlines
FROM departure right join booking on departure.flight_id = booking.flight_id
	right join flight on flight.id = departure.flight_id
	right join passenger on passenger.id = booking.pass_id
group by passenger.id , name;


