/**
    * @file
    * This file contains the SQL code to calculate the volume by week.The week is specified 
    * by the variable `financial_date`, the week of this date is used to perform the computation.
    *
    * In order to compute the volume by specify any day of the desired week 
    * (for example the date for Monday of the week) in the variable `financial_date`.
    *
    */

SELECT toYearWeek('{{var('financial_date')}}') AS year_week, 
sum(dv.trading_volume) AS trading_volume
FROM {{ref('day_volume')}} AS dv
WHERE dv.financial_date >= toStartOfWeek(toDate('{{var('financial_date')}}'))
  AND dv.financial_date <= toLastDayOfWeek(toDate('{{var('financial_date')}}'))