with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('1990-01-01' as date)",
        end_date="cast('2050-12-31' as date)"
    ) }}
)
select
    replace(cast(date_day as varchar), '-', '')::int as datekey,
    date_day as date,
    year(date_day) as year,
    month(date_day) as month,
    monthname(date_day) as monthname,
    quarter(date_day) as quarter,
    dayofweek(date_day) as dayofweek,
    dayname(date_day) as dayofweekname
from date_spine



