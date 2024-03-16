select * from OLYMPICS_HISTORY;
select * from OLYMPICS_HISTORY_NOC_REGIONS;

---------------------------------------------------------------------------------------------------------
1. How many olympics games have been held?

select count(distinct(games)) from OLYMPICS_HISTORY
---------------------------------------------------------------------------------------------------------
2.List down all Olympics games held so far.

select distinct(year),season,city from OLYMPICS_HISTORY order by year

---------------------------------------------------------------------------------------------------------

3. Which year saw the highest and lowest no of countries participating in olympics?

with cte as
(
select games,noc 
from OLYMPICS_HISTORY 
group by games,noc 
order by games,noc
),
cte1 as
(
select games,count(1) as no_of_country, rank() over(order by count(1))as rnk
from cte 
group by  games  
order by 2
)
select * 
from cte1 
where rnk=1 or rnk=(select max(rnk) from cte1)

---------------------------------------------------------------------------------------------------------
4. Which nation has participated in all of the olympic games?

with number_of_olympic as
(
select count(distinct(games)) 
from OLYMPICS_HISTORY
),
cte as
(
select noc,games 
from OLYMPICS_HISTORY group by noc,games order by noc
),
cte1 as
(
select noc,count(1) as country_times_participated from cte group by noc
)

select ohn.region as country ,c1.country_times_participated 
from cte1 c1
inner join OLYMPICS_HISTORY_NOC_REGIONS ohn on c1.noc=ohn.noc
where country_times_participated =(select * from number_of_olympic)

---------------------------------------------------------------------------------------------------------
5. Identify the sport which was played in all summer olympics.

with cte as
(
select count(distinct(games)) from OLYMPICS_HISTORY where season='Summer'
)
select sport,count(distinct games) as no_times_played 
from OLYMPICS_HISTORY 
where season='Summer' group by sport
having count (distinct(games))=(select * from cte)

---------------------------------------------------------------------------------------------------------
6. Which Sports were just played only once in the olympics?

with cte as
(
select count(distinct(games)) from OLYMPICS_HISTORY 
)
select sport,count(distinct games) as no_times_played 
from OLYMPICS_HISTORY 
group by sport
having count (distinct(games))=1

---------------------------------------------------------------------------------------------------------
7. Fetch the total no of sports played in each olympic games.

with cte as
(
select games,sport as no_times_played 
from OLYMPICS_HISTORY 
group by games, sport
order by games
)

select games,count(1) as number_of_sports from cte group by games order by 2 desc

---------------------------------------------------------------------------------------------------------
8. Fetch details of the oldest athletes to win a gold medal.

-- i have done rnk 2 ,because data contain null values and sql have ranked null values as 1
with cte as
(
select * ,dense_rank()over(order by age desc) as rnk
from OLYMPICS_HISTORY 
where medal='Gold'
)
select * from cte where rnk=2

---------------------------------------------------------------------------------------------------------
9. Fetch the top 5 athletes who have won the most gold medals.

with cte1 as
(
select id,count(1) from OLYMPICS_HISTORY where medal='Gold' group by id
),
cte2 as
(
select oh.id,oh.name,c1.count,dense_rank()over(order by count desc) as rnk 
from cte1 c1 inner join (select distinct id,name from OLYMPICS_HISTORY )oh
on oh.id=c1.id
)
select * from cte2 where rnk < 6

---------------------------------------------------------------------------------------------------------
10. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

with cte1 as
(
select id,count(1) from OLYMPICS_HISTORY where medal in('Gold','Silver','Bronze') group by id
),
cte2 as
(
select oh.id,oh.name,c1.count,dense_rank()over(order by count desc) as rnk 
from cte1 c1 inner join (select distinct id,name from OLYMPICS_HISTORY )oh
on oh.id=c1.id
)
select * from cte2 where rnk < 6

---------------------------------------------------------------------------------------------------------
11. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.


with cte1 as
(
select noc,count(1),dense_rank()over(order by count(1)desc) as rnk 
from OLYMPICS_HISTORY where medal in('Gold','Silver','Bronze') 
group by noc
)
select * from cte1 where rnk < 6

---------------------------------------------------------------------------------------------------------
12. In which Sport/event, India has won highest medals.

with cte as
(
select sport ,count(1),dense_rank()over(order by count(1)desc)
from OLYMPICS_HISTORY 
where team='India' and medal in ('Gold','Silver','Bronze') 
group by sport
)

select * from cte where dense_rank=1

---------------------------------------------------------------------------------------------------------
13. Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.

select games,count(1)
from OLYMPICS_HISTORY 
where team='India' and sport='Hockey' and medal in ('Gold','Silver','Bronze') 
group by games 
order by 2 desc


