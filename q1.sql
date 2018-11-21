-- VoteRange

SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

-- You must not change this table definition.

create table q1(
year INT,
countryName VARCHAR(50),
voteRange VARCHAR(20),
partyName VARCHAR(100)
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
--DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.
DROP VIEW IF EXISTS election_percentage CASCADE;
CREATE VIEW election_percentage AS
SELECT country_id, party_id, extract(year from e_date) AS year, cast(votes AS decimal)/votes_valid*100 AS e_percentage, votes, votes_valid
FROM election_result r, election e
WHERE r.election_id = e.id;

DROP VIEW IF EXISTS yearly_percentage CASCADE;
CREATE VIEW yearly_percentage AS
SELECT country_id, party_id, year, avg(e_percentage) AS average_percentage
FROM election_percentage
WHERE year >= 1996 and year <= 2016
GROUP BY country_id, party_id, year;

DROP VIEW IF EXISTS yearly_range CASCADE;
CREATE VIEW yearly_range AS
(SELECT country_id, party_id, year, '(0-5]' AS voteRange
 FROM yearly_percentage
 WHERE average_percentage > 0 and average_percentage <= 5)
	UNION
(SELECT country_id, party_id, year, '(5-10]' AS voteRange
 FROM yearly_percentage
 WHERE average_percentage > 5 and average_percentage <= 10)
	UNION
(SELECT country_id, party_id, year, '(10-20]' AS voteRange
 FROM yearly_percentage
 WHERE average_percentage > 10 and average_percentage <= 20)
	UNION
(SELECT country_id, party_id, year, '(20-30]' AS voteRange
 FROM yearly_percentage
 WHERE average_percentage > 20 and average_percentage <= 30)
	UNION
(SELECT country_id, party_id, year, '(30-40]' AS voteRange
 FROM yearly_percentage
 WHERE average_percentage > 30 and average_percentage <= 40)
	UNION
(SELECT country_id, party_id, year, '(40-100]' AS voteRange
 FROM yearly_percentage
 WHERE average_percentage > 40 and average_percentage <= 100);

DROP VIEW IF EXISTS answer CASCADE;
CREATE VIEW answer AS 
SELECT c.name AS countryName, p.name_short AS partyName, year, voteRange
FROM yearly_range r, country c, party p
WHERE r.country_id = c.id and r.party_id = p.id
ORDER BY countryName, year, partyName;

-- the answer to the query 
insert into q1 (SELECT year, countryName, voteRange, partyName
		FROM answer);

