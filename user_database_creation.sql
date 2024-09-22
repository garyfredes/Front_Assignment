CREATE DATABASE weather_front;
CREATE USER 'front'@'localhost' IDENTIFIED BY '1234';

GRANT ALL PRIVILEGES ON weather_front.* TO 'front'@'localhost';
FLUSH PRIVILEGES;