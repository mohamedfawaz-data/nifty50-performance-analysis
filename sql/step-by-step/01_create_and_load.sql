-- Create schema named "nifty50."
create schema nifty50;
USE nifty50;

-- Create table nifty_raw.
create table nifty_raw(
trade_date date primary key,
open_price decimal(10,2),
high_price decimal(10,2),
low_price decimal(10,2),
close_price decimal(10,2),
shares_traded bigint,
turnover_cr decimal(14,2));

-- Check the table is empty.
truncate table nifty50.nifty_raw;

-- Check the local infile.
show variables like 'local_infile';
set global local_infile = 1;

-- Load the data.
load data local infile 'path/to/nifty_master_clean.csv'
into table  nifty_raw
fields terminated by ','
lines terminated by '\n'
ignore 1 rows
(@date_str, open_price, high_price, low_price, close_price, shares_traded, turnover_cr)
set trade_date = STR_TO_DATE(@date_str, '%d-%m-%Y');

-- Check the data whether it is loaded.
select count(*) as row_count,
min(trade_date) as first_date,
max(trade_date) as last_date
from nifty_raw;