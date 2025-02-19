-- SQL Project spotify

--Create a table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);


--EDA
select * from spotify;  --To see all the data entry in file

select count(*) from spotify; --To see number of data in file

select count(distinct artist) from spotify; --To see different artist

select count(distinct album) from spotify; --To see different album

select distinct album_type from spotify;  --To see different types of album like singles,compilation,etc

select max(duration_min) from spotify;  --To see longest duration of song

select min(duration_min) from spotify;  --To see shortest duration of song

delete from spotify
where duration_min=0  --Songs with '0'min has been deleted

select distinct channel from spotify; --To see different channel

select distinct most_played_on from spotify;  --To see where the songs has been played most



--Data Analysis
--Q1.Retrieve the names of all tracks that have more than 1 billion streams.
select track 
from spotify
where stream > 1000000000;


--Q2.List all albums along with their respective artists.
select distinct album,artist
from spotify
order by 1


--Q3.Get the total number of comments for tracks where licensed = true.
select sum(comments) AS TOTAL_COMMENTS
from spotify
where licensed='true';

--Q4.Find all tracks that belong to the album type single
select track,album_type
from spotify
where album_type = 'single';


--Q5.Count the total number of tracks by each artist.
select  distinct artist,count(track) as total_tracks
from spotify
group by artist
order by 2;


--Q6.Calculate the average danceability of tracks in each album
select album,avg(danceability) as average_danceability
from spotify
group by 1
order by 2 desc;



--Q7.Find the top 5 tracks with the highest energy values.
select track,max(energy) as Highest_energy
from spotify
group by 1
order by 2 desc
limit 5;


--Q8.List all tracks along with their views and likes where official_video=True
select track,
	   SUM(views) as total_views,
	   SUM(likes) as total_likes
from spotify
where official_video='true'
group by 1
order  by 2 desc;


--Q9.For each album,Calculate the total views of all associated tracks
select album,track,
	   sum(views) as total_views
from spotify
group by 1,2
order by 3 desc;

--Q10.Retrieve the track names that have been streamed on spotify more than youtube
select *
	from
	(
	select track,
	coalesce(sum(case when most_played_on='Youtube' then stream end),0) as streamed_on_youtube,
	coalesce(sum(case when most_played_on='Spotify' then stream end),0) as streamed_on_spotify
	from spotify
	group by 1
	) as t1
where 
	  streamed_on_spotify > streamed_on_youtube
	  AND 
	  streamed_on_youtube <> 0;



--Q11.Find the top 3 most viewed tracks for each artist using window function
WITH ranking_artist
as
(
select artist,
		track,
		sum(views) as total_view,
		dense_rank() over(partition by artist order by sum(views) desc ) as rank
from spotify
group by 1,2
order by 1,3 desc
)
select * from ranking_artist
where rank <=3;


--Q12.Write a query to find tracks where the liveness score is above the average
select track,liveness
from spotify
where liveness > ( select avg(liveness)
					from spotify
					);


--Q13.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
with dif_energy
as
(
		select album,
		Max(energy) as highest_energy,
		Min(energy) as lowest_energy
		from spotify
		group by 1
)
select album,
		(highest_energy - lowest_energy) as energy_dif
		from dif_energy
		order by 2 desc;


--Q14.Find tracks where the energy-to-liveness ratio is greater than 1.2.
select track,(energy / liveness) as energy_to_liveness_ratio
from spotify
where (energy/liveness)>1.2;


--Query Optimization
   
EXPLAIN ANALYZE
select artist, track,views
from spotify
where artist ='Gorillaz'
	and most_played_on = 'Youtube'
order by stream desc 
limit 25;

create  index artist_index on spotify(artist);

/* firstly wihout creating index the et 9.03 ms
   and after creating index the et 0.16 ms  */

--END OF PROJECT
























