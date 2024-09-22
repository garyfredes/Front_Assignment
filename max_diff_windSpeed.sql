/* 
Create @n_days, which is the difference in days from
last sunday to today.
I substract those dates to current date to get @last_sunday,
and then substract 6 days to @last_sunday to get
@last_monday
*/
SET @n_days := (SELECT WEEKDAY(curdate())) + 1;
SET @last_sunday := (date_sub(curdate(), INTERVAL @n_days DAY));
SET @last_monday := (date_sub(@last_sunday, INTERVAL 6 DAY));

/*

I use the LAG function to calculate the difference
between consecutive values of windSpeed (I order by timestamp
in the window). That difference is coated in IFNULL to treat
the difference of null values as 0, and then the absolute value
is taken, as we only care about the modulus of the difference.
Finally, I use MAX to get the maximum value of the difference
*/
SELECT MAX(diff)
FROM (
	SELECT 
		@id, 
		timestamp, 
		windSpeed,
		ABS(IFNULL(windSpeed - LAG(windSpeed) OVER w, 0)) AS diff
	FROM weather
    WHERE timestamp BETWEEN @last_monday AND @last_sunday
	WINDOW w AS (ORDER BY `timestamp` ASC)
) AS diff_table;
