-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

CREATE DATABASE tournament;

CREATE TABLE players (
	name	text,
	id		serial PRIMARY KEY
);

CREATE TABLE matches (
	winner		integer REFERENCES players(id), 
	loser		integer	REFERENCES players(id),
	PRIMARY KEY (winner, loser)
);

-- Need a standings view

CREATE VIEW wins AS
	SELECT id, count(winner) AS ct
	FROM players LEFT JOIN matches
	ON id = winner
		GROUP BY id
;

CREATE VIEW losses AS
	SELECT id, count(loser) AS ct
	FROM players LEFT JOIN matches
	ON id = loser
		GROUP BY id
;

CREATE VIEW played AS
		SELECT id, sum(ct) AS ct 
		FROM (
			SELECT * FROM wins 
			UNION 
			SELECT * FROM losses) 
			AS playtmp
		GROUP BY id
;

CREATE VIEW standings AS
	SELECT played.id, wins.ct AS win, played.ct AS games 
		FROM played LEFT JOIN wins
		ON played.id = wins.id 
		ORDER BY win DESC
;

CREATE VIEW fullstandings AS 
	SELECT players.id, name, win, games 
	FROM players, standings 
	WHERE players.id = standings.id 
	ORDER BY win DESC
;


