/*
 * 會話主表 - 記錄會話基本資訊
 * 版本: 1.0.0
 */

DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM user_tables WHERE table_name = 'SESSION_MAIN';
    
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE '
CREATE TABLE session_main (
    capture_time TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    sid NUMBER NOT NULL,
    serial# NUMBER NOT NULL,
    username VARCHAR2(128),
    osuser VARCHAR2(128),
    machine VARCHAR2(64),
    program VARCHAR2(64),
    module VARCHAR2(64),
    action VARCHAR2(64),
    logon_time TIMESTAMP,
    status VARCHAR2(8),
    last_call_et NUMBER,
    blocking_session NUMBER,
    wait_class VARCHAR2(64),
    event VARCHAR2(64),
    seconds_in_wait NUMBER,
    state VARCHAR2(19),
    sql_id VARCHAR2(13),
    prev_sql_id VARCHAR2(13),
    sql_child_number NUMBER,
    sql_exec_id NUMBER,
    sql_exec_start DATE,
    plsql_entry_object_id NUMBER,
    plsql_entry_subprogram_id NUMBER,
    plsql_object_id NUMBER,
    PRIMARY KEY (capture_time, sid, serial#)
)';
        DBMS_OUTPUT.PUT_LINE('表 SESSION_MAIN 已創建');
    ELSE
        DBMS_OUTPUT.PUT_LINE('表 SESSION_MAIN 已存在，跳過創建');
    END IF;
END;
/