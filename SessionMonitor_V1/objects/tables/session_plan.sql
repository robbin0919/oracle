/*
 * 執行計畫表 - 記錄SQL執行計畫詳情
 * 版本: 1.0.0
 */

DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM user_tables WHERE table_name = 'SESSION_PLAN';
    
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE '
        CREATE TABLE session_plan (
            capture_time TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
            sql_id VARCHAR2(13) NOT NULL,
            plan_hash_value NUMBER NOT NULL,
            id NUMBER NOT NULL,
            operation VARCHAR2(100),
            options VARCHAR2(100),
            object_name VARCHAR2(100),
            object_owner VARCHAR2(100),
            access_predicates VARCHAR2(4000),
            filter_predicates VARCHAR2(4000),
            cost NUMBER,
            cardinality NUMBER,
            bytes NUMBER,
            cpu_cost NUMBER,
            io_cost NUMBER,
            PRIMARY KEY (capture_time, sql_id, plan_hash_value, id)
        )';
        DBMS_OUTPUT.PUT_LINE('表 SESSION_PLAN 已創建');
    ELSE
        DBMS_OUTPUT.PUT_LINE('表 SESSION_PLAN 已存在，跳過創建');
    END IF;
END;
/