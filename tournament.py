#!/usr/bin/env python
#
# tournament.py -- implementation of a Swiss-system tournament
#

import psycopg2
import contextlib


def connect():
    """Connect to the PostgreSQL database.  Returns a database connection."""
    return psycopg2.connect("dbname=tournament")


@contextlib.contextmanager
def with_cursor():
    """Handles connection, committing and closing for using a database."""
    conn = connect()
    cur = conn.cursor()
    try:
        yield cur
    except:
        raise
    else:
        conn.commit()
    finally:
        cur.close()
        conn.close()


def deleteMatches():
    """Remove all the match records from the database."""
    with with_cursor() as c:
        c.execute("DELETE FROM matches")


def deletePlayers():
    """Remove all the player records from the database."""
    with with_cursor() as c:
        c.execute("DELETE FROM players")


def countPlayers():
    """Returns the number of players currently registered."""
    with with_cursor() as c:
        c.execute("SELECT COUNT(*) FROM players")
        (result,) = c.fetchone()
    return result


def registerPlayer(name):
    """Adds a player to the tournament database.

    The database assigns a unique serial id number for the player.  (This
    should be handled by your SQL database schema, not in your Python code.)

    Args:
      name: the player's full name (need not be unique).
    """
    with with_cursor() as c:
        c.execute("INSERT INTO players(name) VALUES (%s);", (name,))


def playerStandings():
    """Returns a list of the players and their win records, sorted by wins.

    The first entry in the list should be the player in first place, or a
    player tied for first place if there is currently a tie.

    Returns:
      A list of tuples, each of which contains (id, name, wins, matches):
        id: the player's unique id (assigned by the database)
        name: the player's full name (as registered)
        wins: the number of matches the player has won
        matches: the number of matches the player has played
    """
    with with_cursor() as c:
        c.execute("SELECT * FROM fullstandings")
        result = c.fetchall()
    return result


def reportMatch(winner, loser):
    """Records the outcome of a single match between two players.

    Args:
      winner:  the id number of the player who won
      loser:  the id number of the player who lost
    """
    with with_cursor() as c:
        c.execute("INSERT INTO matches VALUES (%s, %s)", (winner, loser))


def deleteSchedMatch():
    """Remove all the scheduled records from the database."""
    with with_cursor() as c:
        c.execute("DELETE FROM schedmatch")


def countUnassigned():
    """Returns the number of players to be assigned to matches in the round.
    """
    with with_cursor() as c:
        c.execute("SELECT COUNT(*) FROM remainplayers")
        (result,) = c.fetchone()
    return result


def remainMatchCt():
    """Returns the smallest number of unique remaining matches for
    current players.
    """
    with with_cursor() as c:
        c.execute("SELECT * FROM remainmatchct")
        (placeholder, result) = c.fetchone()
    return result


def schedMatch(id1, id2):
    """Assigns a match to schedmatch.

    Args:
      id1:  the id number of the first player
      id2:  the id number of the second player
    """
    with with_cursor() as c:
        if id1 < id2:
            c.execute("INSERT INTO schedmatch VALUES (%s, %s)" % (id1, id2))
        if id1 > id2:
            c.execute("INSERT INTO schedmatch VALUES (%s, %s)" % (id2, id1))


def bestValidMatch(id):
    """Returns the best match for a player.

    Args:
        id:  the id number of a player

    Returns:
        A tuple for a match which contains (id1, id2)
            id1: the first player's unique id
            id2: the second player's unique id
    """
    with with_cursor() as c:
        c.execute("SELECT * FROM remainmatch WHERE id1 = %s OR id2 = %s",
                  (id, id))
        result = c.fetchone()
    return result


def swissPairings():
    """Returns a list of pairs of players for the next round of a match.

    Assuming that there are an even number of players registered, each player
    appears exactly once in the pairings.  Each player is paired with another
    player with an equal or nearly-equal win record, that is, a player adjacent
    to him or her in the standings.

    Returns:
      A list of tuples, each of which contains (id1, name1, id2, name2)
        id1: the first player's unique id
        name1: the first player's name
        id2: the second player's unique id
        name2: the second player's name
    """
    # Continue to assign matches while there are two or more unassigned players
    deleteSchedMatch()
    unassignplayers = countUnassigned()
    while (unassignplayers >= 2):
        # Assign matches to players that have only one valid remaining match
        added = False
        matchcount = remainMatchCt()
        # if there's a id with only one good match, assign it
        # Else assign the best match for the top player
        if (matchcount == 1):
            with with_cursor() as c:
                # Get the id of a team with one valid remaining match
                c.execute("SELECT * FROM remainmatchctstand")
                (nextteam, placeholder1, placeholder2) = c.fetchone()
            # Find the valid match that includes that id
            (id1, id2) = bestValidMatch(nextteam)
            # Assign the match
            schedMatch(id1, id2)
        else:
            with with_cursor() as c:
                # Get the id of the best remaining player
                c.execute("SELECT * FROM remainstand")
                (nextteam, placeholder) = c.fetchone()
            # Find the strongest available match
            (id1, id2) = bestValidMatch(nextteam)
            # Schedule the match
            schedMatch(id1, id2)
        if (unassignplayers > 2):
                unassignplayers = countUnassigned()
        else:
            break
    # Put the assigned matches into a result
    with with_cursor() as c:
        c.execute("SELECT * FROM fullschedmatch")
        result = c.fetchall()
    # Clear the round data
    deleteSchedMatch()
    # Return the result
    return result
