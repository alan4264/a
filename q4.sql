-- Left-right

SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

-- You must not change this table definition.


CREATE TABLE q4(
        countryName VARCHAR(50),
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.
DROP VIEW IF EXISTS party_left_right CASCADE;
CREATE VIEW party_left_right AS
SELECT n.party_id, country_id, left_right
FROM party p, party_position n
WHERE p.id = n.party_id;

DROP VIEW IF EXISTS zero_two CASCADE;
CREATE VIEW zero_two AS
SELECT country_id, count(party_id) AS num
FROM party_left_right
WHERE left_right >= 0 and left_right < 2
GROUP BY country_id;

DROP VIEW IF EXISTS two_four CASCADE;
CREATE VIEW two_four AS
SELECT country_id, count(party_id) AS num
FROM party_left_right
WHERE left_right >= 2 and left_right < 4
GROUP BY country_id;

DROP VIEW IF EXISTS four_six CASCADE;
CREATE VIEW four_six AS
SELECT country_id, count(party_id) AS num
FROM party_left_right
WHERE left_right >= 4 and left_right < 6
GROUP BY country_id;

DROP VIEW IF EXISTS six_eight CASCADE;
CREATE VIEW six_eight AS
SELECT country_id, count(party_id) AS num
FROM party_left_right
WHERE left_right >= 6 and left_right < 8
GROUP BY country_id;

DROP VIEW IF EXISTS eight_ten CASCADE;
CREATE VIEW eight_ten AS
SELECT country_id, count(party_id) AS num
FROM party_left_right
WHERE left_right >= 8 and left_right <= 10
GROUP BY country_id;

DROP VIEW IF EXISTS answer CASCADE;
CREATE VIEW answer AS
SELECT 	country.name AS countryName,
	coalesce(zero_two.num, 0) AS r0_2,
	coalesce(two_four.num, 0) AS r2_4,
	coalesce(four_six.num, 0) AS r4_6,
	coalesce(six_eight.num, 0) AS r6_8,
	coalesce(eight_ten.num, 0) AS r8_10
FROM 		  country 	
	LEFT JOIN zero_two ON country.id = zero_two.country_id
	LEFT JOIN two_four ON country.id = two_four.country_id
	LEFT JOIN four_six ON country.id = four_six.country_id
	LEFT JOIN six_eight ON country.id = six_eight.country_id
	LEFT JOIN eight_ten ON country.id = eight_ten.country_id;

-- the answer to the query 
INSERT INTO q4 (SELECT countryName, r0_2, r2_4, r4_6, r6_8, r8_10
		FROM answer);

