-- Instructions

-- 1a. Display the first and last names of all actors from the table actor.
-- SELECT * FROM actor;
SELECT first_name, last_name 
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT (CONCAT(UPPER(first_name), " " ,UPPER(last_name))) As "Actor Name"
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name like "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor_id, last_name, first_name
FROM actor
WHERE last_name like "%LI%"
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
-- select * from country;
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
Alter table actor
add column Description BLOB AFTER last_name;
-- select * from actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor DROP Description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name) AS Count
FROM actor
GROUP BY last_name 
ORDER BY Count DESC;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(last_name) AS Count
FROM actor
GROUP BY last_name 
Having Count > 1
ORDER BY Count DESC;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
-- select * from actor where last_name like "Williams";
UPDATE `sakila`.`actor` SET `first_name` = 'HARPO' WHERE (`actor_id` = '172');

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE `sakila`.`actor` SET `first_name` = 'GROUCHO' WHERE (`actor_id` = '172');


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- select * from address;
CREATE TABLE IF NOT EXISTS`address` (
 `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
 `address` varchar(50) CHARACTER SET utf8 NOT NULL,
 `address2` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
 `district` varchar(20) CHARACTER SET utf8 NOT NULL,
 `city_id` smallint(5) unsigned NOT NULL,
 `postal_code` varchar(10) CHARACTER SET utf8 DEFAULT NULL,
 `phone` varchar(20) CHARACTER SET utf8 NOT NULL,
 `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 PRIMARY KEY (`address_id`)
 );
-- select * from address;

Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
-- SELECT * FROM staff;
-- SELECT * FROM address;
SELECT S.first_name, S.last_name, A.address
FROM staff AS S
INNER JOIN address AS A
ON S.address_id = A.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
-- select * from staff;
-- select * from payment;
SELECT S.staff_id, S.first_name, S.last_name, count(P.amount) AS "Total Transactions", sum(P.amount) AS "Total amount"
FROM staff AS S
INNER JOIN payment AS P
ON S.staff_id = P.staff_id
WHERE month(P.payment_date)= 08 AND year(P.payment_date)= 2005
GROUP BY staff_id
ORDER BY staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
-- select * from film_actor;
-- select * from film;
SELECT F.title, count(FA.actor_id) AS "Number of Actors"
FROM film AS F
INNER JOIN film_actor AS FA
ON F.film_id = FA.film_id
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
-- select * from inventory;
-- select * from film;
SELECT  F.film_id, F.title, count(I.film_id) AS Copies
FROM film as F
INNER JOIN inventory AS I
ON F.film_id=I.film_id
WHERE F.title LIKE 'Hunchback Impossible'
GROUP BY F.title;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
-- select * from payment;
-- select * from customer;
SELECT C.last_name, C.first_name, SUM(P.amount) AS 'Total_Amount'
FROM customer AS C
INNER JOIN payment AS P
ON C.customer_id = P.customer_id
GROUP BY C.customer_id
ORDER BY C.last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT 
    SUBQUERY.title
FROM
    (SELECT 
        F.*, L.name AS 'language_name'
    FROM
        film AS F
    LEFT JOIN language AS L ON F.language_id = L.language_id
    WHERE
        L.name LIKE 'English') AS SUBQUERY
WHERE
    SUBQUERY.title LIKE 'K%'
        OR SUBQUERY.title LIKE 'Q%';

-- Alternate method 1
SELECT F.title, L.language_id
FROM film AS F
INNER JOIN language AS L
ON F.language_id= L.language_id
WHERE (L.name like 'English') AND (F.title LIKE 'K%' OR 'Q%' );

-- Alternate method 2
SELECT F.title, L.language_id
FROM film AS F
INNER JOIN language AS L
ON F.language_id= L.language_id
WHERE (L.name Like 'English') AND ((F.title LIKE 'K%') OR (F.title LIKE 'Q%' ));

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
-- Method 1 using subqueries
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    actor_id IN (SELECT 
            actor_id
        FROM
            film_actor
        WHERE
            film_id = (SELECT 
                    film_id
                FROM
                    film
                WHERE
                    title = 'Alone Trip'));

-- Alternate method using inner join
SELECT A.actor_id, A.first_name, A.last_name 
FROM actor AS A
INNER JOIN film_actor AS FA ON A.actor_id=FA.actor_id
INNER JOIN film AS F ON F.film_id= FA.film_id
WHERE F.title = 'Alone Trip'
GROUP BY FA.film_id, A.actor_id
;

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT C.first_name, C.last_name, C.email
FROM customer AS C
INNER JOIN address AS A ON A.address_id= C.address_id
INNER JOIN city AS CI ON CI.city_id= A.city_id
INNER JOIN country AS CO ON CO.country_id= CI.country_id
WHERE country LIKE 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
-- select * from film;
-- select * from film_category;
-- select * from category;
SELECT F.title AS 'Family Films'
FROM film AS F
INNER JOIN film_category AS FC ON FC.film_id=F.film_id
INNER JOIN category AS C ON C.category_id= FC.category_id
WHERE C.name LIKE 'Family'
ORDER BY F.title;

-- 7e. Display the most frequently rented movies in descending order.
SELECT 
    F.title, COUNT(R.customer_id) AS 'rental_count'
FROM
    rental AS R
        INNER JOIN
    inventory AS I ON R.inventory_id = I.inventory_id
        INNER JOIN
    film_text AS F ON F.film_id = I.film_id
GROUP BY F.title
ORDER BY rental_count DESC;



-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- select * from staff;
-- select * from payment;
SELECT S.store_id, CONCAT('$',FORMAT((SUM(P.amount)),2)) AS 'Revenue'
FROM payment AS P
INNER JOIN staff AS S ON S.staff_id=P.staff_id
GROUP BY S.store_id
ORDER BY S.store_id;
 

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT S.store_id, C.city, CO.country
FROM store AS S
INNER JOIN address AS A ON A.address_id = S.address_id
INNER JOIN city AS C ON C.city_id= A.city_id
INNER JOIN country AS CO ON CO.country_id= C.country_id

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-- select * from payment;
-- select * from rental;
-- select * from inventory;
-- select * from category;
-- select * from film_category;
-- select * from inventory;
SELECT 
    C.name, CONCAT('$', FORMAT((SUM(P.amount)), 2)) AS 'Revenue'
FROM
    payment AS P
        INNER JOIN
    rental AS R ON R.rental_id = P.rental_id
        INNER JOIN
    inventory AS I ON I.inventory_id = R.inventory_id
        INNER JOIN
    film_category AS FC ON FC.film_id = I.film_id
        INNER JOIN
    category AS C ON C.category_id = FC.category_id
GROUP BY C.name
ORDER BY Revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS (
SELECT 
    C.name, CONCAT('$', FORMAT((SUM(P.amount)), 2)) AS 'Revenue'
FROM
    payment AS P
        INNER JOIN
    rental AS R ON R.rental_id = P.rental_id
        INNER JOIN
    inventory AS I ON I.inventory_id = R.inventory_id
        INNER JOIN
    film_category AS FC ON FC.film_id = I.film_id
        INNER JOIN
    category AS C ON C.category_id = FC.category_id
GROUP BY C.name
ORDER BY Revenue DESC
LIMIT 5
);

-- 8b. How would you display the view that you created in 8a?
-- SHOW CREATE VIEW top_five_genres;
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;
