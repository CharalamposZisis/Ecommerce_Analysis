-- START of SCHEMAS
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(10),
    age_group VARCHAR(120),
    signup_date TIMESTAMP,
    country VARCHAR(50)    
);

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_status VARCHAR(50),
    payment_method VARCHAR(50),
    constraint fk_customer
        foreign key(customer_id)
            references customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id VARCHAR(20),
    product_id VARCHAR(20),
    quantity INT,
    unit_price DECIMAL(10,2), 
    constraint fk_order
        foreign key(order_id)
            references orders(order_id),
    constraint fk_product
        foreign key(product_id)
            references products(product_id)
);

CREATE TABLE reviews (
    review_id VARCHAR(20) PRIMARY KEY,
    product_id VARCHAR(20),
    customer_id VARCHAR(20),
    rating INT,
    review_text TEXT,
    review_date TIMESTAMP,
    constraint fk_product
        foreign key(product_id)
            references products(product_id),
    constraint fk_customer
        foreign key(customer_id)
            references customers(customer_id)
);

-- END of SCHEMAS