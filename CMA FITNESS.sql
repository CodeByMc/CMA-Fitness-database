CREATE TABLE BOOKING(
    Booking_ID   NUMBER PRIMARY KEY,
    Member_ID    NUMBER,
    Session_ID   NUMBER,
    Booking_Date DATE,
    Status       VARCHAR2(20)
);