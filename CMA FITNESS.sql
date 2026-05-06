-- Drop existing objects
DROP TABLE BOOKING CASCADE CONSTRAINTS;
DROP TABLE CLASS_SESSION CASCADE CONSTRAINTS;
DROP TABLE TRAINER CASCADE CONSTRAINTS;
DROP TABLE CLASS_TYPE CASCADE CONSTRAINTS;
DROP TABLE MAINTENANCE CASCADE CONSTRAINTS;
DROP TABLE TECHNICIAN CASCADE CONSTRAINTS;
DROP TABLE EQUIPMENT CASCADE CONSTRAINTS;
DROP TABLE PAYMENT CASCADE CONSTRAINTS;
DROP TABLE PAYMENT_INFO CASCADE CONSTRAINTS;
DROP TABLE MEMBER CASCADE CONSTRAINTS;
DROP TABLE MEMBER_PACKAGE CASCADE CONSTRAINTS;

DROP VIEW ACTIVE_MEMBERS;
DROP VIEW EQUIPMENT_MAINTENANCE;
DROP VIEW TECHNICIAN_WORK;
DROP VIEW EQUIPMENT_STATUS;
DROP VIEW SESSION_VIEW;
DROP VIEW BOOKING_VIEW;
DROP VIEW Member_View;
DROP VIEW Member_Package_View;
DROP VIEW Payment_Info_View;
DROP VIEW Payment_View;
DROP VIEW Member_Payment_View;

-- Create Tables
CREATE TABLE MEMBER_PACKAGE (
    Package_ID     NUMBER(5) PRIMARY KEY,
    Package_Name   VARCHAR2(50),
    Duration       NUMBER(3),
    Monthly_Fee    NUMBER(8,2)
);

CREATE TABLE MEMBER (
    Member_ID              NUMBER(5) PRIMARY KEY,
    Package_ID             NUMBER(5),
    First_Name             VARCHAR2(50),
    Last_Name              VARCHAR2(50),
    Phone                  VARCHAR2(20),
    Email                  VARCHAR2(50),
    Membership_Start_Date  DATE,
    Membership_End_Date    DATE,
    Membership_Status      VARCHAR2(20),
    CONSTRAINT fk_member_package FOREIGN KEY (Package_ID) REFERENCES MEMBER_PACKAGE(Package_ID)
);

CREATE TABLE PAYMENT_INFO (
    Payment_ID         NUMBER(5) PRIMARY KEY,
    Amount_Paid        NUMBER(8,2),
    Outstanding_Amount NUMBER(8,2),
    Payment_Method     VARCHAR2(20),
    Payment_Date       DATE
);

CREATE TABLE PAYMENT (
    Member_ID   NUMBER(5),
    Payment_ID  NUMBER(5),
    PRIMARY KEY (Member_ID, Payment_ID),
    CONSTRAINT fk_payment_member FOREIGN KEY (Member_ID) REFERENCES MEMBER(Member_ID),
    CONSTRAINT fk_payment_info FOREIGN KEY (Payment_ID) REFERENCES PAYMENT_INFO(Payment_ID)
);

CREATE TABLE EQUIPMENT (
    Equipment_ID     NUMBER(5) PRIMARY KEY,
    Equipment_Name   VARCHAR2(50) NOT NULL,
    Serial_Number    VARCHAR2(50) UNIQUE,
    Purchase_Date    DATE,
    Condition        VARCHAR2(20),
    CONSTRAINT chk_equipment_condition CHECK (Condition IN ('Good','Fair','Poor'))
);

CREATE TABLE TECHNICIAN (
    Technician_ID   NUMBER(5) PRIMARY KEY,
    First_Name      VARCHAR2(50) NOT NULL,
    Last_Name       VARCHAR2(50) NOT NULL,
    Phone           VARCHAR2(20) NOT NULL
);

