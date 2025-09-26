
DROP DATABASE IF EXISTS ecommerce_analysis;
CREATE DATABASE ecommerce_analysis;
USE ecommerce_analysis;

-- CREATE TABLES

-- Customers Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_unique_id VARCHAR(50) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    date_of_birth DATE,
    gender ENUM('M', 'F', 'Other'),
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    country VARCHAR(50) DEFAULT 'USA',
    zip_code VARCHAR(10),
    registration_date DATE NOT NULL,
    customer_status ENUM('Active', 'Inactive', 'Suspended') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Product Categories Table
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) UNIQUE NOT NULL,
    category_description TEXT,
    parent_category_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- Products Table

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(200) NOT NULL,
    product_description TEXT,
    category_id INT NOT NULL,
    brand VARCHAR(100),
    price DECIMAL(10,2) NOT NULL,
    cost_price DECIMAL(10,2),
    stock_quantity INT DEFAULT 0,
    weight_kg DECIMAL(8,3),
    dimensions_cm VARCHAR(50), -- "LxWxH"
    product_status ENUM('Active', 'Discontinued', 'Out_of_Stock') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Sellers/Vendors Table
CREATE TABLE sellers (
    seller_id INT PRIMARY KEY AUTO_INCREMENT,
    seller_name VARCHAR(100) NOT NULL,
    seller_email VARCHAR(100) UNIQUE NOT NULL,
    seller_phone VARCHAR(15),
    business_name VARCHAR(150),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50) DEFAULT 'USA',
    zip_code VARCHAR(10),
    commission_rate DECIMAL(5,2) DEFAULT 5.00, -- Percentage
    seller_status ENUM('Active', 'Inactive', 'Suspended') DEFAULT 'Active',
    registration_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    order_status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Returned') DEFAULT 'Pending',
    payment_status ENUM('Pending', 'Paid', 'Failed', 'Refunded') DEFAULT 'Pending',
    shipping_address TEXT NOT NULL,
    billing_address TEXT NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    shipping_cost DECIMAL(8,2) DEFAULT 0.00,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(12,2) NOT NULL,
    shipped_date DATETIME NULL,
    delivered_date DATETIME NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order Items Table
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    seller_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(8,2) DEFAULT 0.00,
    total_price DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

-- Payments Table
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    payment_method ENUM('Credit_Card', 'Debit_Card', 'PayPal', 'Bank_Transfer', 'Cash_on_Delivery', 'Digital_Wallet') NOT NULL,
    payment_provider VARCHAR(50), -- Visa, MasterCard, PayPal, etc.
    payment_amount DECIMAL(12,2) NOT NULL,
    payment_date DATETIME NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed', 'Cancelled', 'Refunded') DEFAULT 'Pending',
    transaction_id VARCHAR(100) UNIQUE,
    payment_reference VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Reviews Table
CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    review_title VARCHAR(200),
    review_text TEXT,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    helpful_votes INT DEFAULT 0,
    verified_purchase BOOLEAN DEFAULT TRUE,
    review_status ENUM('Published', 'Pending', 'Rejected') DEFAULT 'Published',
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Shipping Table
CREATE TABLE shipping (
    shipping_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    shipping_method VARCHAR(100) NOT NULL, -- Standard, Express, Overnight
    shipping_provider VARCHAR(100), -- FedEx, UPS, DHL, etc.
    tracking_number VARCHAR(100),
    shipped_date DATETIME,
    estimated_delivery_date DATE,
    actual_delivery_date DATETIME,
    shipping_cost DECIMAL(8,2),
    shipping_status ENUM('Preparing', 'Shipped', 'In_Transit', 'Delivered', 'Failed') DEFAULT 'Preparing',
    delivery_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);


-- STEP 2: INSERT SAMPLE DATA

