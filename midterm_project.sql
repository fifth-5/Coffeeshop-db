drop database if exists coffee_shop;
create database coffee_shop;
use coffee_shop;

CREATE TABLE menu_items (
    menu_item_id INT AUTO_INCREMENT PRIMARY KEY, -- Surrogate PK
    name VARCHAR(100) NOT NULL, -- Menu item name
    description TEXT, -- Optional description
    price DECIMAL(6,2) NOT NULL CHECK (price > 0), -- Ensure price is positive
    category ENUM('Coffee', 'Tea', 'Pastry', 'Other') NOT NULL DEFAULT 'Other', -- Default category
    available BOOLEAN NOT NULL DEFAULT TRUE, -- Whether item is available
    UNIQUE (name) -- Ensure unique menu item names
);

create table wholesale_vendors (
	vendor_id			INT				PRIMARY KEY		AUTO_INCREMENT,
	vendor_name			VARCHAR(50)		NOT NULL		UNIQUE,
	vendor_address1		VARCHAR(50)		NOT NULL,
	vendor_address2		VARCHAR(50),
	vendor_city			VARCHAR(50)		NOT NULL,
	vendor_state		CHAR(2)			NOT NULL,
	vendor_zip_code		VARCHAR(20)		NOT NULL,
	vendor_phone		VARCHAR(50)		NOT NULL
	-- CONSTRAINT FK_menu_items_vendors FOREIGN KEY (vendor_id) REFERENCES ProductVendors(VendorID);
);

create table employees (
	employee_id			INT				PRIMARY KEY		AUTO_INCREMENT,
	first_name			VARCHAR(100)	NOT NULL,
	last_name			VARCHAR(100)	NOT NULL,
	employee_phone		CHAR(12)		NOT NULL,
	email				VARCHAR(100)	UNIQUE,
	hire_date			DATE			NOT NULL,
	role				VARCHAR(100)	NOT NULL,
	salary				int				NOT NULL		CHECK (salary > 0),
    age					int				NOT NULL		CHECK (age > 0),
    
    CONSTRAINT CK_employees_salary CHECK (salary > 0),
    CONSTRAINT CK_employees_age CHECK (age > 0),
    CONSTRAINT UQ_employees_email UNIQUE (email)
);

-- Create the Customers Table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    loyalty_points INT DEFAULT 0
);

-- Create the Orders Table with a foreign key relationship to Customers
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_price DECIMAL(7,2),
    CONSTRAINT FK_customer_order FOREIGN KEY (customer_id) REFERENCES customers (customer_id) ON DELETE CASCADE
);

-- Create the Order Details Table (bridge Table)
CREATE TABLE order_details (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    menu_item_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    special_instructions TEXT,
    CONSTRAINT FK_order_details_orders FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT FK_order_details_menu_items FOREIGN KEY (menu_item_id) REFERENCES menu_items(menu_item_id) ON DELETE CASCADE
);

-- Bridge table for many <-> many relationship from menu items to vendors
CREATE TABLE vendor_supplies (
    vendor_id		 	INT NOT NULL,
    menu_item_id	 	INT NOT NULL,
    last_supply_date	DATE,
    CONSTRAINT PK_vendor_supplies 
		PRIMARY KEY (vendor_id, menu_item_id),
    CONSTRAINT FK_vendor_supplies_vendors
		FOREIGN KEY (vendor_id)
        REFERENCES wholesale_vendors (vendor_id) ON DELETE CASCADE,
    CONSTRAINT FK_vendor_supplies_menu_items
		FOREIGN KEY (menu_item_id)
		REFERENCES menu_items (menu_item_id) ON DELETE CASCADE
);

