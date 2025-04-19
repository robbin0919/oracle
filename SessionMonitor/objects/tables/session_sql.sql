/*
 * SQL資訊表 - 記錄SQL語句及其統計資訊
 * 版本: 1.0.0
 */

DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM user_tables WHERE table_name = 'SESSION_SQL';
    
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE '
        CREATE TABLE session_sql (
            capture_time TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
            sql_id VARCHAR2(13) NOT NULL,
            sql_fulltext CLOB,
            sql_text VARCHAR2(4000),
            command_type NUMBER,
            parsing_schema_name VARCHAR2(128),
            executions NUMBER,
            elapsed_time NUMBER,
            cpu_time NUMBER,
            buffer_gets NUMBER,
            disk_reads NUMBER,
            direct_writes NUMBER,
            rows_processed NUMBER,
            fetches NUMBER,
            plan_hash_value NUMBER,
            hash_value NUMBER,
            optimizer_cost NUMBER,
            optimizer_mode VARCHAR2(10),
            last_active_time DATE,
            last_load_time DATE,
            PRIMARY KEY (capture_time, sql_id)
        )';
        DBMS_OUTPUT.PUT_LINE('表 SESSION_SQL 已創建');
    ELSE
        DBMS_OUTPUT.PUT_LINE('表 SESSION_SQL 已存在，跳過創建');
    END IF;
END;
/