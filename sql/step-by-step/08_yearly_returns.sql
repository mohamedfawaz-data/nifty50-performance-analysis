use nifty50;

-- Calculate Yearly Returns with Daily Return Data.
create view v_yearly_returns as
select
year(trade_date) as yr,
exp(sum(log_return)) - 1 as yearly_return
from v_daily_returns
where log_return is not null
group by yr
order by yr;

-- Display the Yearly Returns.
select * from v_yearly_returns order by yr;

-- Calculate Monthly  Return from 2021 - 2025.
select avg(monthly_return) as avg_monthly_return
from v_monthly_returns;

-- Check the Yearly Returns with the CAGR and Final Cumulative Index Value.
select exp(sum(ln(1 + yearly_return))) - 1 as total_return_from_years
from v_yearly_returns;

-- Check the Yearly Returns from Monthly Return Data.
select left(year_months, 4) as yr,
exp(sum(ln(1 + monthly_return))) - 1 as yearly_returns_from_months
from v_monthly_returns
group by yr
order by yr;