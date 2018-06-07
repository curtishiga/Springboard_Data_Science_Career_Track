/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

DELETED

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


----------------------------------------------------------------------------------
/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */


SELECT name, membercost
FROM Facilities
WHERE membercost > 0
ORDER BY 2

----------------------------------------------------------------------------------
/* Q2: How many facilities do not charge a fee to members? */


SELECT COUNT(name)
FROM Facilities
WHERE membercost = 0

----------------------------------------------------------------------------------
/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */


SELECT 	name,
	facid,
	membercost,
	monthlymaintenance
FROM Facilities
WHERE membercost < (0.2 * monthlymaintenance)

----------------------------------------------------------------------------------
/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */


SELECT 	*
FROM Facilities
WHERE facid IN (1,5)

----------------------------------------------------------------------------------
/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */


SELECT 	name,
	monthlymaintenance,
	CASE WHEN monthlymaintenance > 100 THEN 'expensive'
	ELSE 'cheap' END AS expense
FROM Facilities

----------------------------------------------------------------------------------
/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */


SELECT 	surname,
	firstname,
	joindate
FROM Members
WHERE joindate = (SELECT MAX(joindate)
		  FROM Members)

----------------------------------------------------------------------------------
/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */


SELECT  CONCAT(firstname,' ',surname) AS name,
	facility_name
FROM Members m
JOIN (SELECT 	f.facid AS facility_id,
		b.memid AS member_id,
		f.name AS facility_name
	FROM Facilities f
	JOIN Bookings b
	ON b.facid = f.facid
	WHERE f.facid IN (0,1)) fb
ON m.memid = fb.member_id
GROUP BY 1
ORDER BY 1

----------------------------------------------------------------------------------
/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */


SELECT	f.name,
	CONCAT(m.firstname,' ',m.surname) AS mem_name,
	CASE WHEN b.memid > 0 THEN (f.membercost * b.slots)
	ELSE (f.guestcost * b.slots) END AS cost
FROM Bookings b, Facilities f, Members m
WHERE b.facid = f.facid
AND b.memid = m.memid
AND LEFT(b.starttime,10) = '2012-09-14'
HAVING cost > 30
ORDER BY 3 DESC

----------------------------------------------------------------------------------
/* Q9: This time, produce the same result as in Q8, but using a subquery. */


SELECT	f.name,
	CONCAT(bm.firstname,' ',bm.surname) AS mem_name,
	CASE WHEN bm.memid > 0 THEN (f.membercost * bm.slots)
	ELSE (f.guestcost * bm.slots) END AS cost
FROM Facilities f
JOIN (SELECT 	m.firstname,
      		m.surname,
      		b.facid,
      		b.memid,
      		b.slots
      FROM Bookings b
      JOIN Members m
      ON b.memid = m.memid
      WHERE LEFT(b.starttime,10) = '2012-09-14') AS bm
ON bm.facid = f.facid
HAVING cost > 30
ORDER BY 3 DESC

----------------------------------------------------------------------------------
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */


SELECT 	name,
	(total_memfees + total_guestfees + total_monthmain) AS revenue
FROM 	(SELECT f.name,
		SUM(CASE WHEN b.memid > 0 THEN (f.membercost * b.slots) END) AS total_memfees,
		SUM(CASE WHEN b.memid = 0 THEN (f.guestcost * b.slots) END) AS total_guestfees,
 		COUNT(DISTINCT(SUBSTR(b.starttime,6,2))) * f.monthlymaintenance AS total_monthmain
	FROM Bookings b, Facilities f
	WHERE b.facid = f.facid
	GROUP BY f.name) AS tc
HAVING revenue > 1000
ORDER BY 2