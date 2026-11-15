use nifty50;

-- Display Best 5 Days and Worst 5 Days.
(select trade_date, daily_return from v_daily_returns
where daily_return is not null
order by daily_return desc limit 5)
union all
(select trade_date, daily_return from v_daily_returns
where daily_return is not null
order by daily_return asc limit 5);

-- 15 Biggest one-day Nifty Movements before and after June 4, 2024 Election Crash.
select trade_date, daily_return,
datediff(trade_date, '2024-06-04') as days_from_election_crash
from v_daily_returnsb
where daily_return is not null
order by abs(daily_return) desc
limit 15;

