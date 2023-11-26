create database music;


SELECT * from album;

 -- ----------------------------------------------------EASY-------------------------------------------------------------------
 
-- Q1) who is the senior most employee based on job title?
-- >
select * from employee
order by levels desc
limit 1;

-- Q2)which contries have the most invoices?
select billing_country,
count(*) as cnt
 from invoice 
 group by billing_country
 order by cnt desc;
 
 -- Q3)What are top 3 value of total invoice?
 select total from invoice
 order by total desc 
 limit 3;
 
 -- Q4) Which city has the best customers? We would like to throw a promotional Music festival in the city  we made the most
 -- money. Write a query that returns one city that has the highest sum of invoice totals. Return both city name and sum of al invoice totals. 
 
 select billing_city,
 sum(total) as total
 from invoice
 group by billing_city
 order by total desc;
 
 -- Q5) Who is the best customer? The custommer who has spent the most money will be declared as the best custommer. Write
 -- a query that returns the person who has spent the most money?
 
 -- As data is not present in customer we will do join operation
 select customer.customer_id,customer.first_name,customer.last_name,sum(invoice.total) as total
 from customer
 join invoice on customer.customer_id = invoice.customer_id
 group by customer.customer_id
 order by total desc;
 
 
 -- ----------------------------------------------MODERATE------------------------------------------------------------------
 
 -- Q1) Write a query to return the email, firat name,last name & Genere of all rock music listner. Return your list ordered
 -- alphabetically by email starting with A
 
 select distinct email,first_name,last_name 
 from customer 
 join invoice on customer.customer_id = invoice.customer_id
 join invoice_line on invoice.invoice_id =invoice_line.invoice_id
 where track_id in(
		select track_id from track
        join genre on track.genre_id = genre.genre_id
        where genre.name like 'ROCK'
)
order by email;

-- Q2) Lets invite the artist who have written the most rock music in our dataset.write a query that returns the artist name and total
-- track count of the top 10 rock bands

select artist.artist_id,artist.name,count(artist.artist_id) as count
from track
join album on album.album_id = track.track_id
join artist on artist.artist_id = album.album_id
join genre on genre.genre_id =track.track_id
where genre.name like 'Rock'
group by artist.artist_id
order by count desc
limit 10;

-- Q3)Retrun all the track name that have a song length longer than the average song length.Return the name and miliseconds for each track
-- Order by the song length with the longest songs listed first;

select name, milliseconds
from track
where milliseconds >( select avg(milliseconds)  from track)
order by milliseconds desc;


-- -------------------------------------------------ADVANCED----------------------------------------------------------------

-- Q2) Find how much amount spent by each customer on artists ?write a query to return customer name ,aritst name and total spent.
-- >
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

-- Q2) We want to find out the most popular music genre for each country.we determine the most popular genre asnthe genre with highest amount of purchass
-- write a query that returns each country along with the top genre.for countries whre the maximum number of purchases is 
-- shared return all genere.


WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;

-- Q3: Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount. 


with Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1