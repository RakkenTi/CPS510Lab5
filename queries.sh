#!/bin/bash

source ./.env

sqlplus64 -L -s "$DB_CONN" <<EOF
SET LINESIZE 160
SET PAGESIZE 60

PROMPT ================================================================================
PROMPT A5 QUERY 1 (EXISTS + Correlated Subqueries):
PROMPT Retrieve customers who have a verified phone number on file AND have completed
PROMPT at least one high-value payment transaction exceeding $300.
PROMPT ================================================================================
SELECT 
    c.CustomerId AS "ID",
    c.FirstName || ' ' || c.LastName AS "Customer Name",
    c.City AS "City",
    c.Email AS "Email"
FROM Customer c
WHERE EXISTS (
    SELECT 1 
    FROM Customer_Phone cp 
    WHERE cp.CustomerId = c.CustomerId
)
AND EXISTS (
    SELECT 1 
    FROM Reservation res
    JOIN Rental r ON res.ReservationId = r.ReservationId
    JOIN Transactions t ON r.RentalId = t.RentalId
    WHERE res.CustomerId = c.CustomerId
      AND t.Amount > 300
)
ORDER BY c.CustomerId;

PROMPT ================================================================================
PROMPT A5 QUERY 2 (MINUS Set Operator):
PROMPT Identify zero-defect vehicles in the fleet that have NEVER required a
PROMPT maintenance record (Fleet VINs MINUS Maintained VINs).
PROMPT ================================================================================
SELECT 
    v.VIN AS "VIN",
    v.Make AS "Make",
    v.Model AS "Model",
    v.Year AS "Year",
    v.Status AS "Current Status"
FROM Vehicle v
WHERE v.VIN IN (
    SELECT VIN FROM Vehicle
    MINUS
    SELECT VIN FROM Maintenance_Record
)
ORDER BY v.Year DESC;

PROMPT ================================================================================
PROMPT A5 QUERY 3 (UNION Set Operator):
PROMPT Generate a Fleet Risk Watchlist combining vehicles with high mileage (> 45,000 km)
PROMPT UNION vehicles that have incurred a single maintenance service costing over $150.
PROMPT ================================================================================
SELECT 
    v.VIN AS "VIN",
    v.Make || ' ' || v.Model AS "Vehicle",
    'High Mileage (>45k km)' AS "Watchlist Reason"
FROM Vehicle v
WHERE v.Mileage > 45000
UNION
SELECT 
    v.VIN AS "VIN",
    v.Make || ' ' || v.Model AS "Vehicle",
    'Expensive Maintenance (>$150)' AS "Watchlist Reason"
FROM Vehicle v
JOIN Maintenance_Record mr ON v.VIN = mr.VIN
WHERE mr.Cost > 150
ORDER BY "VIN", "Watchlist Reason";

PROMPT ================================================================================
PROMPT A5 QUERY 4 (COUNT + Statistics AVG, SUM, MIN, MAX, STDDEV + GROUP BY + HAVING):
PROMPT Branch revenue statistical analysis showing transaction count, total, average,
PROMPT min, max, and standard deviation for branches with at least 2 transactions.
PROMPT ================================================================================
SELECT 
    b.BranchId AS "ID",
    b.BranchName AS "Branch Name",
    COUNT(t.TransactionId) AS "Tx Count",
    SUM(t.Amount) AS "Total Rev ($)",
    ROUND(AVG(t.Amount), 2) AS "Avg Tx ($)",
    MIN(t.Amount) AS "Min Tx ($)",
    MAX(t.Amount) AS "Max Tx ($)",
    ROUND(STDDEV(t.Amount), 2) AS "StdDev ($)"
FROM Branch b
JOIN Rental r ON b.BranchId = r.BranchId
JOIN Transactions t ON r.RentalId = t.RentalId
GROUP BY b.BranchId, b.BranchName
HAVING COUNT(t.TransactionId) >= 2
   AND AVG(t.Amount) > 150
ORDER BY SUM(t.Amount) DESC;

PROMPT ================================================================================
PROMPT A5 QUERY 5 (EXISTS + COUNT + Statistics SUM, AVG + GROUP BY + HAVING):
PROMPT Maintenance cost statistics per vehicle for vehicles that have been rented at
PROMPT least once (EXISTS) and have an average maintenance cost exceeding $90.
PROMPT ================================================================================
SELECT 
    v.VIN AS "VIN",
    v.Make || ' ' || v.Model AS "Vehicle",
    COUNT(mr.MaintenanceId) AS "Service Count",
    SUM(mr.Cost) AS "Total Maint ($)",
    ROUND(AVG(mr.Cost), 2) AS "Avg Maint ($)",
    MAX(mr.Cost) AS "Max Service ($)"
FROM Vehicle v
JOIN Maintenance_Record mr ON v.VIN = mr.VIN
WHERE EXISTS (
    SELECT 1 
    FROM Rental r 
    WHERE r.VIN = v.VIN
)
GROUP BY v.VIN, v.Make, v.Model
HAVING COUNT(mr.MaintenanceId) >= 1
   AND AVG(mr.Cost) > 90
ORDER BY SUM(mr.Cost) DESC;

PROMPT ================================================================================
PROMPT A5 QUERY 6 (UNION + MINUS + COUNT + AVG + GROUP BY + HAVING):
PROMPT Customer spending statistics for active customers (All Customers MINUS Customers
PROMPT with no reservations) whose total spend is above the overall average transaction.
PROMPT ================================================================================
SELECT 
    c.CustomerId AS "ID",
    c.FirstName || ' ' || c.LastName AS "Customer Name",
    COUNT(t.TransactionId) AS "Payments",
    SUM(t.Amount) AS "Total Spent ($)",
    ROUND(AVG(t.Amount), 2) AS "Avg Payment ($)"
FROM Customer c
JOIN Reservation res ON c.CustomerId = res.CustomerId
JOIN Rental r ON res.ReservationId = r.ReservationId
JOIN Transactions t ON r.RentalId = t.RentalId
WHERE c.CustomerId IN (
    SELECT CustomerId FROM Customer
    MINUS
    SELECT CustomerId FROM Customer WHERE CustomerId NOT IN (SELECT CustomerId FROM Reservation)
)
GROUP BY c.CustomerId, c.FirstName, c.LastName
HAVING SUM(t.Amount) > (SELECT AVG(Amount) FROM Transactions)
ORDER BY SUM(t.Amount) DESC;

PROMPT ================================================================================
PROMPT VERIFYING VIEWS (CustomerSpend, VehicleRecords, BranchDetails):
PROMPT ================================================================================
SELECT * FROM CustomerSpend;
SELECT * FROM VehicleRecords;
SELECT * FROM BranchDetails;

EXIT;
EOF
