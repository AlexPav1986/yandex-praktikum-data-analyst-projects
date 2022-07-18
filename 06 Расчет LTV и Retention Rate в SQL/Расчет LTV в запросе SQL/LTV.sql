WITH 
profiles AS
         (SELECT user_id, created_at AS first_ses_month
          FROM tools_shop.users 
          WHERE EXTRACT(YEAR FROM created_at) = '2019'
               AND user_id IN (
                               SELECT DISTINCT user_id
                               FROM tools_shop.orders)
          ),
lifetime AS
        (SELECT o.user_id,
               DATE_TRUNC('month', first_ses_month)::date,  
               EXTRACT(MONTH FROM AGE(o.created_at,first_ses_month)) AS lifetime,
               SUM(total_amt) OVER(PARTITION BY p.user_id ORDER BY o.created_at) AS ltv
        FROM profiles AS p
        JOIN tools_shop.orders AS o ON o.user_id=p.user_id
         )         
SELECT DATE_TRUNC('month', first_ses_month)::date,
       lifetime,
       ROUND(AVG(ltv),2) AS avg_ltv
FROM profiles AS p
JOIN lifetime AS l ON l.user_id=p.user_id
WHERE l.lifetime <= 5
GROUP BY 1, 2;
