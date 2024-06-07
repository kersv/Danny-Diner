-- What is the total amount each customer spent at the restaurant?
SELECT 
  s.customer_id,
  SUM(m.price) AS total_spent
FROM dannys_diner.sales AS s
INNER JOIN dannys_diner.menu AS m
  ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY total_spent desc

-- How many days has each customer visited the restaurant?
SELECT 
  customer_id,
  COUNT(DISTINCT order_date) AS visit_counts
FROM dannys_diner.sales
GROUP BY customer_id
ORDER BY visit_counts desc

-- What was the first item from the menu purchased by each customer?
WITH ordered_sales AS (
SELECT 
  customer_id,
  RANK() OVER (
    PARTITION BY 
      s.customer_id
    ORDER BY 
      s.order_date
  ) AS order_rank,
  m.product_name
FROM dannys_diner.sales AS s
INNER JOIN dannys_diner.menu AS m
  ON s.product_id = m.product_id
)
SELECT
  DISTINCT
  customer_id,
  product_name
FROM ordered_sales
WHERE order_rank = 1

-- What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
  m.product_name,
  COUNT(*) AS total_purchases
FROM dannys_diner.sales AS s
INNER JOIN dannys_diner.menu AS m
  ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY total_purchases desc 
LIMIT 1



-- Which item was the most popular for each customer?
WITH purchase_cte AS (
  SELECT
    s.customer_id,
    m.product_name,
    COUNT(*) AS purchase_count,
    RANK() OVER (
      PARTITION BY s.customer_id
      ORDER BY COUNT(s.*) desc
    ) AS item_rank
  FROM dannys_diner.sales AS s
  INNER JOIN dannys_diner.menu AS m 
    ON s.product_id = m.product_id
  GROUP BY customer_id, product_name
)
SELECT 
  customer_id,
  product_name,
  purchase_count
FROM purchase_cte
WHERE item_rank = 1

-- Which item was purchased first by the customer after they became a member?
WITH members_sales_cte AS (
  SELECT
    sales.customer_id,
    sales.order_date,
    menu.product_name,
    RANK() OVER(
      PARTITION BY sales.customer_id
      ORDER BY sales.order_date
    ) date_rank
  FROM dannys_diner.sales 
  INNER JOIN dannys_diner.members 
    ON sales.customer_id = members.customer_id
  INNER JOIN dannys_diner.menu 
    ON sales.product_id = menu.product_id
  WHERE sales.order_date >= members.join_date 
)
SELECT 
  customer_id,
  order_date,
  product_name
FROM members_sales_cte
WHERE date_rank = 1

-- Which item was purchased just before the customer became a member?
WITH before_members_sales_cte AS (
  SELECT
    sales.customer_id,
    sales.order_date,
    menu.product_name,
    RANK() OVER(
      PARTITION BY sales.customer_id
      ORDER BY sales.order_date desc
    ) date_rank
  FROM dannys_diner.sales 
  INNER JOIN dannys_diner.members 
    ON sales.customer_id = members.customer_id
  INNER JOIN dannys_diner.menu 
    ON sales.product_id = menu.product_id
  WHERE sales.order_date < members.join_date 
)
SELECT 
  customer_id,
  order_date,
  product_name
FROM before_members_sales_cte
WHERE date_rank = 1

-- What is the number of unique menu items and total amount spent for each member before they became a member?
SELECT
  sales.customer_id,
  COUNT(DISTINCT sales.product_id) AS unique_items,
  SUM(menu.price) AS amount_spent
FROM dannys_diner.sales
INNER JOIN dannys_diner.members
  ON sales.customer_id = members.customer_id
INNER JOIN dannys_diner.menu
  ON sales.product_id = menu.product_id
WHERE sales.order_date < members.join_date
GROUP BY sales.customer_id

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH points_cte AS (
SELECT 
  customer_id,
  product_name,
  price,
  (CASE WHEN product_name = 'sushi' THEN price * 20 ELSE price * 10 END) AS points
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
  ON sales.product_id = menu.product_id
)
SELECT
  customer_id,
  SUM(points) AS total_points
FROM points_cte
GROUP BY customer_id
ORDER BY total_points desc

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT 
  sales.customer_id,
  SUM(
  CASE 
    WHEN order_date BETWEEN join_date AND join_date + 6 
    THEN price * 20
    WHEN product_name = 'sushi' THEN price * 20
    ELSE price * 10
    END
  ) AS total_points
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
  ON sales.product_id = menu.product_id
INNER JOIN dannys_diner.members
  ON sales.customer_id = members.customer_id
WHERE order_date <= '2021-01-31'
GROUP BY sales.customer_id
  
-- Join all the tables
DROP TABLE IF EXISTS joint_data;
CREATE TEMP TABLE joint_data AS 
SELECT
  sales.customer_id,
  order_date,
  product_name,
  price,
  (CASE 
  WHEN order_date < join_date OR join_date IS NULL THEN 'N' 
  ELSE 'Y' 
  END) AS member
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
  ON sales.product_id = menu.product_id
LEFT JOIN dannys_diner.members
  ON sales.customer_id = members.customer_id
ORDER BY sales.customer_id, order_date

-- Rank all the members product
SELECT 
  customer_id,
  order_date,
  product_name,
  price,
  member,
  (CASE
    WHEN member = 'N' THEN null 
    ELSE 
      RANK() OVER (
        PARTITION BY customer_id, member 
        ORDER BY order_date
      ) 
  END) AS ranking
FROM joint_data

