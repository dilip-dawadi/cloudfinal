# SQL Commands for Cloud Final Project

## Initial Database Setup

### 1. Connect to MySQL from Bastion Host

```bash
# SSH to bastion first
ssh -i ~/.ssh/cloudfinal-key ec2-user@<BASTION_PUBLIC_IP>

# Connect to RDS MySQL
mysql -h <RDS_ENDPOINT> -u admin -p<YOUR_PASSWORD>
```

### 2. Create Database (if not auto-created)

```sql
-- Show existing databases
SHOW DATABASES;

-- Use the database (created by Terraform)
USE webapp_db;
```

## Table Creation

### Create Users Table

```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_created_at (created_at),
    INDEX idx_email (email)
);
```

### Verify Table Structure

```sql
-- Show table structure
DESCRIBE users;

-- Show table creation statement
SHOW CREATE TABLE users;

-- Show all tables in database
SHOW TABLES;
```

## Data Insertion

### Insert Sample Data

```sql
-- Insert single record
INSERT INTO users (name, email)
VALUES ('John Doe', 'john.doe@example.com');

-- Insert multiple records
INSERT INTO users (name, email) VALUES
    ('Jane Smith', 'jane.smith@example.com'),
    ('Bob Johnson', 'bob.johnson@example.com'),
    ('Alice Williams', 'alice.williams@example.com'),
    ('Charlie Brown', 'charlie.brown@example.com');

-- Insert with specific timestamp
INSERT INTO users (name, email, created_at)
VALUES ('David Lee', 'david.lee@example.com', NOW());
```

## Data Querying

### Select All Data

```sql
-- Get all records
SELECT * FROM users;

-- Get all records ordered by most recent
SELECT * FROM users ORDER BY created_at DESC;

-- Get limited records
SELECT * FROM users ORDER BY created_at DESC LIMIT 10;
```

### Filtered Queries

```sql
-- Count total records
SELECT COUNT(*) as total_users FROM users;

-- Search by name
SELECT * FROM users WHERE name LIKE '%John%';

-- Search by email
SELECT * FROM users WHERE email = 'john.doe@example.com';

-- Get records from last hour
SELECT * FROM users
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 1 HOUR);

-- Get records from today
SELECT * FROM users
WHERE DATE(created_at) = CURDATE();
```

### Formatted Output

```sql
-- Display with custom formatting
SELECT
    id,
    name,
    email,
    DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as created_time
FROM users
ORDER BY created_at DESC;

-- Group by date
SELECT
    DATE(created_at) as date,
    COUNT(*) as count
FROM users
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

## Data Modification

### Update Records

```sql
-- Update single record
UPDATE users
SET email = 'new.email@example.com'
WHERE id = 1;

-- Update multiple records
UPDATE users
SET name = CONCAT(name, ' (Updated)')
WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 DAY);
```

### Delete Records

```sql
-- Delete single record
DELETE FROM users WHERE id = 1;

-- Delete old records
DELETE FROM users
WHERE created_at < DATE_SUB(NOW(), INTERVAL 7 DAY);

-- Delete all records (keep table structure)
TRUNCATE TABLE users;
```

## Monitoring and Statistics

### Database Statistics

```sql
-- Table size and row count
SELECT
    table_name,
    table_rows,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb
FROM information_schema.TABLES
WHERE table_schema = 'webapp_db' AND table_name = 'users';

-- Recent activity
SELECT
    COUNT(*) as total_records,
    MIN(created_at) as first_entry,
    MAX(created_at) as last_entry
FROM users;
```

### User Activity Timeline

```sql
-- Entries per hour (last 24 hours)
SELECT
    HOUR(created_at) as hour,
    COUNT(*) as entries
FROM users
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY HOUR(created_at)
ORDER BY hour;

-- Entries per day (last 7 days)
SELECT
    DATE(created_at) as date,
    COUNT(*) as entries
FROM users
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

## Testing Queries for Video Demonstration