CREATE TABLE order_employees (
    order_id INT NOT NULL,
    employee_id INT NOT NULL,
    PRIMARY KEY (order_id, employee_id),
    CONSTRAINT FK_order_employees_orders FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT FK_order_employees_employees FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

INSERT INTO wholesale_vendors VALUES
(1, 'Coffee Beans Co.', '123 Bean St', NULL, 'Seattle', 'WA', '98101', '555-111-2222'),
(2, 'Roasters Delight', '456 Roast Ave', NULL, 'Portland', 'OR', '97202', '555-222-3333'),
(3, 'Espresso Experts', '789 Brew Blvd', NULL, 'San Francisco', 'CA', '94105', '555-333-4444'),
(4, 'Latte Lovers', '101 Cream Ln', NULL, 'Los Angeles', 'CA', '90001', '555-444-5555'),
(5, 'Caffeine Supply', '202 Energy Dr', NULL, 'Denver', 'CO', '80202', '555-555-6666'),
(6, 'Organic Beans', '303 Nature Way', NULL, 'Austin', 'TX', '73301', '555-666-7777'),
(7, 'Premium Roasts', '404 Aroma St', NULL, 'Chicago', 'IL', '60601', '555-777-8888'),
(8, 'Bean Traders', '505 Commerce Rd', NULL, 'New York', 'NY', '10001', '555-888-9999'),
(9, 'Morning Brew', '606 Wakeup Ct', NULL, 'Miami', 'FL', '33101', '555-999-0000'),
(10, 'Supreme Coffee', '707 Elite Ave', NULL, 'Boston', 'MA', '02101', '555-000-1111');

INSERT INTO employees VALUES
(1, 'Alice', 'Brown', '425-101-2020', 'alice@gmail.com', '2016-01-15', 'Manager', 55000, 43),
(2, 'Johnny', 'Smith', '425-202-5718', 'bob@gmail.com', '2023-02-20', 'Barista', 32000, 22),
(3, 'Charlie', 'Davis', '425-303-4040', null, '2022-03-25', 'Barista', 31000, 35),
(4, 'Diana', 'Wilson', '425-404-6918', 'diana@hotmail.com', '2019-04-10', 'Supervisor', 40000, 26),
(5, 'Ethan', 'Lopez', '425-505-6060', null, '2024-05-05', 'Cashier', 28000, 19),
(6, 'Fiona', 'Martinez', '425-606-2344', 'fiona@outlook.com', '2020-06-15', 'Barista', 31500, 24),
(7, 'George', 'White', '425-707-1555', 'george@gmail.com', '2022-07-20', 'Assistant Manager', 45000, 31),
(8, 'Gregory', 'Chase', '425-229-4817', 'gregory@gmail.com', '2022-08-30', 'Barista', 25000, 18),
(9, 'Josiah', 'Gilroy', '425-808-2341', 'josiah@gmail.com', '2023-09-25', 'Barista', 26000, 18),
(10, 'Jax', 'Queen', '425-808-6612', 'jaxdagoat@gmail.com', '2019-02-17', 'Janitor', 25000, 18);

INSERT INTO menu_items (name, description, price, category, available) VALUES
('Espresso', 'Strong and bold coffee shot.', 2.50, 'Coffee', TRUE),
('Cappuccino', 'Espresso with steamed milk and foam.', 3.50, 'Coffee', TRUE),
('Latte', 'Espresso with steamed milk.', 4.00, 'Coffee', TRUE),
('Green Tea', 'Refreshing brewed green tea.', 2.75, 'Tea', TRUE),
('Chai Latte', 'Spiced tea with steamed milk.', 4.25, 'Tea', TRUE),
('Blueberry Muffin', 'Moist muffin with fresh blueberries.', 2.99, 'Pastry', TRUE),
('Chocolate Croissant', 'Flaky pastry filled with chocolate.', 3.50, 'Pastry', TRUE),
('Bagel with Cream Cheese', 'Toasted bagel with spread.', 3.00, 'Pastry', TRUE),
('Hot Chocolate', 'Rich and creamy chocolate drink.', 3.75, 'Other', TRUE),
('Iced Americano', 'Chilled espresso with water.', 3.00, 'Coffee', TRUE);

-- Insert data into Customers Table
INSERT INTO customers (first_name, last_name, email, phone, loyalty_points) VALUES
('John', 'Doe', 'johndoe@email.com', '123-456-7890', 150),
('Jane', 'Smith', 'janesmith@email.com', '987-654-3210', 200),
('Alice', 'Johnson', 'alicej@email.com', '555-123-4567', 100),
('Bob', 'Brown', 'bobbrown@email.com', '444-789-1234', 50),
('Charlie', 'Williams', 'charliew@email.com', '333-567-8901', 300),
('David', 'Miller', 'davidm@email.com', '222-345-6789', 75),
('Emma', 'Davis', 'emmad@email.com', '111-234-5678', 120),
('Frank', 'Garcia', 'frankg@email.com', '666-890-1234', 90),
('Grace', 'Martinez', 'gracem@email.com', '777-456-7890', 250),
('Henry', 'Lopez', 'henryl@email.com', '888-678-2345', 180);

INSERT INTO orders (customer_id, total_price) VALUES
(1, 25.50),
(2, 15.75),
(3, 40.00),
(4, 10.99),
(5, 22.49),
(6, 35.00),
(7, 18.25),
(8, 27.99),
(9, 12.50),
(10, 50.00);


INSERT INTO order_details (order_id, menu_item_id, quantity, special_instructions) VALUES
(1, 1, 2, 'Extra shot of espresso'),
(2, 3, 1, 'No foam'),
(2, 4, 1, NULL),
(2, 5, 1, 'Extra spice'),
(3, 6, 3, 'With butter'),
(4, 7, 1, 'Toasted'),
(5, 8, 2, 'No sugar'),
(6, 9, 1, 'With whipped cream'),
(7, 10, 1, NULL),
(8, 2, 1, 'Decaf');

INSERT INTO vendor_supplies (vendor_id, menu_item_id, last_supply_date) VALUES
(1, 1, '2025-02-01'),
(2, 2, '2025-02-03'),
(3, 3, '2025-02-05'),
(4, 4, '2025-02-07'),
(5, 5, '2025-02-10'),
(6, 6, '2025-02-12'),
(7, 7, '2025-02-14'),
(8, 8, '2025-02-16'),
(9, 9, '2025-02-18'),
(10, 10, '2025-02-20');

INSERT INTO order_employees (order_id, employee_id) VALUES
(1, 2),
(1, 3),
(2, 1),
(2, 4),
(3, 2),
(3, 5),
(4, 1),
(4, 3),
(5, 4),
(5, 5);
