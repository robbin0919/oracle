-- ASH抽樣表(活動會話歷史)
CREATE TABLE session_ash (
    capture_time TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    ash_time DATE NOT NULL,
    session_id NUMBER NOT NULL,
    session_serial# NUMBER,
    sql_id VARCHAR2(13),
    sql_child_number NUMBER,
    event VARCHAR2(64),
    event_id NUMBER,
    wait_class VARCHAR2(64),
    time_waited NUMBER,
    blocking_session NUMBER,
    blocking_session_serial# NUMBER,
    user_id NUMBER,
    module VARCHAR2(64),
    PRIMARY KEY (capture_time, ash_time, session_id)
);