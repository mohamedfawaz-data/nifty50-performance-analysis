use nifty50;

# Calculate Running Peak and Drawdown.
create view v_drawdown as
select
trade_date,
close_price,
max(close_price) over(order by trade_date rows between unbounded preceding and current row) as running_peak,
close_price / max(close_price) over(order by trade_date rows between unbounded preceding and current row) - 1 as drawdown
from nifty_raw
order by trade_date;

# Display the Drawdown.
select * from v_drawdown order by trade_date limit 10;

-- Display the Max_Drawdown with Date.
select trade_date, close_price, running_peak, drawdown
from v_drawdown
order by drawdown asc
limit 1;

-- Peak Date.
select max(trade_date) as peak_date
from v_drawdown
where close_price = running_peak and
trade_date <= (
select trade_date from v_drawdown order by drawdown asc limit 1);

-- Recovery Date (First date after the trough where price climbed back to or past that peak level.)
select min(trade_date) as recovery_date
from v_drawdown
where trade_date > (
select trade_date from v_drawdown order by drawdown asc limit 1) and
close_price >= (select running_peak from v_drawdown order by drawdown asc limit 1);
