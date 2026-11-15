use nifty50;

-- Creating a View 'ALL IN ONE.'
CREATE VIEW v_daily_returns AS
SELECT
    trade_date,
    close_price,
    (close_price - LAG(close_price) OVER (ORDER BY trade_date)) 
        / LAG(close_price) OVER (ORDER BY trade_date) AS daily_return,
    LN(close_price / LAG(close_price) OVER (ORDER BY trade_date)) AS log_return
FROM nifty_raw
ORDER BY trade_date;

CREATE VIEW v_cumulative_performance AS
SELECT
    trade_date,
    close_price,
    close_price / (SELECT close_price FROM nifty_raw ORDER BY trade_date ASC LIMIT 1) * 100 AS cumulative_index
FROM nifty_raw
ORDER BY trade_date;

CREATE VIEW v_rolling_volatility AS
SELECT
    trade_date,
    daily_return,
    CASE 
        WHEN COUNT(*) OVER (ORDER BY trade_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) = 30
        THEN STDDEV_SAMP(daily_return) OVER (ORDER BY trade_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) * SQRT(252)
        ELSE NULL
    END AS rolling_vol_30d
FROM v_daily_returns
WHERE daily_return IS NOT NULL
ORDER BY trade_date;

CREATE VIEW v_drawdown AS
SELECT
    trade_date,
    close_price,
    MAX(close_price) OVER (ORDER BY trade_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_peak,
    close_price / MAX(close_price) OVER (ORDER BY trade_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) - 1 AS drawdown
FROM nifty_raw
ORDER BY trade_date;

CREATE VIEW v_monthly_returns AS
SELECT
    DATE_FORMAT(trade_date, '%Y-%m') AS year_months,
    EXP(SUM(log_return)) - 1 AS monthly_return
FROM v_daily_returns
WHERE log_return IS NOT NULL
GROUP BY year_months
ORDER BY year_months;

CREATE VIEW v_yearly_returns AS
SELECT
    YEAR(trade_date) AS yr,
    EXP(SUM(log_return)) - 1 AS yearly_return
FROM v_daily_returns
WHERE log_return IS NOT NULL
GROUP BY yr
ORDER BY yr;

-- Confirm all the six 'Create View.'
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'nifty50' AND table_type = 'VIEW';


-- Check and Validate All The Calculations.

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