### Before Scaling Test

```sql
-- Initial count
SELECT COUNT(*) as initial_count FROM users;

-- Show all entries with instance info (if you modify PHP to store instance_id)
SELECT * FROM users ORDER BY created_at DESC LIMIT 10;
```

### During/After Scaling Test

```sql
-- Real-time monitoring (run in loop)
SELECT
    COUNT(*) as total_entries,
    COUNT(DISTINCT DATE(created_at)) as days_active,
    MAX(created_at) as latest_entry
FROM users;

-- Watch new entries appear
SELECT * FROM users
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 5 MINUTE)
ORDER BY created_at DESC;
```

### After Instance Termination Test

```sql
-- Verify data persistence
SELECT
    id,
    name,
    email,
    created_at
FROM users
ORDER BY id DESC;

-- Confirm no data loss
SELECT COUNT(*) as total_count FROM users;
```

## Advanced Queries

### Duplicate Detection

```sql
-- Find duplicate emails
SELECT email, COUNT(*) as count
FROM users
GROUP BY email
HAVING COUNT(*) > 1;
```

### Data Validation

```sql
-- Check for invalid emails
SELECT * FROM users
WHERE email NOT LIKE '%@%.%';

-- Check for empty names
SELECT * FROM users
WHERE name = '' OR name IS NULL;
```

## Backup and Restore

### Export Data

```sql
-- Export to CSV (from command line)
mysql -h <RDS_ENDPOINT> -u admin -p<PASSWORD> webapp_db -e "SELECT * FROM users" > users_backup.csv

-- Create backup table
CREATE TABLE users_backup AS SELECT * FROM users;
```

### Restore Data

```sql
-- Restore from backup table
INSERT INTO users SELECT * FROM users_backup;

-- Copy specific records
INSERT INTO users (name, email)
SELECT name, email FROM users_backup
WHERE created_at >= '2025-01-01';
```

## Cleanup

### Drop Objects

```sql
-- Drop table
DROP TABLE IF EXISTS users;

-- Drop database
DROP DATABASE IF EXISTS webapp_db;
```

## Performance Optimization

### Add Indexes

```sql
-- Add index on email for faster searches
CREATE INDEX idx_email ON users(email);

-- Add composite index
CREATE INDEX idx_name_email ON users(name, email);

-- Show indexes
SHOW INDEX FROM users;
```

### Analyze Table

```sql
-- Analyze table for optimization
ANALYZE TABLE users;

-- Show table status
SHOW TABLE STATUS WHERE Name = 'users';
```

## Useful MySQL Commands

```sql
-- Show current database
SELECT DATABASE();

-- Show current user
SELECT USER();

-- Show MySQL version
SELECT VERSION();

-- Show current time
SELECT NOW();

-- Show all variables
SHOW VARIABLES;

-- Show process list
SHOW PROCESSLIST;

-- Exit MySQL
EXIT;
```

## Quick Reference for Video

```sql
-- 1. Initial setup
USE webapp_db;
CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL, email VARCHAR(100) NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

-- 2. Insert test data
INSERT INTO users (name, email) VALUES ('Test User 1', 'test1@example.com');

-- 3. View all data
SELECT * FROM users ORDER BY created_at DESC;

-- 4. Count records
SELECT COUNT(*) FROM users;

-- 5. Real-time monitoring
SELECT id, name, email, created_at FROM users ORDER BY created_at DESC LIMIT 5;
```

## Troubleshooting

### Connection Issues

```sql
-- Check user privileges
SHOW GRANTS FOR 'admin'@'%';

-- Check if database exists
SHOW DATABASES LIKE 'webapp_db';
```

### Performance Issues

```sql
-- Check slow queries
SHOW FULL PROCESSLIST;

-- Kill long-running query
KILL <process_id>;
```

### Character Encoding

```sql
-- Show character set
SHOW VARIABLES LIKE 'character_set%';

-- Change table character set (if needed)
ALTER TABLE users CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```
