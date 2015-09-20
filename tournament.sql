-- Table definitions for the tournament project.

DROP DATABASE IF EXISTS tournament;
CREATE DATABASE tournament;
\c tournament;

-- players is a table to assign players a unique id.

CREATE TABLE players (
	name	text,
	id		serial PRIMARY KEY
);

-- matches is a table to record matches. Position in matches determines 
-- the winner and loser. ATTN: Winner and loser swapped make a unique entry.

CREATE TABLE matches (
	winner		integer	REFERENCES players(id),
	loser		integer	REFERENCES players(id),
	PRIMARY KEY (winner, loser)
);

-- standings is a view that uses players and matches to count wins and games
-- and then sort wins descending

CREATE VIEW standings AS 
	SELECT players.id, 
		COUNT(CASE WHEN players.id = winner THEN 1 ELSE NULL END) AS win, 
		COUNT(CASE WHEN players.id = winner OR id = loser THEN 1 ELSE NULL END)
			AS games
		FROM players
		LEFT JOIN matches
		ON players.id = winner OR players.id = loser
		GROUP BY players.id
		ORDER BY win DESC
;

-- fullstandings is a view that add the name to standings from players.

CREATE VIEW fullstandings AS 
	SELECT players.id AS id, name, win, games 
	FROM players, standings 
	WHERE players.id = standings.id 
	ORDER BY win DESC
;


-- possiblematch is a view of players that lists all possilbe matches 
-- between players. The lower id number will always be first.

CREATE VIEW possiblematch AS
	SELECT a.id as id1, b.id as id2
	FROM players as a, players as b
	WHERE a.id < b.id
	ORDER BY a.id, b.id
;

-- completematches uses matches to view completed matches so the lower id
-- number will be in id1.

CREATE VIEW completematch AS
	SELECT winner AS id1, loser as id2 FROM matches 
	WHERE winner < loser
	UNION
	SELECT loser AS id1, winner as id2 FROM matches 
	WHERE loser < winner
;

-- schedmatch is a table used to place a scheduled match when assigning
-- players to a new round.

CREATE TABLE schedmatch (
	id1 	integer	REFERENCES players(id),
	id2		integer	REFERENCES players(id)
);

-- fullschedmatch is a view of schedmatch and players to output the scheduled
-- matches in the required format.

CREATE VIEW fullschedmatch AS
	SELECT id1, a.name AS name1, id2, b.name AS name2
	FROM schedmatch, players AS a, players as b
	WHERE id1 = a.id and id2 = b.id
; 

-- available matches is a view that excludes completematches from
-- possiblematches, to show matches that are still available to play
-- without repeating matches.

CREATE VIEW availmatch AS
	SELECT * FROM possiblematch 
	EXCEPT  
	SELECT * FROM completematch
;

-- schedplayer is a view of schedmatch that creates a list of players
-- that have already been scheduled to play in a round.

CREATE VIEW schedplayer AS
	SELECT id1 AS id FROM schedmatch
	UNION 
	SELECT id2 AS id FROM schedmatch
;

-- exceptmatches is a view of schedplayer and players that lists all
-- matches that aren't available because a player is already in a
-- scheduled match.

CREATE VIEW exceptmatch AS
	SELECT a.id AS id1, b.id AS id2
	FROM schedplayer AS a, players AS b
	WHERE a.id < b.id 
	UNION
	SELECT a.id AS id1, b.id AS id2
	FROM players AS a, schedplayer AS b
	WHERE a.id < b.id
;

-- remainmatch is a view of availmatch and exceptmatch that creates a list
-- of matches remaining that are available (completed matches excluded) 
-- and do not include players who are already scheduled.

CREATE VIEW remainmatch AS
	SELECT * FROM availmatch 
	EXCEPT  
	SELECT * FROM exceptmatch
;

-- remainmatchbest is a view of remainmatch and standings that sort
-- remainmatch by the total of the wins of both teams involved in the 
-- match. 

CREATE VIEW remainmatchbest AS
	SELECT id1, id2, (a.win + b.win) AS matchwins 
	FROM remainmatch, standings AS a, standings as b
	WHERE id1 = a.id and id2 = b.id
	ORDER BY matchwins DESC
;

-- remaining players is a view of standings and schedplayer that lists
-- all the ids of the players who haven't been scheduled in a match 
-- for the round.

CREATE VIEW remainplayers AS
	SELECT standings.id AS id from standings 
	EXCEPT
	SELECT id FROM schedplayer
;

-- remainmatchct is a view of remainmatch and players that counts how 
-- many remaining matches there are for each player and sorts by that 
-- count. 

CREATE VIEW remainmatchct AS
	SELECT id, count(id1) AS matchct FROM players, remainmatch
	WHERE id = id1 or id = id2
	GROUP BY id
	ORDER BY matchct
;

--- remainmatchctstand is a view of remainmatchct and standings that
--- sorts the number of matches for a remaining player first by number of 
--- matches, then my the number of wins.

CREATE VIEW remainmatchctstand AS
	SELECT remainmatchct.id AS id, matchct, standings.win AS win
	FROM remainmatchct 
	LEFT JOIN standings
	ON remainmatchct.id = standings.id
	ORDER BY matchct, win DESC
;

-- remainstand is a view of remainplayers and standings that sorts players
-- who have not been scheduled for a match in the round descending by 
-- most wins.

CREATE VIEW remainstand AS
	SELECT remainplayers.id AS id, standings.win AS win
	FROM remainplayers
	LEFT JOIN standings
	ON remainplayers.id = standings.id
	ORDER BY win DESC
;
