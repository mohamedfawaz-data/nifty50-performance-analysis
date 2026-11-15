use nifty50;

-- Calculate Daily Return and Log Return.
create view v_daily_returns as 
select
trade_date,
close_price,
(close_price - lag(close_price) over (order by trade_date))
/ lag(close_price) over (order by trade_date) as daily_return,
ln(close_price / lag(close_price) over (order by trade_date)) as log_return
from nifty_raw
order by trade_date;

-- View the result.
select * from v_daily_returns limit 10;

-- Top 10 Largest Market Moves.
select trade_date, daily_return, log_return,
round(daily_return - log_return, 4) as diff
from v_daily_returns
where daily_return is not null
order by abs(daily_return) desc
limit 10;