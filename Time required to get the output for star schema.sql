SELECT dimfilm.title, dimdate.month, dimcustomer.city, sum(sales_amount) as revenue
FROM factsales
JOIN dimfilm ON (dimfilm.film_key  =factsales.film_key)
JOIN dimdate ON (dimdate.date_key = factsales.date_key)
JOIN dimcustomer on (dimcustomer.customer_key  = factsales.customer_key)
group by (dimfilm.title, dimdate.month, dimcustomer.city)
order by dimfilm.title, dimdate.month, dimcustomer.city, revenue desc;