CREATE TABLE EQUIPMENT (
    Equipment_ID     NUMBER(5) PRIMARY KEY,
    Equipment_Name   VARCHAR2(50),
    Serial_Number    VARCHAR2(50),
    Purchase_Date    DATE,
    Condition        VARCHAR2(20),

    CONSTRAINT chk_equipment_condition
        CHECK (Condition IN ('Good', 'Fair', 'Poor'))
);