CREATE TABLE MAINTENANCE (
    Maintenance_ID   NUMBER(5) PRIMARY KEY,
    Equipment_ID     NUMBER(5) NOT NULL,
    Technician_ID    NUMBER(5) NOT NULL,
    Maintenance_Date DATE NOT NULL,
    Service_Type     VARCHAR2(50),
    Repair_Cost      NUMBER(8,2),
    CONSTRAINT fk_maintenance_equipment FOREIGN KEY (Equipment_ID) REFERENCES EQUIPMENT(Equipment_ID),
    CONSTRAINT fk_maintenance_technician FOREIGN KEY (Technician_ID) REFERENCES TECHNICIAN(Technician_ID),
    CONSTRAINT chk_repair_cost CHECK (Repair_Cost >= 0)
);

CREATE TABLE CLASS_TYPE (
    Class_Type_ID INTEGER PRIMARY KEY,
    Class_Name    VARCHAR2(100) NOT NULL,
    Description   VARCHAR2(255),
    Duration      INTEGER NOT NULL,
    CONSTRAINT CHK_CLASS_TYPE_DURATION CHECK (Duration > 0)
);

CREATE TABLE TRAINER (
    Trainer_ID     INTEGER PRIMARY KEY,
    First_Name     VARCHAR2(50) NOT NULL,
    Last_Name      VARCHAR2(50) NOT NULL,
    Specialisation VARCHAR2(100),
    Session_Rate   NUMBER(8,2) NOT NULL,
    CONSTRAINT CHK_TRAINER_RATE CHECK (Session_Rate >= 0)
);


CREATE TABLE CLASS_SESSION (
    Session_ID         INTEGER PRIMARY KEY,
    Attendance_ID      INTEGER,
    Class_Type_ID      INTEGER NOT NULL,
    Trainer_ID         INTEGER NOT NULL,
    Session_Date       DATE NOT NULL,
    Session_Start_Time TIMESTAMP NOT NULL,
    Session_End_Time   TIMESTAMP NOT NULL,
    CONSTRAINT FK_CLASS_SESSION_CLASS_TYPE FOREIGN KEY (Class_Type_ID) REFERENCES CLASS_TYPE(Class_Type_ID),
    CONSTRAINT FK_CLASS_SESSION_TRAINER FOREIGN KEY (Trainer_ID) REFERENCES TRAINER(Trainer_ID),
    CONSTRAINT CHK_SESSION_TIME CHECK (Session_End_Time > Session_Start_Time)
);

CREATE TABLE BOOKING (
    Booking_ID    INTEGER PRIMARY KEY,
    Member_ID     INTEGER NOT NULL,
    Session_ID    INTEGER NOT NULL,
    Booking_Date  DATE DEFAULT SYSDATE,
    Status        VARCHAR2(20) DEFAULT 'ACTIVE',
    CONSTRAINT FK_BOOKING_MEMBER FOREIGN KEY (Member_ID) REFERENCES MEMBER(Member_ID),
    CONSTRAINT FK_BOOKING_SESSION FOREIGN KEY (Session_ID) REFERENCES CLASS_SESSION(Session_ID),
    CONSTRAINT CHK_BOOKING_STATUS CHECK (Status IN ('ACTIVE','CANCELLED','COMPLETED'))
);

-- Create Indexes
CREATE INDEX idx_member_lastname ON MEMBER(Last_Name);
CREATE INDEX idx_member_package ON MEMBER(Package_ID);
CREATE INDEX idx_equipment_name ON EQUIPMENT(Equipment_Name);
CREATE INDEX idx_equipment_condition ON EQUIPMENT(Condition);
CREATE INDEX idx_technician_lastname ON TECHNICIAN(Last_Name);
CREATE INDEX idx_maintenance_equipment ON MAINTENANCE(Equipment_ID);
CREATE INDEX idx_maintenance_technician ON MAINTENANCE(Technician_ID);
CREATE INDEX idx_maintenance_date ON MAINTENANCE(Maintenance_Date);
CREATE INDEX idx_class_session_attendance ON CLASS_SESSION(Attendance_ID);
CREATE INDEX idx_class_session_class_type ON CLASS_SESSION(Class_Type_ID);
CREATE INDEX idx_class_session_trainer ON CLASS_SESSION(Trainer_ID);
CREATE INDEX idx_booking_session ON BOOKING(Session_ID);
CREATE INDEX idx_booking_member ON BOOKING(Member_ID);
CREATE INDEX idx_payment_member ON PAYMENT (Member_ID);
CREATE INDEX idx_payment_paymentid ON PAYMENT (Payment_ID);
CREATE INDEX idx_paymentinfo_date ON PAYMENT_INFO (Payment_Date);

