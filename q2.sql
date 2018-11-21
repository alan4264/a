-- Winners

SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
countryName VARCHaR(100),
partyName VARCHaR(100),
partyFamily VARCHaR(100),
wonElections INT,
mostRecentlyWonElectionId INT,
mostRecentlyWonElectionYear INT
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.
DROP VIEW IF EXISTS winning_vote CASCADE;
CREATE VIEW winning_vote AS 
SELECT election_id, max(votes) AS max_votes
FROM election_result
GROUP BY election_id;

DROP VIEW IF EXISTS wins CASCADE;
CREATE VIEW wins AS 
SELECT r.election_id, party_id
FROM election_result r, winning_vote v 
WHERE r.election_id = v.election_id and votes = max_votes;

DROP VIEW IF EXISTS wins_count CASCADE;
CREATE VIEW wins_count AS 
SELECT id AS party_id, count(election_id) AS wins_num, country_id
FROM party LEFT JOIN wins ON party.id = wins.party_id
GROUP BY id, country_id;

DROP VIEW IF EXISTS country_average CASCADE;
CREATE VIEW country_average AS 
SELECT country_id, avg(wins_num) AS avg_wins
FROM wins_count
GROUP BY country_id;

DROP VIEW IF EXISTS most_recent_win CASCADE;
CREATE VIEW most_recent_win AS 
SELECT w.party_id, w.election_id, extract(year from i.most_recent_date) AS year
FROM	(
	SELECT party_id, max(e_date) AS most_recent_date
	FROM wins w, election e
	WHERE w.election_id = e.id
	GROUP BY party_id
	) i, wins w, election e
WHERE w.election_id = e.id and w.party_id = i.party_id and i.most_recent_date = e.e_date;

DROP VIEW IF EXISTS more_than_three_times_average CASCADE;
CREATE VIEW more_than_three_times_average AS 
SELECT party_id, c.country_id, c.wins_num
FROM wins_count c, country_average a
WHERE c.country_id = a.country_id and wins_num > 3 * avg_wins;

DROP VIEW IF EXISTS answer_without_partyfamily CASCADE;
CREATE VIEW answer_without_partyfamily AS 
SELECT c.name AS countryName, p.name AS partyName, m.wins_num AS wonElections, m.party_id, r.election_id AS mostRecentlyWonElectionId, r.year AS mostRecentlyWonElectionYear
FROM more_than_three_times_average m, party p, country c, most_recent_win r
WHERE m.party_id = p.id and p.country_id = c.id and m.party_id = r.party_id;

DROP VIEW IF EXISTS answer CASCADE;
CREATE VIEW answer AS 
SELECT countryName, partyName, family AS partyFamily, wonElections, mostRecentlyWonElectionId, mostRecentlyWonElectionYear
FROM answer_without_partyfamily a LEFT JOIN party_family f ON a.party_id = f.party_id;

-- the answer to the query 
insert into q2 (SELECT countryName, partyName, partyFamily, wonElections, mostRecentlyWonElectionId, mostRecentlyWonElectionYear
		FROM answer);

