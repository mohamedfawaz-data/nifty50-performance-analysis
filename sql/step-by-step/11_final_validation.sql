use nifty50;

-- Select Database and show Tables.
select database();
show full tables in nifty50;

-- CAGR Vs Cumulative Index (Day - 04)
select
(select cumulative_index from v_cumulative_performance order by trade_date desc limit 1) as final_index,
(select exp(sum(ln(1 + yearly_return))) from v_yearly_returns) as check_from_years;

-- Yearly Vs Monthly Compounding (Day - 08)
select y.yr, y.yearly_return, m.yearly_return_from_months
from v_yearly_returns y
join(
select left(year_months, 4) as yr,
exp(sum(ln(1 + monthly_return))) - 1 as yearly_return_from_months
from v_monthly_returns
group by yr
) m on y.yr = m.yr;

-- Row count chain across every view.
select
(select count(*) from nifty_raw) as raw_rows,
(select count(*) from v_daily_returns) as daily_returns_rows,
(select count(*) from v_daily_returns where daily_return is not null) as non_null_returns,
(select count(*) from v_drawdown) as drawdown_rows,
(select count(*) from v_monthly_returns) as monthly_rows,
(select count(*) from v_yearly_returns) as yearly_rows;

-- Drop and Rebuilt Test.
drop view if exists v_yearly_returns;
drop view if exists v_monthly_returns;
drop view if exists v_drawdown;
drop view if exists v_rolling_volatility;
drop view if exists v_cumulative_performance;
drop view if exists v_daily_returns;