-- Create Views
CREATE VIEW ACTIVE_MEMBERS AS
SELECT Member_ID, First_Name, Last_Name, Membership_Status
FROM MEMBER WHERE Membership_Status = 'Active';

CREATE VIEW EQUIPMENT_MAINTENANCE AS
SELECT e.Equipment_Name, m.Service_Type, m.Maintenance_Date, m.Repair_Cost,
t.First_Name AS Technician_Name
FROM EQUIPMENT e
JOIN MAINTENANCE m ON e.Equipment_ID = m.Equipment_ID
JOIN TECHNICIAN t ON m.Technician_ID = t.Technician_ID;

CREATE VIEW TECHNICIAN_WORK AS
SELECT t.Technician_ID, t.First_Name, t.Last_Name,
m.Service_Type, m.Maintenance_Date
FROM TECHNICIAN t
JOIN MAINTENANCE m ON t.Technician_ID = m.Technician_ID;

CREATE VIEW EQUIPMENT_STATUS AS
SELECT Equipment_ID, Equipment_Name, Condition
FROM EQUIPMENT;

CREATE VIEW SESSION_VIEW AS
SELECT CS.Session_ID, CT.Class_Name,
T.First_Name || ' ' || T.Last_Name AS Trainer_Name,
CS.Session_Date, CS.Session_Start_Time, CS.Session_End_Time
FROM CLASS_SESSION CS
JOIN CLASS_TYPE CT ON CS.Class_Type_ID = CT.Class_Type_ID
JOIN TRAINER T ON CS.Trainer_ID = T.Trainer_ID;

CREATE VIEW BOOKING_VIEW AS
SELECT B.Booking_ID, B.Member_ID, CS.Session_ID,
CT.Class_Name, CS.Session_Date, B.Status
FROM BOOKING B
JOIN CLASS_SESSION CS ON B.Session_ID = CS.Session_ID
JOIN CLASS_TYPE CT ON CS.Class_Type_ID = CT.Class_Type_ID;

CREATE VIEW Member_View AS
SELECT Member_ID, First_Name, Last_Name, Phone, Email, Membership_Status
FROM MEMBER;

CREATE VIEW Member_Package_View AS
SELECT Package_ID, Package_Name, Duration, Monthly_Fee
FROM MEMBER_PACKAGE;

CREATE VIEW Payment_Info_View AS
SELECT Payment_ID, Amount_Paid, Outstanding_Amount, Payment_Method, Payment_Date
FROM PAYMENT_INFO;

CREATE VIEW Payment_View AS
SELECT Member_ID, Payment_ID
FROM PAYMENT;

CREATE VIEW Member_Payment_View AS
SELECT M.Member_ID, M.First_Name, M.Last_Name,
PI.Payment_ID, PI.Amount_Paid, PI.Outstanding_Amount, PI.Payment_Date
FROM MEMBER M, PAYMENT P, PAYMENT_INFO PI
WHERE M.Member_ID = P.Member_ID
AND P.Payment_ID = PI.Payment_ID;

-- Insert Data
INSERT INTO EQUIPMENT VALUES (1, 'Treadmill', 'SN1001', DATE '2023-05-01', 'Good');
INSERT INTO EQUIPMENT VALUES (2, 'Exercise Bike', 'SN1002', DATE '2022-03-15', 'Fair');
INSERT INTO EQUIPMENT VALUES (3, 'Dumbbells Set', 'SN1003', DATE '2021-08-10', 'Good');
INSERT INTO EQUIPMENT VALUES (4, 'Rowing Machine', 'SN1004', DATE '2020-06-10', 'Poor');
INSERT INTO EQUIPMENT VALUES (5, 'Elliptical Trainer', 'SN1005', DATE '2024-02-20', 'Good');

