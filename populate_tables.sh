#!/bin/bash
source ./.env

sqlplus64 -L -s "$DB_CONN" <<EOF
PROMPT Populating Tables...

-- 1. Branch
INSERT INTO Branch VALUES (1, 'Downtown Core Branch', '200 Yonge St', 'Toronto', 'M5B 2H1');
INSERT INTO Branch VALUES (2, 'Markham East Hub', '350 Steeles Ave E', 'Markham', 'L3R 8T4');
INSERT INTO Branch VALUES (3, 'Scarborough Centre', '300 Borough Dr', 'Toronto', 'M1P 4P5');
INSERT INTO Branch VALUES (4, 'Mississauga Airport', '6301 Silver Dart Dr', 'Mississauga', 'L5P 1B2');

-- 2. Branch_Contact
INSERT INTO Branch_Contact VALUES (1, '416-555-0101');
INSERT INTO Branch_Contact VALUES (1, '416-555-0102');
INSERT INTO Branch_Contact VALUES (2, '905-555-0201');
INSERT INTO Branch_Contact VALUES (3, '416-555-0301');
INSERT INTO Branch_Contact VALUES (4, '905-555-0401');

-- 3. Customer
INSERT INTO Customer VALUES (101, 'Alex', 'Mercer', 'alex.mercer@email.ca', 'M1234-56789-00101', DATE '2025-01-15', '12 Bay St', 'Toronto', 'M5J 2N8');
INSERT INTO Customer VALUES (102, 'Sarah', 'Chen', 'sarah.chen@email.ca', 'C2345-67890-00102', DATE '2025-03-20', '88 Kennedy Rd', 'Markham', 'L3R 0L7');
INSERT INTO Customer VALUES (103, 'David', 'Kowalski', 'david.k@email.ca', 'K3456-78901-00103', DATE '2025-06-10', '45 Dundas St W', 'Mississauga', 'L5B 1H8');
INSERT INTO Customer VALUES (104, 'Elena', 'Rostova', 'elena.r@email.ca', 'R4567-89012-00104', DATE '2025-08-05', '190 Brimley Rd', 'Toronto', 'M1M 3W4');
INSERT INTO Customer VALUES (105, 'Marcus', 'Vance', 'marcus.v@email.ca', 'V5678-90123-00105', DATE '2026-01-12', '70 Highway 7', 'Vaughan', 'L4L 4Y7');

-- 4. Customer_Phone (Note: Customer 105 has no phone on file for EXISTS/MINUS demo)
INSERT INTO Customer_Phone VALUES (101, '416-888-1001');
INSERT INTO Customer_Phone VALUES (101, '647-888-1002');
INSERT INTO Customer_Phone VALUES (102, '905-888-2001');
INSERT INTO Customer_Phone VALUES (103, '905-888-3001');
INSERT INTO Customer_Phone VALUES (104, '416-888-4001');

-- 5. Vehicle
INSERT INTO Vehicle VALUES ('1HGCM82633A004352', 'Honda', 'Civic', 2023, 24500.50, 'CFJD-401', 'Available', 1);
INSERT INTO Vehicle VALUES ('2T1BURHE0JC019283', 'Toyota', 'Corolla', 2022, 52100.00, 'CBTR-882', 'Rented', 1);
INSERT INTO Vehicle VALUES ('1FTFW1E85JFA93847', 'Ford', 'F-150', 2021, 68400.75, 'AXZR-109', 'Maintenance', 2);
INSERT INTO Vehicle VALUES ('5YJ3E1EA1KF392011', 'Tesla', 'Model 3', 2024, 12300.00, 'GVEV-900', 'Available', 2);
INSERT INTO Vehicle VALUES ('JM1BPACL7K1102938', 'Mazda', 'Mazda3', 2023, 31200.25, 'DPLM-554', 'Available', 3);
INSERT INTO Vehicle VALUES ('WAUZZZ8V5KA019284', 'Audi', 'A4', 2022, 46800.00, 'LUXY-777', 'Reserved', 4);

-- 6. Vehicle_Feature
INSERT INTO Vehicle_Feature VALUES ('1HGCM82633A004352', 'Apple CarPlay');
INSERT INTO Vehicle_Feature VALUES ('1HGCM82633A004352', 'Backup Camera');
INSERT INTO Vehicle_Feature VALUES ('2T1BURHE0JC019283', 'Backup Camera');
INSERT INTO Vehicle_Feature VALUES ('1FTFW1E85JFA93847', 'Tow Package');
INSERT INTO Vehicle_Feature VALUES ('5YJ3E1EA1KF392011', 'Autopilot');
INSERT INTO Vehicle_Feature VALUES ('5YJ3E1EA1KF392011', 'Heated Seats');
INSERT INTO Vehicle_Feature VALUES ('WAUZZZ8V5KA019284', 'Heated Seats');

