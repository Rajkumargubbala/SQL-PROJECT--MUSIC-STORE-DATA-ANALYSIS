# creating database
create database musical_store;



 # usinng database
use musical_store;

# creating (employee) table
create table employee(employee_id int primary key, last_name varchar(100) not null,
first_name varchar(100) not null, title varchar(100) not null, reports_to int not null, levels varchar (100) not null,
birthdate varchar(100) not null, hire_date varchar(100) not null, address varchar (100) not null, city varchar (100) not null,
state varchar (100) not null, country varchar (100) not null, postal_code varchar (100) not null, phone varchar (100) not null,
fax varchar (100) not null, email varchar(100) not null);
select * from employee;



# creating (customer) table on foreign key constraint  (support_rep_id)  (reference) from  employee table column (employee_id)
create table customer (customer_id int primary key, first_name varchar (100) not null, last_name varchar (100) not null, 
company varchar (100) default null, address varchar (100) not null, city varchar(100) not null, state varchar(100) default null, 
country varchar (100) not null, postal_code varchar (100) default null, phone varchar (100) default null, fax varchar (100) default null,
email varchar (100) not null, support_rep_id int not null, constraint rs_customer_support_rep_id foreign key (support_rep_id)
references employee (employee_id) on update cascade on delete cascade);
select *  from customer;



# creating (invoice) table on foreign key constraint  (customer_id) (reference) from customer table column (customer_id)
create table invoice(invoice_id int primary key not null, customer_id int not null, invoice_date varchar(100) not null, 
billing_address varchar (100) not null, billing_city varchar (100) not null, billing_state varchar(100) not null, 
billling_country varchar(100) not null, billing_postal_code varchar(100) default null, total decimal (5,2) not null, 
constraint rs_invoice_customer_id foreign key (customer_id) references customer (customer_id) on update cascade on delete cascade);
select * from invoice;


# creating (Media_type) table 
create table Media_type (media_type_id int primary key not null, m_name varchar (100) not null);
select * from media_type;


# creating (genre) table
create table genre (genre_id int primary key not null , g_name varchar (100) not null);
select * from genre;


# creating (artist) table
create table artist (artist_id int primary key not null, a_name varchar (100) not null);
select * from artist;


# creating (album) table on foreign key constraint  (artist_id) (reference) from artist table column (artist_id)
create table album (album_id int primary key not null, title varchar (200) not null, artist_id int not null,
constraint rs_album_artist_id foreign key (artist_id) references artist (artist_id) on update cascade on delete cascade);
select * from album;


# creating (track) table on foreign key constraint  (media_type_id) (reference) from Media_type table column (media_type_id)
# on foreign key constraint  (genre_id) (reference) from genre table column (genre_id)
# on foreign key constraint  (album_id) (reference) from album table column (album_id)
create table track (track_id int primary key not null, t_name varchar(100) not null, album_id int not null, media_type_id int not null,
genre_id int not null, composer varchar(100) default null, milliseconds int not null, bytes int not null, unit_price decimal (4,2) not null,
constraint rs_track_media_type_id foreign key (media_type_id) references Media_type (media_type_id) on update cascade on delete cascade,
constraint rs_track_genre_id foreign key (genre_id) references genre (genre_id) on update cascade on delete cascade,
constraint rs_track_album_id foreign key (album_id) references album (album_id) on update cascade on delete cascade);
select * from track;



# creating(invoice_line) table on foreign key constraint  (invoice_id) (reference) from invoice table column (invoice_id)
create table invoice_line (invoice_line_id int primary key not null, invoice_id int not null, track_id int not null,
unit_price decimal (4,2), quantity int not null, constraint rs_invoice_line_invoice_id foreign key (invoice_id) 
references invoice (invoice_id) on update cascade on delete cascade,
constraint rs_invoice_line_track_id foreign key (track_id) references track (track_id) on update cascade on delete cascade);
select * from invoice_line;




# creating (playlist) table 
create table playlist (playlist_id int primary key not null, p_name varchar (100) not null);
select * from playlist;