INSERT INTO TECHNICIAN VALUES (1, 'Murendi', 'Netshiukhwi', '0821111111');
INSERT INTO TECHNICIAN VALUES (2, 'Adi', 'Mulaudzi', '0832222222');
INSERT INTO TECHNICIAN VALUES (3, 'CV', 'Mkhatshwa', '0843333333');
INSERT INTO TECHNICIAN VALUES (4, 'James', 'Mokoena', '0854444444');
INSERT INTO TECHNICIAN VALUES (5, 'Linda', 'Naidoo', '0865555555');

<<<<<<< Updated upstream
INSERT INTO MAINTENANCE VALUES (1, 1, 1, DATE '2026-03-01', 'Routine Service', 300);
INSERT INTO MAINTENANCE VALUES (2, 2, 2, DATE '2026-03-05', 'Repair', 450);
INSERT INTO MAINTENANCE VALUES (3, 3, 3, DATE '2026-04-01', 'Inspection', 150);
INSERT INTO MAINTENANCE VALUES (4, 4, 4, DATE '2026-06-02', 'Repair', 600);
INSERT INTO MAINTENANCE VALUES (5, 5, 5, DATE '2026-06-20', 'Routine Service', 200);
=======
INSERT INTO MAINTENANCE VALUES (1, 1, 1, DATE '2026-03-01', 'Routine Service', 300.00);
INSERT INTO MAINTENANCE VALUES (2, 2, 2, DATE '2026-03-05', 'Repair', 450.00);
INSERT INTO MAINTENANCE VALUES (3, 3, 3, DATE '2026-04-01', 'Inspection', 150.00);
>>>>>>> Stashed changes

INSERT INTO CLASS_TYPE VALUES (1, 'Yoga', 'Relaxation and flexibility class', 60);
INSERT INTO CLASS_TYPE VALUES (2, 'Strength Training', 'Weight and muscle building class', 60);
INSERT INTO CLASS_TYPE VALUES (3, 'Cardio Fitness', 'Heart and endurance training class', 45);
INSERT INTO CLASS_TYPE VALUES (4, 'Pilates', 'Core strength and posture', 50);
INSERT INTO CLASS_TYPE VALUES (5, 'HIIT', 'High intensity interval training', 30);

INSERT INTO TRAINER VALUES (1, 'John', 'Smith', 'Yoga', 250.00);
INSERT INTO TRAINER VALUES (2, 'Sarah', 'Brown', 'Strength Training', 300.00);
INSERT INTO TRAINER VALUES (3, 'Mike', 'Johnson', 'Cardio Fitness', 280.00);
INSERT INTO TRAINER VALUES (4, 'Emma', 'Williams', 'Pilates', 270.00);
INSERT INTO TRAINER VALUES (5, 'David', 'Lee', 'HIIT', 320.00);

INSERT INTO CLASS_SESSION VALUES (1, NULL, 1, 1, DATE '2026-05-01', TIMESTAMP '2026-05-01 09:00:00', TIMESTAMP '2026-05-01 10:00:00');
INSERT INTO CLASS_SESSION VALUES (2, NULL, 2, 2, DATE '2026-05-10', TIMESTAMP '2026-05-10 10:00:00', TIMESTAMP '2026-05-10 11:00:00');
INSERT INTO CLASS_SESSION VALUES (3, NULL, 3, 3, DATE '2026-05-15', TIMESTAMP '2026-05-15 08:00:00', TIMESTAMP '2026-05-15 08:45:00');
INSERT INTO CLASS_SESSION VALUES (4, NULL, 4, 4, DATE '2025-01-01', TIMESTAMP '2025-01-01 09:00:00', TIMESTAMP '2025-01-01 10:00:00');
INSERT INTO CLASS_SESSION VALUES (5, NULL, 5, 5, DATE '2026-06-05', TIMESTAMP '2026-06-05 09:00:00', TIMESTAMP '2026-06-05 10:00:00');
INSERT INTO CLASS_SESSION VALUES (6, NULL, 1, 2, DATE '2026-06-10', TIMESTAMP '2026-06-10 10:00:00', TIMESTAMP '2026-06-10 11:00:00');
INSERT INTO CLASS_SESSION VALUES (7, NULL, 2, 3, DATE '2026-06-15', TIMESTAMP '2026-06-15 08:00:00', TIMESTAMP '2026-06-15 09:00:00');

