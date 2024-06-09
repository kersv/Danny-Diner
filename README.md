# Danny's Diner 

## Context
Danny is a big fan of Japanese cuisine. In early 2021, he took a leap of faith and opened a small restaurant, Danny’s Diner, featuring his top three favorite dishes: sushi, curry, and ramen. Despite its humble beginnings, Danny's Diner has captured some basic operational data over a few months, but Danny needs help to make sense of it and to use it effectively to improve his business.

## Problem Statement
Danny is eager to leverage the available data to answer several key questions about his customers:

1. **Customer Visiting Patterns**: Understanding how frequently customers visit the diner.
2. **Customer Spending**: Analyzing how much money customers have spent.
3. **Favorite Menu Items**: Identifying which menu items are most popular among customers.

By gaining these insights, Danny aims to enhance customer relationships, deliver more personalized experiences, and make informed decisions about potentially expanding the customer loyalty program. Additionally, Danny needs assistance in generating basic datasets for his team to inspect data without requiring SQL expertise.

## Datasets
The following datasets are provided to help analyze the data and answer the questions:
- `members`: Information about the members.
  
![members](data-tables/members.png)
- `sales`: Records of sales transactions.

![sales](data-tables/sales.png)
- `menu`: Details of the menu items offered.

![menu](data-tables/menu.png)


## Questions
- What is the total amount each customer spent at the restaurant?
- How many days has each customer visited the restaurant?
- What was the first item from the menu purchased by each customer?
- What is the most purchased item on the menu and how many times was it purchased by all customers?
- Which item was the most popular for each customer?
- Which item was purchased first by the customer after they became a member?
- Which item was purchased just before the customer became a member?
- What is the total items and amount spent for each member before they became a member?
- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
- Join all basic data tables.
- Rank all customer products that are members.
