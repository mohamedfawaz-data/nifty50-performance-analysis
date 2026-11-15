use nifty50;

-- Calculate the Annualised Volatility.
select stddev_samp(daily_return) * sqrt(252) as annualised_volatility
from v_daily_returns
where daily_return is not null;

-- Calculate Rolling 30 - Day Volatility.
create view v_rolling_volatility as
select
trade_date,
daily_return,
stddev_samp(daily_return) over (
order by trade_date
rows between 29 preceding and current row
) * sqrt(252) as rolling_vol_30d
from v_daily_returns
where daily_return is not null
order by trade_date;

-- Display the Rolling 30 - Day Volatility.
select * from v_rolling_volatility order by trade_date limit 35;

-- Display the 10 trading dates had the highest 30 - Day Rolling Volatility.
select trade_date,
round(rolling_vol_30d, 4) as rolling_vol_30d
from v_rolling_volatility
order by rolling_vol_30d desc
limit 10;

-- Display min, max and avg of Rolling 30 - Day Volatility.
select min(rolling_vol_30d) as min_vol,
max(rolling_vol_30d) as max_vol,
avg(rolling_vol_30d) as avg_vol
from v_rolling_volatility;


-- Drop the view "v_rolling_volatility."
drop view if exists v_rolling_volatility;

-- Calculate the Rolling 30-Day Volatility again for meanigful data dates.
create view v_rolling_volatility as
select
trade_date,
daily_return,
case
when count(*) over (order by trade_date rows between 29 preceding and current row) = 30
then stddev_samp(daily_return) over (order by trade_date rows between 29 preceding and current row) * sqrt(252)
else null
end as rolling_vol_30d
from v_daily_returns
where daily_return is not null
order by trade_date;

-- Check the first 30 observations.
select * from v_rolling_volatility order by trade_date limit 35;

-- Display the min, max and avgerage Rolling 30-Day Volatility.
select min(rolling_vol_30d) as min_vol,
max(rolling_vol_30d) as max_vol,
avg(rolling_vol_30d) as avg_vol
from v_rolling_volatility;