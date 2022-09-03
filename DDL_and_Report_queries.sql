create table customer_details
(
customer_id int constraint cus_id_pk primary key not null,
customer_name varchar (100),
user_type char(5),
cust_dob date,
phone_number varchar(15),
gender Char (6),
email varchar(100)
);



create table station_details
(
station_id int constraint stn_id_pk primary key not null,
station_name varchar(100),
latitude decimal (2,5),
longitude decimal (2,5)
);



create table pricing
(
bike_type_id int constraint bktyp_id primary key not null,
bike_type varchar(50),
price_per_min int
)
;

select * from pricing;
insert into pricing values (1,'Road Bike',0.1);
insert into pricing values (2,'Classic Bike',0.2);
insert into pricing values (3,'Tour Bike',0.3);
insert into pricing values (4,'BMX',0.4);



create table bike
(
bike_id int constraint bk_id_pk primary key not null,
bike_type_id int,
bike_brand varchar (50),
bike_size char(5),
current_station_id int,
constraint fk_to_biketype foreign key (bike_type_id) references pricing(bike_type_id),
constraint fk_to_curstn foreign key (current_station_id) references station_details(station_id)
);



create table trip_details
(
trip_id int primary key not null,
bike_id int,
customer_id int,
start_station_id int,
end_station_id int,
start_time timestamp,
end_time timestamp,
trip_duration int,
constraint fk_to_bikeid foreign key (bike_id) references bike(bike_id),
constraint fk_to_cusid foreign key (customer_id) references customer_details(customer_id),
constraint fk_to_stnstart foreign key (start_station_id) references station_details(station_id),
constraint fk_to_stnend foreign key (end_station_id) references station_details(station_id)
);


create table payment_details
(
transaction_id int primary key not null,
trip_id int,
payment_type varchar(20),
date_transaction timestamp,
bill_amount int,
constraint fk_to_tripid foreign key (trip_id) references trip_details(trip_id)
)
;

---report 1 - Total earnings per each bike type
select a.bike_type, count(d.trip_id) as Number_of_trips,sum(d.bill_amount) as Total_earnings
from pricing a left outer join bike b  on a.bike_type_id=b.bike_type_id left outer join trip_details c on b.bike_id=c.bike_id left outer join payment_details d on c.trip_id=d.trip_id
group by a.bike_type;

---report 2 - Total travel time of each bike

select a.bike_id, sum(b.trip_duration) as Total_Time_travelled
from bike a left outer join trip_details b on a.bike_id=b.bike_id group by a.bike_id
order by 2;

---report 3 - Season traffic

select 
case when to_char(start_time,'MM') in ('03','04','05') Then count(trip_id) end
from trip_details;
select * from 
(select 'Total Number of trip' as "Season" from Dual),
(select count(trip_id) as  "Spring"
from trip_details 
where to_char(start_time,'MM') in ('03','04','05') and to_char(end_time,'MM') in ('03','04','05')),
(select count(trip_id) as  "Summer"
from trip_details 
where to_char(start_time,'MM') in ('06','07','08') and to_char(end_time,'MM') in ('06','07','08')),
(select count(trip_id) as  "Fall"
from trip_details 
where to_char(start_time,'MM') in ('09','10','11') and to_char(end_time,'MM') in ('09','10','11')),
(select count(trip_id) as  "Winter"
from trip_details 
where to_char(start_time,'MM') in ('12','01','02') and to_char(end_time,'MM') in ('12','01','02'))
;

---report 4 - Gender based usage

select a.gender,
case when a.gender='male' then count(b.trip_id)
when a.gender='female' then count(b.trip_id)
when a.gender='others' then count(b.trip_id) end "Trip Count",
case when a.gender='male' then sum(b.trip_duration)
when a.gender='female' then sum(b.trip_duration)
when a.gender='others' then sum(b.trip_duration) end "Total time used",
max(trip_duration),min(trip_duration)
from customer_details a join trip_details b on a.customer_id=b.customer_id
group by a.gender
;

---report 5 - Trip report

select a.trip_id,a.customer_id,b.customer_name,b.cust_dob,b.phone_number,b.gender,b.email,a.bike_id,e.bike_brand,e.bike_size,f.bike_type,a.start_station_id,c.station_name "Start_station_name",
a.end_station_id,g.station_name "End_station_name",a.trip_duration,d.transaction_id,d.payment_type,d.date_transaction,d.bill_amount
from trip_details a left outer join customer_details b on a.customer_id=b.customer_id
left outer join station_details c on a.start_station_id=c.station_id 
left outer join station_details g on a.end_station_id=g.station_id
left outer join payment_details d on a.trip_id=d.trip_id
left outer join bike e on a.bike_id = e.bike_id 
left outer join pricing f on e.bike_type_id=f.bike_type_id
order by d.date_transaction;