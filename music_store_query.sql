use Music_Store;


-- Q1. senior most employee best on job title

select * from employee
order by levels desc
limit 1;


-- Q2. which countries have the most invoices

select billing_country,count(*) as c from invoice 
group by billing_country
order by c desc;


--  Q3. top 3 values of total invoice

select total from invoice
order by total desc
limit  3;


-- Q4. which city has best customer? We would like to throw a promotional Music Festival in the city we made the most money.
-- write a query that returns one city that has highest some of invoive totals. Return both city name and some of all invoice totals.

select billing_city, sum(total) as invoice_total from invoice
group by billing_city
order by invoice_total desc
limit 1;


-- Q5. who is the best customer on the basis of spending more money? Write a query that returns the person who has spent the most money.

select customer.customer_id,customer.first_name,customer.last_name ,sum(invoice.total) as total
from customer
join invoice
on customer.customer_id = invoice.customer_id
group by customer.customer_id,customer.first_name,customer.last_name 
order by total desc
limit 1;



-- Q6. write query to return email,first_name,last_name,and genre of all rock music.
-- return your list alphabetically  by email .

select distinct email,first_name,last_name 
from customer
join invoice 
on customer.customer_id=invoice.customer_id
join invoiceline
on invoice.invoice_id=invoiceline.invoice_id
where track_id in(
   select track_id from track
   join genre
   on track.genre_id= genre.genre_id
   where genre.name like 'rock'
   )
   order by email;
   
   
   
-- Q7. who have written the most rock music
-- write a query that returns the artist name and total track count of the top 2 rock bands

select artist.artist_id,artist.artist_name,count(artist.artist_id) as number_of_songs
from track
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'rock'
  group by artist.artist_id,artist.artist_name
  order by number_of_songs desc
  limit 2;
  
  
-- Q8. return all the track anmes that have a song length longer than the avg song length
-- return the name,milliseconds for each track
-- order by the song length with the longest song listed first

select t_name,milliseconds from track
where milliseconds>
(select avg(milliseconds) as avg_track_legth from track)
order by milliseconds desc;



-- Q9. how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent.


WITH best_selling_artist AS (
  SELECT
    a.artist_id AS artist_id,
    a.artist_name AS artist_name,
    SUM(il.price * il.quantity) AS total_sales
  FROM
    invoiceline AS il
    JOIN track AS t ON t.track_id = il.track_id
    JOIN album AS al ON al.album_id = t.album_id
    JOIN artist AS a ON a.artist_id = al.artist_id
  GROUP BY a.artist_id,a.artist_name
  ORDER BY total_sales DESC
  LIMIT 1
)
select c.customer_id,c.first_name,c.last_name,bsa.artist_name,SUM(il.price * il.quantity) AS amount_spent
from invoice as i
join customer as c on c.customer_id=i.customer_id
join invoiceline as il on il.invoice_id=i.invoice_id
join track as t on t.track_id=il.track_id
join album as al on al.album_id=t.album_id
join best_selling_artist as bsa
on bsa.artist_id=al.artist_id
group by 1,2,3,4
order by 5 desc;



-- Q10. find out the most popular music genre for each country on the basis of highest amount of purchases.
-- Write a query that returns each country along with the top Genre.

with popular_genre as(
select count(il.quantity) as purchases,c.country,g.name,g.genre_id,
row_number() over(partition by c.country order by count(il.quantity)desc) as rowno
from invoiceline as il
join invoice  as i on i.invoice_id=il.invoice_id
join customer as c on c.customer_id=i.customer_id
join track as t on t.track_id=il.track_id
join genre as g on g.genre_id=t.genre_id
group by 2,3,4
order by 2 asc,1 desc
)
select * from popular_genre where rowno<=1;



-- Q11. query that determines the customer that has  spent the most on music for each country
-- Write a query that returns the country along with the top customer and how much they do have spent.


with customer_with_country as(
select c.customer_id,first_name,last_name,billing_country,sum(total) as total_spending,
row_number() over(partition by billing_country order by sum(total)desc) as rowno
from invoice as i
join customer as c on c.customer_id=i.customer_id
group by 1,2,3,4
order by 4 asc,  total_spending desc
)
select * from customer_with_country 
where rowno<=1;

