# Front Assignment - Gary Fredes

## Summary

The code extract the weather observations data for the last seven days from the NWS. Then it transforms and cleans the data while using pandas.Finally, it loads the resulting data unto the 'weather' database. For this assignment I used the '044PG' station.

All the code is present in 'main.py', but I left the notebook where I was working in: 'pruebaFront.ipynb'

For more details, see the code as it is documented.

## Assumptions

- The id is the '@id' parameter present in the observations
- I extract the last segment of the 'station' data url as the 'station'
- I left the qualityControl data as it could be used as a filter in the future
- I left the unit of Temperature, Humidity and Wind Speed as it makes the table more readable
- I used MySQL as it is the one that I have currently installed on my computer.


## SQL Queries

The SQL queries 1 and 2 are saved as 'avg_temp.sql' and 'max_diff_windSpeed.sql'. But in any case, I leave the queries right here:

Average observed temperature for last week(Mon-Sun).

```SQL
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
```

Maximum wind speed change between two consecutive observations in the last 7
days.

```SQL
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
```


## Configurations

I saved my local dependencies with pip freeze in 'requirements.txt'.

The creation of the database in MySQL is saved in 'user_database_creation.sql'.

```SQL
CREATE DATABASE weather_front;
CREATE USER 'front'@'localhost' IDENTIFIED BY '1234';

GRANT ALL PRIVILEGES ON weather_front.* TO 'front'@'localhost';
FLUSH PRIVILEGES;
```

The database is hosted at 'localhost' with the user 'front' and password '1234'.

## External code

I used the 'insert_on_duplicate' function found at
"https://stackoverflow.com/questions/30337394/pandas-to-sql-fails-on-duplicate-primary-key"