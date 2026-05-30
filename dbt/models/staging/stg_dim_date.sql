select

date_sk,
full_date,
year,
quarter,
month,
month_name,
week_of_year,
day_of_month,
day_of_week,
day_name,
is_weekend

from {{ source('raw','DIM_DATE') }}