#!/bin/bash
source ./.env

sqlplus64 -L -s "$DB_CONN" <<EOF
PROMPT Creating Tables...

CREATE TABLE Branch (
    BranchId NUMBER NOT NULL,
    BranchName VARCHAR2(100) NOT NULL,
    Street VARCHAR2(100) NOT NULL,
    City VARCHAR2(50) NOT NULL,
    AreaCode VARCHAR2(20) NOT NULL,
    CONSTRAINT branch_id_pk PRIMARY KEY (BranchId)
);

CREATE TABLE Branch_Contact (
    BranchId NUMBER NOT NULL,
    ContactNumber VARCHAR2(20),
    CONSTRAINT branch_contact_pk PRIMARY KEY (BranchId, ContactNumber),
    CONSTRAINT branch_contact_fk FOREIGN KEY (BranchId) REFERENCES Branch(BranchId) ON DELETE CASCADE
);

CREATE TABLE Customer (
    CustomerId NUMBER,
    FirstName VARCHAR2(50) NOT NULL,
    LastName VARCHAR2(50) NOT NULL,
    Email VARCHAR2(100) NOT NULL,
    DriverLicenseNumber VARCHAR2(30) NOT NULL,
    RegistrationDate DATE DEFAULT SYSDATE NOT NULL,
    Street VARCHAR2(100) NOT NULL,
    City VARCHAR2(50) NOT NULL,
    AreaCode VARCHAR2(20) NOT NULL,
    CONSTRAINT customer_id_pk PRIMARY KEY (CustomerId),
    CONSTRAINT customer_email_uq UNIQUE (Email),
    CONSTRAINT customer_license_uq UNIQUE (DriverLicenseNumber)
);

CREATE TABLE Customer_Phone (
    CustomerId NUMBER,
    PhoneNumber VARCHAR2(20),
    CONSTRAINT customer_phone_pk PRIMARY KEY (CustomerId, PhoneNumber),
    CONSTRAINT customer_phone_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId) ON DELETE CASCADE
);

CREATE TABLE Vehicle (
    VIN VARCHAR2(17),
    Make VARCHAR2(50) NOT NULL,
    Model VARCHAR2(50) NOT NULL,
    Year NUMBER(4) NOT NULL,
    Mileage NUMBER(10,2) DEFAULT 0.00,
    LicensePlate VARCHAR2(20) NOT NULL,
    Status VARCHAR2(20) DEFAULT 'Available',
    BranchId NUMBER NOT NULL,
    CONSTRAINT vehicle_vin_pk PRIMARY KEY (VIN),
    CONSTRAINT vehicle_plate_uq UNIQUE (LicensePlate),
    CONSTRAINT vehicle_status_chk CHECK (Status IN ('Available', 'Rented', 'Maintenance', 'Reserved')),
    CONSTRAINT vehicle_branch_fk FOREIGN KEY (BranchId) REFERENCES Branch(BranchId)
);

CREATE TABLE Vehicle_Feature (
    VIN VARCHAR2(17),
    Feature VARCHAR2(100),
    CONSTRAINT vehicle_feature_pk PRIMARY KEY (VIN, Feature),
    CONSTRAINT vehicle_feature_fk FOREIGN KEY (VIN) REFERENCES Vehicle(VIN) ON DELETE CASCADE
);

CREATE TABLE Maintenance_Record (
    MaintenanceId NUMBER,
    Maint_Date DATE DEFAULT SYSDATE NOT NULL,
    Type VARCHAR2(50) NOT NULL,
    Cost NUMBER(10,2) DEFAULT 0.00,
    VIN VARCHAR2(17) NOT NULL,
    CONSTRAINT maint_record_pk PRIMARY KEY (MaintenanceId),
    CONSTRAINT maint_cost_chk CHECK (Cost >= 0),
    CONSTRAINT maint_vehicle_fk FOREIGN KEY (VIN) REFERENCES Vehicle(VIN) ON DELETE CASCADE
);