-- Insert Categories
INSERT INTO categories (category_name, category_description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Computers', 'Laptops, desktops, and computer accessories'),
('Mobile Phones', 'Smartphones and mobile accessories'),
('Home & Garden', 'Home improvement and garden supplies'),
('Clothing', 'Apparel for men, women, and children'),
('Sports & Outdoors', 'Sports equipment and outdoor gear'),
('Books', 'Books and educational materials'),
('Beauty & Health', 'Beauty products and health supplements'),
('Toys & Games', 'Toys, games, and entertainment'),
('Automotive', 'Car parts and automotive accessories');

-- Insert nested categories
INSERT INTO categories (category_name, category_description, parent_category_id) VALUES
('Laptops', 'Portable computers', 2),
('Smartphones', 'Mobile phones', 3),
('Gaming', 'Gaming consoles and games', 1),
('Furniture', 'Home furniture', 4),
('Men\'s Clothing', 'Clothing for men', 5);

-- Insert Sellers
INSERT INTO sellers (seller_name, seller_email, seller_phone, business_name, city, state, zip_code, commission_rate, registration_date) VALUES
('Tech Solutions LLC', 'contact@techsolutions.com', '555-0101', 'Tech Solutions LLC', 'San Francisco', 'CA', '94105', 3.5, '2023-01-15'),
('Fashion Forward Inc', 'sales@fashionforward.com', '555-0102', 'Fashion Forward Inc', 'New York', 'NY', '10001', 4.0, '2023-01-20'),
('Home Essentials Co', 'info@homeessentials.com', '555-0103', 'Home Essentials Co', 'Chicago', 'IL', '60601', 5.0, '2023-02-01'),
('Sports Central', 'orders@sportscentral.com', '555-0104', 'Sports Central', 'Austin', 'TX', '73301', 4.5, '2023-02-15'),
('Book World', 'support@bookworld.com', '555-0105', 'Book World', 'Seattle', 'WA', '98101', 6.0, '2023-03-01'),
('Beauty Zone', 'hello@beautyzone.com', '555-0106', 'Beauty Zone', 'Miami', 'FL', '33101', 5.5, '2023-03-10'),
('Game Hub', 'sales@gamehub.com', '555-0107', 'Game Hub', 'Los Angeles', 'CA', '90001', 3.0, '2023-03-20'),
('Auto Parts Plus', 'info@autopartsplus.com', '555-0108', 'Auto Parts Plus', 'Detroit', 'MI', '48201', 4.0, '2023-04-01');

-- Insert Products
INSERT INTO products (product_name, product_description, category_id, brand, price, cost_price, stock_quantity, weight_kg) VALUES
-- Electronics
('MacBook Pro 16"', 'High-performance laptop for professionals', 11, 'Apple', 2499.99, 2000.00, 25, 2.14),
('Dell XPS 13', 'Ultra-portable Windows laptop', 11, 'Dell', 1299.99, 950.00, 40, 1.27),
('iPhone 14 Pro', 'Latest flagship smartphone', 12, 'Apple', 999.99, 750.00, 100, 0.206),
('Samsung Galaxy S23', 'Android flagship smartphone', 12, 'Samsung', 849.99, 650.00, 85, 0.168),
('Sony PlayStation 5', 'Next-gen gaming console', 13, 'Sony', 499.99, 400.00, 20, 4.5),
('Nintendo Switch OLED', 'Portable gaming console', 13, 'Nintendo', 349.99, 280.00, 60, 0.42),

-- Home & Garden
('IKEA Office Chair', 'Ergonomic office chair', 14, 'IKEA', 199.99, 120.00, 50, 15.5),
('Standing Desk', 'Height-adjustable standing desk', 14, 'FlexiSpot', 299.99, 200.00, 30, 35.0),
('Smart Thermostat', 'WiFi-enabled programmable thermostat', 4, 'Nest', 249.99, 180.00, 75, 0.5),
('Robot Vacuum', 'Automated cleaning robot', 4, 'Roomba', 399.99, 280.00, 35, 3.4),

-- Clothing
('Men\'s Hoodie', 'Cotton blend pullover hoodie', 15, 'Nike', 79.99, 45.00, 200, 0.8),
('Women\'s Jeans', 'High-waisted skinny jeans', 5, 'Levi\'s', 89.99, 50.00, 150, 0.6),
('Running Shoes', 'Lightweight running shoes', 6, 'Adidas', 129.99, 75.00, 120, 0.4),
('Yoga Mat', 'Premium non-slip yoga mat', 6, 'Manduka', 59.99, 30.00, 80, 1.2),

-- Books & Others
('Data Science Handbook', 'Complete guide to data science', 7, 'O\'Reilly', 49.99, 25.00, 100, 0.8),
('Wireless Headphones', 'Noise-canceling wireless headphones', 1, 'Sony', 199.99, 120.00, 90, 0.25),
('Bluetooth Speaker', 'Portable wireless speaker', 1, 'JBL', 89.99, 55.00, 110, 0.6),
('Fitness Tracker', 'Heart rate and activity monitor', 8, 'Fitbit', 149.99, 95.00, 70, 0.04),
('Skincare Set', 'Complete skincare routine kit', 8, 'Cetaphil', 79.99, 40.00, 60, 0.5),
('Board Game', 'Strategy board game for families', 9, 'Hasbro', 39.99, 20.00, 85, 1.5);

-- Insert Customers
INSERT INTO customers (customer_unique_id, first_name, last_name, email, phone, date_of_birth, gender, city, state, zip_code, registration_date) VALUES
('CUST001', 'John', 'Smith', 'john.smith@email.com', '555-1001', '1985-03-15', 'M', 'New York', 'NY', '10001', '2023-01-10'),
('CUST002', 'Emma', 'Johnson', 'emma.johnson@email.com', '555-1002', '1990-07-22', 'F', 'Los Angeles', 'CA', '90001', '2023-01-15'),
('CUST003', 'Michael', 'Brown', 'michael.brown@email.com', '555-1003', '1988-11-08', 'M', 'Chicago', 'IL', '60601', '2023-01-20'),
('CUST004', 'Sarah', 'Davis', 'sarah.davis@email.com', '555-1004', '1992-05-14', 'F', 'Houston', 'TX', '77001', '2023-02-01'),
('CUST005', 'David', 'Wilson', 'david.wilson@email.com', '555-1005', '1987-09-30', 'M', 'Phoenix', 'AZ', '85001', '2023-02-10'),
('CUST006', 'Lisa', 'Miller', 'lisa.miller@email.com', '555-1006', '1995-12-03', 'F', 'Philadelphia', 'PA', '19101', '2023-02-15'),
('CUST007', 'James', 'Garcia', 'james.garcia@email.com', '555-1007', '1983-04-18', 'M', 'San Antonio', 'TX', '78201', '2023-03-01'),
('CUST008', 'Maria', 'Rodriguez', 'maria.rodriguez@email.com', '555-1008', '1991-08-25', 'F', 'San Diego', 'CA', '92101', '2023-03-05'),
('CUST009', 'Robert', 'Martinez', 'robert.martinez@email.com', '555-1009', '1989-01-12', 'M', 'Dallas', 'TX', '75201', '2023-03-10'),
('CUST010', 'Jennifer', 'Anderson', 'jennifer.anderson@email.com', '555-1010', '1994-06-07', 'F', 'San Jose', 'CA', '95101', '2023-03-15'),
('CUST011', 'William', 'Taylor', 'william.taylor@email.com', '555-1011', '1986-10-21', 'M', 'Austin', 'TX', '73301', '2023-04-01'),
('CUST012', 'Ashley', 'Thomas', 'ashley.thomas@email.com', '555-1012', '1993-02-28', 'F', 'Jacksonville', 'FL', '32099', '2023-04-05'),
('CUST013', 'Christopher', 'Jackson', 'christopher.jackson@email.com', '555-1013', '1984-07-16', 'M', 'Fort Worth', 'TX', '76101', '2023-04-10'),
('CUST014', 'Amanda', 'White', 'amanda.white@email.com', '555-1014', '1996-11-09', 'F', 'Columbus', 'OH', '43085', '2023-04-15'),
('CUST015', 'Daniel', 'Harris', 'daniel.harris@email.com', '555-1015', '1990-03-04', 'M', 'Charlotte', 'NC', '28201', '2023-04-20');

-- Insert Orders with realistic data
INSERT INTO orders (order_number, customer_id, order_date, order_status, payment_status, shipping_address, billing_address, subtotal, tax_amount, shipping_cost, total_amount, shipped_date, delivered_date) VALUES
('ORD-2024-001', 1, '2024-01-15 10:30:00', 'Delivered', 'Paid', '123 Main St, New York, NY 10001', '123 Main St, New York, NY 10001', 2499.99, 199.99, 0.00, 2699.98, '2024-01-16 09:00:00', '2024-01-18 14:30:00'),
('ORD-2024-002', 2, '2024-01-20 14:45:00', 'Delivered', 'Paid', '456 Oak Ave, Los Angeles, CA 90001', '456 Oak Ave, Los Angeles, CA 90001', 1549.98, 123.99, 15.99, 1689.96, '2024-01-21 11:00:00', '2024-01-24 16:20:00'),
('ORD-2024-003', 3, '2024-02-01 09:15:00', 'Delivered', 'Paid', '789 Pine St, Chicago, IL 60601', '789 Pine St, Chicago, IL 60601', 999.99, 79.99, 0.00, 1079.98, '2024-02-02 08:30:00', '2024-02-05 13:45:00'),
('ORD-2024-004', 4, '2024-02-10 16:20:00', 'Processing', 'Paid', '321 Elm Dr, Houston, TX 77001', '321 Elm Dr, Houston, TX 77001', 849.99, 67.99, 12.99, 930.97, NULL, NULL),
('ORD-2024-005', 5, '2024-02-15 11:30:00', 'Shipped', 'Paid', '654 Cedar Ln, Phoenix, AZ 85001', '654 Cedar Ln, Phoenix, AZ 85001', 899.98, 71.99, 19.99, 991.96, '2024-02-16 10:15:00', NULL),
('ORD-2024-006', 1, '2024-03-01 13:45:00', 'Delivered', 'Paid', '123 Main St, New York, NY 10001', '123 Main St, New York, NY 10001', 299.99, 23.99, 9.99, 333.97, '2024-03-02 09:30:00', '2024-03-04 15:20:00'),
('ORD-2024-007', 6, '2024-03-05 08:20:00', 'Delivered', 'Paid', '987 Maple Ave, Philadelphia, PA 19101', '987 Maple Ave, Philadelphia, PA 19101', 169.98, 13.59, 7.99, 191.56, '2024-03-06 14:00:00', '2024-03-09 11:30:00'),
('ORD-2024-008', 7, '2024-03-10 15:10:00', 'Delivered', 'Paid', '147 Birch St, San Antonio, TX 78201', '147 Birch St, San Antonio, TX 78201', 629.97, 50.39, 0.00, 680.36, '2024-03-11 12:45:00', '2024-03-14 09:15:00'),
('ORD-2024-009', 8, '2024-03-20 12:00:00', 'Cancelled', 'Refunded', '258 Willow Rd, San Diego, CA 92101', '258 Willow Rd, San Diego, CA 92101', 199.99, 15.99, 8.99, 224.97, NULL, NULL),
('ORD-2024-010', 9, '2024-04-01 10:45:00', 'Delivered', 'Paid', '369 Spruce Ave, Dallas, TX 75201', '369 Spruce Ave, Dallas, TX 75201', 449.98, 35.99, 12.99, 498.96, '2024-04-02 11:20:00', '2024-04-05 16:40:00'),
('ORD-2024-011', 2, '2024-04-10 14:30:00', 'Delivered', 'Paid', '456 Oak Ave, Los Angeles, CA 90001', '456 Oak Ave, Los Angeles, CA 90001', 1299.99, 103.99, 0.00, 1403.98, '2024-04-11 09:15:00', '2024-04-14 13:25:00'),
('ORD-2024-012', 10, '2024-04-15 16:15:00', 'Processing', 'Paid', '741 Aspen Dr, San Jose, CA 95101', '741 Aspen Dr, San Jose, CA 95101', 229.98, 18.39, 6.99, 255.36, NULL, NULL),
('ORD-2024-013', 11, '2024-05-01 09:30:00', 'Shipped', 'Paid', '852 Poplar St, Austin, TX 73301', '852 Poplar St, Austin, TX 73301', 319.98, 25.59, 11.99, 357.56, '2024-05-02 08:45:00', NULL),
('ORD-2024-014', 12, '2024-05-10 11:20:00', 'Delivered', 'Paid', '963 Hickory Ave, Jacksonville, FL 32099', '963 Hickory Ave, Jacksonville, FL 32099', 89.99, 7.19, 5.99, 103.17, '2024-05-11 10:30:00', '2024-05-13 14:15:00'),
('ORD-2024-015', 13, '2024-05-20 13:40:00', 'Pending', 'Pending', '159 Walnut Rd, Fort Worth, TX 76101', '159 Walnut Rd, Fort Worth, TX 76101', 799.98, 63.99, 0.00, 863.97, NULL, NULL);

-- Insert Order Items
INSERT INTO order_items (order_id, product_id, seller_id, quantity, unit_price, total_price) VALUES
-- Order 1: MacBook Pro
(1, 1, 1, 1, 2499.99, 2499.99),
-- Order 2: iPhone + Wireless Headphones
(2, 3, 1, 1, 999.99, 999.99),
(2, 16, 1, 1, 199.99, 199.99),
(2, 19, 6, 1, 79.99, 79.99),
(2, 11, 2, 1, 79.99, 79.99),
(2, 13, 4, 1, 129.99, 129.99),
-- Order 3: iPhone 14 Pro
(3, 3, 1, 1, 999.99, 999.99),
-- Order 4: Samsung Galaxy S23
(4, 4, 1, 1, 849.99, 849.99),
-- Order 5: PS5 + Game
(5, 5, 7, 1, 499.99, 499.99),
(5, 20, 8, 1, 39.99, 39.99),
(5, 6, 7, 1, 349.99, 349.99),
-- Order 6: Standing Desk
(6, 8, 3, 1, 299.99, 299.99),
-- Order 7: Men's Hoodie + Yoga Mat
(7, 11, 2, 1, 79.99, 79.99),
(7, 14, 4, 1, 59.99, 59.99),
(7, 18, 6, 1, 149.99, 149.99),
-- Order 8: Multiple items
(8, 17, 1, 1, 89.99, 89.99),
(8, 15, 8, 1, 49.99, 49.99),
(8, 19, 6, 2, 79.99, 159.98),
(8, 10, 3, 1, 399.99, 399.99),
-- Order 9: Wireless Headphones (cancelled)
(9, 16, 1, 1, 199.99, 199.99),
-- Order 10: Nintendo Switch + Fitness Tracker
(10, 6, 7, 1, 349.99, 349.99),
(10, 18, 6, 1, 149.99, 149.99),
-- Order 11: Dell XPS 13
(11, 2, 1, 1, 1299.99, 1299.99),
-- Order 12: Office Chair + Skincare
(12, 7, 3, 1, 199.99, 199.99),
(12, 19, 6, 1, 79.99, 79.99),
-- Order 13: Running Shoes + Bluetooth Speaker + Yoga Mat
(13, 13, 4, 1, 129.99, 129.99),
(13, 17, 1, 1, 89.99, 89.99),
(13, 14, 4, 2, 59.99, 119.98),
-- Order 14: Women's Jeans
(14, 12, 2, 1, 89.99, 89.99),
-- Order 15: Multiple high-value items
(15, 9, 3, 1, 249.99, 249.99),
(15, 10, 3, 1, 399.99, 399.99),
(15, 18, 6, 1, 149.99, 149.99);

-- Insert Payments
INSERT INTO payments (order_id, payment_method, payment_provider, payment_amount, payment_date, payment_status, transaction_id) VALUES
(1, 'Credit_Card', 'Visa', 2699.98, '2024-01-15 10:35:00', 'Completed', 'TXN-001-2024'),
(2, 'Credit_Card', 'MasterCard', 1689.96, '2024-01-20 14:50:00', 'Completed', 'TXN-002-2024'),
(3, 'PayPal', 'PayPal', 1079.98, '2024-02-01 09:20:00', 'Completed', 'TXN-003-2024'),
(4, 'Credit_Card', 'Visa', 930.97, '2024-02-10 16:25:00', 'Completed', 'TXN-004-2024'),
(5, 'Debit_Card', 'MasterCard', 991.96, '2024-02-15 11:35:00', 'Completed', 'TXN-005-2024'),
(6, 'Digital_Wallet', 'Apple Pay', 333.97, '2024-03-01 13:50:00', 'Completed', 'TXN-006-2024'),
(7, 'Credit_Card', 'Visa', 191.56, '2024-03-05 08:25:00', 'Completed', 'TXN-007-2024'),
(8, 'PayPal', 'PayPal', 680.36, '2024-03-10 15:15:00', 'Completed', 'TXN-008-2024'),
(9, 'Credit_Card', 'Visa', 224.97, '2024-03-20 12:05:00', 'Refunded', 'TXN-009-2024'),
(10, 'Credit_Card', 'MasterCard', 498.96, '2024-04-01 10:50:00', 'Completed', 'TXN-010-2024'),
(11, 'Credit_Card', 'Visa', 1403.98, '2024-04-10 14:35:00', 'Completed', 'TXN-011-2024'),
(12, 'Digital_Wallet', 'Google Pay', 255.36, '2024-04-15 16:20:00', 'Completed', 'TXN-012-2024'),
(13, 'Credit_Card', 'MasterCard', 357.56, '2024-05-01 09:35:00', 'Completed', 'TXN-013-2024'),
(14, 'Debit_Card', 'Visa', 103.17, '2024-05-10 11:25:00', 'Completed', 'TXN-014-2024'),
(15, 'Credit_Card', 'Visa', 863.97, '2024-05-20 13:45:00', 'Pending', 'TXN-015-2024');

-- Insert Reviews
INSERT INTO reviews (order_id, product_id, customer_id, rating, review_title, review_text, review_date) VALUES
(1, 1, 1, 5, 'Excellent laptop!', 'Amazing performance for work and creative tasks. Highly recommended!', '2024-01-20 15:30:00'),
(2, 3, 2, 4, 'Great phone but pricey', 'Love the camera quality and performance, but wish it was more affordable.', '2024-01-25 11:15:00'),
(2, 16, 2, 5, 'Perfect headphones', 'Excellent sound quality and noise cancellation. Worth every penny!', '2024-01-25 11:20:00'),
(3, 3, 3, 5, 'Best smartphone ever', 'Incredible features and build quality. Very satisfied with this purchase.', '2024-02-08 14:45:00'),
(4, 4, 4, 4, 'Good Android phone', 'Solid performance and good value for money. Battery life could be better.', '2024-02-15 16:30:00'),
(5, 5, 5, 5, 'Gaming paradise', 'PS5 exceeded all expectations. Graphics are mind-blowing!', '2024-02-20 19:45:00'),
(6, 8, 1, 4, 'Quality desk', 'Sturdy and adjustable. Great for home office setup.', '2024-03-07 10:30:00'),
(7, 14, 6, 5, 'Best yoga mat ever', 'Perfect grip and comfort. Highly recommend for yoga practice.', '2024-03-12 08:15:00'),
(8, 10, 7, 4, 'Roomba works great', 'Saves so much time on cleaning. Sometimes gets stuck under furniture.', '2024-03-18 13:20:00'),
(10, 6, 9, 5, 'Nintendo Switch is amazing', 'Perfect for gaming on the go. Kids love it too!', '2024-04-08 17:00:00'),
(11, 2, 2, 4, 'Solid laptop', 'Good performance and portability. Screen could be brighter.', '2024-04-18 12:45:00'),
(13, 13, 11, 5, 'Comfortable running shoes', 'Perfect fit and great cushioning. Ideal for daily runs.', '2024-05-05 07:30:00'),
(14, 12, 12, 3, 'Jeans are okay', 'Decent quality but sizing runs small. Color faded after few washes.', '2024-05-15 20:15:00');

-- Insert Shipping Data
INSERT INTO shipping (order_id, shipping_method, shipping_provider, tracking_number, shipped_date, estimated_delivery_date, actual_delivery_date, shipping_cost, shipping_status, delivery_notes) VALUES
(1, 'Standard', 'FedEx', 'FDX123456789', '2024-01-16 09:00:00', '2024-01-18', '2024-01-18 14:30:00', 0.00, 'Delivered', 'Delivered to front door'),
(2, 'Express', 'UPS', 'UPS987654321', '2024-01-21 11:00:00', '2024-01-24', '2024-01-24 16:20:00', 15.99, 'Delivered', 'Signed by recipient'),
(3, 'Standard', 'USPS', 'USPS456789123', '2024-02-02 08:30:00', '2024-02-05', '2024-02-05 13:45:00', 0.00, 'Delivered', 'Left with neighbor'),
(4, 'Express', 'FedEx', 'FDX789123456', '2024-02-10 16:25:00', '2024-02-13', NULL, 12.99, 'Shipped', 'In transit'),
(5, 'Overnight', 'DHL', 'DHL321654987', '2024-02-16 10:15:00', '2024-02-17', NULL, 19.99, 'Shipped', 'Out for delivery'),
(6, 'Standard', 'UPS', 'UPS654321789', '2024-03-02 09:30:00', '2024-03-04', '2024-03-04 15:20:00', 9.99, 'Delivered', 'Delivered to mailbox'),
(7, 'Express', 'FedEx', 'FDX147258369', '2024-03-06 14:00:00', '2024-03-09', '2024-03-09 11:30:00', 7.99, 'Delivered', 'Delivered to front door'),
(8, 'Standard', 'USPS', 'USPS741852963', '2024-03-11 12:45:00', '2024-03-14', '2024-03-14 09:15:00', 0.00, 'Delivered', 'Signed by recipient'),
(10, 'Express', 'UPS', 'UPS159753486', '2024-04-02 11:20:00', '2024-04-05', '2024-04-05 16:40:00', 12.99, 'Delivered', 'Left at side door'),
(11, 'Standard', 'FedEx', 'FDX951357246', '2024-04-11 09:15:00', '2024-04-14', '2024-04-14 13:25:00', 0.00, 'Delivered', 'Delivered to front door'),
(12, 'Express', 'DHL', 'DHL753951486', '2024-04-15 16:20:00', '2024-04-18', NULL, 6.99, 'In_Transit', 'Expected delivery today'),
(13, 'Standard', 'UPS', 'UPS486159753', '2024-05-02 08:45:00', '2024-05-06', NULL, 11.99, 'Shipped', 'Package sorted at facility'),
(14, 'Express', 'USPS', 'USPS357159486', '2024-05-11 10:30:00', '2024-05-13', '2024-05-13 14:15:00', 5.99, 'Delivered', 'Delivered to mailbox');


-- STEP 3: CREATE INDEXES FOR OPTIMIZATION

-- Primary indexes for frequently queried columns
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
CREATE INDEX idx_orders_status ON orders(order_status, payment_status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_state ON customers(state);
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_reviews_product ON reviews(product_id);
CREATE INDEX idx_reviews_customer ON reviews(customer_id);

-- Composite indexes for complex queries
CREATE INDEX idx_order_items_order_product ON order_items(order_id, product_id);
CREATE INDEX idx_orders_date_status ON orders(order_date, order_status);
CREATE INDEX idx_products_category_price ON products(category_id, price);


-- STEP 4: VERIFICATION QUERIES
-- Verify database structure
SHOW TABLES;

-- Check record counts
SELECT 
    'customers' as table_name, COUNT(*) as record_count FROM customers
UNION ALL
SELECT 
    'categories' as table_name, COUNT(*) as record_count FROM categories
UNION ALL
SELECT 
    'products' as table_name, COUNT(*) as record_count FROM products
UNION ALL
SELECT 
    'sellers' as table_name, COUNT(*) as record_count FROM sellers
UNION ALL
SELECT 
    'orders' as table_name, COUNT(*) as record_count FROM orders
UNION ALL
SELECT 
    'order_items' as table_name, COUNT(*) as record_count FROM order_items
UNION ALL
SELECT 
    'payments' as table_name, COUNT(*) as record_count FROM payments
UNION ALL
SELECT 
    'reviews' as table_name, COUNT(*) as record_count FROM reviews
UNION ALL
SELECT 
    'shipping' as table_name, COUNT(*) as record_count FROM shipping;

-- Quick data validation
SELECT 
    CONCAT('$', FORMAT(o.total_revenue, 2)) as Total_Revenue,
    o.total_orders as Total_Orders,
    o.pending_orders as Pending_Orders,
    c.active_customers as Active_Customers,
    CONCAT('$', FORMAT(o.avg_order_value, 2)) as Average_Order_Value
FROM 
    (SELECT 
        SUM(CASE WHEN payment_status = 'Paid' THEN total_amount ELSE 0 END) as total_revenue,
        COUNT(*) as total_orders,
        COUNT(CASE WHEN payment_status = 'Pending' THEN 1 END) as pending_orders,
        AVG(CASE WHEN payment_status = 'Paid' THEN total_amount END) as avg_order_value
     FROM orders
    ) o
CROSS JOIN
    (SELECT COUNT(*) as active_customers 
     FROM customers 
     WHERE customer_status = 'Active'
    ) c;

-- Sample data preview
SELECT 'CUSTOMERS SAMPLE' as section;
SELECT customer_id, first_name, last_name, email, city, state 
FROM customers 
LIMIT 5;

SELECT 'PRODUCTS SAMPLE' as section;
SELECT p.product_name, p.brand, p.price, c.category_name
FROM products p
JOIN categories c ON p.category_id = c.category_id
LIMIT 5;

SELECT 'ORDERS SAMPLE' as section;
SELECT o.order_number, c.first_name, c.last_name, o.order_date, o.total_amount, o.order_status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LIMIT 5;

