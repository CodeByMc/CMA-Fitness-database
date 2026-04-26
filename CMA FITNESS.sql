
CREATE TABLE Trainer (
    trainer_id      NUMBER(5) PRIMARY KEY,
    first_name      VARCHAR2(50) NOT NULL,
    last_name       VARCHAR2(50) NOT NULL,
    specialization  VARCHAR2(100),
    session_rate    NUMBER(8,2)
);