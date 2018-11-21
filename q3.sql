-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
        countryName varchar(50),
        year int,
        participationRatio real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.
DROP VIEW IF EXISTS election_ratio CASCADE;
CREATE VIEW election_ratio AS
SELECT id AS election_id, country_id, cast(votes_cast AS decimal)/electorate AS ratio, extract(year from e_date) AS year
FROM election;

DROP VIEW IF EXISTS yearly_ratio CASCADE;
CREATE VIEW yearly_ratio AS
SELECT country_id, year, avg(ratio) AS ratio
FROM election_ratio
WHERE year >= 2001 and year <= 2016
GROUP BY country_id, year;

DROP VIEW IF EXISTS decreasing_ratio CASCADE;
CREATE VIEW decreasing_ratio AS
SELECT r1.country_id
FROM yearly_ratio r1, yearly_ratio r2
WHERE r1.year < r2.year and r1.ratio > r2.ratio;

DROP VIEW IF EXISTS answer CASCADE;
CREATE VIEW answer AS
SELECT c.name AS countryName, year, r.ratio AS participationRatio
FROM yearly_ratio r, country c
WHERE NOT EXISTS (SELECT *
		  FROM decreasing_ratio d
		  WHERE r.country_id = d.country_id)
      and r.country_id = c.id;

-- the answer to the query 
insert into q3 (SELECT countryName, year, participationRatio
		FROM answer);

