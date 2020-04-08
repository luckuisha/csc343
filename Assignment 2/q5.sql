-- Q5. Flight Hopping

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5 (
	destination CHAR(3),
	num_flights INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
-- DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS day CASCADE;
DROP VIEW IF EXISTS n CASCADE;

CREATE VIEW day AS
SELECT day::date as day FROM q5_parameters;
-- can get the given date using: (SELECT day from day)

create view n as
SELECT n FROM q5_parameters;
-- can get the given number of flights using: (SELECT n from n)

-- HINT: You can answer the question by writing one recursive query below, without any more views.
-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q5
WITH RECURSIVE ans AS (
    (
    SELECT 1 AS num, inbound as start, s_arv as tyme
    from flight
    where upper(outbound) = 'YYZ' 
    	and s_dep::date = (select day from day) 
    	and 1 <= (SELECT n from n)
    )
    UNION ALL
    (
    SELECT num + 1 as num, flight.inbound as start, flight.s_arv as tyme
    FROM flight, ans
    where outbound = start
    	and s_dep > tyme
    	AND num < (SELECT n from n)
    	AND s_dep < (tyme + interval '24 hours')
    )
)
     
select start as destination, num as num_flights
from ans;
