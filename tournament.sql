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
	winner		integer	REFERENCES players(id),
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
	SELECT played.id AS id, wins.ct AS win, played.ct AS games 
		FROM played LEFT JOIN wins 
		ON played.id = wins.id
		ORDER BY win DESC
;

CREATE VIEW fullstandings AS 
	SELECT players.id AS id, name, win, games 
	FROM players, standings 
	WHERE players.id = standings.id 
	ORDER BY win DESC
;

CREATE VIEW possiblematch AS
	SELECT a.id as id1, b.id as id2
	FROM players as a, players as b
	WHERE a.id < b.id
	ORDER BY a.id, b.id
;

CREATE VIEW completematch AS
	SELECT winner AS id1, loser as id2 FROM matches 
	WHERE winner < loser
	UNION
	SELECT loser AS id1, winner as id2 FROM matches 
	WHERE loser < winner
;

CREATE TABLE schedmatch (
	id1 	integer	REFERENCES players(id),
	id2		integer	REFERENCES players(id)
);

CREATE VIEW fullschedmatch AS
	SELECT id1, a.name AS name1, id2, b.name AS name2
	FROM schedmatch, players AS a, players as b
	WHERE id1 = a.id and id2 = b.id
; 
	
CREATE VIEW availmatch AS
	SELECT * FROM possiblematch 
	EXCEPT  
	SELECT * FROM completematch
;

CREATE VIEW schedplayer AS
	SELECT id1 AS id FROM schedmatch
	UNION 
	SELECT id2 AS id FROM schedmatch
;

CREATE VIEW exceptmatch AS
	SELECT a.id AS id1, b.id AS id2
	FROM schedplayer AS a, players AS b
	WHERE a.id < b.id 
	UNION
	SELECT a.id AS id1, b.id AS id2
	FROM players AS a, schedplayer AS b
	WHERE a.id < b.id
;

CREATE VIEW remainmatch AS
	SELECT * FROM availmatch 
	EXCEPT  
	SELECT * FROM exceptmatch
;

CREATE VIEW remainmatchbest AS
	SELECT id1, id2, (a.win + b.win) AS matchwins 
	FROM remainmatch, standings AS a, standings as b
	WHERE id1 = a.id and id2 = b.id
	ORDER BY matchwins DESC
;

CREATE VIEW remainplayers AS
	SELECT standings.id AS id from standings 
	EXCEPT
	SELECT id FROM schedplayer
;

CREATE VIEW remainmatchct AS
	SELECT id, count(id1) AS matchct FROM players, remainmatch
	WHERE id = id1 or id = id2
	GROUP BY id
	ORDER BY matchct
;

CREATE VIEW remainstand AS
	SELECT remainplayers.id AS id, standings.win AS win
	FROM remainplayers
	LEFT JOIN standings
	ON remainplayers.id = standings.id
	ORDER BY win DESC
;




