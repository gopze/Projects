#SWIGGY DATASET

# Assign Dataset
use assignment;

# View Data
select * from swiggy_2;

#Count Records in a Dataset
select count(*) from swiggy_2;      -- 50,030 rows

# Drop column 'head'
ALTER TABLE swiggy_2
DROP COLUMN head;

# Rename column ''
ALTER TABLE swiggy_2
CHANGE COLUMN `veg_or_non-veg` veg_or_non_veg VARCHAR(10);

# Check for null values
SELECT count(*) 
FROM swiggy_2 WHERE restaurant_no IS NULL;      -- 0 rows

# Q1: Restaurant count with 4.5 plus rating 
SELECT COUNT(distinct restaurant_no) AS Higest_rated_restaurants
FROM swiggy_2 
WHERE rating > 4.5;     -- 18 restaurants

#Q2 : City with Highest No. of restaurants
SELECT city,COUNT(distinct restaurant_no) as restaurant_count
FROM swiggy_2 
GROUP BY city
ORDER BY restaurant_count DESC
LIMIT 1;    -- Bangalore

#Q3 : Restaurant count with word 'Pizza' in their name
SELECT COUNT(DISTINCT restaurant_no) as Pizza_restaurants
FROM swiggy_2
WHERE restaurant_name like '%Pizza%';    -- 14 restaurants

#Q4 : Most common Cuisine
SELECT cuisine,count(distinct restaurant_no) as cuisine_count
FROM swiggy_2
GROUP BY cuisine
ORDER BY cuisine_count desc
LIMIT 1;     -- 'North Indian,Chinese'

#Q5 : Average rating of Restaurants in each city
SELECT city, round(avg(rating),2) as avg_rating
FROM swiggy_2
GROUP BY city;     -- Bangalore	= 4.12, Ahmedabad = 4.07

#Q6 : The Highest price of item under the 'RECOMMENDED' menu category for each restaurant ?
SELECT restaurant_no,restaurant_name,menu_category,max(price) as max_price
FROM swiggy_2
WHERE menu_category ='recommended'
GROUP BY restaurant_name,restaurant_no,menu_category;
#(or)
select  restaurant_no,restaurant_name,menu_category,price
from
	(select restaurant_no,restaurant_name,menu_category,price,row_number() over (partition by restaurant_no order by price desc) as rw
    from swiggy_2 
    where menu_category ='recommended')x
where x.rw=1;

#Q7 : Top 5 Expensive restaurants with International cuisines
SELECT DISTINCT restaurant_no, restaurant_name,cuisine, cost_per_person
FROM swiggy_2
WHERE cuisine NOT LIKE '%india%'
ORDER BY cost_per_person desc
limit 5;

#Q8 : Restaurants whose average cost is higher than average cost of all restaurants combined
with avg_restaurant as
(
SELECT DISTINCT restaurant_no, restaurant_name,round(avg(cost_per_person),0) as avg_cost
FROM swiggy_2
GROUP BY restaurant_name,restaurant_no
),
total_avg as
(
select round(avg(cost_per_person),0) as total_avg_cost from swiggy_2  
)
select ar.restaurant_no, ar.restaurant_name,ar.avg_cost,ta.total_avg_cost
from avg_restaurant ar
join total_avg ta
on  ar.avg_cost>ta.total_avg_cost;

#(or)

select distinct restaurant_no,restaurant_name,cost_per_person,
(select round(avg(cost_per_person),0) from swiggy_2) as Total_avg
from swiggy_2
where cost_per_person >(select round(avg(cost_per_person),0) from swiggy_2);

#Q9 : Restaurants with same name in different locations
SELECT distinct a.restaurant_name, a.city AS city1, b.city AS city2
FROM swiggy_2 a
JOIN swiggy_2 b ON a.restaurant_name = b.restaurant_name 
AND a.city != b.city
WHERE a.city > b.city
ORDER BY a.restaurant_name;

#Q10: Restaurant with most items in Main course
SELECT DISTINCT restaurant_no, restaurant_name,count(menu_category) as Main_course_count 
FROM swiggy_2
WHERE menu_category like '%Main%'
GROUP BY restaurant_name,restaurant_no
ORDER by Main_course_count desc
LIMIT 1;   -- 'Spice Up' restaurant

#Q11 : Restaurants that serve only 100% Vegetarian

SELECT DISTINCT restaurant_no,restaurant_name
FROM swiggy_2
WHERE restaurant_name NOT IN (
    SELECT restaurant_name
    FROM swiggy_2
    WHERE veg_or_non_veg = 'Non-Veg'
);
#(or)
SELECT DISTINCT restaurant_no,restaurant_name,
ROUND((COUNT(CASE WHEN veg_or_non_veg ='Veg' THEN 1 END)/count(*)*100),0) as vegetarian_percetage
FROM swiggy_2
GROUP BY restaurant_no,restaurant_name
HAVING vegetarian_percetage=100
ORDER by restaurant_name;


#Q12: Restaurant providing lowest average price for all items
SELECT DISTINCT restaurant_no,restaurant_name,min(cost_per_person) as lowest_avg_price
FROM swiggy_2
GROUP BY restaurant_no,restaurant_name
ORDER by lowest_avg_price
LIMIT 1;

#(OR)

SELECT DISTINCT restaurant_no,restaurant_name,AVG(price) as lowest_avg_price
FROM swiggy_2
GROUP BY restaurant_no,restaurant_name
ORDER by lowest_avg_price
LIMIT 1;    -- 'Urban Kitli'

-- recheck Q12 answer 

#Q13 : Top 5 Restaurants with Highest number of Categories
SELECT DISTINCT restaurant_no,restaurant_name,count(distinct menu_category) as no_of_categories
FROM swiggy_2
GROUP BY restaurant_no,restaurant_name
ORDER by no_of_categories desc
LIMIT 5;

#Q14 : Top 5 Restaurants with Highest Percentage of Non-Vegetarian food
SELECT DISTINCT restaurant_no,restaurant_name,
ROUND((COUNT(CASE WHEN veg_or_non_veg ='Non-Veg' THEN 1 END)/count(*)*100),2) as non_veg_percetage
FROM swiggy_2
GROUP BY restaurant_no,restaurant_name
ORDER by non_veg_percetage desc
LIMIT 5;