INSERT INTO MEMBER_PACKAGE VALUES (1, 'Basic Package', 1, 250.00);
INSERT INTO MEMBER_PACKAGE VALUES (2, 'Standard Package', 3, 600.00);
INSERT INTO MEMBER_PACKAGE VALUES (3, 'Premium Package', 6, 1000.00);
INSERT INTO MEMBER_PACKAGE VALUES (4, 'Student Package', 2, 400.00);
INSERT INTO MEMBER_PACKAGE VALUES (5, 'VIP Package', 12, 2000.00);

INSERT INTO MEMBER VALUES (101, 1, 'Thabo', 'Mokoena', '0712345678', 'thabo@gmail.com', DATE '2026-01-01', DATE '2026-02-01', 'Active');
INSERT INTO MEMBER VALUES (102, 2, 'Lerato', 'Dlamini', '0723456789', 'lerato@gmail.com', DATE '2026-01-10', DATE '2026-04-10', 'Active');
INSERT INTO MEMBER VALUES (103, 3, 'Sipho', 'Nkosi', '0734567890', 'sipho@gmail.com', DATE '2026-02-01', DATE '2026-08-01', 'Active');
INSERT INTO MEMBER VALUES (104, 4, 'Neo', 'Mashaba', '0741111111', 'neo@gmail.com', DATE '2026-01-01', DATE '2026-12-01', 'Active');
INSERT INTO MEMBER VALUES (105, 5, 'Aisha', 'Khan', '0752222222', 'aisha@gmail.com', DATE '2025-01-01', DATE '2025-10-01', 'Expired');
INSERT INTO MEMBER VALUES (106, 1, 'Daniel', 'Mabena', '0763333333', 'daniel.mabena@gmail.com', DATE '2022-01-01', DATE '2023-01-01', 'Expired');
INSERT INTO MEMBER VALUES (107, 2, 'Precious', 'Ndlovu', '0774444444', 'precious.ndlovu@gmail.com', DATE '2021-01-01', DATE '2023-03-01', 'Expired');

INSERT INTO PAYMENT_INFO VALUES (201, 250.00, 0.00, 'Cash', DATE '2026-01-01');
INSERT INTO PAYMENT_INFO VALUES (202, 300.00, 300.359, 'Card', DATE '2026-01-10');
INSERT INTO PAYMENT_INFO VALUES (203, 1000.00, 0.00, 'EFT', DATE '2026-02-01');
INSERT INTO PAYMENT_INFO VALUES (204, 400.00, 100.00, 'Card', DATE '2026-03-01');
INSERT INTO PAYMENT_INFO VALUES (205, 2000.00, 0.00, 'EFT', DATE '2026-04-01');

INSERT INTO PAYMENT VALUES (101, 201);
INSERT INTO PAYMENT VALUES (102, 202);
INSERT INTO PAYMENT VALUES (103, 203);
INSERT INTO PAYMENT VALUES (104, 204);
INSERT INTO PAYMENT VALUES (105, 205);

INSERT INTO BOOKING VALUES (1, 101, 1, SYDATE, 'ACTIVE');
INSERT INTO BOOKING VALUES (2, 102, 2, SYSDATE, 'COMPLETED');
INSERT INTO BOOKING VALUES (3, 103, 3, SYSDATE, 'ACTIVE');
INSERT INTO BOOKING VALUES (4, 101, 4, SYSDATE, 'ACTIVE');
INSERT INTO BOOKING VALUES (5, 102, 5, SYSDATE, 'ACTIVE');
INSERT INTO BOOKING VALUES (6, 103, 1, SYSDATE, 'ACTIVE');
INSERT INTO BOOKING VALUES (7, 104, 4, SYSDATE, 'CANCELLED');
INSERT INTO BOOKING VALUES (8, 105, 5, SYSDATE, 'COMPLETED');
 
