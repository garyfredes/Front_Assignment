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
Finally, I calculate the average of temperature
for the data between those dates (last week).
*/
SELECT AVG(temperature)
FROM weather
WHERE timestamp BETWEEN @last_monday AND @last_sunday;