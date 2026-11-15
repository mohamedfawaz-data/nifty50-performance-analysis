use nifty50;

-- Calculate CAGR.
select
power(
(select close_price from nifty_raw order by trade_date desc limit 1) / 
(select close_price from nifty_raw order by trade_date asc limit 1),
365.25 / (select datediff(max(trade_date), min(trade_date)) from nifty_raw)
) -1 as cagr;

/* Take the first Nifty closing price as 100 and show how the Nifty's value would have changed relative to that starting point throughout the dataset - 
Cumulative Performance Index */
create view v_cumulative_performance as
select
trade_date,
close_price,
close_price / (select close_price from nifty_raw order by trade_date asc limit 1) * 100 as cumulative_index
from nifty_raw
order by trade_date;

-- View the Cumulative Performance Index
select * from v_cumulative_performance order by trade_date desc limit 5;

-- Cumulative Performance Index check query
select
(select cumulative_index from v_cumulative_performance order by trade_date desc limit 1) as final_index,
(select close_price from nifty_raw order by trade_date desc limit 1) / 
(select close_price from nifty_raw order by trade_date asc limit 1) * 100 as check_calc;
