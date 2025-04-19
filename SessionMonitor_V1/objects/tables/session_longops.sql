-- 長時間運行操作表
CREATE TABLE session_longops (
    capture_time TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    sid NUMBER NOT NULL,
    serial# NUMBER NOT NULL,
    opname VARCHAR2(64),
    target VARCHAR2(64),
    sofar NUMBER,
    totalwork NUMBER,
    units VARCHAR2(30),
    elapsed_seconds NUMBER,
    time_remaining NUMBER,
    sql_id VARCHAR2(13),
    sql_plan_hash_value NUMBER,
    PRIMARY KEY (capture_time, sid, serial#, nvl(sql_id, 'NONE'))
);