-- Test Tables
SELECT * FROM MEMBER;
SELECT * FROM MEMBER_PACKAGE;
SELECT * FROM PAYMENT_INFO;
SELECT * FROM PAYMENT;
SELECT * FROM EQUIPMENT;
SELECT * FROM TECHNICIAN;
SELECT * FROM MAINTENANCE;
SELECT * FROM CLASS_TYPE;
SELECT * FROM TRAINER;
SELECT * FROM CLASS_SESSION;
SELECT * FROM BOOKING;

-- Test All Views
SELECT * FROM ACTIVE_MEMBERS;
SELECT * FROM EQUIPMENT_MAINTENANCE;
SELECT * FROM TECHNICIAN_WORK;
SELECT * FROM EQUIPMENT_STATUS;
SELECT * FROM SESSION_VIEW;
SELECT * FROM BOOKING_VIEW;
SELECT * FROM Member_View;
SELECT * FROM Member_Package_View;
SELECT * FROM Payment_Info_View;
SELECT * FROM Payment_View;
SELECT * FROM Member_Payment_View;

----QUERIES-----

-- LIMITATION OF ROWS AND COLUMNS 

SELECT * FROM MEMBER 
WHERE PACKAGE_ID >= 2;

SELECT First_Name, Last_Name 
FROM MEMBER;

SELECT * FROM MAINTENANCE 
WHERE SERVICE_TYPE = 'Repair';

SELECT Equipment_Name 
FROM EQUIPMENT;

--SORTING
SELECT First_Name, Last_Name
FROM MEMBER
ORDER BY Last_Name;

SELECT Equipment_Name, Condition
FROM EQUIPMENT
ORDER BY Condition;

SELECT Service_Type, Repair_Cost
FROM MAINTENANCE
ORDER BY Repair_Cost ASC;

SELECT Session_ID, Session_Date
FROM CLASS_SESSION
ORDER BY Session_Date;

--LIKE, AND, OR

SELECT First_Name, Last_Name
FROM MEMBER
WHERE First_Name LIKE 'T%';

SELECT *
FROM MAINTENANCE
WHERE Repair_Cost > 200 AND Service_Type = 'Repair';

SELECT *
FROM BOOKING
WHERE Status = 'ACTIVE' OR Status = 'COMPLETED';



--VARIABLES AND CHARACTER FUNCTIONS 

DEFINE member_status = 'Active';

SELECT Member_ID, First_Name, Last_Name, Membership_Status
FROM MEMBER
WHERE Membership_Status = '&member_status';

DEFINE equipment_condition = 'Good';

SELECT Equipment_ID, Equipment_Name, Condition
FROM EQUIPMENT
WHERE Condition = '&equipment_condition';

DEFINE booking_status = 'ACTIVE';

SELECT Booking_ID, Member_ID, Session_ID, Status
FROM BOOKING
WHERE Status = '&booking_status';

SELECT Member_ID,
       UPPER(First_Name) AS Upper_First_Name,
       UPPER(Last_Name) AS Upper_Last_Name,
       LOWER(Email) AS Lower_Email,
       First_Name || ' ' || Last_Name AS Full_Name,
       LENGTH(First_Name) AS First_Name_Length
FROM MEMBER;

SELECT Trainer_ID,
       INITCAP(First_Name || ' ' || Last_Name) AS Trainer_Name,
       UPPER(Specialisation) AS Specialisation
FROM TRAINER;

SELECT Technician_ID,
       INITCAP(First_Name || ' ' || Last_Name) AS Technician_Name,
       SUBSTR(Phone, 1, 3) AS Phone_Code
FROM TECHNICIAN;

SELECT Equipment_ID,
       UPPER(Equipment_Name) AS Equipment_Name,
       LOWER(Condition) AS Equipment_Condition
FROM EQUIPMENT;

SELECT Class_Type_ID,
       UPPER(Class_Name) AS Class_Name,
       SUBSTR(Description, 1, 20) AS Short_Description
FROM CLASS_TYPE;


--AGGREGATE FUNCTIONS 

