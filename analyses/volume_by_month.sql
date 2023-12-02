/**
    * @file
    * This file contains the SQL code to calculate the volume by month.The month is specified 
    * by the variable `financial_date`, the month of this date is used to perform the computation.
    *
    * In order to compute the volume by specify any day of the month (for example the first date) 
    * in the variable `financial_date`.
    */

SELECT toYear('{{var('financial_date')}}') AS financial_year, 
toMonth('{{var('financial_date')}}') AS financial_month, 
sum(dv.trading_volume) AS trading_volume
FROM {{ref('day_volume')}} AS dv
WHERE dv.financial_date >= toStartOfMonth(toDate('{{var('financial_date')}}'))
  AND dv.financial_date <= toLastDayOfMonth(toDate('{{var('financial_date')}}'))