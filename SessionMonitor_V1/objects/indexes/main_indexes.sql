/*
 * SESSION_MAIN 表索引
 * 版本: 1.0.0
 */

DECLARE
    v_count NUMBER;
BEGIN
    -- SQL_ID 索引
    SELECT COUNT(*) INTO v_count FROM user_indexes WHERE index_name = 'IDX_MAIN_SQL_ID';
    
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE INDEX idx_main_sql_id ON session_main(sql_id)';
        DBMS_OUTPUT.PUT_LINE('索引 IDX_MAIN_SQL_ID 已創建');
    ELSE
        DBMS_OUTPUT.PUT_LINE('索引 IDX_MAIN_SQL_ID 已存在，跳過創建');
    END IF;
    
    -- PREV_SQL_ID 索引
    SELECT COUNT(*) INTO v_count FROM user_indexes WHERE index_name = 'IDX_MAIN_PREV_SQL_ID';
    
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE INDEX idx_main_prev_sql_id ON session_main(prev_sql_id)';
        DBMS_OUTPUT.PUT_LINE('索引 IDX_MAIN_PREV_SQL_ID 已創建');
    ELSE
        DBMS_OUTPUT.PUT_LINE('索引 IDX_MAIN_PREV_SQL_ID 已存在，跳過創建');
    END IF;
    
    -- CAPTURE_TIME 索引
    SELECT COUNT(*) INTO v_count FROM user_indexes WHERE index_name = 'IDX_MAIN_CAPTURE_TIME';
    
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE INDEX idx_main_capture_time ON session_main(capture_time)';
        DBMS_OUTPUT.PUT_LINE('索引 IDX_MAIN_CAPTURE_TIME 已創建');
    ELSE
        DBMS_OUTPUT.PUT_LINE('索引 IDX_MAIN_CAPTURE_TIME 已存在，跳過創建');
    END IF;
    
    -- BLOCKING_SESSION 索引
    SELECT COUNT(*) INTO v_count FROM user_indexes WHERE index_name = 'IDX_MAIN_BLOCKING';
    
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE INDEX idx_main_blocking ON session_main(blocking_session)';
        DBMS_OUTPUT.PUT_LINE('索引 IDX_MAIN_BLOCKING 已創建');
    ELSE
        DBMS_OUTPUT.PUT_LINE('索引 IDX_MAIN_BLOCKING 已存在，跳過創建');
    END IF;
END;
/