SELECT COUNT(*) AS Total_Members
FROM MEMBER;

SELECT COUNT(*) AS Total_Packages,
       AVG(Monthly_Fee) AS Average_Monthly_Fee,
       MAX(Monthly_Fee) AS Highest_Monthly_Fee,
       MIN(Monthly_Fee) AS Lowest_Monthly_Fee
FROM MEMBER_PACKAGE;

SELECT COUNT(*) AS Total_Payments,
       SUM(Amount_Paid) AS Total_Amount_Paid,
       SUM(Outstanding_Amount) AS Total_Outstanding,
       AVG(Amount_Paid) AS Average_Payment
FROM PAYMENT_INFO;

SELECT COUNT(*) AS Total_Equipment
FROM EQUIPMENT;

SELECT COUNT(*) AS Total_Maintenance,
       SUM(Repair_Cost) AS Total_Repair_Cost,
       AVG(Repair_Cost) AS Average_Repair_Cost,
       MAX(Repair_Cost) AS Highest_Repair_Cost,
       MIN(Repair_Cost) AS Lowest_Repair_Cost
FROM MAINTENANCE;

SELECT COUNT(*) AS Total_Trainers,
       AVG(Session_Rate) AS Average_Session_Rate,
       MAX(Session_Rate) AS Highest_Session_Rate,
       MIN(Session_Rate) AS Lowest_Session_Rate
FROM TRAINER;

SELECT COUNT(*) AS Total_Class_Types,
       AVG(Duration) AS Average_Class_Duration,
       MAX(Duration) AS Longest_Class,
       MIN(Duration) AS Shortest_Class
FROM CLASS_TYPE;

SELECT COUNT(*) AS Total_Bookings
FROM BOOKING;



--GROUP BY AND HAVING 

SELECT Membership_Status, COUNT(*) AS Total_Members
FROM MEMBER
GROUP BY Membership_Status
HAVING COUNT(*) >= 1;

SELECT Package_ID, COUNT(*) AS Total_Members
FROM MEMBER
GROUP BY Package_ID
HAVING COUNT(*) >= 1;

SELECT Payment_Method,
       COUNT(*) AS Number_Of_Payments,
       SUM(Amount_Paid) AS Total_Paid
FROM PAYMENT_INFO
GROUP BY Payment_Method
HAVING SUM(Amount_Paid) > 0;

SELECT Condition, COUNT(*) AS Total_Equipment
FROM EQUIPMENT
GROUP BY Condition
HAVING COUNT(*) >= 1;

SELECT Service_Type,
       COUNT(*) AS Total_Services,
       SUM(Repair_Cost) AS Total_Repair_Cost
FROM MAINTENANCE
GROUP BY Service_Type
HAVING SUM(Repair_Cost) > 0;

SELECT Technician_ID,
       COUNT(*) AS Total_Jobs,
       SUM(Repair_Cost) AS Total_Repair_Cost
FROM MAINTENANCE
GROUP BY Technician_ID
HAVING COUNT(*) >= 1;

SELECT Specialisation,
       COUNT(*) AS Total_Trainers,
       AVG(Session_Rate) AS Average_Rate
FROM TRAINER
GROUP BY Specialisation
HAVING AVG(Session_Rate) > 0;

SELECT Duration,
       COUNT(*) AS Total_Classes
FROM CLASS_TYPE
GROUP BY Duration
HAVING COUNT(*) >= 1;

SELECT Status,
       COUNT(*) AS Total_Bookings
FROM BOOKING
GROUP BY Status
HAVING COUNT(*) >= 1;



--JOINS 


SELECT M.Member_ID,
       M.First_Name,
       M.Last_Name,
       MP.Package_Name,
       MP.Monthly_Fee
FROM MEMBER M
JOIN MEMBER_PACKAGE MP
ON M.Package_ID = MP.Package_ID;

SELECT M.Member_ID,
       M.First_Name,
       M.Last_Name,
       PI.Payment_ID,
       PI.Amount_Paid,
       PI.Outstanding_Amount,
       PI.Payment_Method,
       PI.Payment_Date
