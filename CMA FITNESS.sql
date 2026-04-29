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
    CONSTRAINT fk_member_package
        FOREIGN KEY (Package_ID)
        REFERENCES MEMBER_PACKAGE(Package_ID)
);

DROP TABLE PAYMENT_INFO CASCADE CONSTRAINTS;

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
    CONSTRAINT fk_payment_member
        FOREIGN KEY (Member_ID)
        REFERENCES MEMBER(Member_ID),
    CONSTRAINT fk_payment_info
        FOREIGN KEY (Payment_ID)
        REFERENCES PAYMENT_INFO(Payment_ID)
);

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


CREATE INDEX idx_member_package ON MEMBER (Package_ID);

CREATE INDEX idx_payment_member ON PAYMENT (Member_ID);

CREATE INDEX idx_payment_paymentid ON PAYMENT (Payment_ID);

CREATE INDEX idx_paymentinfo_date ON PAYMENT_INFO (Payment_Date);


INSERT INTO MEMBER_PACKAGE VALUES (1, 'Basic Package', 1, 250.00);
INSERT INTO MEMBER_PACKAGE VALUES (2, 'Standard Package', 3, 600.00);
INSERT INTO MEMBER_PACKAGE VALUES (3, 'Premium Package', 6, 1000.00);

INSERT INTO MEMBER VALUES (101, 1, 'Thabo', 'Mokoena', '0712345678', 'thabo@gmail.com', DATE '2026-01-01', DATE '2026-02-01', 'Active');
INSERT INTO MEMBER VALUES (102, 2, 'Lerato', 'Dlamini', '0723456789', 'lerato@gmail.com', DATE '2026-01-10', DATE '2026-04-10', 'Active');
INSERT INTO MEMBER VALUES (103, 3, 'Sipho', 'Nkosi', '0734567890', 'sipho@gmail.com', DATE '2026-02-01', DATE '2026-08-01', 'Active');

INSERT INTO PAYMENT_INFO VALUES (201, 250.00, 0.00, 'Cash', DATE '2026-01-01');
INSERT INTO PAYMENT_INFO VALUES (202, 300.00, 300.00, 'Card', DATE '2026-01-10');
INSERT INTO PAYMENT_INFO VALUES (203, 1000.00, 0.00, 'EFT', DATE '2026-02-01');

INSERT INTO PAYMENT VALUES (101, 201);
INSERT INTO PAYMENT VALUES (102, 202);
INSERT INTO PAYMENT VALUES (103, 203);

COMMIT;

SELECT * FROM MEMBER_PACKAGE;
SELECT * FROM MEMBER;
SELECT * FROM PAYMENT_INFO;
SELECT * FROM PAYMENT;

