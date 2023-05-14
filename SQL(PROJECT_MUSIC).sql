1.	Who is the senior most employee based on job title?

use music;

select * from employee 
order by levels desc
limit 1;

2.	Which countries have the most invoices?

select * from invoice;

select count(*) as c, billing_country
from invoice
group by billing_country
order by c desc;


3.	What are top 3 values of total invoices

select * from invoice;

select total from invoice
order by total desc
limit 3;

4.	Which city has the best customers? We would like to throw a promotional music festival
 in the city we made the most money. write a query that returns one city that has the highest
 sum of invoice totals. Return both the city name & sum of all invoice totals
 
 select sum(total) as invoice_total, billing_city
 from invoice
 group by billing_city
 order by invoice_total desc;
 
 5. Who is the best customer? The customer who has spent the most money will be declared the best customer.
 Write a query that returns the person who has spent the most money.
 
 
SELECT 
    *
FROM
    customer;
    
SELECT 
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    SUM(invoice.total) AS total
FROM
    customer
        JOIN
    invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC
LIMIT 1
 
 
 SET-2
 
 1. Write query to return the email, first name, last name, & genre of all rock music listeners.
 Return your list ordered alphabetically by email starting with A.
 
 select distinct email, first_name, last_name
 from customer
 join invoice on customer.customer_id=invoice.customer_id
 join invoice_line on invoice.invoice_id= invoice_line.invoice_id
 where track_id in(
	select track_id from track
    join genre on track.genre_id=genre.genre_id
    where genre.name like 'Rock'
)
order by email; 

-- 2. Let's invite the artists who have written the most rock music in our dataset.Write a query 
that returns the artist name and total track count of the tp 10 rock bands.


select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id= track.genre_id
where genre.name like 'Rock'
Group by artist.artist_id
order by number_of_songs desc
limit 10; 

-- 3. Return all the track names that have a song length longer than the average song length. Return 
the name and milliseconds for each track. Order by the song length with the longest songs listed first.

select name,milliseconds
from track
where milliseconds > (
	select avg(milliseconds) as avg_track_length
    from track)
    order by milliseconds desc;
    
SET-3

--1. Find how much amount spent by each customer on artists? write a query to return customer name, artist name and total spent.

With best_selling_artist as (
	select artist.artist_id as artist_id,artist.name as artist_name,
    sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
    from invoice_line
    join track on track.track_id= invoice_line.track_id
    join album on album.album_id= track.album_id
    join artist on artist.artist_id= album.artist_id
    group by 1
    order by 3 desc
    limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id= i.customer_id
join invoice_line il on il.invoice_id= i.invoice_id
join track t on t.track_id= il.track_id
join album alb on alb.album_id= t.album_id
join best_selling_artist bsa on bsa.artist_id= alb.artist_id
group by 1,2,3,4
order by 5 desc;


2.we want to find out the most popular music genre for each country. We determine the most popular genre as the genre with the highest mount of purchases.
 write a query that returns each countryalong with the top genre. For countries where the maximum number of purchases is shared return all genres.
 
 with popular_genre as
 (
	select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
    row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as RowNo
    from invoice_line
    join invoice on invoice.invoice_id= invoice_line.invoice_id
    join customer on customer.customer_id= invoice.customer_id
    join track  on track.track_id= invoice_line.track_id
    join genre on genre.genre_id= track.genre_id
    Group by 2,3,4
    order by 2 asc, 1 desc
)
select * from popular_genre where RowNo <=1


3. write a query that determine the customer that has spent the most on music for each country. Write a query that returns the country along with the top 
 customer and how much they spent.For countries where the top amount spent is shared, provide all customers who spent this amount.
 
 with customer_with_country as
 (
	select customer.customer_id, first_name, last_name, billing_country,sum(total) as total_spending,
    row_number() over(partition by billing_country order by sum(total) desc) as RowNo
    from invoice
    join customer on customer.customer_id= invoice.customer_id
    Group by 1,2,3,4
    order by 4 asc, 5 desc
)
select * from customer_with_country where RowNo <=1

