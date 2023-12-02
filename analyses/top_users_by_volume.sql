SELECT duv.user_id AS user_id, sum(duv.trading_volume) AS trading_volume
FROM {{ref('day_user_volume')}} AS duv
WHERE duv.financial_date = '{{var('financial_date')}}'
GROUP BY duv.user_id
ORDER BY sum(duv.trading_volume) DESC
LIMIT {{var('top_n')}}
