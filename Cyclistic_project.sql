--Combine data into one table which contant only data will analyze
SELECT 
 COALESCE(t_09.ride_id,t_08.ride_id,t_05.ride_id,t_06.ride_id,t_07.ride_id,t_10.ride_id,t_11.ride_id,t_12.ride_id,t_01.ride_id,t_02.ride_id,t_03.ride_id,t_04.ride_id) as ride_id,
 COALESCE(t_09.started_at,t_08.started_at,t_05.started_at,t_06.started_at,t_07.started_at,t_10.started_at,t_11.started_at,t_12.started_at,t_01.started_at,t_02.started_at,t_03.started_at,t_04.started_at) as started_at,
 COALESCE(t_09.ended_at,t_08.ended_at,t_05.ended_at,t_06.ended_at,t_07.ended_at,t_10.ended_at,t_11.ended_at,t_12.ended_at,t_01.ended_at,t_02.ended_at,t_03.ended_at,t_04.ended_at) as ended_at,
 COALESCE(t_09.member_casual,t_08.member_casual,t_05.member_casual,t_06.member_casual,t_07.member_casual,t_10.member_casual,t_11.member_casual,t_12.member_casual,t_01.member_casual,t_02.member_casual,t_03.member_casual,t_04.member_casual) as member_casual,
 COALESCE(t_09.rideable_type,t_08.rideable_type,t_05.rideable_type,t_06.rideable_type,t_07.rideable_type,t_10.rideable_type,t_11.rideable_type,t_12.rideable_type,t_01.rideable_type,t_02.rideable_type,t_03.rideable_type,t_04.rideable_type) as rideable_type

FROM 
cyctistic_project.dbo.[202009-divvy-tripdata]  t_09
full  join  cyctistic_project.dbo.[202007-divvy-tripdata] t_07
ON t_09.ride_id = t_07.ride_id 
full  join  cyctistic_project.dbo.[202008-divvy-tripdata] t_08
ON t_09.ride_id = t_08.ride_id
full join cyctistic_project.dbo.[202005-divvy-tripdata]  t_05
ON t_09.ride_id = t_05.ride_id
full join cyctistic_project.dbo.[202006-divvy-tripdata]  t_06
ON t_09.ride_id = t_06.ride_id
full join cyctistic_project.dbo.[202010-divvy-tripdata]  t_10
ON t_09.ride_id = t_10.ride_id
full  join cyctistic_project.dbo.[202011-divvy-tripdata]  t_11
ON t_09.ride_id = t_11.ride_id
full  join cyctistic_project.dbo.[202012-divvy-tripdata]  t_12
ON t_09.ride_id = t_12.ride_id
full  join cyctistic_project.dbo.[202101-divvy-tripdata]  t_01
ON t_09.ride_id = t_01.ride_id
full  join cyctistic_project.dbo.[202102-divvy-tripdata]  t_02
ON t_09.ride_id = t_02.ride_id
full join cyctistic_project.dbo.[202103-divvy-tripdata] t_03
ON t_09.ride_id = t_03.ride_id
full join cyctistic_project.dbo.[202104-divvy-tripdata]  t_04
ON t_09.ride_id = t_04.ride_id;
-- checking duplicate and nulll
select count(distinct ride_id) as distinct_ride_id, count(ride_id) as number_ride_id
from cyctistic_project.dbo.cleaned_cyclistic
--We have 3119841 rows but distinct have 3119632 
--Delete  duplicate rows
With CEL AS 
( 
Select *,row_number() over(partition by ride_id order by ride_id) as RN
From cyctistic_project.dbo.cleaned_cyclistic
)
DELETE from CEL where RN <> 1;
--checking 
select count(ride_id) as number_ride_id
from cyctistic_project.dbo.cleaned_cyclistic
-- checking null value in all column
select *
from cyctistic_project.dbo.cleaned_cyclistic
where ride_id is null or
      started_at is null or
	  ended_at is null or 
	  member_casual is null or 
	  rideable_type is null ;
--Result: 0 row is null
--add column table
alter table cyctistic_project.dbo.cleaned_cyclistic
add day_of_week  int null ,
  hour_started_at int  null ,
  ride_length int null,
  month_of_year int; 
--add value to column table
update cyctistic_project.dbo.cleaned_cyclistic
set day_of_week = datepart(weekday,started_at),
    hour_started_at = datepart(hour,started_at),
	ride_length = datediff(ss,started_at,ended_at),
	month_of_year = month(started_at) ;
--delete ride_length negative
select *
From cyctistic_project.dbo.cleaned_cyclistic
where ride_length >0 ;

--Analyzing data 
--count number total number of member rides and cusual rides
select member_casual,count(ride_id) as number_rides
from cyctistic_project.dbo.Cleaned_cyclistic_project
group by member_casual;
--Summary data with the average ride length and  the number of rides each member_casual by hour
select member_casual,
       hour_started_at,
       avg(ride_length) as average_ride_length,
       count(ride_id) as number_of_rides
from cyctistic_project.dbo.Cleaned_cyclistic_project
group by member_casual,hour_started_at
order by  member_casual,hour_started_at;
--Summary data with the average ride length and  the number of rides each member_casual by day_of_week
select member_casual,
       day_of_week,
       avg(ride_length) as average_ride_length,
       count(ride_id) as number_of_rides
from cyctistic_project.dbo.Cleaned_cyclistic_project
group by member_casual,day_of_week
order by  member_casual,day_of_week;
--Summary data with the average ride length and  the number of rides each member_casual by month
select member_casual,
       month_of_year,
       avg(ride_length) as average_ride_length,
       count(ride_id) as number_of_rides
from cyctistic_project.dbo.Cleaned_cyclistic_project
group by member_casual,month_of_year
order by  member_casual,month_of_year;

