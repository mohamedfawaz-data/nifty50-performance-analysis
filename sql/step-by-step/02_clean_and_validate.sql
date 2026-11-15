use nifty50;

-- Check the null values.
select
sum(trade_date is null) as null_dates,
sum(open_price is null) as null_open,
sum(high_price is null) as null_high,
sum(low_price is null) as null_low,
sum(close_price is null) as null_close,
sum(shares_traded is null) as null_shares,
sum(turnover_cr is null) as null_turnover
from nifty_raw;

-- Check the duplicates of the date.
select trade_date, count(*)
from nifty_raw
group by trade_date
having count(*) > 1;

-- Check the nonsensical prices.
select * from nifty_raw
where high_price < low_price
or close_price > high_price
or close_price < low_price
or open_price > high_price
or open_price < low_price;

-- Check the row count per year.
select year(trade_date) as yr, count(*) as trading_days
from nifty_raw
group by yr
order by yr;