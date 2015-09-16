Tournament

Tournament manages a database of players and matches of a Swiss-style 
tournament. 

Features:
  * Add players.
  * Create rounds of matches for players in the tournament.
  * Report standings.
  * Record winners and losers of matches.
  * Count players.
  * Clear players.
  * Clear matches.
  * SQL file to DROP table and database for testing purposes.
  * Will not repeat matches in tournaments.


Dependencies
------------

  * Python 2.7
  * PostgrepSQL


Usage
-----

0) Install the dependencies listed above.

1) Open tournament.py, tournament_test.py and tournament.sql

2) Import tournament.sql in psql.

3) Connect to the database tournament.

3) Run tournament_test.py

Reset Databases
_______________

1. Import clean_tournament.sql

Known Issues
------------

It doesn't have a front end.



Credits
_______

This project was developed as a part of my participation in the Full Stack Developer Nanodegree and is subject to Udacity's Terms of Service:

https://www.udacity.com/legal/tos

Original work and modifications made by Greg Quinlan
QuinlanGL@gmail.com


Thanks
------

Thanks to Udacity's Introduction to Relational Databases for the learning and for the tournament_test.py code.