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

