CREATE TABLE MAINTENANCE (
    Maintenance_ID   NUMBER(5) PRIMARY KEY,
    Equipment_ID     NUMBER(5),
    Technician_ID    NUMBER(5),
    Maintenance_Date DATE,
    Service_Type     VARCHAR2(50),
    Repair_Cost      NUMBER(8,2),

    CONSTRAINT fk_maintenance_equipment
        FOREIGN KEY (Equipment_ID)
        REFERENCES EQUIPMENT(Equipment_ID),

    CONSTRAINT fk_maintenance_technician
        FOREIGN KEY (Technician_ID)
        REFERENCES TECHNICIAN(Technician_ID)
);