use nifty50;

-- Calculate Monthly Returns.
create view v_monthly_returns as
select 
date_format(trade_date, '%Y-%m') as year_months,
exp(sum(log_return)) - 1 as monthly_return	
from v_daily_returns
where log_return is not null
group by year_months
order by year_months;
 
 -- Display the Monthly Return.
 select * from v_monthly_returns order by year_months;
 
 -- Positive and Negative Months count.
 select
 sum(case when monthly_return > 0 then 1 else 0 end) as positive_month,
 sum(case when monthly_return <= 0 then 1 else 0 end) as negative_month,
 count(*) as total_months
 from v_monthly_returns;
 
 -- Display Best and Worst Month.
 (select year_months, monthly_return from v_monthly_returns order by monthly_return desc limit 1)
 union all
 (select year_months, monthly_return from v_monthly_returns order by monthly_return asc limit 1);
 
 -- Rank the Worst Months (Check 2022-03 and 2022-06 because these two are confirmed real-world events.)
select year_months, monthly_return, worst_rank
from (
select year_months, monthly_return,
rank() over (order by monthly_return asc) as worst_rank
from v_monthly_returns
) ranked
where year_months in ('2022-03', '2022-06');

-- Check 2024-06 Election Crash Month's Rank.
select year_months, monthly_return, worst_rank
from (
select year_months, monthly_return,
rank() over (order by monthly_return asc) as worst_rank
from v_monthly_returns
) ranked
where year_months in ('2024-06');
 