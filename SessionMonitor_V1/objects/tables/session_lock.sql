-- 會話鎖表
CREATE TABLE session_lock (
    capture_time TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    sid NUMBER NOT NULL,
    serial# NUMBER NOT NULL,
    lock_type VARCHAR2(8) NOT NULL,
    mode_held VARCHAR2(40),
    mode_requested VARCHAR2(40),
    lock_id1 VARCHAR2(40),
    lock_id2 VARCHAR2(40),
    blocking_others VARCHAR2(3),
    PRIMARY KEY (capture_time, sid, serial#, lock_type)
);
