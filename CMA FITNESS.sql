<<<<<<< HEAD
CREATE TABLE Membership_Package (
    package_id        NUMBER(5) PRIMARY KEY,
    package_name      VARCHAR2(50) NOT NULL,
    duration_months   NUMBER(3) NOT NULL,
    monthly_fee       NUMBER(8,2) NOT NULL
=======

CREATE TABLE Trainer (
    trainer_id      NUMBER(5) PRIMARY KEY,
    first_name      VARCHAR2(50) NOT NULL,
    last_name       VARCHAR2(50) NOT NULL,
    specialization  VARCHAR2(100),
    session_rate    NUMBER(8,2)
>>>>>>> 46648df462ef4cde1a82d54e00d18f6c4a53cef8
);