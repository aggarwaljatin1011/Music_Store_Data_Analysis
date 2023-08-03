/*Music Store Data Analysis Project Queries Solutions*/

/*I. Easy Questions */

/*Q.1 Who is the senior most employee based on job title? */
Select * from employee
order by levels desc 
limit 1;

/*Q.2 Which countries have the most Invoices? */
Select billing_country,count(invoice_id) as No_of_Invoices 
from invoice
group by billing_country
order by billing_country desc
limit 1;

/*Q.3. What are top 3 values of total invoice? */
Select invoice_id , total 
from invoice 
order by total desc 
limit 3;

/*Q.4 What are the tracks composed by “Angus Young, Malcolm Young , Brian Johnson”? */
Select track_id,name
from track
where composer = 'Angus Young, Malcolm Young, Brian Johnson';

/*Q.5. What is the no. of tracks available for each playlist_id? */
select playlist_id,count(track_id) as No_of_Tracks
from playlist_track
group by playlist_id;

/*Q.6. What are albums of the artist with his/her id = 90? */
select album_id,title 
from album 
where artist_id = '90';

/*Q.7. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals. */
Select billing_city,sum(total) as invoice_total 
from invoice
group by billing_city 
order by invoice_total desc 
limit 1;

/*Q.8. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money.*/
SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) AS Total_Money_Spent
FROM 
customer JOIN invoice 
ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY Total_Money_Spent DESC
LIMIT 1;

/*Q.9. What are the different media types available? */
Select * from media_type;


/*II. Moderate Questions */

/* Q.1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A.*/
SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;

/*Q.2. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands*/
SELECT artist.artist_id, artist.name as Artist_Name,COUNT(artist.artist_id) as Total_Track_Count
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY Total_Track_Count DESC
LIMIT 10;

/*Q.3. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first*/
SELECT name,milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC;

/*Q.4 Return playlist_id,track_id,album_id,media_type_id,media_type where album_id for the track is greater than 2000. */
Select playlist.playlist_id,track.track_id,album_id,media_type.media_type_id,media_type.name As Media_Type 
from playlist
Join playlist_track On playlist.playlist_id = playlist_track.playlist_id
Join track On track.track_id = playlist_track.track_id
Join media_type On track.media_type_id = media_type.media_type_id
Where track.track_id > 2000
Order By track.track_id desc;


/* III. Advance Questions */

/*Q.1. Find how much amount spent by each customer on best selling artists? Write a query to return customer name, artist name and total spent.*/
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

/*Q.2. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres*/
WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;

/* Q.3.	Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount*/
WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

Select cc.*
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;


/*
Thanks for visting my project.
Hope you understood the solutions to the queries mentioned in the pdf file.
Like the queries I have solved here many more queries can be made & solved using the same database.
*/