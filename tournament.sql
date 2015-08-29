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
	id1		integer REFERENCES players(id) 
	id2		integer	REFERENCES players(id)
	winner	integer REFERENCES players(id)
	PRIMARY KEY (id1, id2)
);

-- Create loser view


-- Need a standings view