FROM MEMBER M
JOIN PAYMENT P
ON M.Member_ID = P.Member_ID
JOIN PAYMENT_INFO PI
ON P.Payment_ID = PI.Payment_ID;

SELECT E.Equipment_ID,
       E.Equipment_Name,
       E.Condition,
       M.Maintenance_ID,
       M.Service_Type,
       M.Repair_Cost
FROM EQUIPMENT E
JOIN MAINTENANCE M
ON E.Equipment_ID = M.Equipment_ID;

SELECT T.Technician_ID,
       T.First_Name,
       T.Last_Name,
       M.Maintenance_ID,
       M.Service_Type,
       M.Maintenance_Date
FROM TECHNICIAN T
JOIN MAINTENANCE M
ON T.Technician_ID = M.Technician_ID;

SELECT CS.Session_ID,
       CT.Class_Name,
       T.First_Name || ' ' || T.Last_Name AS Trainer_Name,
       CS.Session_Date,
       CS.Session_Start_Time,
       CS.Session_End_Time
FROM CLASS_SESSION CS
JOIN CLASS_TYPE CT
ON CS.Class_Type_ID = CT.Class_Type_ID
JOIN TRAINER T
ON CS.Trainer_ID = T.Trainer_ID;

SELECT B.Booking_ID,
       M.First_Name,
       M.Last_Name,
       CT.Class_Name,
       CS.Session_Date,
       B.Status
FROM BOOKING B
JOIN MEMBER M
ON B.Member_ID = M.Member_ID
JOIN CLASS_SESSION CS
ON B.Session_ID = CS.Session_ID
JOIN CLASS_TYPE CT
ON CS.Class_Type_ID = CT.Class_Type_ID;
------------------------------------------------------------Date Funtions 
SELECT E.Equipment_Name,
       T.First_Name AS Technician_First_Name,
       T.Last_Name AS Technician_Last_Name,
       M.Maintenance_ID,
       M.Maintenance_Date
FROM EQUIPMENT E
JOIN MAINTENANCE M 
    ON E.Equipment_ID = M.Equipment_ID 
JOIN TECHNICIAN T 
    ON M.Technician_ID = T.Technician_ID
WHERE M.Maintenance_Date >= SYSDATE - 180;
------------------------------------------------------------Round and Truncate
SELECT M.First_Name, M.Last_Name,
       TO_CHAR(ROUND(PI.Outstanding_Amount, 2), '999999.00') AS Balance_Due
FROM MEMBER M
JOIN PAYMENT P ON M.Member_ID = P.Member_ID
JOIN PAYMENT_INFO PI ON P.Payment_ID = PI.Payment_ID
WHERE PI.Outstanding_Amount > 0;

SELECT First_Name, Last_Name,
       TO_CHAR(TRUNC(Session_Rate, 2), '999999.00') AS Displayed_Rate
FROM TRAINER;
------------------------------------------------------------Subquries
SELECT Package_ID, Package_Name,
       ( SELECT COUNT(*) FROM MEMBER M
           WHERE M.Package_ID = MP.Package_ID
       ) AS Total_Members  FROM MEMBER_PACKAGE MP;
      
SELECT First_Name, Last_Name FROM MEMBER M WHERE Membership_Status = 'Active'
AND EXISTS (SELECT B.Member_ID FROM BOOKING B WHERE B.Member_ID = M.Member_ID
AND B.Status = 'ACTIVE');
------------------------------------------------------------EXTRA FUNCTIONALITY
SELECT DISTINCT Equipment_ID, Equipment_Name
FROM EQUIPMENT
WHERE Equipment_ID IN (
    SELECT Equipment_ID
    FROM MAINTENANCE
);

UPDATE BOOKING B
SET Status = 'COMPLETED'
WHERE B.Status = 'ACTIVE'
AND EXISTS (
    SELECT 1
    FROM CLASS_SESSION CS
    WHERE CS.Session_ID = B.Session_ID
    AND CS.Session_Date < SYSDATE
);

DELETE FROM MEMBER M WHERE M.Membership_End_Date < (SYSDATE - 365);