CREATE TABLE Reservation (
    ReservationId NUMBER,
    PickupDate DATE NOT NULL,
    DropoffDate DATE NOT NULL,
    CustomerId NUMBER NOT NULL,
    CONSTRAINT reservation_id_pk PRIMARY KEY (ReservationId),
    CONSTRAINT res_dates_chk CHECK (DropoffDate >= PickupDate),
    CONSTRAINT res_customer_fk FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId) ON DELETE CASCADE
);

CREATE TABLE Rental (
    RentalId NUMBER,
    ReservationId NUMBER NOT NULL,
    VIN VARCHAR2(17) NOT NULL,
    BranchId NUMBER NOT NULL,
    TruePickupDate DATE NOT NULL,
    TrueDropoffDate DATE,
    KilometersTravelledBefore NUMBER(10,2) NOT NULL,
    KilometersTravelledAfter NUMBER(10,2),
    FuelUsed NUMBER(8,2),
    CONSTRAINT rental_id_pk PRIMARY KEY (RentalId),
    CONSTRAINT rental_reservation_uq UNIQUE (ReservationId),
    CONSTRAINT rental_res_fk FOREIGN KEY (ReservationId) REFERENCES Reservation(ReservationId),
    CONSTRAINT rental_vehicle_fk FOREIGN KEY (VIN) REFERENCES Vehicle(VIN),
    CONSTRAINT rental_branch_fk FOREIGN KEY (BranchId) REFERENCES Branch(BranchId),
    CONSTRAINT rental_dates_chk CHECK (TrueDropoffDate IS NULL OR TrueDropoffDate >= TruePickupDate)
);

CREATE TABLE Transactions (
    TransactionId NUMBER,
    RentalId NUMBER NOT NULL,
    Trans_Date DATE DEFAULT SYSDATE NOT NULL,
    Type VARCHAR2(50) NOT NULL,
    Amount NUMBER(10,2) NOT NULL,
    PaymentMethod VARCHAR2(30) NOT NULL,
    CONSTRAINT transaction_id_pk PRIMARY KEY (TransactionId),
    CONSTRAINT trans_amount_chk CHECK (Amount >= 0),
    CONSTRAINT trans_rental_fk FOREIGN KEY (RentalId) REFERENCES Rental(RentalId) ON DELETE CASCADE
);

PROMPT Creating Views...

CREATE OR REPLACE VIEW CustomerSpend AS
SELECT
    c.CustomerId AS "Customer ID",
    c.FirstName || ' ' || c.LastName AS "Customer Name",
    COUNT(DISTINCT r.RentalId) AS "Rental Amount",
    SUM(t.Amount) AS "Total $ Spent"
FROM Customer c
JOIN Reservation res ON c.CustomerId = res.CustomerId
JOIN Rental r ON res.ReservationId = r.ReservationId
JOIN Transactions t ON r.RentalId = t.RentalId
GROUP BY c.CustomerId, c.FirstName, c.LastName;

CREATE OR REPLACE VIEW VehicleRecords AS
SELECT
    v.VIN AS "VIN",
    v.Make || ' ' || v.Model AS "Vehicle",
    b.BranchName AS "Branch",
    mr.MaintenanceId AS "Maintenance ID",
    mr.Maint_Date AS "Maintenance Date",
    mr.Type AS "Service Type",
    mr.Cost AS "Service Cost"
FROM Vehicle v
JOIN Branch b ON v.BranchId = b.BranchId
JOIN Maintenance_Record mr ON mr.VIN = v.VIN;

CREATE OR REPLACE VIEW BranchDetails AS
SELECT
    b.BranchId AS "Branch ID",
    b.BranchName AS "Branch Name",
    b.City AS "City",
    COUNT(DISTINCT v.VIN) AS "Branch vehicle count",
    COUNT(DISTINCT r.RentalId) AS "Total Rentals"
FROM Branch b
LEFT JOIN Vehicle v ON b.BranchId = v.BranchId
LEFT JOIN Rental r ON b.BranchId = r.BranchId
GROUP BY b.BranchId, b.BranchName, b.City;

PROMPT All tables and views created successfully.
EXIT;
EOF
