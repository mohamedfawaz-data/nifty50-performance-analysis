use nifty50;

-- 	DISTRIBUTION OF DAILY RETURNS USING SKEWNESS AND KURTOSIS.

-- Mean and Standard Deviation.
select avg(daily_return) as mean_return,
stddev_samp(daily_return) as std_dev
from v_daily_returns
where daily_return is not null;

-- Calculate Skewness and Kurtosis.
select
(sum(power((daily_return - m.mean_return) / m.std_dev, 3)) / count(*)) as skewness,
(sum(power((daily_return - m.mean_return) / m.std_dev, 4)) / count(*)) - 3 as excess_kurtosis
from v_daily_returns
cross join (
select avg(daily_return) as mean_return, stddev_samp(daily_return) as std_dev
from v_daily_returns
where daily_return is not null
) m
where daily_return is not null;

-- Calculate a Daily Returns Range with Concentraded Trading Days.
select
case
when daily_return < -0.04 then 'below -4%'
when daily_return < -0.03 then '-4% to -3%'
when daily_return < -0.02 then '-3% to -2%'
when daily_return < -0.01 then '-2% to  -1%'
when daily_return < 0 then '-1% to 0%'
when daily_return < 0.01 then '0% to 1%'
when daily_return < 0.02 then '1% to 2%'
when daily_return < 0.03 then '2% to 3%'
when daily_return < 0.04 then '3% to 4%'
else 'above 4%'
end as return_bucket,
count(*) as frequency
from v_daily_returns
where daily_return is not null
group by return_bucket
order by min(daily_return);

-- Check the Total Number of Non-Null Daily Returns.
select count(*) as total_return_days
from v_daily_returns
where daily_return is not null;