# creating (playlist_tract) table on foreign key constraint  (playlist_id) (reference) from playlist table column (playlist_id)
# on foreign key constraint  (track_id) (reference) from track table column (track_id)
create table playlist_track (playlist_id int not null, track_id int not null,
constraint rs_playlist_track_playlist_id foreign key (playlist_id) references playlist (playlist_id) on update cascade on delete cascade,
constraint rs_playlist_track_track_id foreign key (track_id) references track (track_id) on update cascade on delete cascade);
select * from playlist_track;




##############  Question Set 1 - Easy  ################

# 1) Who is the senior most employee based on job title?
select title,first_name,last_name,levels from employee order by levels desc limit 1; 


# 2) Which countries have the most Invoices?
select count(total)as r ,billling_country from invoice group by billling_country order by r desc;


# 3) What are top 3 values of total invoice?
select total from invoice order by total desc limit 3;


# 4) Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
# Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.
select billing_city, sum(total) as invoice_total from invoice group by billing_city order by invoice_total desc limit 1;


# 5) Who is the best customer? The customer who has spent the most money will be declared the best customer. 
#    Write a query that returns the person who has spent the most money.
select customer.customer_id, concat(first_name,last_name),sum(total) as money_spent from customer
inner join invoice on customer.customer_id = invoice.customer_id group by customer.customer_id order by money_spent desc limit 1;



#  ********************** Question Set 2 – Moderate ***********************

# 1) Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. 
#    Return your list ordered alphabetically by email starting with A.
select distinct email, first_name, last_name, genre.g_name 
from customer inner join invoice on invoice.customer_id = customer.customer_id
inner join invoice_line on invoice.invoice_id = invoice_line.invoice_id inner join track on invoice_line.track_id = track.track_id 
inner join genre on track.genre_id = genre.genre_id where genre.g_name = 'Rock' order by  email;



# 2) Let's invite the artists who have written the most rock music in our dataset.
#    Write a query that returns the Artist name and total track count of the top 10 rock bands
select artist.artist_id, artist.a_name,COUNT(artist.artist_id) as r from track 
inner join album on album.album_id = track.album_id inner join artist on artist.artist_id = album.artist_id
inner join genre on genre.genre_id = track.genre_id where genre.g_name like 'Rock'
group by artist.artist_id order by r desc limit 10;


# 3) Return all the track names that have a song length longer than the average song length. 
#    Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.
select t_name , milliseconds from track where milliseconds > (select avg(milliseconds) from track ) order by 
milliseconds desc;



# ****************************** Question Set 3 – Advance ***********************************

# 1) Find how much amount is spent by each customer on artists? 
#    Write a query to return customer name, artist name and total spent. 
select concat(first_name,last_name),artist.artist_id, artist.a_name, sum(invoice_line.unit_price*invoice_line.quantity) as total_sales from customer
inner join invoice on customer.customer_id = invoice. customer_id inner join invoice_line on invoice.invoice_id = invoice_line.invoice_id
inner join track on track.track_id = invoice_line.track_id inner join album on album.album_id = track.album_id
inner join artist on artist.artist_id = album.artist_id
group by customer.customer_id,artist.artist_id order by total_sales desc ;


# 2) We want to find out the most popular music Genre for each country. 
#    We determine the most popular genre as the genre with the highest amount of purchases. 
#    Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres
select country, genre.g_name, sum(invoice_line.quantity) as Purchases from customer inner join invoice 
on customer.customer_id = invoice.customer_id inner join invoice_line on invoice.invoice_id = invoice_line.invoice_id
inner join track  on invoice_line.track_id = track.track_id inner join genre on track.genre_id = genre.genre_id
group by genre.g_name,customer.country order by customer.country;


# 3) Write a query that determines the customer that has spent the most on music for each country. 
#    Write a query that returns the country along with the top customer and how much they spent. 
#    For countries where the top amount spent is shared, provide all customers who spent this amount.
select customer.country , concat(first_name,last_name) as Customer_Name,  sum(invoice_line.unit_price) as Total_Spent 
from customer inner join invoice on customer.customer_id = invoice.customer_id
inner join invoice_line on invoice.invoice_id = invoice_line.invoice_id group by customer.country, Customer_Name order by Country;


