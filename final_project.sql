use coffee_shop;

-- INDEXES --

/*
Indexes
You already know the queries used in the above problems.
Now, institute indexes for those queries 
using the guidance from For the Final Group Project: Notes about Indexes listed from under Week 8
*/

-- INDEXES FOR ORDERS TABLE
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);

-- INDEXES FOR ORDER_DETAILS TABLE
CREATE INDEX idx_order_details_order_id ON order_details(order_id);
CREATE INDEX idx_order_details_menu_item_id ON order_details(menu_item_id);
CREATE INDEX idx_order_details_order_item ON order_details(order_id, menu_item_id);

-- INDEXES FOR MENU_ITEMS TABLE
CREATE INDEX idx_menu_items_price ON menu_items(price);

-- INDEXES FOR EMPLOYEES TABLE
CREATE INDEX idx_employees_salary ON employees(salary);
CREATE INDEX idx_employees_salary_filter ON employees(salary);

-- INDEXES FOR VENDOR_SUPPLIES TABLE
CREATE INDEX idx_vendor_supplies_menu_item_id ON vendor_supplies(menu_item_id);
CREATE INDEX idx_vendor_supplies_vendor_id ON vendor_supplies(vendor_id);

-- INDEXES FOR STORED FUNCTION PERFORMANCE
CREATE INDEX idx_orders_employee_id ON orders(order_id);
CREATE INDEX idx_menu_items_menu_item ON menu_items(menu_item_id);
CREATE INDEX idx_order_employees_employee ON order_employees(employee_id);


-- SUBQUERY --

/*
Subquery
Can involve 1 or more tables
Can be correlated or non-correlated
The clause of the Select Statement that the sub-query is listed is up to your team 
*/

/* this is a query that retrieves employees who have a salary greater than the average salary of all employees.
(This is a non-correlated subquery because it runs independently before the main query executes) */

SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- UPDATABLE SINGLE TABLE VIEW --

/*
Updatable Single Table View
Make sure the Single Table View created is updatable
Issue a query against the Updatable Single-Table View before the Insert or Update statement is made through the view to see the original state of the data
Next, issue an Update or Insert Statement against the View to make a change in the state of the data
Next, issue the same query against the view to show the state of the data changed because of the Insert or Update Statement
*/

/* this is an updatable view for employees that allows modifications. */

/* Step 1: Create the Updatable View */
DROP VIEW IF EXISTS vw_employee_salary_info;
CREATE VIEW vw_employee_salary_info AS
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > 25000;

/* step 2: Query the View Before Update */
SELECT * FROM vw_employee_salary_info;

/* step 3: Update an Employee’s Salary Through the View */
UPDATE vw_employee_salary_info
SET salary = 35000
WHERE employee_id = 5;

/* step 4: Query the View After Update */
SELECT * FROM vw_employee_salary_info;

-- STORED PROCEDURE --

/*
Stored Procedure
Code a SPROC that uses a combination of Cursor, Loop, If Statement (or Case Statement) and necessary select statement(s) against the database to calculate a value
Note: While and If Statement can be used for controlling how many times the Cursor For Loop executes
We also need to have an If Statement whose branches will vary in how the calculation is implemented. 
At the end of the SPROC's execution, the calculated value is printed out
Use the Call Statement to execute the SPROC
If your SROC takes in a parameter value, then call the SPROC with a parameter value
*/

DROP PROCEDURE IF EXISTS sp_calculate_order_revenue;
DELIMITER //

CREATE PROCEDURE sp_calculate_order_revenue()
BEGIN
    -- Variables
    DECLARE done INT DEFAULT 0;
    DECLARE order_total DECIMAL(7,2);
    DECLARE order_discount DECIMAL(7,2);
    DECLARE total_revenue DECIMAL(10,2) DEFAULT 0;
    DECLARE cur CURSOR FOR SELECT total_price FROM orders;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO order_total;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Discount 10% for large orders ($25+)
        IF order_total >= 25 THEN
            SET order_discount = order_total * 0.10;
        ELSE
            SET order_discount = 0;
        END IF;

        SET total_revenue = total_revenue + (order_total - order_discount);
    END LOOP;

    CLOSE cur;
    
    SELECT CONCAT('Total Revenue after discounts: $', total_revenue) AS Revenue;
END //

DELIMITER ;

CALL sp_calculate_order_revenue();

-- STORED FUNCTION --

/*
Stored Function
Code a Select Statement that in its Select Clause calls a Stored Function
The Stored Function calculates a value so that when the Select Statement is executed, the value calculated by the Stored Function is printed out
The Stored Function uses a combination of an If Statement (or Case Statement) and necessary select statement(s) against the database to calculate and return a value
If your Stored Function takes in a parameter value, then execute the Stored Function with a parameter value

*/

DROP FUNCTION IF EXISTS fn_calculate_employee_revenue;

DELIMITER $$

CREATE FUNCTION fn_calculate_employee_revenue(employee_id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_revenue DECIMAL(10,2) DEFAULT 0;

    -- Calculate total revenue for the given employee based on items they handled
    SELECT COALESCE(SUM(od.quantity * mi.price), 0)
    INTO total_revenue
    FROM order_details od
    JOIN menu_items mi ON od.menu_item_id = mi.menu_item_id
    JOIN order_employees oe ON od.order_id = oe.order_id
    WHERE oe.employee_id = employee_id; 

    -- Return the total revenue
    RETURN total_revenue;
END$$

DELIMITER ;

SELECT fn_calculate_employee_revenue(1) AS total_revenue;

-- MULTI TABLE QUERY --

/*
Multi-Table Query
Tables to use? Your team's choice
Clauses that MUST be used
Select
From
Group By
Where
Having
Order By
In the Select Clause
you need to use a built-in Function offered by SQL 
*/

-- Select relevant customer and order details along with total order value
SELECT 
    c.customer_id,  -- Customer ID
    c.first_name AS customer_first_name,  -- Customer first name
    c.last_name AS customer_last_name,  -- Customer last name
    o.order_id,  -- Order ID
    o.order_date,  -- Date when the order was placed
    SUM(od.quantity * mi.price) AS total_order_value,  -- Total value of the order (calculated)
    COUNT(od.menu_item_id) AS total_items_ordered  -- Total number of different items in the order
FROM customers c

-- Join the orders table to get customer orders
JOIN orders o ON c.customer_id = o.customer_id

-- Join the order_details table to get item quantities per order
JOIN order_details od ON o.order_id = od.order_id

-- Join the menu_items table to get the price of each menu item
JOIN menu_items mi ON od.menu_item_id = mi.menu_item_id

-- Group by customer and order to summarize total spending per order
GROUP BY c.customer_id, c.first_name, c.last_name, o.order_id, o.order_date

-- Filter to show only orders where the total value is greater than $5
HAVING total_order_value > 5

-- Sort results in descending order based on total order value
ORDER BY total_order_value DESC;