-- 7. Maintenance_Record (Note: Tesla and Mazda have no maintenance records for MINUS demo)
INSERT INTO Maintenance_Record VALUES (501, DATE '2026-01-10', 'Oil Change', 89.99, '1HGCM82633A004352');
INSERT INTO Maintenance_Record VALUES (502, DATE '2026-02-14', 'Brake Replacement', 420.00, '2T1BURHE0JC019283');
INSERT INTO Maintenance_Record VALUES (503, DATE '2026-02-28', 'Oil Change', 95.00, '2T1BURHE0JC019283');
INSERT INTO Maintenance_Record VALUES (504, DATE '2026-03-05', 'Transmission Repair', 850.00, '1FTFW1E85JFA93847');
INSERT INTO Maintenance_Record VALUES (505, DATE '2026-03-12', 'Tire Rotation', 110.00, '1FTFW1E85JFA93847');
INSERT INTO Maintenance_Record VALUES (506, DATE '2026-03-18', 'Battery Inspection', 160.00, 'WAUZZZ8V5KA019284');

-- 8. Reservation (Customer 105 has no reservations for MINUS demo)
INSERT INTO Reservation VALUES (1001, DATE '2026-02-01', DATE '2026-02-05', 101);
INSERT INTO Reservation VALUES (1002, DATE '2026-02-10', DATE '2026-02-15', 102);
INSERT INTO Reservation VALUES (1003, DATE '2026-03-01', DATE '2026-03-04', 101);
INSERT INTO Reservation VALUES (1004, DATE '2026-03-08', DATE '2026-03-12', 103);
INSERT INTO Reservation VALUES (1005, DATE '2026-03-15', DATE '2026-03-20', 104);
INSERT INTO Reservation VALUES (1006, DATE '2026-03-22', DATE '2026-03-25', 102);

-- 9. Rental
INSERT INTO Rental VALUES (2001, 1001, '1HGCM82633A004352', 1, DATE '2026-02-01', DATE '2026-02-05', 24000.00, 24500.50, 38.50);
INSERT INTO Rental VALUES (2002, 1002, '5YJ3E1EA1KF392011', 2, DATE '2026-02-10', DATE '2026-02-15', 11500.00, 12300.00, 0.00);
INSERT INTO Rental VALUES (2003, 1003, '2T1BURHE0JC019283', 1, DATE '2026-03-01', DATE '2026-03-04', 51800.00, 52100.00, 24.00);
INSERT INTO Rental VALUES (2004, 1004, 'JM1BPACL7K1102938', 3, DATE '2026-03-08', DATE '2026-03-12', 30700.00, 31200.25, 35.20);
INSERT INTO Rental VALUES (2005, 1005, 'WAUZZZ8V5KA019284', 4, DATE '2026-03-15', DATE '2026-03-20', 46000.00, 46800.00, 55.00);
INSERT INTO Rental VALUES (2006, 1006, '1FTFW1E85JFA93847', 2, DATE '2026-03-22', DATE '2026-03-25', 68000.00, 68400.75, 62.30);

-- 10. Transactions
INSERT INTO Transactions VALUES (3001, 2001, DATE '2026-02-05', 'Rental Fee', 280.00, 'Credit Card');
INSERT INTO Transactions VALUES (3002, 2001, DATE '2026-02-05', 'Insurance', 60.00, 'Credit Card');
INSERT INTO Transactions VALUES (3003, 2002, DATE '2026-02-15', 'Rental Fee', 450.00, 'Debit Card');
INSERT INTO Transactions VALUES (3004, 2003, DATE '2026-03-04', 'Rental Fee', 220.00, 'Credit Card');
INSERT INTO Transactions VALUES (3005, 2004, DATE '2026-03-12', 'Rental Fee', 310.00, 'Credit Card');
INSERT INTO Transactions VALUES (3006, 2005, DATE '2026-03-20', 'Rental Fee', 520.00, 'Credit Card');
INSERT INTO Transactions VALUES (3007, 2005, DATE '2026-03-20', 'Late Fee', 75.00, 'Cash');
INSERT INTO Transactions VALUES (3008, 2006, DATE '2026-03-25', 'Rental Fee', 390.00, 'Debit Card');

COMMIT;
PROMPT All tables populated successfully.
EXIT;
EOF
